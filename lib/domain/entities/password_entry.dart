import 'dart:convert';
import 'dart:typed_data';

/// Запись о сохранённом пароле
class PasswordEntry {
  const PasswordEntry({
    this.id,
    this.profileId,
    this.categoryId,
    required this.service,
    this.password,
    this.encryptedPassword,
    this.nonce,
    required this.config,
    this.login,
    this.url,
    this.notes,
    this.expireDays,
    required this.createdAt,
    this.updatedAt,
    this.encryptedServiceBlob,
    this.encryptedLoginBlob,
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
      url: json['url'] as String?,
      notes: json['notes'] as String?,
      expireDays: json['expireDays'] as int?,
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

  /// URL сервиса (опциональный, plaintext в v6).
  final String? url;

  /// Произвольные заметки пользователя (plaintext в v6).
  final String? notes;

  /// Срок действия пароля в днях (null = не истекает).
  final int? expireDays;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Зашифрованное имя сервиса (BLOB из SQLite, схема v5).
  ///
  /// Формат: `nonce(12) + ciphertext + mac(16)` из ChaCha20-Poly1305 на
  /// vault-ключе профиля. `null` означает запись старого формата (до
  /// схемы v5 или до первого unlock'а), тогда используется plaintext-
  /// колонка [service].
  final List<int>? encryptedServiceBlob;

  /// Зашифрованный логин — аналогично [encryptedServiceBlob].
  final List<int>? encryptedLoginBlob;

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
      if (url != null) 'url': url,
      if (notes != null) 'notes': notes,
      if (expireDays != null) 'expireDays': expireDays,
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
    String? url,
    String? notes,
    int? expireDays,
    DateTime? updatedAt,
    List<int>? encryptedServiceBlob,
    List<int>? encryptedLoginBlob,
    bool clearEncryptedServiceBlob = false,
    bool clearEncryptedLoginBlob = false,
    bool clearUrl = false,
    bool clearNotes = false,
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
      url: clearUrl ? null : (url ?? this.url),
      notes: clearNotes ? null : (notes ?? this.notes),
      expireDays: expireDays ?? this.expireDays,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      encryptedServiceBlob: clearEncryptedServiceBlob
          ? null
          : (encryptedServiceBlob ?? this.encryptedServiceBlob),
      encryptedLoginBlob: clearEncryptedLoginBlob
          ? null
          : (encryptedLoginBlob ?? this.encryptedLoginBlob),
    );
  }

  /// Создаёт PasswordEntry из строки SQLite (таблица `password_entries`).
  ///
  /// `encryptedConfigBytes` — содержимое колонки `encrypted_config` из
  /// связанной строки таблицы `password_configs` (один-к-одному по
  /// `entry_id`). Если конфиг отсутствует — передаётся `null`.
  factory PasswordEntry.fromMap(
    Map<String, Object?> map, {
    Uint8List? encryptedConfigBytes,
  }) {
    final encryptedPasswordBlob = map['encrypted_password'];
    String? encryptedPassword;
    if (encryptedPasswordBlob is Uint8List) {
      if (encryptedPasswordBlob.isNotEmpty) {
        encryptedPassword = utf8.decode(encryptedPasswordBlob);
      }
    } else if (encryptedPasswordBlob is List<int> &&
        encryptedPasswordBlob.isNotEmpty) {
      encryptedPassword = utf8.decode(encryptedPasswordBlob);
    } else if (encryptedPasswordBlob is String &&
        encryptedPasswordBlob.isNotEmpty) {
      encryptedPassword = encryptedPasswordBlob;
    }

    String config = '';
    if (encryptedConfigBytes != null && encryptedConfigBytes.isNotEmpty) {
      config = utf8.decode(encryptedConfigBytes);
    }

    final createdAtMs = map['created_at'] as int?;
    final updatedAtMs = map['updated_at'] as int?;

    List<int>? readBlob(Object? raw) {
      if (raw == null) return null;
      if (raw is Uint8List) {
        return raw.isEmpty ? null : raw;
      }
      if (raw is List<int>) {
        return raw.isEmpty ? null : raw;
      }
      return null;
    }

    // Восстанавливает строковый nonce из Uint8List (колонка BLOB SQLite).
    // Используется для поля [nonce], которое хранится как Base64-строка, но
    // записывается/читается через BLOB, поэтому нужен явный UTF-8 декодинг.
    String? readNonceBlob(Object? raw) {
      if (raw == null) return null;
      if (raw is Uint8List) {
        return raw.isEmpty ? null : utf8.decode(raw);
      }
      if (raw is List<int>) {
        return raw.isEmpty ? null : utf8.decode(raw);
      }
      return null;
    }

    return PasswordEntry(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      categoryId: map['category_id'] as int?,
      service: (map['service'] as String?) ?? '',
      login: map['login'] as String?,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      encryptedPassword: encryptedPassword,
      nonce: readNonceBlob(map['nonce']),
      config: config,
      expireDays: map['expire_days'] as int?,
      createdAt: createdAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
          : DateTime.now(),
      updatedAt: updatedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
          : null,
      encryptedServiceBlob: readBlob(map['encrypted_service']),
      encryptedLoginBlob: readBlob(map['encrypted_login']),
    );
  }

