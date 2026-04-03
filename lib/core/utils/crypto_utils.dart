import 'dart:convert';
import 'dart:math';

/// Утилиты для криптографических операций
class CryptoUtils {
  const CryptoUtils._();

  // ==================== BASE64 ====================

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

  // ==================== URL-SAFE BASE64 ====================

  /// Кодирует байты в URL-safe Base64 (RFC 4648)
  ///
  /// Заменяет '+' на '-' и '/' на '_' для безопасного использования в URL
  /// Удаляет символы заполнения '='
  static String encodeBytesBase64Url(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Декодирует байты из URL-safe Base64
  ///
  /// Автоматически восстанавливает padding при необходимости
  static List<int> decodeBytesBase64Url(String encoded) {
    // Восстанавливаем padding
    final padded = encoded.padRight(
      encoded.length + (4 - encoded.length % 4) % 4,
      '=',
    );
    // Заменяем URL-safe символы обратно на стандартные
    final normalized = padded.replaceAll('-', '+').replaceAll('_', '/');
    return base64Decode(normalized);
  }

  /// Кодирует строку в URL-safe Base64
  static String encodeBase64Url(String text) {
    return encodeBytesBase64Url(utf8.encode(text));
  }

  /// Декодирует строку из URL-safe Base64
  static String decodeBase64Url(String encoded) {
    return utf8.decode(decodeBytesBase64Url(encoded));
  }

  // ==================== БЕЗОПАСНОЕ ЗАТИРАНИЕ ====================

  /// Безопасно затирает чувствительные данные из памяти
  ///
  /// Использует многократную перезапись для защиты от:
  /// - Cold boot атак
  /// - Дампа памяти
  /// - Остаточных данных в RAM
  ///
  /// Алгоритм затирания:
  /// 1. Заполнение случайными данными
  /// 2. Заполнение нулями
  /// 3. Заполнение единицами (0xFF)
  /// 4. Финальные нули
  ///
  /// [data] - чувствительные данные для затирания
  static void secureWipeData(List<int> data) {
    if (data.isEmpty) return;

    final random = Random.secure();

    // Шаг 1: Заполнение случайными данными
    for (int i = 0; i < data.length; i++) {
      data[i] = random.nextInt(256);
    }

    // Шаг 2: Заполнение нулями
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }

    // Шаг 3: Заполнение единицами (0xFF)
    for (int i = 0; i < data.length; i++) {
      data[i] = 0xFF;
    }

    // Шаг 4: Финальные нули
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// Затирание ключа шифрования
  ///
  /// Алиас для [secureWipeData] с более семантическим именем
  static void secureWipeKey(List<int> key) {
    secureWipeData(key);
  }

  /// Затирание пароля
  ///
  /// Алиас для [secureWipeData] с более семантическим именем
  static void secureWipePassword(List<int> password) {
    secureWipeData(password);
  }

  // ==================== CONSTANT-TIME СРАВНЕНИЕ ====================

  /// Constant-time сравнение двух массивов байтов
  ///
  /// Защищено от timing attacks:
  /// - Время выполнения не зависит от данных
  /// - Нет раннего выхода при несовпадении
  /// - Все байты сравниваются всегда
  ///
  /// [a] - первый массив
  /// [b] - второй массив
  /// Возвращает `true` если массивы идентичны
  static bool constantTimeEquals(List<int> a, List<int> b) {
    // Используем максимальную длину для constant-time сравнения
    final maxLen = a.length > b.length ? a.length : b.length;
    
    int result = 0;
    for (int i = 0; i < maxLen; i++) {
      // Безопасный доступ: используем 0 для выходящих за границы индексов
      final byteA = i < a.length ? a[i] : 0;
      final byteB = i < b.length ? b[i] : 0;
      result |= byteA ^ byteB;
    }
    
    // Если длины разные, результат всегда false
    if (a.length != b.length) {
      return false;
    }

    return result == 0;
  }

  /// Constant-time сравнение Base64 строк
  ///
  /// Декодирует строки и сравнивает байты
  static bool constantTimeEqualsBase64(String a, String b) {
    final bytesA = base64Decode(a);
    final bytesB = base64Decode(b);
    return constantTimeEquals(bytesA, bytesB);
  }

  // ==================== ГЕНЕРАЦИЯ СЛУЧАЙНЫХ ДАННЫХ ====================

  /// Генерирует криптографически стойкие случайные байты
  ///
  /// [length] - количество байт
  static List<int> generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }

  /// Генерирует случайный nonce заданной длины
  ///
  /// [length] - длина nonce (по умолчанию 32 байта)
  static List<int> generateSecureNonce({int length = 32}) {
    return generateSecureRandomBytes(length);
  }

  /// Генерирует случайную соль для PBKDF2
  ///
  /// [length] - длина соли (по умолчанию 32 байта)
  static List<int> generateSecureSalt({int length = 32}) {
    return generateSecureRandomBytes(length);
  }
}
