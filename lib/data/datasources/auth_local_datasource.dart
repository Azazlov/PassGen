import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';

/// Источник данных для аутентификации
class AuthLocalDataSource {
  static const String _pinHashKey = 'auth_pin_hash';
  static const String _pinSaltKey = 'auth_pin_salt';
  static const String _failedAttemptsKey = 'auth_failed_attempts';
  static const String _lockoutTimestampKey = 'auth_lockout_timestamp';

  static const int maxFailedAttempts = 5;
  static const int lockoutDurationSeconds = 30;
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int pbkdf2Iterations = 10000;

  /// Проверяет валидность PIN (4-8 цифр)
  bool isValidPinFormat(String pin) {
    if (pin.length < minPinLength || pin.length > maxPinLength) {
      return false;
    }
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  /// Проверяет, установлен ли PIN
  Future<bool> isPinSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_pinHashKey);
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка проверки установки PIN');
    }
  }

  /// Хэширует PIN с солью используя PBKDF2
  Future<Map<String, String>> _hashPin(String pin) async {
    // Генерируем случайную соль
    final saltBytes = _generateSecureRandomBytes(32);
    final salt = base64Encode(saltBytes);

    // Создаём хэш
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: pbkdf2Iterations,
      bits: 256,
    );

    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: Uint8List.fromList(saltBytes),
    );

    final hash = base64Encode(await secretKey.extractBytes());

    return {'hash': hash, 'salt': salt};
  }

  /// Проверяет PIN против сохранённого хэша
  Future<bool> _verifyPinHash(
    String pin,
    String storedHash,
    String storedSalt,
  ) async {
    try {
      final saltBytes = base64Decode(storedSalt);

      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: pbkdf2Iterations,
        bits: 256,
      );

      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: pin,
        nonce: Uint8List.fromList(saltBytes),
      );

      final computedHash = base64Encode(await secretKey.extractBytes());

      return computedHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Устанавливает новый PIN
  Future<bool> setupPin(String pin) async {
    try {
      if (!isValidPinFormat(pin)) {
        throw const ValidationFailure(message: 'PIN должен содержать 4-8 цифр');
      }

      final hashed = await _hashPin(pin);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_pinHashKey, hashed['hash']!);
      await prefs.setString(_pinSaltKey, hashed['salt']!);
      await prefs.setInt(_failedAttemptsKey, 0);
      await prefs.remove(_lockoutTimestampKey);

      return true;
    } catch (e) {
      if (e is ValidationFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка установки PIN');
    }
  }

  /// Проверяет PIN
  Future<Map<String, dynamic>> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Проверяем, установлен ли PIN
      final storedHash = prefs.getString(_pinHashKey);
      final storedSalt = prefs.getString(_pinSaltKey);

      if (storedHash == null || storedSalt == null) {
        return {'result': 'notSetup', 'isLocked': false};
      }

      // Проверяем блокировку
      final isLocked = await _isLocked();
      if (isLocked) {
        return {'result': 'locked', 'isLocked': true};
      }

      // Проверяем PIN
      final isValid = await _verifyPinHash(pin, storedHash, storedSalt);

      if (isValid) {
        // Сбрасываем счётчик неудачных попыток
        await prefs.setInt(_failedAttemptsKey, 0);
        return {'result': 'success', 'isLocked': false};
      } else {
        // Увеличиваем счётчик неудачных попыток
        final failedAttempts = await _incrementFailedAttempts();
        final isNowLocked = failedAttempts >= maxFailedAttempts;

        if (isNowLocked) {
          await _setLockout();
        }

        return {
          'result': 'wrongPin',
          'isLocked': isNowLocked,
          'remainingAttempts': maxFailedAttempts - failedAttempts,
        };
      }
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка проверки PIN');
    }
  }

  /// Меняет PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      if (!isValidPinFormat(newPin)) {
        throw const ValidationFailure(message: 'PIN должен содержать 4-8 цифр');
      }

      // Проверяем старый PIN
      final verifyResult = await verifyPin(oldPin);
      if (verifyResult['result'] != 'success') {
        throw const AuthFailure(
          message: 'Неверный старый PIN',
          type: AuthFailureType.wrongPin,
        );
      }

      // Устанавливаем новый PIN
      return await setupPin(newPin);
    } catch (e) {
      if (e is ValidationFailure || e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка смены PIN');
    }
  }

  /// Удаляет PIN
  Future<bool> removePin(String pin) async {
    try {
      // Проверяем PIN
      final verifyResult = await verifyPin(pin);
      if (verifyResult['result'] != 'success') {
        throw const AuthFailure(
          message: 'Неверный PIN',
          type: AuthFailureType.wrongPin,
        );
      }

      // Удаляем данные
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinHashKey);
      await prefs.remove(_pinSaltKey);
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_lockoutTimestampKey);

      return true;
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка удаления PIN');
    }
  }

  /// Проверяет, заблокирован ли пользователь
  Future<bool> _isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTimestamp = prefs.getInt(_lockoutTimestampKey);

    if (lockoutTimestamp == null) {
      return false;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    final now = DateTime.now();

    if (now.isBefore(lockoutTime)) {
      return true;
    }

    // Блокировка истекла, сбрасываем
    await prefs.remove(_lockoutTimestampKey);
    await prefs.setInt(_failedAttemptsKey, 0);

    return false;
  }

  /// Увеличивает счётчик неудачных попыток
  Future<int> _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_failedAttemptsKey) ?? 0;
    final newValue = current + 1;
    await prefs.setInt(_failedAttemptsKey, newValue);
    return newValue;
  }

  /// Устанавливает блокировку
  Future<void> _setLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = DateTime.now().add(
      const Duration(seconds: lockoutDurationSeconds),
    );
    await prefs.setInt(
      _lockoutTimestampKey,
      lockoutTime.millisecondsSinceEpoch,
    );
  }

  /// Получает количество неудачных попыток
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  /// Получает время разблокировки
  Future<DateTime?> getLockoutUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lockoutTimestampKey);
    if (timestamp == null) return null;

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().isBefore(lockoutTime)) {
      return lockoutTime;
    }

    return null;
  }

  /// Проверяет, истёк ли срок блокировки
  Future<bool> checkLockoutExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTimestamp = prefs.getInt(_lockoutTimestampKey);

    if (lockoutTimestamp == null) {
      return true;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    if (DateTime.now().isAfter(lockoutTime)) {
      // Блокировка истекла, сбрасываем
      await prefs.remove(_lockoutTimestampKey);
      await prefs.setInt(_failedAttemptsKey, 0);
      return true;
    }

    return false;
  }

  /// Получает состояние аутентификации
  Future<Map<String, dynamic>> getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isPinSetup = prefs.containsKey(_pinHashKey);
    final isLocked = await _isLocked();
    final failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final lockoutUntil = await getLockoutUntil();

    return {
      'isPinSetup': isPinSetup,
      'isLocked': isLocked,
      'failedAttempts': failedAttempts,
      'remainingAttempts': maxFailedAttempts - failedAttempts,
      'lockoutUntil': lockoutUntil,
    };
  }

  /// Сбрасывает состояние (для выхода из приложения)
  Future<void> resetAuthState() async {
    // Не сбрасываем PIN, только счётчик попыток если блокировка истекла
    await checkLockoutExpired();
  }

  /// Генерирует криптографически стойкие случайные байты
  List<int> _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }
}
