/// Сущность профиля пользователя
///
/// Каждый профиль — изолированный контекст с собственным PIN,
/// солью и derived_key. Нет общего admin-ключа.
class Profile {
  const Profile({
    this.id,
    required this.name,
    this.avatarEmoji,
    required this.createdAt,
    this.lastAccessedAt,
  });

  /// ID профиля (SQLite auto-increment)
  final int? id;

  /// Отображаемое имя профиля
  final String name;

  /// Emoji-аватарка (опционально)
  final String? avatarEmoji;

  /// Дата создания
  final DateTime createdAt;

  /// Дата последнего доступа
  final DateTime? lastAccessedAt;

  Profile copyWith({
    int? id,
    String? name,
    String? avatarEmoji,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'avatar_emoji': avatarEmoji,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_accessed_at': lastAccessedAt?.millisecondsSinceEpoch,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      name: json['name'] as String,
      avatarEmoji: json['avatar_emoji'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_accessed_at'] as int)
          : null,
    );
  }

  @override
  String toString() => 'Profile(id: $id, name: $name)';
}
