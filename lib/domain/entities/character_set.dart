/// Набор символов для генерации пароля
class CharacterSet {
  /// Метка набора (например, "Строчные", "Цифры")
  final String label;

  /// Краткое описание (например, "a-z", "0-9")
  final String subtitle;

  /// Символы набора
  final String characters;

  /// Количество символов
  final int count;

  /// Включён ли набор
  final bool isEnabled;

  const CharacterSet({
    required this.label,
    required this.subtitle,
    required this.characters,
    required this.count,
    required this.isEnabled,
  });

  /// Исключить похожие символы (l, 1, I, O, 0)
  CharacterSet excludeSimilar() {
    final similar = {'l', '1', 'I', 'O', '0'};
    final filtered = characters.split('').where((c) => !similar.contains(c)).join();
    return CharacterSet(
      label: label,
      subtitle: subtitle,
      characters: filtered,
      count: filtered.length,
      isEnabled: isEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          subtitle == other.subtitle &&
          characters == other.characters &&
          count == other.count &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode => Object.hash(label, subtitle, characters, count, isEnabled);
}
