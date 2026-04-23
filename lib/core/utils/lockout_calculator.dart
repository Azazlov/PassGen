import 'dart:math';

/// Калькулятор прогрессивной блокировки PIN по сериям неудачных попыток.
///
/// Формула: delay = min(base * growth^(seriesIndex - 1), max)
///
/// Поведение:
/// - Серия 1 (5 неудач) → 30 сек
/// - Серия 2 (10 неудач) → 3 мин
/// - Серия 3 → 18 мин
/// - Серия 4 → ≈ 1.8 ч
/// - Серия 5 → ≈ 10.8 ч
/// - Серия 6+ → 7 суток (потолок)
class LockoutCalculator {
  const LockoutCalculator._();

  /// Базовая задержка первой серии (секунды)
  static const int baseLockoutSeconds = 30;

  /// Коэффициент роста между сериями
  static const double growthFactor = 6.0;

  /// Максимальная задержка — 7 суток (секунды)
  static const int maxLockoutSeconds = 7 * 24 * 3600;

  /// Количество неудачных попыток в одной серии
  static const int attemptsPerSeries = 5;

  /// Вычисляет задержку блокировки по индексу серии.
  ///
  /// [seriesIndex] — номер серии (1 = первая блокировка после 5 неудач).
  /// При seriesIndex <= 0 возвращает Duration.zero.
  static Duration calculateDelay(int seriesIndex) {
    if (seriesIndex <= 0) return Duration.zero;
    final seconds = (baseLockoutSeconds * pow(growthFactor, seriesIndex - 1)).toInt();
    return Duration(seconds: min(seconds, maxLockoutSeconds));
  }

  /// Возвращает количество неудачных попыток, необходимых для активации
  /// блокировки с учётом текущей серии.
  ///
  /// Например, при seriesIndex = 0 (нет серий) требуется 5 попыток.
  static int attemptsNeededForLockout(int seriesIndex) {
    return attemptsPerSeries;
  }

  /// Форматирует задержку в человекочитаемую строку.
  static String formatDelay(Duration delay) {
    if (delay.inDays > 0) {
      return '${delay.inDays} д ${delay.inHours.remainder(24)} ч';
    } else if (delay.inHours > 0) {
      return '${delay.inHours} ч ${delay.inMinutes.remainder(60)} мин';
    } else if (delay.inMinutes > 0) {
      return '${delay.inMinutes} мин ${delay.inSeconds.remainder(60)} сек';
    } else {
      return '${delay.inSeconds} сек';
    }
  }
}
