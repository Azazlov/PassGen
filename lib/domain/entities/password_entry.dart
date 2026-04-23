import 'dart:convert';

/// Запись о сохранённом пароле
class PasswordEntry {
  const PasswordEntry({
    this.id,
    this.profileId,
    this.categoryId,
    required this.service,
    this.password, // ← Теперь необязательный (только для временного хранения)
    this.encryptedPassword, // ← Зашифрованный пароль (Base64)
    this.nonce, // ← Nonce для шифрования (Base64)
    required this.config,
    this.login,
    required this.createdAt,
    this.updatedAt,
  });

  /// Создаёт PasswordEntry из JSON
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as int?,
      profileId: json['profile_id'] as int?,
      categoryId: json['category_id'] as int?,
      service: json['service'] ?? '',
      password: json['password'] as String?, // ← Для обратной совместимости
      encryptedPassword: json['encrypted_password'] as String?,
      nonce: json['nonce'] as String?,
      config: json['config'] ?? '',
      login: json['login'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
  final int? id;
  final int? profileId;
  final int? categoryId;
  final String service;
  final String? password; // ← Открытый пароль (только в RAM, не сохраняется)
  final String? encryptedPassword; // ← Зашифрованный пароль (Base64)
  final String? nonce; // ← Nonce для шифрования (Base64)
  final String config;
  final String? login;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Преобразует PasswordEntry в JSON (только зашифрованные данные!)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (categoryId != null) 'category_id': categoryId,
      'service': service,
      // НИКОГДА не сохраняем открытый пароль!
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (nonce != null) 'nonce': nonce,
      'config': config,
      if (login != null) 'login': login,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Расшифровывает пароль используя мастер-пароль
  ///
  /// [masterPassword] - мастер-пароль пользователя (PIN)
  /// Возвращает расшифрованный пароль или null при ошибке
  ///
  /// Формат: данные сохранены в мини-формате (pbkdf2-nonce + nonceBox + ciphertext + mac)
  Future<String?> decryptPassword(String masterPassword) async {
    if (!isEncrypted) {
      // Если пароль не зашифрован (старые записи), возвращаем как есть
      return password;
    }

    try {
      // Дешифрование требует знания формата и доступа к EncryptorLocalDataSource
      // Этот метод должен быть вынесен в data layer или использовать dependency injection
      // Временное решение: возвращаем null, т.к. дешифрование должно выполняться через репозиторий
      // 
      // Правильное решение: использовать PasswordEntryRepository.decryptPassword(entry, masterPassword)
      // который вызовет EncryptorLocalDataSource.decryptFromMini(...)
      return null;
    } catch (e) {
      return null; // Ошибка дешифрования
    }
  }

  /// Создаёт копию записи с обновлёнными данными
  PasswordEntry copyWith({
    int? id,
    int? profileId,
    int? categoryId,
    String? service,
    String? password,
    String? encryptedPassword,
    String? nonce,
    String? config,
    String? login,
    DateTime? updatedAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      categoryId: categoryId ?? this.categoryId,
      service: service ?? this.service,
      password: password ?? this.password,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      nonce: nonce ?? this.nonce,
      config: config ?? this.config,
      login: login ?? this.login,
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
  static bool existsForServiceAndPassword(
    List<PasswordEntry> entries,
    String service,
    String password,
  ) {
    return entries.any(
      (e) =>
          e.service.toLowerCase() == service.toLowerCase() &&
          e.password == password,
    );
  }

  /// Находит запись по сервису
  static PasswordEntry? findByService(
    List<PasswordEntry> entries,
    String service,
  ) {
    try {
      return entries.firstWhere(
        (e) => e.service.toLowerCase() == service.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Проверяет, есть ли зашифрованный пароль
  bool get isEncrypted => encryptedPassword != null && nonce != null;

  /// Проверяет, есть ли открытый пароль (в RAM)
  bool get hasPlainText => password != null;

  /// Возвращает пароль для отображения (открытый или зашифрованный)
  /// ⚠️ ВРЕМЕННО: Для полной реализации требуется дешифрование
  String? get displayPassword => password ?? encryptedPassword;

  @override
  String toString() =>
      'PasswordEntry(service: $service, encrypted: $isEncrypted, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntry &&
        other.service == service &&
        other.encryptedPassword == encryptedPassword &&
        other.config == config;
  }

  @override
  int get hashCode => service.hashCode ^ config.hashCode;
}
