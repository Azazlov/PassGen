/// Схема базы данных SQLite
///
/// Версия схемы: 3 (v0.5.2)
/// Версия приложения: 0.5.2
///
/// История изменений:
/// - Version 1: Initial schema (5 таблиц)
/// - Version 2: Добавлена таблица auth_data, индексы
/// - Version 2.1 (v0.5.1): Увеличены итерации PBKDF2 до 100K (исторический шаг)
/// - Version 3 (v0.5.2): Добавлена таблица password_history для истории паролей
///
/// Текущие криптопараметры (см. [EncryptionParams.v2]): PBKDF2-HMAC-SHA256,
/// 600 000 итераций (соответствует рекомендации OWASP 2024).
class DatabaseSchema {
  static const int version = 3;
  static const String appVersion = '0.5.2';
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
''';

  // ==================== ТАБЛИЦЫ ====================

  /// Таблица категорий
  static const String categories = '''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT,
      is_system INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''';

  /// Таблица записей паролей
  static const String passwordEntries = '''
    CREATE TABLE password_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER REFERENCES categories(id),
      service TEXT NOT NULL,
      login TEXT,
      encrypted_password BLOB NOT NULL,
      nonce BLOB NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  /// Таблица конфигураций паролей
  static const String passwordConfigs = '''
    CREATE TABLE password_configs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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

  /// Таблица данных аутентификации (v2)
  static const String authData = '''
    CREATE TABLE auth_data (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''';

  /// Таблица истории паролей (v3)
  static const String passwordHistory = '''
    CREATE TABLE password_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entry_id INTEGER NOT NULL REFERENCES password_entries(id) ON DELETE CASCADE,
      service TEXT NOT NULL,
      encrypted_password BLOB NOT NULL,
      nonce BLOB NOT NULL,
      config TEXT NOT NULL,
      login TEXT,
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
