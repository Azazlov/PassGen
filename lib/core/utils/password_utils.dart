import 'package:zxcvbn/zxcvbn.dart';

/// Утилиты для оценки надёжности пароля
class PasswordUtils {
  const PasswordUtils._();

  /// Оценивает надёжность пароля по шкале от 0.0 до 1.0
  ///
  /// Используется комбинация двух методов:
  /// - [zxcvbn] — анализирует предсказуемость пароля (оценка от 0 до 4 → нормализуется до 0.0–1.0)
  /// - [password_strength] — эвристическая оценка на основе длины, разнообразия символов и т.д.
  ///
  /// Веса: 80% — zxcvbn (более точен), 20% — password_strength (дополнительный сигнал)
  static double evaluateStrength(String password) {
    if (password.isEmpty) return 0.0;

    // ЗАЩИТНЫЙ БАРЬЕР (Short-circuit)
    // Если пароль состоит только из цифр и он достаточно длинный (20+ символов)
    final onlyDigits = RegExp(r'^\d+$').hasMatch(password);

    if (onlyDigits && password.length >= 20) {
      return 0.8;
    }

    // ОГРАНИЧЕНИЕ ДЛИНЫ ДЛЯ ВСЕХ ТИПОВ
    // zxcvbn не стоит кормить строками > 64 символов
    final analysisInput = password.length > 64
        ? password.substring(0, 64)
        : password;

    try {
      // Оценка через zxcvbn
      final zxcvbnResult = Zxcvbn().evaluate(analysisInput);
      final zxcvbnScore = (zxcvbnResult.score ?? 0) / 4.0;

      // Эвристика
      final heuristicScore = _estimatePasswordStrength(password);

      return 0.8 * zxcvbnScore + 0.2 * heuristicScore;
    } catch (e) {
      // Если ошибка в библиотеке, возвращаем эвристику
      return _estimatePasswordStrength(password);
    }
  }

  /// Эвристическая оценка надёжности пароля
  static double _estimatePasswordStrength(String password) {
    double score = 0.0;

    // Длина
    if (password.length >= 8) score += 0.2;
    if (password.length >= 12) score += 0.2;
    if (password.length >= 16) score += 0.2;
    if (password.length >= 20) score += 0.2;

    // Разнообразие символов
    if (password.contains(RegExp(r'[a-z]'))) score += 0.05;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.05;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.05;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=[]\;`~]'))) score += 0.1;

    // Уникальность символов
    final uniqueRatio = password.split('').toSet().length / password.length;
    score += uniqueRatio * 0.1;

    return score.clamp(0.0, 1.0);
  }
}
