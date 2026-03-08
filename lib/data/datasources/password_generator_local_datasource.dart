import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../../../../core/utils/password_utils.dart';
import 'encryptor_local_datasource.dart';
import 'storage_local_datasource.dart';
import '../../domain/entities/password_entry.dart';

/// Локальный источник данных для генерации паролей
class PasswordGeneratorLocalDataSource {
  final EncryptorLocalDataSource _encryptor;
  final StorageLocalDataSource _storage;

  const PasswordGeneratorLocalDataSource(this._encryptor, this._storage);

  /// Алфавиты символов
  static const String digits = '0123456789';
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String symbols = '!@#%^&*_+-=[]{};:,.?';
  
  /// Похожие символы для исключения
  static const String similarCharacters = '1lI0Oo';

  /// Получает алфавит по флагу
  String getAlphabetByFlag(int flag) {
    switch (flag) {
      case 1: return digits;
      case 4: return lowercase;
      case 16: return uppercase;
      case 64: return symbols;
      default: return '';
    }
  }

  /// Генерирует пароль с расширенными настройками
  Map<String, String> generate({
    required List<int> lengthRange,
    required int flags,
    bool excludeSimilar = false,
    bool allUnique = false,
    bool useLowercase = true,
    bool useUppercase = true,
    bool useDigits = true,
    bool useSymbols = true,
    String? customCharacters,
  }) {
    try {
      final length = _encryptor.generateRandomInt(
        min: lengthRange[0],
        max: lengthRange[1] + 1,
      );

      final rands = _encryptor.generateRandomBytes(length: length * 2);

      return _coreEngine(
        length: length,
        flags: flags,
        rands: rands,
        excludeSimilar: excludeSimilar,
        allUnique: allUnique,
        useLowercase: useLowercase,
        useUppercase: useUppercase,
        useDigits: useDigits,
        useSymbols: useSymbols,
        customCharacters: customCharacters,
      );
    } catch (e) {
      return {
        'password': '',
        'strength': '0',
        'config': '',
        'error': e.toString(),
      };
    }
  }

  /// Восстанавливает пароль из конфига
  Map<String, String> restoreFromConfig(String config) {
    try {
      final parts = config.split('.');
      if (parts.length < 3) {
        throw const FormatException('Invalid config format');
      }

      final length = int.parse(CryptoUtils.decodeBase64(parts[0]));
      final flags = int.parse(CryptoUtils.decodeBase64(parts[1]));
      final rands = CryptoUtils.decodeBytesBase64(parts[2]);

      return _coreEngine(length: length, flags: flags, rands: rands);
    } catch (e) {
      return {
        'password': '',
        'strength': '0',
        'config': '',
        'error': 'Restore failed: $e',
      };
    }
  }

