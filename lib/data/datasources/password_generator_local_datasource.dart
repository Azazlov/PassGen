import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../../../../core/utils/password_utils.dart';
import '../../domain/entities/password_entry.dart';
import 'encryptor_local_datasource.dart';
import 'storage_local_datasource.dart';

/// Локальный источник данных для генерации паролей
class PasswordGeneratorLocalDataSource {
  const PasswordGeneratorLocalDataSource(this._encryptor, this._storage);
  final EncryptorLocalDataSource _encryptor;
  final StorageLocalDataSource _storage;

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
      case 1:
        return digits;
      case 4:
        return lowercase;
      case 16:
        return uppercase;
      case 64:
        return symbols;
      default:
        return '';
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

  /// Leet-таблица подстановок для глитч-генерации
  static const Map<String, List<String>> _leetMap = {
    'a': ['4', '@'],
    'b': ['8', '6'],
    'e': ['3'],
    'g': ['9', '6'],
    'i': ['1', '!', '|'],
    'l': ['1', '7'],
    'o': ['0', '()'],
    's': ['5', '\$'],
    't': ['7', '+'],
    'z': ['2'],
    'A': ['4', '@'],
    'B': ['8', '6'],
    'E': ['3'],
    'G': ['9', '6'],
    'I': ['1', '!', '|'],
    'L': ['1', '7'],
    'O': ['0', '()'],
    'S': ['5', '\$'],
    'T': ['7', '+'],
    'Z': ['2'],
  };

  /// Генерирует глитч-пароль из исходной строки (leet-трансформация)
  Map<String, String> generateGlitch(String input) {
    try {
      if (input.isEmpty) {
        return {
          'password': '',
          'strength': '0',
          'config': '',
          'error': 'Исходная строка не может быть пустой',
        };
      }
      final password = _leetTransform(input);
      final strength = PasswordUtils.evaluateStrength(password);
      return {
        'password': password,
        'strength': strength.toString(),
        'config': input,
      };
    } catch (e) {
      return {
        'password': '',
        'strength': '0',
        'config': '',
        'error': e.toString(),
      };
    }
  }

  /// Применяет leet-подстановки к входной строке
  static String _leetTransform(String input) {
    final random = Random();
    final result = StringBuffer();

    for (final char in input.split('')) {
      if (char == ' ') {
        result.write(' ');
        continue;
      }

      final substitutions = _leetMap[char];
      if (substitutions != null && random.nextDouble() < 0.7) {
        result.write(substitutions[random.nextInt(substitutions.length)]);
      } else {
        if (random.nextDouble() < 0.3) {
          result.write(
            char == char.toUpperCase()
                ? char.toLowerCase()
                : char.toUpperCase(),
          );
        } else {
          result.write(char);
        }
      }
    }

    return result.toString();
  }

