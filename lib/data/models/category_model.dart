/// Модель категории для базы данных
class CategoryModel {
  final int? id;
  final String name;
  final String? icon;
  final bool isSystem;
  final DateTime createdAt;

  const CategoryModel({
    this.id,
    required this.name,
    this.icon,
    this.isSystem = false,
    required this.createdAt,
  });

  /// Создание из Map (SQLite)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      isSystem: (map['is_system'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Преобразование в Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'is_system': isSystem ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Копия с изменениями
  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, isSystem: $isSystem)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.isSystem == isSystem;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.hashCode ^ isSystem.hashCode;
}