  /// Ядро генерации пароля
  Map<String, String> _coreEngine({
    required int length,
    required int flags,
    required List<int> rands,
    bool excludeSimilar = false,
    bool allUnique = false,
    bool useLowercase = true,
    bool useUppercase = true,
    bool useDigits = true,
    bool useSymbols = true,
    String? customCharacters,
  }) {
    if (rands.isEmpty) {
      return {'password': '', 'strength': '0', 'config': ''};
    }

    int getSafeRand(int index) => rands[index % rands.length];

    final passwordChars = <String>[];
    var allAllowedChars = '';
    var randCursor = 0;

    // Если используется режим "Свой+" с пользовательскими наборами
    if (customCharacters != null && customCharacters.isNotEmpty) {
      // Используем только пользовательские символы
      allAllowedChars = customCharacters;
    } else {
      // Стандартный режим с флагами
      // Категории: Digits(1), Lower(4), Upper(16), Symbols(64)
      for (final f in [1, 4, 16, 64]) {
        if ((flags & f) != 0) {
          String chars = getAlphabetByFlag(f);

          // Исключаем похожие символы если нужно
          if (excludeSimilar) {
            for (final char in similarCharacters.split('')) {
              chars = chars.replaceAll(char, '');
            }
          }

          if (chars.isNotEmpty) {
            // Проверяем соответствующие use* флаги
            bool shouldInclude = false;
            switch (f) {
              case 1: shouldInclude = useDigits; break;
              case 4: shouldInclude = useLowercase; break;
              case 16: shouldInclude = useUppercase; break;
              case 64: shouldInclude = useSymbols; break;
            }

            if (shouldInclude) {
              allAllowedChars += chars;

              // Required проверка (флаг << 1)
              if ((flags & (f << 1)) != 0 && passwordChars.length < length) {
                var charIndex = getSafeRand(randCursor) % chars.length;
                var char = chars[charIndex];
                
                // Если allUnique = true, проверяем уникальность
                if (allUnique) {
                  // Пытаемся найти уникальный символ
                  var attempts = 0;
                  while (passwordChars.contains(char) && attempts < chars.length) {
                    charIndex = (charIndex + 1) % chars.length;
                    char = chars[charIndex];
                    attempts++;
                  }
                }
                
                if (!passwordChars.contains(char)) {
                  passwordChars.add(char);
                }
                randCursor++;
              }
            }
          }
        }
      }
    }

    if (allAllowedChars.isEmpty) {
      return {'password': '', 'strength': '0'};
    }

    // Исключаем похожие символы из всех разрешённых если нужно
    if (excludeSimilar) {
      for (final char in similarCharacters.split('')) {
        allAllowedChars = allAllowedChars.replaceAll(char, '');
      }
    }

    // Заполнение до нужной длины
    while (passwordChars.length < length) {
      var charIndex = getSafeRand(randCursor) % allAllowedChars.length;
      var char = allAllowedChars[charIndex];
      
      if (allUnique) {
        // Если allUnique = true, пытаемся найти уникальный символ
        var attempts = 0;
        while (passwordChars.contains(char) && attempts < allAllowedChars.length) {
          charIndex = (charIndex + 1) % allAllowedChars.length;
          char = allAllowedChars[charIndex];
          attempts++;
        }
        
        // Если не нашли уникальный символ, добавляем только если не содержится
        if (!passwordChars.contains(char)) {
          passwordChars.add(char);
        } else {
          // Если все символы использованы, прерываем цикл
          break;
        }
      } else {
        passwordChars.add(char);
      }
      randCursor++;
    }

    // Перемешивание (Fisher-Yates)
    for (int i = passwordChars.length - 1; i > 0; i--) {
      final j = getSafeRand(length + i) % (i + 1);
      final temp = passwordChars[i];
      passwordChars[i] = passwordChars[j];
      passwordChars[j] = temp;
    }

    final password = passwordChars.join('');
    final strength = PasswordUtils.evaluateStrength(password);

    final config = _generateConfig(length: length, flags: flags, rands: rands);

    return {
      'password': password,
      'strength': strength.toString(),
      'config': config,
    };
  }

  /// Создаёт конфиг генерации
  String _generateConfig({
    required int length,
    required int flags,
    required List<int> rands,
  }) {
    return '${CryptoUtils.encodeBase64(length.toString())}.'
        '${CryptoUtils.encodeBase64(flags.toString())}.'
        '${CryptoUtils.encodeBytesBase64(rands)}';
  }

  /// Создаёт зашифрованную конфигурацию пароля
  Future<String> createEncryptedConfig({
    required String passwordConfig,
    required String masterPassword,
  }) async {
    final messageBytes = utf8.encode(passwordConfig);
    final passwordBytes = utf8.encode(masterPassword);

    return await _encryptor.encryptToMini(
      message: messageBytes,
      password: passwordBytes,
    );
  }

  /// Расшифровывает конфигурацию пароля
  Future<String> decryptConfig({
    required String encryptedConfig,
    required String masterPassword,
  }) async {
    final passwordBytes = utf8.encode(masterPassword);

    final decryptedBytes = await _encryptor.decryptFromMini(
      miniEncrypted: encryptedConfig,
      password: passwordBytes,
    );

    return utf8.decode(decryptedBytes);
  }

  /// Генерирует UUID
  String generateUuid() {
    return const Uuid().v8();
  }

  /// Сохраняет пароль в хранилище
  /// Возвращает результат с информацией о том, был ли пароль обновлён
  Future<Map<String, dynamic>> savePassword({
    required String service,
    required String password,
    required String config,
    int? categoryId,
    String? login,
  }) async {
    try {
      // Получаем текущие пароли
      final passwords = await _storage.getPasswords();

      // Проверяем, существует ли уже запись с таким сервисом
      final existingIndex = passwords.indexWhere(
        (e) => e.service.toLowerCase() == service.toLowerCase(),
      );

      if (existingIndex != -1) {
        // Обновляем существующую запись
        final existingEntry = passwords[existingIndex];
        final updatedEntry = existingEntry.copyWith(
          password: password,
          config: config,
          login: login ?? existingEntry.login,
          categoryId: categoryId ?? existingEntry.categoryId,
          updatedAt: DateTime.now(),
        );
        passwords[existingIndex] = updatedEntry;
      } else {
        // Создаём новую запись
        final newEntry = PasswordEntry(
          service: service,
          password: password,
          config: config,
          login: login,
          categoryId: categoryId,
          createdAt: DateTime.now(),
        );
        passwords.add(newEntry);
      }

      await _storage.savePasswords(passwords);

      return {
        'success': true,
        'error': null,
        'updated': existingIndex != -1,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
