/// Модель лога безопасности для базы данных
class SecurityLogModel {
  const SecurityLogModel({
    this.id,
    this.profileId,
    required this.actionType,
    required this.timestamp,
    this.details,
  });

  /// Создание из Map (SQLite)
  factory SecurityLogModel.fromMap(Map<String, dynamic> map) {
    return SecurityLogModel(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      actionType: map['action_type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      details: map['details'] as String?,
    );
  }
  final int? id;
  final int? profileId;
  final String actionType;
  final DateTime timestamp;
  final String? details;

  /// Преобразование в Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      'action_type': actionType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (details != null) 'details': details,
    };
  }

  /// Копия с изменениями
  SecurityLogModel copyWith({
    int? id,
    int? profileId,
    String? actionType,
    DateTime? timestamp,
    String? details,
  }) {
    return SecurityLogModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      actionType: actionType ?? this.actionType,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
    );
  }

  @override
  String toString() {
    return 'SecurityLogModel(id: $id, profileId: $profileId, actionType: $actionType, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityLogModel &&
        other.id == id &&
        other.profileId == profileId &&
        other.actionType == actionType &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      id.hashCode ^ profileId.hashCode ^ actionType.hashCode ^ timestamp.hashCode;
}
