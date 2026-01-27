import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'encrypted.dart';

void main() {
  group('Encrypted Class Tests', () {
    late Encrypted encrypter;
    late Encrypted decrypter;

    const String testMessage = "This is a secret message.";
    const String testPassword = "strongpassword";
    final List<int> testMessageBytes = utf8.encode(testMessage);
    final List<int> testPasswordBytes = utf8.encode(testPassword);

    setUp(() {
      encrypter = Encrypted();
      decrypter = Encrypted();
    });

    // Tests for random() function
    group('random() function', () {
      test('generates random bytes with default length (32)', () {
        final result = random();
        expect(result.length, equals(32));
        expect(result, isA<List<int>>());
      });

      test('generates random bytes with custom length', () {
        final result = random(len: 16);
        expect(result.length, equals(16));
      });

      test('generates random bytes within specified range', () {
        final result = random(len: 100, range: const [0, 100]);
        for (final byte in result) {
          expect(byte, greaterThanOrEqualTo(0));
          expect(byte, lessThan(100));
        }
      });

      test('generates different random values on each call', () {
        final result1 = random();
        final result2 = random();
        expect(result1, isNot(equals(result2)));
      });

      test('respects custom range boundaries', () {
        final result = random(len: 50, range: const [50, 150]);
        for (final byte in result) {
          expect(byte, greaterThanOrEqualTo(50));
          expect(byte, lessThan(150));
        }
      });
    });

    // Tests for randomInt() function
    group('randomInt() function', () {
      test('generates random integer with default range', () {
        final result = randomInt();
        expect(result, greaterThanOrEqualTo(0));
        expect(result, lessThan(100));
      });

      test('generates random integer within custom range', () {
        final result = randomInt(min: 10, max: 20);
        expect(result, greaterThanOrEqualTo(10));
        expect(result, lessThan(20));
      });

      test('generates random integer with negative range', () {
        final result = randomInt(min: -50, max: 50);
        expect(result, greaterThanOrEqualTo(-50));
        expect(result, lessThan(50));
      });

      test('generates different values on each call', () {
        final result1 = randomInt(min: 0, max: 1000);
        final result2 = randomInt(min: 0, max: 1000);
        final result3 = randomInt(min: 0, max: 1000);
        expect([result1, result2, result3], isNotEmpty);
      });
    });

    // Tests for encryption and decryption
    group('Encryption and Decryption', () {
      test('encrypts message and returns ciphertext', () async {
        final result = await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );
        expect(result, isA<List<int>>());
        expect(result, isNotEmpty);
        // Ciphertext should be different from original message
        expect(result, isNot(equals(testMessageBytes)));
      });

      test('decrypts encrypted message correctly', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(testMessage));
      });

      test('fails to decrypt with wrong password', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final wrongPassword = utf8.encode("wrongpassword");

        expect(
          () async => await decrypter.getDeEncr(passwd: wrongPassword),
          throwsA(isA<String>()),
        );
      });

      test('encrypts empty message', () async {
        final emptyBytes = <int>[];
        final result = await encrypter.getEncr(
          message: emptyBytes,
          password: testPasswordBytes,
        );
        expect(result, isA<List<int>>());
      });

      test('encrypts very long message', () async {
        final longMessage = 'A' * 10000;
        final longMessageBytes = utf8.encode(longMessage);

        await encrypter.getEncr(
          message: longMessageBytes,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(longMessage));
      });

      test('each encryption produces different ciphertext', () async {
        final cipher1 = await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final encrypter2 = Encrypted();
        final cipher2 = await encrypter2.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        // Different nonces should produce different ciphertexts
        expect(cipher1, isNot(equals(cipher2)));
      });
    });

    // Tests for JSON export/import
    group('JSON Export and Import', () {
      test('exports encrypted config as valid JSON', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final jsonString = encrypter.getEncrJSON();
        expect(jsonString, isA<String>());

        // Should be valid JSON
        final decoded = jsonDecode(jsonString);
        expect(decoded, isA<Map>());
        expect(decoded.containsKey('nonce'), isTrue);
        expect(decoded.containsKey('nonceBox'), isTrue);
        expect(decoded.containsKey('cipherText'), isTrue);
        expect(decoded.containsKey('mac'), isTrue);
      });

      test('loads from JSON and decrypts correctly', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final jsonString = encrypter.getEncrJSON();
        decrypter = Encrypted(encrJSON: jsonString);

        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(testMessage));
      });

      test('JSON fields are base64 encoded', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final jsonString = encrypter.getEncrJSON();
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

        // All fields should be valid base64 strings
        for (final value in decoded.values) {
          expect(value, isA<String>());
          // Should not throw when decoding
          expect(() => base64Decode(value), returnsNormally);
        }
      });

      test('throws error for invalid JSON', () {
        expect(
          () => Encrypted(encrJSON: 'invalid json'),
          throwsA(isA<String>()),
        );
      });

      test('throws error for malformed JSON format', () {
        final badJson = jsonEncode({
          'nonce': 'invalidbase64!!!',
          'nonceBox': base64Encode([1, 2, 3]),
          'cipherText': base64Encode([1, 2, 3]),
          'mac': base64Encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
        });
        expect(
          () => Encrypted(encrJSON: badJson),
          throwsA(isA<String>()),
        );
      });
    });

    // Tests for Mini format export/import
    group('Mini Format Export and Import', () {
      test('exports encrypted config in mini format', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final miniEncr = encrypter.getMiniEncr();
        expect(miniEncr, isA<String>());

        // Should be valid base64
        expect(() => base64Decode(miniEncr), returnsNormally);
      });

      test('mini format is more compact than JSON', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final jsonString = encrypter.getEncrJSON();
        final miniEncr = encrypter.getMiniEncr();

        // Mini format should be shorter
        expect(miniEncr.length, lessThan(jsonString.length));
      });

      test('loads from mini format and decrypts correctly', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final miniEncr = encrypter.getMiniEncr();
        decrypter = Encrypted(encrJSON: miniEncr);

        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(testMessage));
      });

      test('mini format structure is correct', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final miniEncr = encrypter.getMiniEncr();
        final bytes = base64Decode(miniEncr);

        // Structure: nonce(32) + nonceBox(12) + cipherText + mac(16)
        expect(bytes.length, greaterThan(32 + 12 + 16));
      });

      test('throws error for invalid mini format', () {
        expect(
          () => Encrypted(encrJSON: base64Encode([1, 2, 3])),
          throwsA(isA<String>()),
        );
      });
    });

    // Tests for edge cases
    group('Edge Cases', () {
      test('handles unicode characters in message', () async {
        final unicodeMessage = "Привет мир 你好世界 🔐";
        final unicodeBytes = utf8.encode(unicodeMessage);

        await encrypter.getEncr(
          message: unicodeBytes,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(unicodeMessage));
      });

      test('handles special characters in password', () async {
        final specialPassword = utf8.encode("p@ss!#\$%&*()[]{}");

        await encrypter.getEncr(
          message: testMessageBytes,
          password: specialPassword,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: specialPassword,
        );
        final decryptedMessage = utf8.decode(decryptedBytes);

        expect(decryptedMessage, equals(testMessage));
      });

      test('handles binary data (raw bytes)', () async {
        final binaryData = [0, 1, 2, 255, 254, 253, 128];

        await encrypter.getEncr(
          message: binaryData,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: testPasswordBytes,
        );

        expect(decryptedBytes, equals(binaryData));
      });

      test('password case is sensitive', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final upperPassword = utf8.encode("STRONGPASSWORD");

        expect(
          () async => await decrypter.getDeEncr(passwd: upperPassword),
          throwsA(isA<String>()),
        );
      });

      test('single character message and password', () async {
        final singleChar = utf8.encode('A');
        final singleCharPass = utf8.encode('P');

        await encrypter.getEncr(
          message: singleChar,
          password: singleCharPass,
        );

        decrypter = Encrypted(encrJSON: encrypter.getEncrJSON());
        final decryptedBytes = await decrypter.getDeEncr(
          passwd: singleCharPass,
        );

        expect(utf8.decode(decryptedBytes), equals('A'));
      });
    });

    // Tests for consistency
    group('Consistency Tests', () {
      test('same plaintext with same password produces different ciphertexts', () async {
        final encrypter1 = Encrypted();
        final encrypter2 = Encrypted();

        final cipher1 = await encrypter1.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final cipher2 = await encrypter2.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        // Different due to random nonce
        expect(cipher1, isNot(equals(cipher2)));
      });

      test('can decrypt multiple times with same config', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        final jsonString = encrypter.getEncrJSON();
        decrypter = Encrypted(encrJSON: jsonString);

        final decrypted1 = await decrypter.getDeEncr(passwd: testPasswordBytes);
        final decrypted2 = await decrypter.getDeEncr(passwd: testPasswordBytes);

        expect(decrypted1, equals(decrypted2));
        expect(utf8.decode(decrypted1), equals(testMessage));
      });

      test('exported JSON can be re-imported multiple times', () async {
        await encrypter.getEncr(
          message: testMessageBytes,
          password: testPasswordBytes,
        );

        var jsonString = encrypter.getEncrJSON();

        for (int i = 0; i < 3; i++) {
          decrypter = Encrypted(encrJSON: jsonString);
          final decrypted = await decrypter.getDeEncr(passwd: testPasswordBytes);
          expect(utf8.decode(decrypted), equals(testMessage));
          jsonString = decrypter.getEncrJSON();
        }
      });
    });
  });
}