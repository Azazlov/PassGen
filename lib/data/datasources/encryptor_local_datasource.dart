import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/crypto_utils.dart';

/// Локальный источник данных для шифрования/дешифрования
class EncryptorLocalDataSource {
  late final Chacha20 _algorithm = Chacha20.poly1305Aead();

  /// Генерирует случайные байты
  List<int> generateRandomBytes({
    int length = 32,
    List<int> range = const [0, 255],
  }) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => random.nextInt(range[1] - range[0]) + range[0],
    );
  }

  /// Генерирует случайное число
  int generateRandomInt({int min = 0, int max = 100}) {
    final random = Random.secure();
    return random.nextInt(max - min) + min;
  }

  /// Создаёт ключ шифрования из пароля
  Future<SecretKey> _deriveKey({
    required List<int> password,
    List<int>? nonce,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000,
      bits: 256,
    );

    nonce ??= generateRandomBytes(length: 32);

    return pbkdf2.deriveKeyFromPassword(
      password: CryptoUtils.encodeBytesBase64(password),
      nonce: nonce,
    );
  }

  /// Шифрует сообщение и возвращает данные в JSON формате
  Future<Map<String, dynamic>> encrypt({
    required List<int> message,
    required List<int> password,
  }) async {
    try {
      final nonce = generateRandomBytes();
      final secretKey = await _deriveKey(password: password, nonce: nonce);

      final secretBox = await _algorithm.encrypt(message, secretKey: secretKey);

      return {
        'nonce': CryptoUtils.encodeBytesBase64(nonce),
        'nonceBox': CryptoUtils.encodeBytesBase64(secretBox.nonce),
        'cipherText': CryptoUtils.encodeBytesBase64(secretBox.cipherText),
        'mac': CryptoUtils.encodeBytesBase64(secretBox.mac.bytes),
      };
    } catch (e) {
      throw EncryptionFailure(message: 'Ошибка шифрования: $e');
    }
  }

  /// Дешифрует сообщение из JSON формата
  Future<List<int>> decrypt({
    required Map<String, dynamic> encryptedData,
    required List<int> password,
  }) async {
    try {
      final nonce = CryptoUtils.decodeBytesBase64(
        encryptedData['nonce'] as String,
      );
      final nonceBox = CryptoUtils.decodeBytesBase64(
        encryptedData['nonceBox'] as String,
      );
      final cipherText = CryptoUtils.decodeBytesBase64(
        encryptedData['cipherText'] as String,
      );
      final macBytes = CryptoUtils.decodeBytesBase64(
        encryptedData['mac'] as String,
      );

      final secretBox = SecretBox(
        cipherText,
        nonce: nonceBox,
        mac: Mac(macBytes),
      );

      final secretKey = await _deriveKey(password: password, nonce: nonce);

      return await _algorithm.decrypt(secretBox, secretKey: secretKey);
    } catch (e) {
      throw EncryptionFailure(message: 'Ошибка дешифрования: $e');
    }
  }

  /// Шифрует и возвращает мини-формат (компактный base64)
  Future<String> encryptToMini({
    required List<int> message,
    required List<int> password,
  }) async {
    final data = await encrypt(message: message, password: password);

    final nonce = CryptoUtils.decodeBytesBase64(data['nonce'] as String);
    final nonceBox = CryptoUtils.decodeBytesBase64(data['nonceBox'] as String);
    final cipherText = CryptoUtils.decodeBytesBase64(
      data['cipherText'] as String,
    );
    final mac = CryptoUtils.decodeBytesBase64(data['mac'] as String);

    return CryptoUtils.encodeBytesBase64(nonce + nonceBox + cipherText + mac);
  }

  /// Дешифрует из мини-формата
  Future<List<int>> decryptFromMini({
    required String miniEncrypted,
    required List<int> password,
  }) async {
    try {
      final bytes = CryptoUtils.decodeBytesBase64(miniEncrypted);

      final nonce = bytes.sublist(0, 32);
      final nonceBox = bytes.sublist(32, 44);
      final cipherText = bytes.sublist(44, bytes.length - 16);
      final mac = Mac(bytes.sublist(bytes.length - 16, bytes.length));

      final secretBox = SecretBox(cipherText, nonce: nonceBox, mac: mac);
      final secretKey = await _deriveKey(password: password, nonce: nonce);

      return await _algorithm.decrypt(secretBox, secretKey: secretKey);
    } catch (e) {
      throw EncryptionFailure(message: 'Ошибка дешифрования мини-формата: $e');
    }
  }

  /// Создаёт JSON строку из зашифрованных данных
  static String toJsonString(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// Парсит JSON строку в данные
  static Map<String, dynamic> fromJsonString(String jsonStr) {
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
