import 'package:password_strength/password_strength.dart';
import 'package:zxcvbn/zxcvbn.dart';

/// Оценивает надёжность пароля по шкале от 0.0 до 1.0.
///
/// Используется комбинация двух методов:
/// - [zxcvbn] — анализирует предсказуемость пароля (оценка от 0 до 4 → нормализуется до 0.0–1.0).
/// - [password_strength] — эвристическая оценка на основе длины, разнообразия символов и т.д.
///
/// Веса: 80% — zxcvbn (более точен), 20% — password_strength (дополнительный сигнал).
double getPasswdStrength(String password) {
  // Быстрый выход для пустых или очень коротких паролей
  if (password.isEmpty) return 0.0;

  // Оценка через zxcvbn (основной метод)
  final zxcvbnResult = Zxcvbn().evaluate(password);
  final zxcvbnScore = (zxcvbnResult.score ?? 0) / 4.0; // Нормализация 0–4 → 0.0–1.0

  // Эвристическая оценка
  final heuristicScore = estimatePasswordStrength(password);

  // Взвешенное среднее
  return 0.8 * zxcvbnScore + 0.2 * heuristicScore;
}