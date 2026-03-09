/// Система отступов и сетка
///
/// Все отступы кратны 4dp (предпочтительно 8dp)
/// согласно ТЗ (Раздел 2.4)
library;

import 'package:flutter/material.dart';

class Spacing {
  const Spacing._();

  /// Очень маленький отступ (4dp)
  static const double xs = 4.0;

  /// Маленький отступ (8dp)
  static const double sm = 8.0;

  /// Средний отступ (16dp)
  static const double md = 16.0;

  /// Большой отступ (24dp)
  static const double lg = 24.0;

  /// Очень большой отступ (32dp)
  static const double xl = 32.0;

  /// Экстра большой отступ (48dp)
  static const double xxl = 48.0;
}

/// Расширения для удобного создания EdgeInsets
extension SpacingExtension on num {
  /// Все отступы равны значению
  EdgeInsets get all => EdgeInsets.all(toDouble());

  /// Симметричные отступы (вертикальные и горизонтальные)
  EdgeInsets get symmetric =>
      EdgeInsets.symmetric(vertical: toDouble(), horizontal: toDouble());

  /// Только вертикальные отступы
  EdgeInsets get vertical =>
      EdgeInsets.only(top: toDouble(), bottom: toDouble());

  /// Только горизонтальные отступы
  EdgeInsets get horizontal =>
      EdgeInsets.only(left: toDouble(), right: toDouble());
}

/// Утилиты для работы с отступами
class SpacingUtils {
  /// Отступ между элементами списка
  static EdgeInsets listPadding = const EdgeInsets.all(Spacing.md);

  /// Отступ для карточек
  static EdgeInsets cardPadding = const EdgeInsets.all(Spacing.md);

  /// Отступ для кнопок
  static EdgeInsets buttonPadding = const EdgeInsets.symmetric(
    horizontal: Spacing.lg,
    vertical: Spacing.md,
  );

  /// Отступ для полей ввода
  static EdgeInsets inputPadding = const EdgeInsets.all(Spacing.md);
}
