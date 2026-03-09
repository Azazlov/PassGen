/// Категория для группировки паролей
class Category {
  const Category({
    this.id,
    required this.name,
    this.icon,
    this.isSystem = false,
    required this.createdAt,
  });
  final int? id;
  final String name;
  final String? icon;
  final bool isSystem;
  final DateTime createdAt;

  /// Системные категории по умолчанию
  static final List<Category> systemCategories = [
    Category(
      name: 'Соцсети',
      icon: '👥',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Почта',
      icon: '📧',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Банки',
      icon: '🏦',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Магазины',
      icon: '🛒',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Работа',
      icon: '💼',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Развлечения',
      icon: '🎮',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    Category(
      name: 'Другое',
      icon: '📁',
      isSystem: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  ];

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name, icon: $icon)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
