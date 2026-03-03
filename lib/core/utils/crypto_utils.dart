import 'dart:convert';

/// Утилиты для кодирования/декодирования Base64
class CryptoUtils {
  const CryptoUtils._();

  /// Кодирует строку в Base64
  static String encodeBase64(String text) {
    return base64Encode(utf8.encode(text));
  }

  /// Декодирует строку из Base64
  static String decodeBase64(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  /// Кодирует байты в Base64
  static String encodeBytesBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  /// Декодирует байты из Base64
  static List<int> decodeBytesBase64(String encoded) {
    return base64Decode(encoded);
  }
}
