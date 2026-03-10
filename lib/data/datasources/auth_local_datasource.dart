import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/crypto_utils.dart';
import 'encryptor_local_datasource.dart';

/// Источник данных для аутентификации
/// 
/// Поддерживает два режима хранения:
/// - SharedPreferences (legacy, для обратной совместимости)
/// - SQLite (новый, более безопасный)
class AuthLocalDataSource {
  // Ключи для SharedPreferences (legacy)
  static const String _pinHashKey = 'auth_pin_hash';
  static const String _pinSaltKey = 'auth_pin_salt';
  static const String _failedAttemptsKey = 'auth_failed_attempts';
  static const String _lockoutTimestampKey = 'auth_lockout_timestamp';

  // Ключи для SQLite
  static const String _sqlitePinHashKey = 'pin_hash';
  static const String _sqlitePinSaltKey = 'pin_salt';
  static const String _sqliteFailedAttemptsKey = 'failed_attempts';
  static const String _sqliteLockoutTimestampKey = 'lockout_timestamp';

  static const int maxFailedAttempts = 5;
  static const int lockoutDurationSeconds = 30;
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int pbkdf2Iterations = 10000;

  final Database? _database;

  AuthLocalDataSource({Database? database}) : _database = database;

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
      // Пробуем SQLite (новый способ)
      if (_database != null) {
        final result = await _database!.query(
          'auth_data',
          where: 'key = ?',
          whereArgs: [_sqlitePinHashKey],
        );
        if (result.isNotEmpty) {
          return true;
        }
      }

