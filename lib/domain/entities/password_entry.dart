import 'dart:convert';

/// Запись о сохранённом пароле
class PasswordEntry {
  final String service;
  final String password;
  final String config;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PasswordEntry({
    required this.service,
    required this.password,
    required this.config,
    required this.createdAt,
    this.updatedAt,
  });

  /// Создаёт PasswordEntry из JSON
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      service: json['service'] ?? '',
      password: json['password'] ?? '',
      config: json['config'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Преобразует PasswordEntry в JSON
  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'password': password,
      'config': config,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Создаёт копию записи с обновлёнными данными
  PasswordEntry copyWith({
    String? service,
    String? password,
    String? config,
    DateTime? updatedAt,
  }) {
    return PasswordEntry(
      service: service ?? this.service,
      password: password ?? this.password,
      config: config ?? this.config,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Преобразует список PasswordEntry в JSON строку
  static String encodeList(List<PasswordEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  /// Преобразует JSON строку в список PasswordEntry
  static List<PasswordEntry> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => PasswordEntry.fromJson(e)).toList();
  }

  /// Проверяет, существует ли уже запись с таким сервисом
  static bool existsForService(List<PasswordEntry> entries, String service) {
    return entries.any((e) => e.service.toLowerCase() == service.toLowerCase());
  }

  /// Проверяет, существует ли уже запись с таким паролем
  static bool existsForPassword(List<PasswordEntry> entries, String password) {
    return entries.any((e) => e.password == password);
  }

  /// Проверяет, существует ли уже запись с таким сервисом и паролем
  static bool existsForServiceAndPassword(List<PasswordEntry> entries, String service, String password) {
    return entries.any((e) => 
      e.service.toLowerCase() == service.toLowerCase() && e.password == password
    );
  }

  /// Находит запись по сервису
  static PasswordEntry? findByService(List<PasswordEntry> entries, String service) {
    try {
      return entries.firstWhere(
        (e) => e.service.toLowerCase() == service.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'PasswordEntry(service: $service, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntry &&
        other.service == service &&
        other.password == password &&
        other.config == config;
  }

  @override
  int get hashCode => service.hashCode ^ password.hashCode ^ config.hashCode;
}
