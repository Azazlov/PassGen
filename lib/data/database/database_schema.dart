/// Схема базы данных SQLite
/// Версия схемы: 1
class DatabaseSchema {
  static const int version = 1;

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

  // ==================== ИНДЕКСЫ ====================

  /// Индексы для ускорения поиска
  static const List<String> indexes = [
    'CREATE INDEX IF NOT EXISTS idx_password_entries_category ON password_entries(category_id)',
    'CREATE INDEX IF NOT EXISTS idx_password_entries_service ON password_entries(service)',
    'CREATE INDEX IF NOT EXISTS idx_security_logs_action ON security_logs(action_type)',
    'CREATE INDEX IF NOT EXISTS idx_security_logs_timestamp ON security_logs(timestamp)',
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
  ];

  /// SQL для создания всех индексов
  static String createAllIndexes() => indexes.join(';');
}