      // Fallback на SharedPreferences (legacy)
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_pinHashKey);
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка проверки установки PIN');
    }
  }

  /// Сохраняет данные аутентификации в SQLite
  Future<void> _saveToSqlite(String key, String value) async {
    if (_database == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await _database!.insert(
      'auth_data',
      {
        'key': key,
        'value': value,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Читает данные аутентификации из SQLite
  Future<String?> _readFromSqlite(String key) async {
    if (_database == null) return null;

    final result = await _database!.query(
      'auth_data',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  /// Удаляет данные аутентификации из SQLite
  Future<void> _deleteFromSqlite(String key) async {
    if (_database == null) return;

    await _database!.delete(
      'auth_data',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Сохраняет целочисленное значение в SQLite
  Future<void> _saveIntToSqlite(String key, int value) async {
    if (_database == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await _database!.insert(
      'auth_data',
      {
        'key': key,
        'value': value.toString(),
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Читает целочисленное значение из SQLite
  Future<int?> _readIntFromSqlite(String key) async {
    if (_database == null) return null;

    final result = await _database!.query(
      'auth_data',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    final value = result.first['value'] as String?;
    return value != null ? int.tryParse(value) : null;
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

      final computedHashBytes = await secretKey.extractBytes();
      final computedHash = base64Encode(computedHashBytes);

      // Constant-time сравнение хэшей (защита от timing attacks)
      final isValid = CryptoUtils.constantTimeEqualsBase64(computedHash, storedHash);

      // Затирание ключа из памяти
      CryptoUtils.secureWipeKey(computedHashBytes);

      return isValid;
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
      
      // Сохраняем в SQLite (новый способ)
      if (_database != null) {
        await _saveToSqlite(_sqlitePinHashKey, hashed['hash']!);
        await _saveToSqlite(_sqlitePinSaltKey, hashed['salt']!);
        await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
        await _deleteFromSqlite(_sqliteLockoutTimestampKey);
      }

      // Сохраняем в SharedPreferences (legacy, для обратной совместимости)
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
      String? storedHash;
      String? storedSalt;

      // Читаем из SQLite (новый способ)
      if (_database != null) {
        storedHash = await _readFromSqlite(_sqlitePinHashKey);
        storedSalt = await _readFromSqlite(_sqlitePinSaltKey);
      }

      // Fallback на SharedPreferences (legacy)
      if (storedHash == null || storedSalt == null) {
        final prefs = await SharedPreferences.getInstance();
        storedHash ??= prefs.getString(_pinHashKey);
        storedSalt ??= prefs.getString(_pinSaltKey);
      }

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
        if (_database != null) {
          await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
        }
        final prefs = await SharedPreferences.getInstance();
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

  /// Меняет PIN с ротацией ключей шифрования
  ///
  /// Процесс ротации:
  /// 1. Проверка старого PIN
  /// 2. Derive старого ключа
  /// 3. Расшифровка всех паролей старым ключом
  /// 4. Derive нового ключа
  /// 5. Зашифровка всех паролей новым ключом
  /// 6. Сохранение нового PIN
  /// 7. Затирание старых ключей
  Future<bool> changePin(String oldPin, String newPin, {Database? database}) async {
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

      // Получаем базу данных для работы с паролями
      final db = database ?? _database;

      if (db != null) {
        // Выполняем ротацию ключей
        await _rotateEncryptionKeys(oldPin, newPin, db);
      }

      // Устанавливаем новый PIN
      return await setupPin(newPin);
    } catch (e) {
      if (e is ValidationFailure || e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка смены PIN');
    }
  }

  /// Выполняет ротацию ключей шифрования при смене PIN
  ///
  /// [oldPin] - старый PIN-код
  /// [newPin] - новый PIN-код
  /// [db] - база данных с паролями
  Future<void> _rotateEncryptionKeys(
    String oldPin,
    String newPin,
    Database db,
  ) async {
    // 1. Получаем соль старого PIN
    final oldSaltBase64 = await _readFromSqlite(_sqlitePinSaltKey);
    if (oldSaltBase64 == null) {
      throw const StorageFailure(message: 'Соль старого PIN не найдена');
    }
    final oldSaltBytes = base64Decode(oldSaltBase64);

    // 2. Derive старого ключа
    final oldPbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: pbkdf2Iterations,
      bits: 256,
    );

    final oldSecretKey = await oldPbkdf2.deriveKeyFromPassword(
      password: oldPin,
      nonce: Uint8List.fromList(oldSaltBytes),
    );

    final oldKeyBytes = await oldSecretKey.extractBytes();

    // 3. Получаем все пароли из БД
    final passwordEntries = await db.query('password_entries');

    for (final entry in passwordEntries) {
      final encryptedPassword = entry['encrypted_password'] as List<int>;
      final nonceBytes = entry['nonce'] as List<int>;

      // 4. Расшифровываем пароль старым ключом
      List<int>? decryptedPassword;
      try {
        decryptedPassword = await _decryptPassword(
          encryptedPassword,
          nonceBytes,
          oldKeyBytes,
        );
      } catch (e) {
        // Если не удалось расшифровать, пропускаем
        continue;
      }

      // 5. Получаем новый ключ
      final newSaltBase64 = await _readFromSqlite(_sqlitePinSaltKey);
      if (newSaltBase64 == null) {
        throw const StorageFailure(message: 'Соль нового PIN не найдена');
      }
      final newSaltBytes = base64Decode(newSaltBase64);

      final newPbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: pbkdf2Iterations,
        bits: 256,
      );

      final newSecretKey = await newPbkdf2.deriveKeyFromPassword(
        password: newPin,
        nonce: Uint8List.fromList(newSaltBytes),
      );

      final newKeyBytes = await newSecretKey.extractBytes();

      // 6. Зашифровываем пароль новым ключом
      final encryptedData = await _encryptPassword(
        decryptedPassword,
        newKeyBytes,
      );

      // 7. Обновляем запись в БД
      await db.update(
        'password_entries',
        {
          'encrypted_password': encryptedData['cipherText'],
          'nonce': encryptedData['nonce'],
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [entry['id']],
      );

      // 8. Затираем decrypted пароль
      CryptoUtils.secureWipeData(decryptedPassword);
    }

    // 9. Затираем старые ключи
    CryptoUtils.secureWipeKey(oldKeyBytes);
  }

  /// Расшифровывает пароль
  Future<List<int>> _decryptPassword(
    List<int> encryptedData,
    List<int> nonce,
    List<int> key,
  ) async {
    final algorithm = Chacha20.poly1305Aead();

    // Создаём ключ из байт
    final secretKey = SecretKey(key);

    // Создаём nonce box
    final nonceBox = Uint8List.fromList(nonce);

    // Для расшифровки нужен SecretBox с ciphertext и mac
    // Упрощённая версия - в реальной реализации нужно хранить MAC отдельно
    // Здесь предполагаем, что encryptedData содержит ciphertext||mac

    // Временное решение: используем EncryptorLocalDataSource
    final encryptor = EncryptorLocalDataSource();

    // Декодируем из нашего формата
    final decrypted = await encryptor.decryptFromMini(
      miniEncrypted: base64Encode(encryptedData),
      password: key,
    );

    return decrypted;
  }

  /// Шифрует пароль
  Future<Map<String, dynamic>> _encryptPassword(
    List<int> password,
    List<int> key,
  ) async {
    final encryptor = EncryptorLocalDataSource();

    final encrypted = await encryptor.encrypt(
      message: password,
      password: key,
    );

    return {
      'cipherText': base64Decode(encrypted['cipherText'] as String),
      'nonce': base64Decode(encrypted['nonce'] as String),
    };
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

      // Удаляем данные из SQLite
      if (_database != null) {
        await _deleteFromSqlite(_sqlitePinHashKey);
        await _deleteFromSqlite(_sqlitePinSaltKey);
        await _deleteFromSqlite(_sqliteFailedAttemptsKey);
        await _deleteFromSqlite(_sqliteLockoutTimestampKey);
      }

      // Удаляем данные из SharedPreferences (legacy)
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
    int? lockoutTimestamp;

    // Читаем из SQLite
    if (_database != null) {
      lockoutTimestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);
    }

    // Fallback на SharedPreferences
    if (lockoutTimestamp == null) {
      final prefs = await SharedPreferences.getInstance();
      lockoutTimestamp = prefs.getInt(_lockoutTimestampKey);
    }

    if (lockoutTimestamp == null) {
      return false;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    final now = DateTime.now();

    if (now.isBefore(lockoutTime)) {
      return true;
    }

    // Блокировка истекла, сбрасываем
    if (_database != null) {
      await _deleteFromSqlite(_sqliteLockoutTimestampKey);
      await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockoutTimestampKey);
    await prefs.setInt(_failedAttemptsKey, 0);

    return false;
  }

  /// Увеличивает счётчик неудачных попыток
  Future<int> _incrementFailedAttempts() async {
    int? current;

    // Читаем из SQLite
    if (_database != null) {
      current = await _readIntFromSqlite(_sqliteFailedAttemptsKey);
    }

    // Fallback на SharedPreferences
    if (current == null) {
      final prefs = await SharedPreferences.getInstance();
      current = prefs.getInt(_failedAttemptsKey) ?? 0;
    }

    final newValue = current + 1;

    // Сохраняем в оба хранилища
    if (_database != null) {
      await _saveIntToSqlite(_sqliteFailedAttemptsKey, newValue);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_failedAttemptsKey, newValue);

    return newValue;
  }

  /// Устанавливает блокировку
  Future<void> _setLockout() async {
    final lockoutTime = DateTime.now().add(
      const Duration(seconds: lockoutDurationSeconds),
    );
    final timestamp = lockoutTime.millisecondsSinceEpoch;

    // Сохраняем в SQLite
    if (_database != null) {
      await _saveIntToSqlite(_sqliteLockoutTimestampKey, timestamp);
    }

    // Сохраняем в SharedPreferences (legacy)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockoutTimestampKey, timestamp);
  }

  /// Получает количество неудачных попыток
  Future<int> getFailedAttempts() async {
    int? attempts;

    // Читаем из SQLite
    if (_database != null) {
      attempts = await _readIntFromSqlite(_sqliteFailedAttemptsKey);
    }

    // Fallback на SharedPreferences
    if (attempts == null) {
      final prefs = await SharedPreferences.getInstance();
      attempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    }

    return attempts;
  }

  /// Получает время разблокировки
  Future<DateTime?> getLockoutUntil() async {
    int? timestamp;

    // Читаем из SQLite
    if (_database != null) {
      timestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);
    }

    // Fallback на SharedPreferences
    if (timestamp == null) {
      final prefs = await SharedPreferences.getInstance();
      timestamp = prefs.getInt(_lockoutTimestampKey);
    }

    if (timestamp == null) return null;

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().isBefore(lockoutTime)) {
      return lockoutTime;
    }

    return null;
  }

  /// Проверяет, истёк ли срок блокировки
  Future<bool> checkLockoutExpired() async {
    int? lockoutTimestamp;

    // Читаем из SQLite
    if (_database != null) {
      lockoutTimestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);
    }

    // Fallback на SharedPreferences
    if (lockoutTimestamp == null) {
      final prefs = await SharedPreferences.getInstance();
      lockoutTimestamp = prefs.getInt(_lockoutTimestampKey);
    }

    if (lockoutTimestamp == null) {
      return true;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    if (DateTime.now().isAfter(lockoutTime)) {
      // Блокировка истекла, сбрасываем
      if (_database != null) {
        await _deleteFromSqlite(_sqliteLockoutTimestampKey);
        await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lockoutTimestampKey);
      await prefs.setInt(_failedAttemptsKey, 0);
      return true;
    }

    return false;
  }

  /// Получает состояние аутентификации
  Future<Map<String, dynamic>> getAuthState() async {
    bool isPinSetupResult = false;

    // Проверяем SQLite
    if (_database != null) {
      final hash = await _readFromSqlite(_sqlitePinHashKey);
      isPinSetupResult = hash != null;
    }

    // Fallback на SharedPreferences
    if (!isPinSetupResult) {
      final prefs = await SharedPreferences.getInstance();
      isPinSetupResult = prefs.containsKey(_pinHashKey);
    }

    final isLocked = await _isLocked();
    final failedAttempts = await getFailedAttempts();
    final lockoutUntil = await getLockoutUntil();

    return {
      'isPinSetup': isPinSetupResult,
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
