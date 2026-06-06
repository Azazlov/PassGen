/// Схема базы данных SQLite
///
/// Версия схемы: 7 (v0.6.3)
/// Версия приложения: 0.6.3
///
/// История изменений:
/// - Version 1: Initial schema (5 таблиц)
/// - Version 2: Добавлена таблица auth_data, индексы
/// - Version 2.1 (v0.5.1): Увеличены итерации PBKDF2 до 100K (исторический шаг)
/// - Version 3 (v0.5.2): Добавлена таблица password_history для истории паролей
/// - Version 4 (v0.6.0): Многопрофильность (profiles + profile_id everywhere)
/// - Version 5 (v0.6.1): Полевое шифрование метаданных (encrypted_service /
///                       encrypted_login BLOB на password_entries и
///                       password_history). Plaintext колонки `service`/`login`
///                       сохранены для совместимости и будут удалены в v6.
/// - Version 6 (v0.6.2): Добавлены поля `url` и `notes` в password_entries и
///                       password_history (TEXT, nullable). Шифрование этих
///                       полей планируется отдельным этапом.
/// - Version 7 (v0.6.3): Добавлено поле `expire_days` в password_entries
///                       (INTEGER, nullable). При регенерации используются
///                       оригинальные настройки генерации пароля.
///
/// Текущие криптопараметры (см. [EncryptionParams.v2]): PBKDF2-HMAC-SHA256,
/// 600 000 итераций (соответствует рекомендации OWASP 2024).
class DatabaseSchema {
  static const int version = 7;
  static const String appVersion = '0.6.3';
  static const String schemaInfo = '''
Version 1: Initial schema (5 tables)
  - categories
  - password_entries
  - password_configs
  - security_logs
  - app_settings

Version 2: Added auth_data table, indexes
  - auth_data (для безопасного хранения PIN)
  - 4 индекса для оптимизации

Version 2.1 (v0.5.1): Security improvements
  - PBKDF2 iterations: 10,000 → 100,000 (исторический шаг; текущая v2 = 600,000)
  - Duplicate check on import (service + login)
  - Rollback on import error
  - Configurable clipboard timeout

Version 3 (v0.5.2): Password history tracking
  - password_history (история изменений паролей)
  - Индекс для быстрого поиска по entry_id

Version 4 (v0.6.0): Multi-profile support
  - profiles (профили пользователей)
  - auth_data перестроена под per-profile (profile_id PK)
  - profile_id во всех связанных таблицах
  - Новые индексы для профилей

Version 5 (v0.6.1): Field-level encryption
  - encrypted_service / encrypted_login (BLOB, nullable)
    в password_entries и password_history
  - service / login plaintext колонки сохранены для совместимости и для
    fallback'а в случае отсутствия активного vault-ключа (тестовые сценарии,
    одноразовые миграционные сценарии)

Version 6 (v0.6.2): Additional metadata fields
  - url (TEXT, nullable) — адрес сервиса
  - notes (TEXT, nullable) — заметки пользователя
  - Добавлены в password_entries и password_history

Version 7 (v0.6.3): Password expiration & regeneration
  - expire_days (INTEGER, nullable) в password_entries
  - Регенерация использует оригинальные настройки генерации
''';

  // ==================== ТАБЛИЦЫ ====================

  /// Таблица профилей (v4)
  static const String profiles = '''
    CREATE TABLE profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      avatar_emoji TEXT,
      created_at INTEGER NOT NULL,
      last_accessed_at INTEGER
    )
  ''';

  /// Таблица категорий
  static const String categories = '''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER REFERENCES profiles(id),
      name TEXT NOT NULL,
      icon TEXT,
      is_system INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''';

