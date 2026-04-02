import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../database/database_helper.dart';
import 'encryptor_local_datasource.dart';

/// Источник данных для аутентификации
///
/// Хранение данных выполняется ТОЛЬКО в SQLite для безопасности.
/// SharedPreferences НЕ используется для хранения чувствительных данных.
class AuthLocalDataSource {
  // Ключи для SQLite
  static const String _sqlitePinHashKey = 'pin_hash';
  static const String _sqlitePinSaltKey = 'pin_salt';
  static const String _sqliteFailedAttemptsKey = 'failed_attempts';
  static const String _sqliteLockoutTimestampKey = 'lockout_timestamp';

  static const int maxFailedAttempts = 5;
  static const int lockoutDurationSeconds = 30;
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int pbkdf2Iterations = 10000; // Текущая версия итераций
  static const int legacyPbkdf2Iterations = 10000; // Старая версия для миграции (v0.5.1)
  
  // Ключ для отслеживания версии итераций
  static const String _sqlitePbkdf2IterationsKey = 'pbkdf2_iterations';

  Database? _database;

  /// Конструктор с готовой базой данных
  AuthLocalDataSource({Database? database}) : _database = database;

  /// Получает базу данных
  Future<Database> get _db async {
  debugPrint('[AuthLocalDataSource] _db вызван, _database = ${_database != null ? "инициализирована" : "NULL"}');
    if (_database != null) {
  debugPrint('[AuthLocalDataSource] _db возвращает существующую базу');
      return _database!;
    }
  debugPrint('[AuthLocalDataSource] _db выбрасывает ошибку - база не инициализирована');
    throw const StorageFailure(message: 'База данных не инициализирована');
  }

