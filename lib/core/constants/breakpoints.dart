/// Брейкпоинты для адаптивной вёрстки
///
/// Определяет контрольные ширины экрана для переключения макетов
/// согласно ТЗ (Раздел 3.1)
class Breakpoints {
  const Breakpoints._();

  /// Максимальная ширина для мобильного устройства (<600dp)
  static const double mobileMax = 600;

  /// Минимальная ширина для планшета (≥600dp)
  static const double tabletMin = 600;

  /// Минимальная ширина для десктопа (≥900dp)
  static const double desktopMin = 900;

  /// Минимальная ширина для широкоформатного экрана (≥1200dp)
  static const double wideMin = 1200;
}

/// Расширение для определения типа устройства
extension BreakpointExtension on double {
  /// Мобильное устройство (<600dp)
  bool get isMobile => this < Breakpoints.mobileMax;

  /// Планшет (600-900dp)
  bool get isTablet =>
      this >= Breakpoints.tabletMin && this < Breakpoints.desktopMin;

  /// Десктоп (900-1200dp)
  bool get isDesktop =>
      this >= Breakpoints.desktopMin && this < Breakpoints.wideMin;

  /// Широкоформатный экран (>1200dp)
  bool get isWide => this >= Breakpoints.wideMin;

  /// Планшет или больше (≥600dp)
  bool get isTabletOrLarger => this >= Breakpoints.tabletMin;

  /// Десктоп или больше (≥900dp)
  bool get isDesktopOrLarger => this >= Breakpoints.desktopMin;
}