  /// Преобразует PasswordEntry в Map для SQLite (таблица `password_entries`).
  ///
  /// `defaultProfileId` используется, если `profileId` не задан явно.
  /// Поле `config` сюда НЕ попадает — оно хранится в отдельной таблице
  /// `password_configs`; используйте [encryptedConfigBlob] для получения
  /// байтов для записи в `password_configs.encrypted_config`.
  ///
  /// Колонка `nonce` хранит Base64-encoded PBKDF2 nonce (первые 32 байта из
  /// мини-формата), который нужен `save_password_usecase` для записи старого
  /// пароля в `password_history` перед обновлением.
  Map<String, Object?> toMap({int? defaultProfileId}) {
    final encryptedPasswordBytes = encryptedPassword != null
        ? Uint8List.fromList(utf8.encode(encryptedPassword!))
        : Uint8List(0);

    // Если значение зашифровано — в plaintext-колонку кладём пустую строку
    // (колонка NOT NULL, поэтому null нельзя), чтобы на диске не оставалось
    // подсказки о реальном сервисе.
    final servicePlaintext = encryptedServiceBlob != null ? '' : service;
    final loginPlaintext = encryptedLoginBlob != null ? null : login;

    return <String, Object?>{
      if (id != null) 'id': id,
      'profile_id': profileId ?? defaultProfileId,
      'category_id': categoryId,
      'service': servicePlaintext,
      'login': loginPlaintext,
      'url': url,
      'notes': notes,
      'encrypted_password': encryptedPasswordBytes,
      'nonce': nonce != null
          ? Uint8List.fromList(utf8.encode(nonce!))
          : Uint8List(0),
      if (encryptedServiceBlob != null)
        'encrypted_service': Uint8List.fromList(encryptedServiceBlob!),
      if (encryptedLoginBlob != null)
        'encrypted_login': Uint8List.fromList(encryptedLoginBlob!),
      if (expireDays != null) 'expire_days': expireDays,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': (updatedAt ?? createdAt).millisecondsSinceEpoch,
    };
  }

  /// Возвращает зашифрованный `config` как байты для записи в
  /// `password_configs.encrypted_config`. Если `config` пуст — `null`.
  Uint8List? encryptedConfigBlob() {
    if (config.isEmpty) return null;
    return Uint8List.fromList(utf8.encode(config));
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
  /// 
  /// Используется мини-формат (pbkdf2-nonce + nonceBox + ciphertext + mac),
  /// поэтому nonce может быть null - это нормально.
  bool get isEncrypted => encryptedPassword != null && encryptedPassword!.isNotEmpty;

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
