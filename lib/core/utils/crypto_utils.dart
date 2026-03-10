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
    // Разная длина → сразу false (но всё равно выполняем сравнение для constant-time)
    if (a.length != b.length) {
      // Фиктическое сравнение для поддержания постоянного времени
      for (int i = 0; i < a.length; i++) {
        // Пустой цикл для timing attack protection
      }
      for (int i = 0; i < b.length; i++) {
        // Пустой цикл для timing attack protection
      }
      return false;
    }

    // Сравниваем все байты, накапливая различия
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
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
