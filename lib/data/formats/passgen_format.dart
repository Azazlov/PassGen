import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Фирменный формат файла PassGen (.passgen)
/// 
/// Структура файла:
/// - HEADER: "PASSGEN_V1" (10 байт)
/// - VERSION: версия формата (1 байт)
/// - FLAGS: флаги (1 байт)
/// - NONCE: nonce для шифрования (32 байта)
/// - DATA_LENGTH: длина зашифрованных данных (4 байта)
/// - DATA: зашифрованные JSON данные
/// - MAC: authentication tag (16 байт)
class PassgenFormat {
  static const String magicHeader = 'PASSGEN_V1';
  static const int formatVersion = 1;
  static const int flagsNone = 0;

  PassgenFormat();

  /// Экспорт данных в формат .passgen
  /// 
  /// [data] - данные для экспорта (список паролей)
  /// [masterPassword] - мастер-пароль для шифрования
  /// Возвращает Base64 строку с данными в формате .passgen
  Future<String> exportToJson({
    required List<Map<String, dynamic>> data,
    required String masterPassword,
  }) async {
    try {
      // Сериализуем данные в JSON
      final jsonData = jsonEncode(data);
      final jsonDataBytes = utf8.encode(jsonData);

      // Генерируем nonce
      final random = Random.secure();
      final nonce = List<int>.generate(32, (_) => random.nextInt(256));

      // Создаём ключ шифрования
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 10000,
        bits: 256,
      );

      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: masterPassword,
        nonce: Uint8List.fromList(nonce),
      );

      // Шифруем данные
      final algorithm = Chacha20.poly1305Aead();
      final secretBox = await algorithm.encrypt(
        jsonDataBytes,
        secretKey: secretKey,
      );

      // Формируем структуру файла
      final headerBytes = utf8.encode(magicHeader); // 10 байт
      final versionBytes = [formatVersion]; // 1 байт
      final flagsBytes = [flagsNone]; // 1 байт
      final nonceBytes = nonce; // 32 байта
      final dataLengthBytes = _intToBytes(secretBox.cipherText.length); // 4 байта
      final cipherTextBytes = secretBox.cipherText;
      final macBytes = secretBox.mac.bytes; // 16 байт

      // Объединяем все части
      final allBytes = <int>[
        ...headerBytes,
        ...versionBytes,
        ...flagsBytes,
        ...nonceBytes,
        ...dataLengthBytes,
        ...cipherTextBytes,
        ...macBytes,
      ];

      // Возвращаем Base64 строку
      return base64Encode(allBytes);
    } catch (e) {
      throw PassgenFormatException('Ошибка экспорта: $e');
    }
  }

  /// Импорт данных из формата .passgen
  /// 
  /// [base64Data] - Base64 строка с данными в формате .passgen
  /// [masterPassword] - мастер-пароль для дешифрования
  /// Возвращает список распарсенных данных
  Future<List<Map<String, dynamic>>> importFromJson({
    required String base64Data,
    required String masterPassword,
  }) async {
    try {
      // Декодируем Base64
      final allBytes = base64Decode(base64Data);

      // Парсим структуру файла
      var offset = 0;

      // HEADER (10 байт)
      final headerBytes = allBytes.sublist(offset, offset + 10);
      final header = utf8.decode(headerBytes);
      offset += 10;

      if (header != magicHeader) {
        throw PassgenFormatException('Неверный формат файла: $header');
      }

      // VERSION (1 байт)
      final version = allBytes[offset];
      offset += 1;

      if (version != formatVersion) {
        throw PassgenFormatException('Неподдерживаемая версия: $version');
      }

      // FLAGS (1 байт)
      final flags = allBytes[offset];
      offset += 1;

      // NONCE (32 байта)
      final nonce = allBytes.sublist(offset, offset + 32);
      offset += 32;

      // DATA_LENGTH (4 байта)
      final dataLength = _bytesToInt(allBytes.sublist(offset, offset + 4));
      offset += 4;

      // CIPHER_TEXT (dataLength байт)
      final cipherText = allBytes.sublist(offset, offset + dataLength);
      offset += dataLength;

      // MAC (16 байт)
      final macBytes = allBytes.sublist(offset, offset + 16);

      // Создаём ключ дешифрования
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 10000,
        bits: 256,
      );

      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: masterPassword,
        nonce: Uint8List.fromList(nonce),
      );

      // Дешифруем данные
      final algorithm = Chacha20.poly1305Aead();
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      // Парсим JSON
      final jsonData = utf8.decode(decryptedBytes);
      final data = jsonDecode(jsonData) as List<dynamic>;

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is PassgenFormatException) rethrow;
      throw PassgenFormatException('Ошибка импорта: $e');
    }
  }

  /// Преобразует int в 4 байта (little-endian)
  List<int> _intToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  /// Преобразует 4 байта в int (little-endian)
  int _bytesToInt(List<int> bytes) {
    return bytes[0] |
        (bytes[1] << 8) |
        (bytes[2] << 16) |
        (bytes[3] << 24);
  }
}

/// Ошибка формата PassGen
class PassgenFormatException implements Exception {
  final String message;

  PassgenFormatException(this.message);

  @override
  String toString() => 'PassgenFormatException: $message';
}
