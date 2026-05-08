import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../../../../core/utils/encryption_versioning.dart';

/// Локальный источник данных для шифрования/дешифрования
class EncryptorLocalDataSource {
  late final Chacha20 _algorithm = Chacha20.poly1305Aead();
  
  // Centralized PBKDF2 parameters (используем текущую версию)
  static int get _pbkdf2Iterations => EncryptionParams.v2().iterations;

  /// Генерирует случайные байты
  List<int> generateRandomBytes({
    int length = 32,
    List<int> range = const [0, 255],
  }) {
    final random = Random.secure();
    // range[1] включительно, поэтому +1
    return List.generate(
      length,
      (_) => random.nextInt(range[1] - range[0] + 1) + range[0],
    );
  }

  /// Генерирует случайное число
  ///
  /// [min] включительно, [max] исключительно
  int generateRandomInt({int min = 0, int max = 100}) {
    final random = Random.secure();
    return random.nextInt(max - min) + min;
  }

  /// Создаёт ключ шифрования из пароля
  Future<SecretKey> _deriveKey({
    required List<int> password,
    List<int>? nonce,
  }) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
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

      // Извлекаем байты ключа перед затиранием (если нужно)
      // SecretKey сам управляет памятью, но мы можем затереть входной пароль
      CryptoUtils.secureWipeData(password);

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

      final result = await _algorithm.decrypt(secretBox, secretKey: secretKey);

      // Затираем пароль после использования
      CryptoUtils.secureWipeData(password);

      return result;
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

  // ==================== VAULT-KEY (PER-PROFILE) ====================

  /// Производит «vault key» из PIN и соли профиля.
  ///
  /// Один раз после успешной аутентификации этот ключ кэшируется в памяти
  /// (см. `VaultKeySession`) и используется для быстрого шифрования/дешифрования
  /// метаданных (`service`, `login`) — без повторного PBKDF2 на каждое поле.
  Future<List<int>> deriveVaultKeyBytes({
    required List<int> pin,
    required List<int> salt,
  }) async {
    final secretKey = await _deriveKey(password: pin, nonce: salt);
    final extracted = await secretKey.extractBytes();
    return extracted;
  }

  /// Шифрует короткое поле уже выведенным ключом и возвращает компактный BLOB.
  ///
  /// Формат: `nonce(12) + ciphertext + mac(16)`. Не требует PBKDF2 —
  /// предполагается, что `keyBytes` уже выведены через `deriveVaultKeyBytes`.
  /// Безопасность: nonce генерируется случайно для каждого вызова, ключ
  /// (per-profile, выведенный из PIN+pin_salt) обеспечивает изоляцию профилей.
  Future<List<int>> encryptFieldWithKey({
    required List<int> message,
    required List<int> keyBytes,
  }) async {
    try {
      final nonce = generateRandomBytes(length: 12);
      final secretKey = SecretKey(keyBytes);
      final secretBox = await _algorithm.encrypt(
        message,
        secretKey: secretKey,
        nonce: nonce,
      );
      return <int>[
        ...secretBox.nonce,
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ];
    } catch (e) {
      throw EncryptionFailure(message: 'Ошибка шифрования поля: $e');
    }
  }

  /// Расшифровывает поле, зашифрованное `encryptFieldWithKey`.
  Future<List<int>> decryptFieldWithKey({
    required List<int> blob,
    required List<int> keyBytes,
  }) async {
    if (blob.length < 12 + 16) {
      throw const EncryptionFailure(message: 'Слишком короткий BLOB поля');
    }
    try {
      final nonce = blob.sublist(0, 12);
      final cipherText = blob.sublist(12, blob.length - 16);
      final mac = Mac(blob.sublist(blob.length - 16));
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
      final secretKey = SecretKey(keyBytes);
      return await _algorithm.decrypt(secretBox, secretKey: secretKey);
    } catch (e) {
      throw EncryptionFailure(message: 'Ошибка дешифрования поля: $e');
    }
  }
}
