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

  const PasswordGenerationSettings({
    this.strength = 2,
    this.lengthRange = const [8, 14],
    this.flags = 0,
    this.requireUppercase = false,
    this.requireLowercase = false,
    this.requireDigits = false,
    this.requireSymbols = false,
    this.allUnique = false,
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
    );
  }

  @override
  String toString() => 'PasswordGenerationSettings(strength: $strength, length: $lengthRange)';
}
