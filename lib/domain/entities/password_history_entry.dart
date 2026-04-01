/// Запись истории изменений пароля
/// 
/// Сохраняет предыдущие версии паролей для возможности отката
/// или аудита изменений
class PasswordHistoryEntry {
  const PasswordHistoryEntry({
    this.id,
    required this.entryId,
    required this.service,
    required this.encryptedPassword,
    required this.nonce,
    required this.config,
    this.login,
    required this.createdAt,
    this.reason,
  });

  /// Создаёт PasswordHistoryEntry из JSON
  factory PasswordHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PasswordHistoryEntry(
      id: json['id'] as int?,
      entryId: json['entry_id'] as int,
      service: json['service'] ?? '',
      encryptedPassword: json['encrypted_password'] ?? '',
      nonce: json['nonce'] ?? '',
      config: json['config'] ?? '',
      login: json['login'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      reason: json['reason'] as String?,
    );
  }

  final int? id;
  final int entryId;  // Ссылка на текущую запись PasswordEntry
  final String service;
  final String encryptedPassword;  // Зашифрованный пароль (Base64)
  final String nonce;  // Nonce для шифрования (Base64)
  final String config;  // Конфигурация генерации
  final String? login;
  final DateTime createdAt;
  final String? reason;  // Причина изменения (например, "Плановая смена", "Компрометация")

  /// Преобразует PasswordHistoryEntry в JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'entry_id': entryId,
      'service': service,
      'encrypted_password': encryptedPassword,
      'nonce': nonce,
      'config': config,
      if (login != null) 'login': login,
      'created_at': createdAt.toIso8601String(),
      if (reason != null) 'reason': reason,
    };
  }

  /// Создаёт копию записи с обновлёнными данными
  PasswordHistoryEntry copyWith({
    int? id,
    int? entryId,
    String? service,
    String? encryptedPassword,
    String? nonce,
    String? config,
    String? login,
    DateTime? createdAt,
    String? reason,
  }) {
    return PasswordHistoryEntry(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      service: service ?? this.service,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      nonce: nonce ?? this.nonce,
      config: config ?? this.config,
      login: login ?? this.login,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
    );
  }

  @override
  String toString() =>
      'PasswordHistoryEntry(entryId: $entryId, service: $service, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordHistoryEntry &&
        other.entryId == entryId &&
        other.encryptedPassword == encryptedPassword &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => entryId.hashCode ^ createdAt.hashCode;
}
