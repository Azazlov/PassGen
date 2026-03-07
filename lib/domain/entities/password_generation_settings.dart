/// Настройки генерации пароля
class PasswordGenerationSettings {
  final int strength;
  final List<int> lengthRange;
  final int flags;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigits;
  final bool requireSymbols;
  final bool allUnique;
  final bool excludeSimilar; // Исключать похожие символы (1, l, I, O, 0)
  final String? customCharacters; // Пользовательские символы
  
  // Флаги для пользовательских наборов символов
  final bool useCustomLowercase; // Использовать строчные
  final bool useCustomUppercase; // Использовать заглавные
  final bool useCustomDigits;    // Использовать цифры
  final bool useCustomSymbols;   // Использовать спецсимволы

  const PasswordGenerationSettings({
    this.strength = 2,
    this.lengthRange = const [8, 14],
    this.flags = 0,
    this.requireUppercase = false,
    this.requireLowercase = false,
    this.requireDigits = false,
    this.requireSymbols = false,
    this.allUnique = false,
    this.excludeSimilar = false,
    this.customCharacters,
    this.useCustomLowercase = true,
    this.useCustomUppercase = true,
    this.useCustomDigits = true,
    this.useCustomSymbols = true,
  });

  PasswordGenerationSettings copyWith({
    int? strength,
    List<int>? lengthRange,
    int? flags,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireDigits,
    bool? requireSymbols,
    bool? allUnique,
    bool? excludeSimilar,
    String? customCharacters,
    bool? useCustomLowercase,
    bool? useCustomUppercase,
    bool? useCustomDigits,
    bool? useCustomSymbols,
  }) {
    return PasswordGenerationSettings(
      strength: strength ?? this.strength,
      lengthRange: lengthRange ?? this.lengthRange,
      flags: flags ?? this.flags,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireDigits: requireDigits ?? this.requireDigits,
      requireSymbols: requireSymbols ?? this.requireSymbols,
      allUnique: allUnique ?? this.allUnique,
      excludeSimilar: excludeSimilar ?? this.excludeSimilar,
      customCharacters: customCharacters ?? this.customCharacters,
      useCustomLowercase: useCustomLowercase ?? this.useCustomLowercase,
      useCustomUppercase: useCustomUppercase ?? this.useCustomUppercase,
      useCustomDigits: useCustomDigits ?? this.useCustomDigits,
      useCustomSymbols: useCustomSymbols ?? this.useCustomSymbols,
    );
  }

  @override
  String toString() => 'PasswordGenerationSettings(strength: $strength, length: $lengthRange, excludeSimilar: $excludeSimilar)';
}