  /// Восстанавливает пароль из конфига (URL-safe Base64)
  Map<String, String> restoreFromConfig(String config) {
    try {
      final parts = config.split('.');
      if (parts.length < 3) {
        throw const FormatException('Invalid config format');
      }

      final length = int.parse(CryptoUtils.decodeBase64Url(parts[0]));
      final flags = int.parse(CryptoUtils.decodeBase64Url(parts[1]));
      final rands = CryptoUtils.decodeBytesBase64Url(parts[2]);

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
              case 1:
                shouldInclude = useDigits;
                break;
              case 4:
                shouldInclude = useLowercase;
                break;
              case 16:
                shouldInclude = useUppercase;
                break;
              case 64:
                shouldInclude = useSymbols;
                break;
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
                  while (passwordChars.contains(char) &&
                      attempts < chars.length) {
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

    // Защитная проверка: если allUnique и длина превышает доступные символы
    if (allUnique && length > allAllowedChars.length) {
      return {
        'password': '',
        'strength': '0',
        'config': '',
        'error':
            'Невозможно создать уникальный пароль: требуется $length, '
            'доступно ${allAllowedChars.length} символов',
      };
    }

    // Заполнение до нужной длины
    while (passwordChars.length < length) {
      var charIndex = getSafeRand(randCursor) % allAllowedChars.length;
      var char = allAllowedChars[charIndex];

      if (allUnique) {
        // Если allUnique = true, пытаемся найти уникальный символ
        var attempts = 0;
        while (passwordChars.contains(char) &&
            attempts < allAllowedChars.length) {
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

  /// Создаёт конфиг генерации (URL-safe Base64)
  String _generateConfig({
    required int length,
    required int flags,
    required List<int> rands,
  }) {
    return '${CryptoUtils.encodeBase64Url(length.toString())}.'
        '${CryptoUtils.encodeBase64Url(flags.toString())}.'
        '${CryptoUtils.encodeBytesBase64Url(rands)}';
  }

  /// Создаёт зашифрованную конфигурацию пароля
  Future<String> createEncryptedConfig({
    required String passwordConfig,
    required String masterPassword,
  }) {
    final messageBytes = utf8.encode(passwordConfig);
    final passwordBytes = utf8.encode(masterPassword);

    return _encryptor.encryptToMini(
      message: messageBytes,
      password: passwordBytes,
    );
  }

  /// Расшифровывает конфигурацию пароля
  ///
  /// Поддерживает обратную совместимость: если дешифровка не удалась,
  /// проверяет, является ли config открытым текстом (старый формат).
  Future<String> decryptConfig({
    required String encryptedConfig,
    required String masterPassword,
  }) async {
    try {
      final decrypted = await _encryptor.decryptFromMini(
        miniEncrypted: encryptedConfig,
        password: utf8.encode(masterPassword),
      );
      return utf8.decode(decrypted);
    } catch (_) {
      // Fallback: возможно старый формат (открытый текст)
      // Проверяем, что это валидный Base64 конфиг
      if (encryptedConfig.contains('.') && !encryptedConfig.contains(' ')) {
        return encryptedConfig;
      }
      throw const PasswordGenerationFailure(message: 'Неверный формат конфига');
    }
  }

  /// Генерирует UUID
  String generateUuid() {
    return const Uuid().v8();
  }

  /// Сохраняет пароль в хранилище
  ///
  /// ШИФРОВАНИЕ: Пароль И конфигурация шифруются с использованием мастер-пароля (PIN)
  /// Данные сохраняются в мини-формате (компактный Base64: pbkdf2-nonce + nonceBox + ciphertext + mac)
  /// Возвращает результат с информацией о том, был ли пароль обновлён
  Future<Map<String, dynamic>> savePassword({
    required String service,
    required String password,
    required String config,
    String? masterPassword,
    int? categoryId,
    String? login,
  }) async {
    if (masterPassword == null || masterPassword.isEmpty) {
      return {
        'success': false,
        'error':
            'Мастер-пароль не предоставлен. Невозможно зашифровать пароль.',
      };
    }

    try {
      final passwords = await _storage.getPasswords();
      final masterPasswordBytes = utf8.encode(masterPassword);

      final miniEncrypted = await _encryptor.encryptToMini(
        message: utf8.encode(password),
        password: masterPasswordBytes,
      );

      CryptoUtils.secureWipePassword(utf8.encode(password));

      final encryptedConfig = await _encryptor.encryptToMini(
        message: utf8.encode(config),
        password: masterPasswordBytes,
      );

      CryptoUtils.secureWipePassword(masterPasswordBytes);

      // Извлекаем PBKDF2-nonce из мини-формата (первые 32 байта до декодирования).
      // This nonce is stored separately in the entry so that
      // `save_password_usecase` can pass it to `saveHistoryEntry` and record a
      // history entry before overwriting the password.
      final pbkdf2Nonce = _extractPbkdf2Nonce(miniEncrypted);

      final existingIndex = passwords.indexWhere(
        (e) => e.service.toLowerCase() == service.toLowerCase(),
      );

      if (existingIndex != -1) {
        final existingEntry = passwords[existingIndex];
        final updatedEntry = existingEntry.copyWith(
          encryptedPassword: miniEncrypted,
          nonce: pbkdf2Nonce,
          config: encryptedConfig,
          login: login ?? existingEntry.login,
          categoryId: categoryId ?? existingEntry.categoryId,
          updatedAt: DateTime.now(),
        );
        passwords[existingIndex] = updatedEntry;
      } else {
        final newEntry = PasswordEntry(
          service: service,
          encryptedPassword: miniEncrypted,
          nonce: pbkdf2Nonce,
          config: encryptedConfig,
          login: login,
          categoryId: categoryId,
          createdAt: DateTime.now(),
        );
        passwords.add(newEntry);
      }

      await _storage.savePasswords(passwords);

      return {'success': true, 'error': null, 'updated': existingIndex != -1};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Извлекает PBKDF2-nonce из мини-формата.
  ///
  /// Мини-формат: Base64(32-байтовый_nonce) + rest. Возвращает Base64-encoded nonce.
  static String _extractPbkdf2Nonce(String miniEncrypted) {
    final bytes = CryptoUtils.decodeBytesBase64(miniEncrypted);
    final nonceBytes = bytes.sublist(0, 32);
    return CryptoUtils.encodeBytesBase64(nonceBytes);
  }
}
