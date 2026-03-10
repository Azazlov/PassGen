import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/core/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils Tests', () {
    // ==================== SECURE WIPE TESTS ====================

    group('Secure Wipe Tests', () {
      test('secureWipeData затирает данные нулями', () {
        final data = [1, 2, 3, 4, 5, 6, 7, 8];
        final originalLength = data.length;

        CryptoUtils.secureWipeData(data);

        // После затирания все байты должны быть 0
        expect(data.length, equals(originalLength));
        for (final byte in data) {
          expect(byte, equals(0));
        }
      });

      test('secureWipeKey затирает ключ', () {
        final key = [255, 128, 64, 32, 16, 8, 4, 2, 1];

        CryptoUtils.secureWipeKey(key);

        for (final byte in key) {
          expect(byte, equals(0));
        }
      });

      test('secureWipePassword затирает пароль', () {
        final password = [49, 50, 51, 52]; // "1234" in ASCII

        CryptoUtils.secureWipePassword(password);

        for (final byte in password) {
          expect(byte, equals(0));
        }
      });

      test('secureWipeData работает с пустым массивом', () {
        final data = <int>[];

        // Не должно выбрасывать исключение
        expect(() => CryptoUtils.secureWipeData(data), returnsNormally);
        expect(data.isEmpty, isTrue);
      });

      test('secureWipeData работает с большими данными', () {
        final data = List<int>.generate(1024, (i) => i % 256);

        CryptoUtils.secureWipeData(data);

        for (final byte in data) {
          expect(byte, equals(0));
        }
      });
    });

    // ==================== CONSTANT-TIME COMPARISON TESTS ====================

    group('Constant-Time Comparison Tests', () {
      test('constantTimeEquals возвращает true для одинаковых массивов', () {
        final a = [1, 2, 3, 4, 5];
        final b = [1, 2, 3, 4, 5];

        expect(CryptoUtils.constantTimeEquals(a, b), isTrue);
      });

      test('constantTimeEquals возвращает false для разных массивов', () {
        final a = [1, 2, 3, 4, 5];
        final b = [1, 2, 3, 4, 6];

        expect(CryptoUtils.constantTimeEquals(a, b), isFalse);
      });

      test('constantTimeEquals возвращает false для массивов разной длины', () {
        final a = [1, 2, 3, 4, 5];
        final b = [1, 2, 3, 4];

        expect(CryptoUtils.constantTimeEquals(a, b), isFalse);
      });

      test('constantTimeEquals работает с пустыми массивами', () {
        final a = <int>[];
        final b = <int>[];

        expect(CryptoUtils.constantTimeEquals(a, b), isTrue);
      });

      test('constantTimeEquals работает с нулевыми байтами', () {
        final a = [0, 0, 0, 0];
        final b = [0, 0, 0, 0];

        expect(CryptoUtils.constantTimeEquals(a, b), isTrue);
      });

      test('constantTimeEquals работает с максимальными байтами (0xFF)', () {
        final a = [255, 255, 255, 255];
        final b = [255, 255, 255, 255];

        expect(CryptoUtils.constantTimeEquals(a, b), isTrue);

        final c = [255, 255, 254, 255];
        expect(CryptoUtils.constantTimeEquals(a, c), isFalse);
      });

      test('constantTimeEqualsBase64 сравнивает Base64 строки', () {
        final a = 'AQIDBA=='; // [1, 2, 3, 4]
        final b = 'AQIDBA=='; // [1, 2, 3, 4]
        final c = 'AQIDBQ=='; // [1, 2, 3, 5]

        expect(CryptoUtils.constantTimeEqualsBase64(a, b), isTrue);
        expect(CryptoUtils.constantTimeEqualsBase64(a, c), isFalse);
      });

      test('constantTimeEqualsBase64 работает с пустыми строками', () {
        final a = '';
        final b = '';

        expect(CryptoUtils.constantTimeEqualsBase64(a, b), isTrue);
      });
    });

    // ==================== RANDOM DATA GENERATION TESTS ====================

    group('Random Data Generation Tests', () {
      test('generateSecureRandomBytes генерирует байты правильной длины', () {
        final bytes = CryptoUtils.generateSecureRandomBytes(32);

        expect(bytes.length, equals(32));
      });

      test('generateSecureRandomBytes генерирует разные значения', () {
        final bytes1 = CryptoUtils.generateSecureRandomBytes(32);
        final bytes2 = CryptoUtils.generateSecureRandomBytes(32);

        expect(bytes1, isNot(equals(bytes2)));
      });

      test('generateSecureRandomBytes генерирует байты в диапазоне [0, 255]', () {
        for (int i = 0; i < 100; i++) {
          final bytes = CryptoUtils.generateSecureRandomBytes(100);
          for (final byte in bytes) {
            expect(byte, inInclusiveRange(0, 255));
          }
        }
      });

      test('generateSecureNonce генерирует nonce правильной длины', () {
        final nonce = CryptoUtils.generateSecureNonce(length: 32);

        expect(nonce.length, equals(32));
      });

      test('generateSecureNonce генерирует разные nonce', () {
        final nonce1 = CryptoUtils.generateSecureNonce();
        final nonce2 = CryptoUtils.generateSecureNonce();

        expect(nonce1, isNot(equals(nonce2)));
      });

      test('generateSecureSalt генерирует соль правильной длины', () {
        final salt = CryptoUtils.generateSecureSalt(length: 32);

        expect(salt.length, equals(32));
      });

      test('generateSecureSalt генерирует разные соли', () {
        final salt1 = CryptoUtils.generateSecureSalt();
        final salt2 = CryptoUtils.generateSecureSalt();

        expect(salt1, isNot(equals(salt2)));
      });
    });

    // ==================== BASE64 ENCODING/DECODING TESTS ====================

    group('Base64 Encoding/Decoding Tests', () {
      test('encodeBytesBase64 и decodeBytesBase64 работают корректно', () {
        final original = [1, 2, 3, 4, 5, 6, 7, 8];

        final encoded = CryptoUtils.encodeBytesBase64(original);
        final decoded = CryptoUtils.decodeBytesBase64(encoded);

        expect(decoded, equals(original));
      });

      test('encodeBase64 и decodeBase64 работают корректно', () {
        final original = 'Hello, World!';

        final encoded = CryptoUtils.encodeBase64(original);
        final decoded = CryptoUtils.decodeBase64(encoded);

        expect(decoded, equals(original));
      });
    });

    // ==================== INTEGRATION TESTS ====================

    group('Integration Tests', () {
      test('Затирание после constant-time сравнения', () {
        final data = [1, 2, 3, 4, 5];
        final dataCopy = List<int>.from(data);

        // Сравниваем
        final result = CryptoUtils.constantTimeEquals(data, dataCopy);
        expect(result, isTrue);

        // Затираем
        CryptoUtils.secureWipeData(data);

        // Проверяем затирание
        for (final byte in data) {
          expect(byte, equals(0));
        }
      });

      test('Генерация и затирание случайных данных', () {
        final randomData = CryptoUtils.generateSecureRandomBytes(64);

        // Проверяем, что данные не нулевые
        final hasNonZero = randomData.any((byte) => byte != 0);
        expect(hasNonZero, isTrue);

        // Затираем
        CryptoUtils.secureWipeData(randomData);

        // Проверяем затирание
        for (final byte in randomData) {
          expect(byte, equals(0));
        }
      });

      test('Constant-time сравнение Base64 после генерации', () {
        final salt1 = CryptoUtils.generateSecureSalt();
        final salt2 = CryptoUtils.generateSecureSalt();

        final salt1Base64 = CryptoUtils.encodeBytesBase64(salt1);
        final salt2Base64 = CryptoUtils.encodeBytesBase64(salt2);

        // Разные соли должны быть разными
        expect(CryptoUtils.constantTimeEqualsBase64(salt1Base64, salt2Base64), isFalse);

        // Одинаковые должны совпадать
        expect(CryptoUtils.constantTimeEqualsBase64(salt1Base64, salt1Base64), isTrue);
      });
    });
  });
}
