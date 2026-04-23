/// Результат глитчирования текста
class GlitchResult {
  const GlitchResult({
    required this.originalText,
    required this.glitchedPassword,
    required this.strength,
    required this.strengthLabel,
    required this.appliedRules,
  });

  final String originalText;
  final String glitchedPassword;
  final double strength;
  final String strengthLabel;
  final Map<String, dynamic> appliedRules;

  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'glitchedPassword': glitchedPassword,
      'strength': strength,
      'strengthLabel': strengthLabel,
      'appliedRules': appliedRules,
    };
  }

  @override
  String toString() =>
      'GlitchResult(strength: $strength, label: $strengthLabel)';
}
