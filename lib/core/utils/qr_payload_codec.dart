import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../domain/entities/qr_transfer_payload.dart';
import '../../core/errors/failures.dart';
import 'crypto_utils.dart';

/// Кодирование/декодирование QR-payload с шифрованием.
///
/// Security model:
/// - transfer PIN вводится пользователем (out-of-band)
/// - PBKDF2-HMAC-SHA256(transferPin, salt, 100000) → transfer_key
/// - ChaCha20-Poly1305(transfer_key, nonce, serialized_entry) → ciphertext + MAC
class QrPayloadCodec {
  const QrPayloadCodec();

  static const int _transferIterations = 100000;
  static const int _keyLengthBits = 256;

  /// Шифрует сериализованную запись пароля в payload.
  Future<QrTransferPayload> encrypt({
    required List<int> entryBytes,
    required String transferPin,
    int ttlSeconds = 300,
  }) async {
    final nonce = CryptoUtils.generateSecureRandomBytes(12);
    final salt = CryptoUtils.generateSecureRandomBytes(16);

    final transferKey = await _deriveKey(transferPin, salt, _transferIterations);

    final algorithm = Chacha20.poly1305Aead();
    final secretBox = await algorithm.encrypt(
      entryBytes,
      secretKey: transferKey,
    );

    return QrTransferPayload(
      version: '1',
      nonce: CryptoUtils.encodeBytesBase64Url(nonce),
      saltBase64: CryptoUtils.encodeBytesBase64Url(salt),
      iterations: _transferIterations,
      ciphertextBase64: CryptoUtils.encodeBytesBase64Url(secretBox.cipherText),
      macBase64: CryptoUtils.encodeBytesBase64Url(secretBox.mac.bytes),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      expirySeconds: ttlSeconds,
    );
  }

  /// Расшифровывает payload в сериализованную запись.
  Future<List<int>> decrypt({
    required QrTransferPayload payload,
    required String transferPin,
  }) async {
    if (payload.isExpired) {
      throw const ValidationFailure(message: 'QR-код истёк');
    }

    final nonce = CryptoUtils.decodeBytesBase64Url(payload.nonce);
    final salt = CryptoUtils.decodeBytesBase64Url(payload.saltBase64);
    final cipherText = CryptoUtils.decodeBytesBase64Url(payload.ciphertextBase64);
    final mac = Mac(CryptoUtils.decodeBytesBase64Url(payload.macBase64));

    final transferKey = await _deriveKey(
      transferPin,
      salt,
      payload.iterations,
    );

    final algorithm = Chacha20.poly1305Aead();
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

    try {
      return await algorithm.decrypt(secretBox, secretKey: transferKey);
    } catch (e) {
      throw const AuthFailure(
        message: 'Неверный transfer PIN или повреждённые данные',
        type: AuthFailureType.wrongPin,
      );
    }
  }

  Future<SecretKey> _deriveKey(
    String pin,
    List<int> salt,
    int iterations,
  ) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _keyLengthBits,
    );
    return pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: Uint8List.fromList(salt),
    );
  }
}
