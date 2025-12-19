import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'encrypted.dart';

void main() {
  group('Encrypted', () {
    test('getEncr encrypts message and stores cipher data', () async {
      final encrypter = Encrypted();
      final message = utf8.encode('Secret message');
      final password = utf8.encode('password123');

      await encrypter.getEncr(message: message, passwd: password);

      final json = encrypter.getEncrJSON();
      expect(json, isNotEmpty);
    });

    test('getDeEncr decrypts message correctly', () async {
      final encrypter = Encrypted();
      final originalMessage = 'Test message';
      final messageBytes = utf8.encode(originalMessage);
      final password = utf8.encode('password123');

      await encrypter.getEncr(message: messageBytes, passwd: password);
      final encrJSON = encrypter.getEncrJSON();

      final decrypter = Encrypted(encrJSON: encrJSON);
      final decryptedBytes = await decrypter.getDeEncr(passwd: password);
      final decryptedMessage = utf8.decode(decryptedBytes);

      expect(decryptedMessage, equals(originalMessage));
    });

    test('getDeEncr throws on wrong password', () async {
      final encrypter = Encrypted();
      final message = utf8.encode('Secret');
      final password = utf8.encode('correct');

      await encrypter.getEncr(message: message, passwd: password);
      final encrJSON = encrypter.getEncrJSON();

      final decrypter = Encrypted(encrJSON: encrJSON);
      expect(
        () => decrypter.getDeEncr(passwd: utf8.encode('wrong')),
        throwsA(isA<String>()),
      );
    });

    test('getEncrJSON exports valid JSON config', () async {
      final encrypter = Encrypted();
      await encrypter.getEncr(
        message: utf8.encode('test'),
        passwd: utf8.encode('pass'),
      );

      final json = encrypter.getEncrJSON();
      final decoded = jsonDecode(json);

      expect(decoded['nonce'], isNotNull);
      expect(decoded['nonceBox'], isNotNull);
      expect(decoded['cipherText'], isNotNull);
      expect(decoded['mac'], isNotNull);
    });

    test('random generates correct byte length', () {
      final bytes = random(len: 16);
      expect(bytes.length, equals(16));
    });

    test('randomInt generates value in range', () {
      final value = randomInt(min: 10, max: 20);
      expect(value, greaterThanOrEqualTo(10));
      expect(value, lessThan(20));
    });
  });
}