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
  if (password.isEmpty) return 0.0;

  // 1. ЗАЩИТНЫЙ БАРЬЕР (Short-circuit)
  // Если пароль состоит только из цифр и он достаточно длинный
  // (20+ символов), zxcvbn "сходит с ума". 
  // Для безопасности 20 цифр — это уже очень много энтропии.
  final onlyDigits = RegExp(r'^\d+$').hasMatch(password);
  
  if (onlyDigits && password.length >= 20) {
    // Возвращаем фиксированную высокую оценку для длинных цифровых паролей
    // 0.8 — это "сильный", но не "идеальный" (так как нет спецсимволов)
    return 0.8; 
  }

  // 2. ОГРАНИЧЕНИЕ ДЛИНЫ ДЛЯ ВСЕХ ТИПОВ
  // Даже если там не только цифры, zxcvbn не стоит кормить строками > 64 симв.
  String analysisInput = password.length > 64 
      ? password.substring(0, 64) 
      : password;

  try {
    // 3. Оценка через zxcvbn
    final zxcvbnResult = Zxcvbn().evaluate(analysisInput);
    final zxcvbnScore = (zxcvbnResult.score ?? 0) / 4.0;

    // 4. Ваша эвристика (она обычно быстрая)
    final heuristicScore = estimatePasswordStrength(password);

    return 0.8 * zxcvbnScore + 0.2 * heuristicScore;
  } catch (e) {
    // Если всё же произошла ошибка в библиотеке, возвращаем эвристику
    return estimatePasswordStrength(password);
  }
}