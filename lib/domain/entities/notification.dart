/// Тип уведомления
enum NotificationType {
  /// Предупреждение о слабом пароле
  weakPassword,

  /// Предупреждение о повторяющемся пароле
  duplicatePassword,

  /// Предупреждение о старом пароле
  oldPassword,

  /// Информация об успешном действии
  success,

  /// Ошибка
  error,

  /// Предупреждение безопасности
  securityWarning,
}

/// Уведомление для пользователя
class Notification {
  // URL для действия (если применимо)

  /// Создаёт уведомление о слабом пароле
  factory Notification.weakPassword({
    required String service,
    required int entryId,
    required String details,
  }) {
    return Notification(
      id: 'weak_pwd_$entryId${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.weakPassword,
      title: 'Слабый пароль',
      message: 'Пароль для сервиса "$service" недостаточно надёжен. $details',
      entryId: entryId,
      service: service,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление о повторяющемся пароле
  factory Notification.duplicatePassword({
    required String service,
    required int entryId,
    required String duplicateService,
  }) {
    return Notification(
      id: 'dup_pwd_$entryId${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.duplicatePassword,
      title: 'Повторяющийся пароль',
      message:
          'Пароль для сервиса "$service" совпадает с паролем для "$duplicateService"',
      entryId: entryId,
      service: service,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление о старом пароле
  factory Notification.oldPassword({
    required String service,
    required int entryId,
    required int daysOld,
  }) {
    return Notification(
      id: 'old_pwd_$entryId${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.oldPassword,
      title: 'Старый пароль',
      message: 'Пароль для сервиса "$service" не обновлялся $daysOld дней',
      entryId: entryId,
      service: service,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление об успехе
  factory Notification.success({
    required String title,
    required String message,
  }) {
    return Notification(
      id: 'success_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.success,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление об ошибке
  factory Notification.error({required String title, required String message}) {
    return Notification(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.error,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление о безопасности
  factory Notification.securityWarning({
    required String title,
    required String message,
    int? entryId,
    String? service,
  }) {
    return Notification(
      id: 'security_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.securityWarning,
      title: title,
      message: message,
      entryId: entryId,
      service: service,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт уведомление из JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      type: NotificationType.values[json['type'] as int],
      title: json['title'] as String,
      message: json['message'] as String,
      entryId: json['entry_id'] as int?,
      service: json['service'] as String?,
      isRead: (json['is_read'] as int?) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      actionUrl: json['action_url'] as String?,
    );
  }
  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.entryId,
    this.service,
    this.isRead = false,
    required this.createdAt,
    this.actionUrl,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final int? entryId; // Связь с записью пароля (если применимо)
  final String? service; // Название сервиса (если применимо)
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl;

  /// Создаёт копию уведомления с обновлёнными данными
  Notification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    int? entryId,
    String? service,
    bool? isRead,
    DateTime? createdAt,
    String? actionUrl,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      entryId: entryId ?? this.entryId,
      service: service ?? this.service,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Преобразует уведомление в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'message': message,
      if (entryId != null) 'entry_id': entryId,
      if (service != null) 'service': service,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      if (actionUrl != null) 'action_url': actionUrl,
    };
  }

  @override
  String toString() =>
      'Notification(id: $id, type: $type, title: $title, service: $service)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
