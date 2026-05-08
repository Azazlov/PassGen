/// Запись лога безопасности
class SecurityLog {
  const SecurityLog({
    this.id,
    this.profileId,
    required this.actionType,
    required this.timestamp,
    this.details,
  });

  /// Создаёт SecurityLog из JSON
  factory SecurityLog.fromJson(Map<String, dynamic> json) {
    return SecurityLog(
      id: json['id'] as int?,
      profileId: json['profile_id'] as int?,
      actionType: json['action_type'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      details: json['details'] as String?,
    );
  }
  final int? id;
  final int? profileId;
  final String actionType;
  final DateTime timestamp;
  final String? details;

  /// Преобразует SecurityLog в JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      'action_type': actionType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (details != null) 'details': details,
    };
  }

  /// Создаёт копию с обновлёнными данными
  SecurityLog copyWith({
    int? id,
    int? profileId,
    String? actionType,
    DateTime? timestamp,
    String? details,
  }) {
    return SecurityLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      actionType: actionType ?? this.actionType,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
    );
  }

  @override
  String toString() => 'SecurityLog(action: $actionType, profile: $profileId, time: $timestamp)';
}
