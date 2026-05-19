import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../core/utils/encryption_versioning.dart';
import '../../../core/utils/lockout_calculator.dart';
import 'encryptor_local_datasource.dart';

/// Источник данных для аутентификации (v0.6 — per-profile)
///
/// Каждый профиль имеет независимую строку в auth_data:
/// (profile_id, pin_hash, pin_salt, failed_attempts, series_index, lockout_until, biometric_enabled, created_at)
class AuthLocalDataSource {
  const AuthLocalDataSource({Database? database}) : _database = database;

  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static int get pbkdf2Iterations => EncryptionParams.v2().iterations;

  final Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database;
    throw const StorageFailure(message: 'База данных не инициализирована');
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ ====================

  bool isValidPinFormat(String pin) {
    if (pin.length < minPinLength || pin.length > maxPinLength) return false;
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  List<int> _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }

  /// Читает максимум попыток PIN из app_settings (3–10).
  ///
  /// Возвращает [LockoutCalculator.defaultAttemptsPerSeries] (5) если значение
  /// не задано или таблица недоступна. Значение нормализуется к допустимому
  /// диапазону через [LockoutCalculator.clampAttempts].
  Future<int> _readMaxAttempts() async {
    try {
      final db = await _db;
      final rows = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['security.max_pin_attempts'],
        limit: 1,
      );
      if (rows.isEmpty) return LockoutCalculator.defaultAttemptsPerSeries;
      final raw = rows.first['value'] as String?;
      if (raw == null) return LockoutCalculator.defaultAttemptsPerSeries;
      final parsed = int.tryParse(raw.trim());
      if (parsed == null) return LockoutCalculator.defaultAttemptsPerSeries;
      return LockoutCalculator.clampAttempts(parsed);
    } catch (_) {
      return LockoutCalculator.defaultAttemptsPerSeries;
    }
  }

  // ==================== PER-PROFILE CRUD ====================

  Future<Map<String, dynamic>?> _getProfileAuthData(int profileId) async {
    try {
      final db = await _db;
      final result = await db.query(
        'auth_data',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateProfileAuthData(
    int profileId, {
    String? pinHash,
    String? pinSalt,
    int? failedAttempts,
    int? seriesIndex,
    int? lockoutUntil,
    int? biometricEnabled,
  }) async {
    try {
      final db = await _db;
      final existing = await _getProfileAuthData(profileId);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (existing == null) {
        await db.insert('auth_data', {
          'profile_id': profileId,
          'pin_hash': pinHash ?? '',
          'pin_salt': pinSalt ?? '',
          'failed_attempts': failedAttempts ?? 0,
          'series_index': seriesIndex ?? 0,
          'lockout_until': lockoutUntil,
          'biometric_enabled': biometricEnabled ?? 0,
          'created_at': now,
        });
      } else {
        await db.update(
          'auth_data',
          {
            if (pinHash != null) 'pin_hash': pinHash,
            if (pinSalt != null) 'pin_salt': pinSalt,
            if (failedAttempts != null) 'failed_attempts': failedAttempts,
            if (seriesIndex != null) 'series_index': seriesIndex,
            if (lockoutUntil != null) 'lockout_until': lockoutUntil,
            if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
          },
          where: 'profile_id = ?',
          whereArgs: [profileId],
        );
      }
    } catch (_) {
      // Игнорируем ошибки
    }
  }

  Future<void> _deleteProfileAuthData(int profileId) async {
    try {
      final db = await _db;
      await db.delete('auth_data', where: 'profile_id = ?', whereArgs: [profileId]);
    } catch (_) {}
  }

  /// Возвращает байты `pin_salt` для указанного профиля или `null`,
  /// если строки нет / соль пустая.
  ///
  /// Используется `VaultUnlockService` для вывода vault-ключа на тех же
  /// `(PIN, salt)`, что и хеш PIN'а, без дублирования логики PBKDF2.
  Future<List<int>?> getProfileSalt(int profileId) async {
    final row = await _getProfileAuthData(profileId);
    if (row == null) return null;
    final saltBase64 = row['pin_salt'] as String?;
    if (saltBase64 == null || saltBase64.isEmpty) return null;
    try {
      return base64Decode(saltBase64);
    } catch (_) {
      return null;
    }
  }

  // ==================== ХЭШИРОВАНИЕ ====================

  Future<Map<String, String>> _hashPin(String pin) async {
    final saltBytes = _generateSecureRandomBytes(32);
    final salt = base64Encode(saltBytes);

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

  Future<bool> _verifyPinHash(String pin, String storedHash, String storedSalt) async {
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
      final isValid = CryptoUtils.constantTimeEqualsBase64(computedHash, storedHash);
      try {
        final modifiable = Uint8List.fromList(computedHashBytes);
        CryptoUtils.secureWipeKey(modifiable);
      } catch (_) {}
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // ==================== ПУБЛИЧНЫЕ МЕТОДЫ ====================

  /// Проверяет, установлен ли PIN для профиля
  Future<bool> isPinSetup({int? profileId}) async {
    try {
      final db = await _db;
      final result = await db.query('auth_data', limit: 1);
      if (profileId != null) {
        final row = await _getProfileAuthData(profileId);
        return row != null && (row['pin_hash'] as String?)?.isNotEmpty == true;
      }
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Устанавливает PIN для профиля
  Future<bool> setupPin(String pin, {required int profileId}) async {
    try {
      if (!isValidPinFormat(pin)) {
        throw const ValidationFailure(message: 'PIN должен содержать 4-8 цифр');
      }
      final hashed = await _hashPin(pin);
      await _updateProfileAuthData(
        profileId,
        pinHash: hashed['hash']!,
        pinSalt: hashed['salt']!,
        failedAttempts: 0,
        seriesIndex: 0,
        lockoutUntil: null,
        biometricEnabled: 0,
      );
      return true;
    } catch (e) {
      if (e is ValidationFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка установки PIN');
    }
  }

  /// Проверяет PIN для профиля с прогрессивной блокировкой
  Future<Map<String, dynamic>> verifyPin(
    String pin, {
    required int profileId,
  }) async {
    try {
      final row = await _getProfileAuthData(profileId);
      if (row == null) {
        return {'result': 'notSetup', 'isLocked': false};
      }

      final storedHash = row['pin_hash'] as String?;
      final storedSalt = row['pin_salt'] as String?;
      if (storedHash == null || storedSalt == null || storedHash.isEmpty) {
        return {'result': 'notSetup', 'isLocked': false};
      }

      // Проверка блокировки
      final lockoutUntilRaw = row['lockout_until'] as int?;
      if (lockoutUntilRaw != null) {
        final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutUntilRaw);
        if (DateTime.now().isBefore(lockoutUntil)) {
          return {
            'result': 'locked',
            'isLocked': true,
            'lockoutUntil': lockoutUntil,
          };
        }
        // Блокировка истекла — сброс
        await _updateProfileAuthData(
          profileId,
          failedAttempts: 0,
          lockoutUntil: null,
        );
      }

      // Проверка PIN
      final isValid = await _verifyPinHash(pin, storedHash, storedSalt);

      if (isValid) {
        // Успех: сброс всего
        await _updateProfileAuthData(
          profileId,
          failedAttempts: 0,
          seriesIndex: 0,
          lockoutUntil: null,
        );
        return {'result': 'success', 'isLocked': false};
      } else {
        // Неудача: инкремент попыток
        final currentFailed = (row['failed_attempts'] as int?) ?? 0;
        final currentSeries = (row['series_index'] as int?) ?? 0;
        final newFailed = currentFailed + 1;

        final maxAttempts = await _readMaxAttempts();
        if (newFailed >= maxAttempts) {
          // Новая серия блокировки
          final newSeries = currentSeries + 1;
          final delay = LockoutCalculator.calculateDelay(newSeries);
          final lockoutTime = DateTime.now().add(delay);
          await _updateProfileAuthData(
            profileId,
            failedAttempts: 0,
            seriesIndex: newSeries,
            lockoutUntil: lockoutTime.millisecondsSinceEpoch,
          );
          return {
            'result': 'wrongPin',
            'isLocked': true,
            'remainingAttempts': 0,
            'lockoutUntil': lockoutTime,
            'seriesIndex': newSeries,
          };
        } else {
          await _updateProfileAuthData(
            profileId,
            failedAttempts: newFailed,
          );
          return {
            'result': 'wrongPin',
            'isLocked': false,
            'remainingAttempts': maxAttempts - newFailed,
            'seriesIndex': currentSeries,
          };
        }
      }
    } catch (e) {
      if (e is ValidationFailure || e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка проверки PIN');
    }
  }

  /// Смена PIN с ротацией ключей шифрования
  Future<bool> changePin(
    String oldPin,
    String newPin, {
    required int profileId,
  }) async {
    try {
      if (!isValidPinFormat(newPin)) {
        throw const ValidationFailure(message: 'PIN должен содержать 4-8 цифр');
      }
      final verifyResult = await verifyPin(oldPin, profileId: profileId);
      if (verifyResult['result'] != 'success') {
        throw const AuthFailure(
          message: 'Неверный старый PIN',
          type: AuthFailureType.wrongPin,
        );
      }

      final db = await _db;
      final newHashData = await _hashPin(newPin);
      final newSalt = newHashData['salt']!;
      final newHash = newHashData['hash']!;

      await _rotateEncryptionKeys(oldPin, newPin, newSalt, db, profileId);

      await _updateProfileAuthData(
        profileId,
        pinHash: newHash,
        pinSalt: newSalt,
        failedAttempts: 0,
        seriesIndex: 0,
        lockoutUntil: null,
      );
      return true;
    } catch (e) {
      if (e is ValidationFailure || e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка смены PIN');
    }
  }

  /// Удаляет PIN профиля
  Future<bool> removePin(String pin, {required int profileId}) async {
    try {
      final verifyResult = await verifyPin(pin, profileId: profileId);
      if (verifyResult['result'] != 'success') {
        throw const AuthFailure(
          message: 'Неверный PIN',
          type: AuthFailureType.wrongPin,
        );
      }
      await _deleteProfileAuthData(profileId);
      return true;
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка удаления PIN');
    }
  }

  /// Возвращает состояние аутентификации профиля
  Future<Map<String, dynamic>> getAuthState({int? profileId}) async {
    try {
      final db = await _db;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='auth_data'",
      );
      if (tables.isEmpty) {
        return {'isPinSetup': false, 'isLocked': false};
      }

      if (profileId != null) {
        final row = await _getProfileAuthData(profileId);
        if (row == null) {
          return {'isPinSetup': false, 'isLocked': false};
        }
        final lockoutRaw = row['lockout_until'] as int?;
        final isLocked = lockoutRaw != null &&
            DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(lockoutRaw));
        final failed = (row['failed_attempts'] as int?) ?? 0;
        final series = (row['series_index'] as int?) ?? 0;
        final maxAttempts = await _readMaxAttempts();
        return {
          'isPinSetup': (row['pin_hash'] as String?)?.isNotEmpty == true,
          'isLocked': isLocked,
          'failedAttempts': failed,
          'remainingAttempts': maxAttempts - failed,
          'lockoutUntil': isLocked ? DateTime.fromMillisecondsSinceEpoch(lockoutRaw) : null,
          'seriesIndex': series,
        };
      }

      // Если profileId не указан — проверяем, есть ли вообще auth_data
      final any = await db.query('auth_data', limit: 1);
      return {'isPinSetup': any.isNotEmpty, 'isLocked': false};
    } catch (_) {
      return {'isPinSetup': false, 'isLocked': false};
    }
  }

  /// Сбрасывает состояние блокировки (если истекла)
  Future<void> resetAuthState({int? profileId}) async {
    if (profileId != null) {
      final row = await _getProfileAuthData(profileId);
      if (row != null) {
        final lockoutRaw = row['lockout_until'] as int?;
        if (lockoutRaw != null &&
            DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(lockoutRaw))) {
          await _updateProfileAuthData(
            profileId,
            failedAttempts: 0,
            lockoutUntil: null,
          );
        }
      }
    }
  }

  // ==================== РОТАЦИЯ КЛЮЧЕЙ ====================

  Future<void> _rotateEncryptionKeys(
    String oldPin,
    String newPin,
    String newSalt,
    Database db,
    int profileId,
  ) async {
    final oldRow = await _getProfileAuthData(profileId);
    if (oldRow == null) throw const StorageFailure(message: 'Данные профиля не найдены');

    final oldSaltBase64 = oldRow['pin_salt'] as String?;
    if (oldSaltBase64 == null) throw const StorageFailure(message: 'Соль старого PIN не найдена');

    final oldSaltBytes = base64Decode(oldSaltBase64);
    final oldPbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: pbkdf2Iterations, bits: 256);
    final oldSecretKey = await oldPbkdf2.deriveKeyFromPassword(
      password: oldPin,
      nonce: Uint8List.fromList(oldSaltBytes),
    );
    final oldKeyBytes = await oldSecretKey.extractBytes();

    final newSaltBytes = base64Decode(newSalt);
    final newPbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: pbkdf2Iterations, bits: 256);
    final newSecretKey = await newPbkdf2.deriveKeyFromPassword(
      password: newPin,
      nonce: Uint8List.fromList(newSaltBytes),
    );
    final newKeyBytes = await newSecretKey.extractBytes();

    final entries = await db.query(
      'password_entries',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );

    for (final entry in entries) {
      final encryptedPassword = entry['encrypted_password'] as List<int>;
      final nonceBytes = entry['nonce'] as List<int>;
      List<int>? decryptedPassword;
      try {
        decryptedPassword = await _decryptPassword(encryptedPassword, nonceBytes, oldKeyBytes);
      } catch (_) {
        continue;
      }
      final encryptedData = await _encryptPassword(decryptedPassword, newKeyBytes);
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
      try {
        final modifiable = Uint8List.fromList(decryptedPassword);
        CryptoUtils.secureWipeData(modifiable);
      } catch (_) {}
    }

    try {
      CryptoUtils.secureWipeKey(Uint8List.fromList(oldKeyBytes));
    } catch (_) {}
    try {
      CryptoUtils.secureWipeKey(Uint8List.fromList(newKeyBytes));
    } catch (_) {}
  }

  Future<List<int>> _decryptPassword(
    List<int> encryptedData,
    List<int> nonce,
    List<int> key,
  ) async {
    final encryptor = EncryptorLocalDataSource();
    return encryptor.decryptFromMini(
      miniEncrypted: base64Encode(encryptedData),
      password: key,
    );
  }

  Future<Map<String, dynamic>> _encryptPassword(
    List<int> password,
    List<int> key,
  ) async {
    final encryptor = EncryptorLocalDataSource();
    final encrypted = await encryptor.encrypt(message: password, password: key);
    return {
      'cipherText': base64Decode(encrypted['cipherText'] as String),
      'nonce': base64Decode(encrypted['nonce'] as String),
    };
  }
}
