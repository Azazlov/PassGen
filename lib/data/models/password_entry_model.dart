/// Модель записи пароля для базы данных
class PasswordEntryModel {
  const PasswordEntryModel({
    this.id,
    this.categoryId,
    required this.service,
    this.login,
    required this.encryptedPassword,
    required this.nonce,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создание из Map (SQLite)
  factory PasswordEntryModel.fromMap(Map<String, dynamic> map) {
    return PasswordEntryModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int?,
      service: map['service'] as String,
      login: map['login'] as String?,
      encryptedPassword: map['encrypted_password'] as List<int>? ?? [],
      nonce: map['nonce'] as List<int>? ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
  final int? id;
  final int? categoryId;
  final String service;
  final String? login;
  final List<int> encryptedPassword;
  final List<int> nonce;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Преобразование в Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      'service': service,
      if (login != null) 'login': login,
      'encrypted_password': encryptedPassword,
      'nonce': nonce,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Копия с изменениями
  PasswordEntryModel copyWith({
    int? id,
    int? categoryId,
    String? service,
    String? login,
    List<int>? encryptedPassword,
    List<int>? nonce,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordEntryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      service: service ?? this.service,
      login: login ?? this.login,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      nonce: nonce ?? this.nonce,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PasswordEntryModel(id: $id, service: $service, login: $login, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntryModel &&
        other.id == id &&
        other.service == service &&
        other.login == login &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode =>
      id.hashCode ^ service.hashCode ^ login.hashCode ^ categoryId.hashCode;
}