  /// Проверяет валидность PIN (4-8 цифр)
  bool isValidPinFormat(String pin) {
    if (pin.length < minPinLength || pin.length > maxPinLength) {
      return false;
    }
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  /// Проверяет, установлен ли PIN
  ///
  /// Проверка выполняется ТОЛЬКО в SQLite.
  Future<bool> isPinSetup() async {
  debugPrint('[AuthLocalDataSource] isPinSetup вызван');
  debugPrint('[AuthLocalDataSource] isPinSetup: _database = ${_database != null ? "инициализирована" : "NULL"}');
    
    try {
      // Проверяем ТОЛЬКО SQLite
  debugPrint('[AuthLocalDataSource] isPinSetup: получение базы данных...');
      final db = await _db;
  debugPrint('[AuthLocalDataSource] isPinSetup: база данных получена');
      
  debugPrint('[AuthLocalDataSource] isPinSetup: запрос к БД...');
      final result = await db.query(
        'auth_data',
        where: 'key = ?',
        whereArgs: [_sqlitePinHashKey],
      );
  debugPrint('[AuthLocalDataSource] isPinSetup: результат = ${result.length} записей');
      
      final isSetup = result.isNotEmpty;
  debugPrint('[AuthLocalDataSource] isPinSetup: возвращает $isSetup');
      return isSetup;
    } catch (_) {
  debugPrint('[AuthLocalDataSource] isPinSetup: ОШИБКА, возвращает false');
      // Если ошибка - считаем что PIN не установлен
      return false;
    }
  }

  /// Сохраняет данные аутентификации в SQLite
  Future<void> _saveToSqlite(String key, String value) async {
    try {
      final db = await _db;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert(
        'auth_data',
        {
          'key': key,
          'value': value,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Игнорируем ошибки сохранения
    }
  }

  /// Читает данные аутентификации из SQLite
  Future<String?> _readFromSqlite(String key) async {
    try {
      final db = await _db;
      final result = await db.query(
        'auth_data',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) return null;
      return result.first['value'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Удаляет данные аутентификации из SQLite
  Future<void> _deleteFromSqlite(String key) async {
    try {
      final db = await _db;
      await db.delete(
        'auth_data',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (_) {
      // Игнорируем ошибки удаления
    }
  }

  /// Сохраняет целочисленное значение в SQLite
  Future<void> _saveIntToSqlite(String key, int value) async {
    try {
      final db = await _db;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert(
        'auth_data',
        {
          'key': key,
          'value': value.toString(),
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Игнорируем ошибки сохранения
    }
  }

  /// Читает целочисленное значение из SQLite
  Future<int?> _readIntFromSqlite(String key) async {
    try {
      final db = await _db;
      final result = await db.query(
        'auth_data',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) return null;
      final value = result.first['value'] as String?;
      return value != null ? int.tryParse(value) : null;
    } catch (_) {
      return null;
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
  debugPrint('[AuthLocalDataSource] _verifyPinHash: START');
  debugPrint('[AuthLocalDataSource] _verifyPinHash: storedHash = $storedHash');
  debugPrint('[AuthLocalDataSource] _verifyPinHash: storedSalt = $storedSalt');
  debugPrint('[AuthLocalDataSource] _verifyPinHash: pin = $pin');
  
      final saltBytes = base64Decode(storedSalt);
  debugPrint('[AuthLocalDataSource] _verifyPinHash: saltBytes.length = ${saltBytes.length}');

      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: pbkdf2Iterations,
        bits: 256,
      );

  debugPrint('[AuthLocalDataSource] _verifyPinHash: PBKDF2 created, iterations = $pbkdf2Iterations');

      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: pin,
        nonce: Uint8List.fromList(saltBytes),
      );

  debugPrint('[AuthLocalDataSource] _verifyPinHash: secretKey derived');

      final computedHashBytes = await secretKey.extractBytes();
  debugPrint('[AuthLocalDataSource] _verifyPinHash: computedHashBytes.length = ${computedHashBytes.length}');
      
      final computedHash = base64Encode(computedHashBytes);
  debugPrint('[AuthLocalDataSource] _verifyPinHash: computedHash = $computedHash');
  debugPrint('[AuthLocalDataSource] _verifyPinHash: storedHash      = $storedHash');
  debugPrint('[AuthLocalDataSource] _verifyPinHash: hashes match = ${computedHash == storedHash}');

      // Constant-time сравнение хэшей (защита от timing attacks)
      final isValid = CryptoUtils.constantTimeEqualsBase64(computedHash, storedHash);

  debugPrint('[AuthLocalDataSource] _verifyPinHash: isValid = $isValid');

  try{
      // Затирание ключа из памяти
      CryptoUtils.secureWipeKey(computedHashBytes);
  } catch (_) {};
  

      return isValid;
    } catch (e) {
  debugPrint('[AuthLocalDataSource] _verifyPinHash: ERROR = $e');
      return false;
    }
  }

  /// Устанавливает новый PIN
  ///
  /// Хранение данных выполняется ТОЛЬКО в SQLite для безопасности.
  /// SharedPreferences не используется для хранения чувствительных данных.
  Future<bool> setupPin(String pin) async {
  debugPrint('[AuthLocalDataSource] setupPin вызван, PIN длина: ${pin.length}');
  debugPrint('[AuthLocalDataSource] setupPin: _database = ${_database != null ? "инициализирована" : "NULL"}');
    
    try {
      if (!isValidPinFormat(pin)) {
  debugPrint('[AuthLocalDataSource] setupPin: неверный формат PIN');
        throw const ValidationFailure(message: 'PIN должен содержать 4-8 цифр');
      }

  debugPrint('[AuthLocalDataSource] setupPin: хэширование PIN...');
      final hashed = await _hashPin(pin);
  debugPrint('[AuthLocalDataSource] setupPin: PIN захэширован');

      // Сохраняем ТОЛЬКО в SQLite (безопасное хранилище)
  debugPrint('[AuthLocalDataSource] setupPin: получение базы данных...');
      final db = await _db;
  debugPrint('[AuthLocalDataSource] setupPin: база данных получена');
      
  debugPrint('[AuthLocalDataSource] setupPin: сохранение hash...');
      await _saveToSqlite(_sqlitePinHashKey, hashed['hash']!);
  debugPrint('[AuthLocalDataSource] setupPin: hash сохранён');
      
  debugPrint('[AuthLocalDataSource] setupPin: сохранение salt...');
      await _saveToSqlite(_sqlitePinSaltKey, hashed['salt']!);
  debugPrint('[AuthLocalDataSource] setupPin: salt сохранён');
      
  debugPrint('[AuthLocalDataSource] setupPin: сброс попыток...');
      await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
  debugPrint('[AuthLocalDataSource] setupPin: попытки сброшены');
      
  debugPrint('[AuthLocalDataSource] setupPin: удаление lockout...');
      await _deleteFromSqlite(_sqliteLockoutTimestampKey);
  debugPrint('[AuthLocalDataSource] setupPin: lockout удалён');

  debugPrint('[AuthLocalDataSource] setupPin: УСПЕХ! PIN установлен');
      return true;
    } catch (e) {
  debugPrint('[AuthLocalDataSource] setupPin: ОШИБКА: $e');
      if (e is ValidationFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка установки PIN');
    }
  }

  /// Проверяет PIN
  ///
  /// Чтение данных выполняется ТОЛЬКО из SQLite.
  /// SharedPreferences не используется для чтения чувствительных данных.
  Future<Map<String, dynamic>> verifyPin(String pin) async {
  debugPrint('[AuthLocalDataSource] verifyPin вызван, PIN длина: ${pin.length}');
  debugPrint('[AuthLocalDataSource] verifyPin: _database = ${_database != null ? "инициализирована" : "NULL"}');
    
    try {
      String? storedHash;
      String? storedSalt;

      // Читаем ТОЛЬКО из SQLite (безопасное хранилище)
  debugPrint('[AuthLocalDataSource] verifyPin: получение базы данных...');
      final db = await _db;
  debugPrint('[AuthLocalDataSource] verifyPin: база данных получена');
      
  debugPrint('[AuthLocalDataSource] verifyPin: чтение hash...');
      storedHash = await _readFromSqlite(_sqlitePinHashKey);
  debugPrint('[AuthLocalDataSource] verifyPin: hash = ${storedHash != null ? "найден" : "NULL"}');
      
  debugPrint('[AuthLocalDataSource] verifyPin: чтение salt...');
      storedSalt = await _readFromSqlite(_sqlitePinSaltKey);
  debugPrint('[AuthLocalDataSource] verifyPin: salt = ${storedSalt != null ? "найден" : "NULL"}');

      if (storedHash == null || storedSalt == null) {
  debugPrint('[AuthLocalDataSource] verifyPin: PIN НЕ УСТАНОВЛЕН (hash или salt = null)');
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
      final db = await _db;

      // Выполняем ротацию ключей
      await _rotateEncryptionKeys(oldPin, newPin, db);

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
  /// 
  /// Процесс ротации:
  /// 1. Получаем соль старого PIN
  /// 2. Derive старого ключа
  /// 3. Расшифровка всех паролей старым ключом
  /// 4. Derive нового ключа (единожды, не в цикле)
  /// 5. Зашифровка всех паролей новым ключом
  /// 6. Обновление записей в БД
  /// 7. Затирание всех чувствительных данных
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

    // 3. Получаем соль нового PIN и деривируем новый ключ (единожды)
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

    // 4. Получаем все пароли из БД
    final passwordEntries = await db.query('password_entries');

    for (final entry in passwordEntries) {
      final encryptedPassword = entry['encrypted_password'] as List<int>;
      final nonceBytes = entry['nonce'] as List<int>;

      // 5. Расшифровываем пароль старым ключом
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

      // 8. Затираем расшифрованный пароль
      CryptoUtils.secureWipeData(decryptedPassword);
    }

    // 9. Затираем все ключи после использования
    CryptoUtils.secureWipeKey(oldKeyBytes);
    CryptoUtils.secureWipeKey(newKeyBytes);
  }

  /// Расшифровывает пароль
  Future<List<int>> _decryptPassword(
    List<int> encryptedData,
    List<int> nonce,
    List<int> key,
  ) async {
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
  /// 
  /// Удаление выполняется ТОЛЬКО из SQLite.
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

      // Удаляем данные ТОЛЬКО из SQLite
      if (_database != null) {
        await _deleteFromSqlite(_sqlitePinHashKey);
        await _deleteFromSqlite(_sqlitePinSaltKey);
        await _deleteFromSqlite(_sqliteFailedAttemptsKey);
        await _deleteFromSqlite(_sqliteLockoutTimestampKey);
      }

      return true;
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const StorageFailure(message: 'Ошибка удаления PIN');
    }
  }

  /// Проверяет, заблокирован ли пользователь
  ///
  /// Чтение данных выполняется ТОЛЬКО из SQLite.
  Future<bool> _isLocked() async {
    int? lockoutTimestamp;

    // Читаем ТОЛЬКО из SQLite
    lockoutTimestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);

    if (lockoutTimestamp == null) {
      return false;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    final now = DateTime.now();

    if (now.isBefore(lockoutTime)) {
      return true;
    }

    // Блокировка истекла, сбрасываем
    await _deleteFromSqlite(_sqliteLockoutTimestampKey);
    await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);

    return false;
  }

  /// Увеличивает счётчик неудачных попыток
  ///
  /// Сохранение выполняется ТОЛЬКО в SQLite.
  Future<int> _incrementFailedAttempts() async {
    int? current = await _readIntFromSqlite(_sqliteFailedAttemptsKey);

    if (current == null) {
      current = 0;
    }

    final newValue = current + 1;

    // Сохраняем ТОЛЬКО в SQLite
    await _saveIntToSqlite(_sqliteFailedAttemptsKey, newValue);

    return newValue;
  }

  /// Устанавливает блокировку
  ///
  /// Сохранение выполняется ТОЛЬКО в SQLite.
  Future<void> _setLockout() async {
    final lockoutTime = DateTime.now().add(
      const Duration(seconds: lockoutDurationSeconds),
    );
    final timestamp = lockoutTime.millisecondsSinceEpoch;

    // Сохраняем ТОЛЬКО в SQLite
    await _saveIntToSqlite(_sqliteLockoutTimestampKey, timestamp);
  }

  /// Получает количество неудачных попыток
  ///
  /// Чтение выполняется ТОЛЬКО из SQLite.
  Future<int> getFailedAttempts() async {
    int? attempts = await _readIntFromSqlite(_sqliteFailedAttemptsKey);
    return attempts ?? 0;
  }

  /// Получает время разблокировки
  ///
  /// Чтение выполняется ТОЛЬКО из SQLite.
  Future<DateTime?> getLockoutUntil() async {
    int? timestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);

    if (timestamp == null) return null;

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().isBefore(lockoutTime)) {
      return lockoutTime;
    }

    return null;
  }

  /// Проверяет, истёк ли срок блокировки
  ///
  /// Чтение и сброс выполняются ТОЛЬКО в SQLite.
  Future<bool> checkLockoutExpired() async {
    int? lockoutTimestamp = await _readIntFromSqlite(_sqliteLockoutTimestampKey);

    if (lockoutTimestamp == null) {
      return true;
    }

    final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
    if (DateTime.now().isAfter(lockoutTime)) {
      // Блокировка истекла, сбрасываем
      await _deleteFromSqlite(_sqliteLockoutTimestampKey);
      await _saveIntToSqlite(_sqliteFailedAttemptsKey, 0);
      return true;
    }

    return false;
  }

  /// Получает состояние аутентификации
  ///
  /// Чтение выполняется ТОЛЬКО из SQLite.
  Future<Map<String, dynamic>> getAuthState() async {
    bool isPinSetupResult = false;

    // Проверяем ТОЛЬКО SQLite с обработкой ошибок
    try {
      final db = await _db;
      // Проверяем существует ли таблица
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='auth_data'",
      );
      
      if (tables.isNotEmpty) {
        final hash = await _readFromSqlite(_sqlitePinHashKey);
        isPinSetupResult = hash != null;
      }
    } catch (_) {
      // Если база не инициализирована или таблица не существует,
      // считаем что PIN не установлен
      isPinSetupResult = false;
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