  /// Таблица записей паролей.
  ///
  /// Plaintext-колонки `service` / `login` остаются `NOT NULL` для
  /// совместимости с записями v1..v4. Реальные значения хранятся в
  /// `encrypted_service` / `encrypted_login` (BLOB), а в plaintext-полях
  /// после первого unlock'а профиля остаётся пустая строка `''`.
  static const String passwordEntries = '''
    CREATE TABLE password_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER REFERENCES profiles(id),
      category_id INTEGER REFERENCES categories(id),
      service TEXT NOT NULL,
      login TEXT,
      url TEXT,
      notes TEXT,
      encrypted_password BLOB NOT NULL,
      nonce BLOB NOT NULL,
      encrypted_service BLOB,
      encrypted_login BLOB,
      expire_days INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  /// Таблица конфигураций паролей
  static const String passwordConfigs = '''
    CREATE TABLE password_configs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER REFERENCES profiles(id),
      entry_id INTEGER UNIQUE REFERENCES password_entries(id),
      strength INTEGER,
      min_length INTEGER,
      max_length INTEGER,
      flags INTEGER,
      require_unique INTEGER DEFAULT 0,
      encrypted_config BLOB
    )
  ''';

  /// Таблица логов безопасности
  static const String securityLogs = '''
    CREATE TABLE security_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER REFERENCES profiles(id),
      action_type TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      details TEXT
    )
  ''';

  /// Таблица настроек приложения
  static const String appSettings = '''
    CREATE TABLE app_settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      encrypted INTEGER DEFAULT 0
    )
  ''';

  /// Таблица данных аутентификации (v4 — per-profile)
  static const String authData = '''
    CREATE TABLE auth_data (
      profile_id INTEGER NOT NULL PRIMARY KEY REFERENCES profiles(id),
      pin_hash TEXT NOT NULL,
      pin_salt TEXT NOT NULL,
      failed_attempts INTEGER DEFAULT 0,
      series_index INTEGER DEFAULT 0,
      lockout_until INTEGER,
      biometric_enabled INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''';

  /// Таблица истории паролей (v3, расширена в v5).
  ///
  /// Аналогично `password_entries`, plaintext `service`/`login` остаются для
  /// совместимости со старыми записями; новые добавляются с непустыми
  /// `encrypted_service`/`encrypted_login`.
  static const String passwordHistory = '''
    CREATE TABLE password_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER REFERENCES profiles(id),
      entry_id INTEGER NOT NULL REFERENCES password_entries(id) ON DELETE CASCADE,
      service TEXT NOT NULL,
      encrypted_password BLOB NOT NULL,
      nonce BLOB NOT NULL,
      config TEXT NOT NULL,
      login TEXT,
      url TEXT,
      notes TEXT,
      encrypted_service BLOB,
      encrypted_login BLOB,
      created_at INTEGER NOT NULL,
      reason TEXT
    )
  ''';

  // ==================== ИНДЕКСЫ ====================

  /// Индексы для ускорения поиска
  static const List<String> indexes = [
    'CREATE INDEX IF NOT EXISTS idx_password_entries_category ON password_entries(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_password_entries_service ON password_entries(service)',
    'CREATE INDEX IF NOT EXISTS idx_security_logs_action ON security_logs(action_type)',
    'CREATE INDEX IF NOT EXISTS idx_security_logs_timestamp ON security_logs(timestamp)',
    'CREATE INDEX IF NOT EXISTS idx_password_history_entry ON password_history(entry_id)',
    'CREATE INDEX IF NOT EXISTS idx_password_history_created ON password_history(created_at)',
    // v4 индексы
    'CREATE INDEX IF NOT EXISTS idx_password_entries_profile ON password_entries(profile_id)',
    'CREATE INDEX IF NOT EXISTS idx_security_logs_profile ON security_logs(profile_id)',
    'CREATE INDEX IF NOT EXISTS idx_password_history_profile ON password_history(profile_id)',
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_auth_data_profile ON auth_data(profile_id)',
    'CREATE INDEX IF NOT EXISTS idx_categories_profile ON categories(profile_id)',
    'CREATE INDEX IF NOT EXISTS idx_password_configs_profile ON password_configs(profile_id)',
  ];

  // ==================== СИСТЕМНЫЕ КАТЕГОРИИ ====================

  /// Предустановленные системные категории
  static const List<Map<String, dynamic>> systemCategories = [
    {'name': 'Соцсети', 'icon': '👥', 'is_system': 1},
    {'name': 'Почта', 'icon': '📧', 'is_system': 1},
    {'name': 'Банки', 'icon': '🏦', 'is_system': 1},
    {'name': 'Магазины', 'icon': '🛒', 'is_system': 1},
    {'name': 'Работа', 'icon': '💼', 'is_system': 1},
    {'name': 'Развлечения', 'icon': '🎮', 'is_system': 1},
    {'name': 'Другое', 'icon': '📁', 'is_system': 1},
  ];

  // ==================== ИНИЦИАЛИЗАЦИЯ ====================

  /// SQL для создания всех таблиц
  static const List<String> createAllTables = [
    profiles,
    categories,
    passwordEntries,
    passwordConfigs,
    securityLogs,
    appSettings,
    authData,
    passwordHistory,
  ];

  /// SQL для создания всех индексов
  static String createAllIndexes() => indexes.join(';');
}
