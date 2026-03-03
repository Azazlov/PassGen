/// Константы флагов для категорий символов в пароле
class PasswordFlags {
  const PasswordFlags._();

  // Базовые флаги категорий
  static const int digits = 1 << 0;           // 1
  static const int digitsRequired = 1 << 1;   // 2
  static const int lowercase = 1 << 2;        // 4
  static const int lowercaseRequired = 1 << 3; // 8
  static const int uppercase = 1 << 4;        // 16
  static const int uppercaseRequired = 1 << 5; // 32
  static const int symbols = 1 << 6;          // 64
  static const int symbolsRequired = 1 << 7;  // 128
  static const int allUnique = 1 << 8;        // 256

  // Предустановленные конфигурации флагов по уровням сложности
  static const Map<int, int> strengthFlags = {
    0: digits,                                    // Очень слабый
    1: digits | lowercase,                        // Слабый
    2: digits | lowercase | uppercase,            // Средний
    3: digits | lowercase | uppercase | symbols,  // Сильный
    4: digits | lowercase | uppercase | symbols | allUnique, // Очень сильный
  };

  // Диапазоны длин паролей по уровням сложности
  static const Map<int, List<int>> strengthLengthRanges = {
    0: [4, 6],
    1: [6, 8],
    2: [8, 14],
    3: [14, 20],
    4: [20, 32],
  };

  // Метки уровней сложности
  static const Map<int, String> strengthLabels = {
    0: 'Очень слабый',
    1: 'Слабый',
    2: 'Средний',
    3: 'Сильный',
    4: 'Очень сильный',
  };
}

/// Константы приложения
class AppConstants {
  const AppConstants._();

  static const String appName = 'PassGen';
  static const String appVersion = '0.3.2';
  static const String developer = '@Azazlov';
  
  // Ключи хранилища
  static const String passwordConfigsKey = 'psswdGen';
  static const String encryptorConfigsKey = 'endecrypter';
  static const String masterPasswordKey = 'master_password';
  
  // Настройки по умолчанию
  static const int defaultExpireDays = 30;
  static const int defaultPasswordStrength = 2;
  static const String defaultCategory = 'None';
  static const String defaultService = 'None';
}
