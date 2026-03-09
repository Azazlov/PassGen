/// Модель конфигурации пароля для базы данных
class PasswordConfigModel {
  const PasswordConfigModel({
    this.id,
    this.entryId,
    this.strength,
    this.minLength,
    this.maxLength,
    this.flags,
    this.requireUnique = false,
    this.encryptedConfig,
  });

  /// Создание из Map (SQLite)
  factory PasswordConfigModel.fromMap(Map<String, dynamic> map) {
    return PasswordConfigModel(
      id: map['id'] as int?,
      entryId: map['entry_id'] as int?,
      strength: map['strength'] as int?,
      minLength: map['min_length'] as int?,
      maxLength: map['max_length'] as int?,
      flags: map['flags'] as int?,
      requireUnique: (map['require_unique'] as int?) == 1,
      encryptedConfig: map['encrypted_config'] as List<int>?,
    );
  }
  final int? id;
  final int? entryId;
  final int? strength;
  final int? minLength;
  final int? maxLength;
  final int? flags;
  final bool requireUnique;
  final List<int>? encryptedConfig;

  /// Преобразование в Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (strength != null) 'strength': strength,
      if (minLength != null) 'min_length': minLength,
      if (maxLength != null) 'max_length': maxLength,
      if (flags != null) 'flags': flags,
      'require_unique': requireUnique ? 1 : 0,
      if (encryptedConfig != null) 'encrypted_config': encryptedConfig,
    };
  }

  /// Копия с изменениями
  PasswordConfigModel copyWith({
    int? id,
    int? entryId,
    int? strength,
    int? minLength,
    int? maxLength,
    int? flags,
    bool? requireUnique,
    List<int>? encryptedConfig,
  }) {
    return PasswordConfigModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      strength: strength ?? this.strength,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      flags: flags ?? this.flags,
      requireUnique: requireUnique ?? this.requireUnique,
      encryptedConfig: encryptedConfig ?? this.encryptedConfig,
    );
  }

  @override
  String toString() {
    return 'PasswordConfigModel(id: $id, entryId: $entryId, strength: $strength, '
        'minLength: $minLength, maxLength: $maxLength, requireUnique: $requireUnique)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordConfigModel &&
        other.id == id &&
        other.entryId == entryId;
  }

  @override
  int get hashCode => id.hashCode ^ entryId.hashCode;
}
