import 'package:sqflite/sqflite.dart';
import 'database_schema.dart';

/// Миграции базы данных
class DatabaseMigrations {
  /// Карта миграций: версия → функция миграции
  static final Map<int, MigrationFunction> _migrations = {
    1: _migrateToV1,
    2: _migrateToV2,
    3: _migrateToV3,
    4: _migrateToV4,
  };

  /// Получение списка миграций для применения
  static List<int> getMigrationsToApply(int oldVersion, int newVersion) {
    final migrations = <int>[];
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      if (_migrations.containsKey(version)) {
        migrations.add(version);
      }
    }
    return migrations;
  }

  /// Применение миграции
  static Future<void> applyMigration(Database db, int version) async {
    final migration = _migrations[version];
    if (migration != null) {
      await migration(db);
    }
  }

  /// Применение всех необходимых миграций
  static Future<void> applyMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final migrations = getMigrationsToApply(oldVersion, newVersion);
    for (final version in migrations) {
      await applyMigration(db, version);
    }
  }

  // ==================== МИГРАЦИИ ====================

  /// Миграция к версии 1
  /// Создание начальной схемы базы данных
  static Future<void> _migrateToV1(Database db) async {
    // Создаём таблицы v1
    final v1Tables = [
      DatabaseSchema.categories,
      DatabaseSchema.passwordEntries,
      DatabaseSchema.passwordConfigs,
      DatabaseSchema.securityLogs,
      DatabaseSchema.appSettings,
    ];

    for (final table in v1Tables) {
      await db.execute(table);
    }

    // Создаём индексы
    await db.execute(DatabaseSchema.createAllIndexes());

    // Вставляем системные категории
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final category in DatabaseSchema.systemCategories) {
      await db.insert('categories', {
        'name': category['name'],
        'icon': category['icon'],
        'is_system': category['is_system'],
        'created_at': now,
      });
    }
  }

  /// Миграция к версии 2
  /// Добавление таблицы auth_data для хранения данных аутентификации
  static Future<void> _migrateToV2(Database db) async {
    // Создаём таблицу auth_data (legacy key-value, будет перестроена в v4)
    await db.execute('''
      CREATE TABLE auth_data (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// Миграция к версии 3
  /// Добавление таблицы password_history для истории изменений паролей
  static Future<void> _migrateToV3(Database db) async {
    // Создаём таблицу password_history
    await db.execute(DatabaseSchema.passwordHistory);

    // Создаём индексы для таблицы истории
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_password_history_entry ON password_history(entry_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_password_history_created ON password_history(created_at)',
    );
  }

  /// Миграция к версии 4
  /// Многопрофильность: per-profile auth_data, profile_id в связанных таблицах
  static Future<void> _migrateToV4(Database db) async {
    await db.transaction((txn) async {
      // 1. Создать таблицу profiles
      await txn.execute(DatabaseSchema.profiles);

      // 2. Создать дефолтный профиль
      final now = DateTime.now().millisecondsSinceEpoch;
      await txn.insert('profiles', {
        'id': 1,
        'name': 'Профиль по умолчанию',
        'created_at': now,
      });

      // 3. Добавить profile_id в связанные таблицы
      await txn.execute(
        'ALTER TABLE password_entries ADD COLUMN profile_id INTEGER REFERENCES profiles(id)',
      );
      await txn.execute(
        'ALTER TABLE security_logs ADD COLUMN profile_id INTEGER REFERENCES profiles(id)',
      );
      await txn.execute(
        'ALTER TABLE password_history ADD COLUMN profile_id INTEGER REFERENCES profiles(id)',
      );
      await txn.execute(
        'ALTER TABLE categories ADD COLUMN profile_id INTEGER REFERENCES profiles(id)',
      );
      await txn.execute(
        'ALTER TABLE password_configs ADD COLUMN profile_id INTEGER REFERENCES profiles(id)',
      );

      // 4. Привязать существующие данные к дефолтному профилю
      await txn.execute(
        'UPDATE password_entries SET profile_id = 1 WHERE profile_id IS NULL',
      );
      await txn.execute(
        'UPDATE security_logs SET profile_id = 1 WHERE profile_id IS NULL',
      );
      await txn.execute(
        'UPDATE password_history SET profile_id = 1 WHERE profile_id IS NULL',
      );
      await txn.execute(
        'UPDATE categories SET profile_id = 1 WHERE profile_id IS NULL',
      );
      await txn.execute(
        'UPDATE password_configs SET profile_id = 1 WHERE profile_id IS NULL',
      );

      // 5. Перестроить auth_data под per-profile схему
      // SQLite не поддерживает ALTER TABLE ADD COLUMN с UNIQUE constraint
      await txn.execute('''
        CREATE TABLE auth_data_new (
          profile_id INTEGER NOT NULL PRIMARY KEY REFERENCES profiles(id),
          pin_hash TEXT NOT NULL,
          pin_salt TEXT NOT NULL,
          failed_attempts INTEGER DEFAULT 0,
          series_index INTEGER DEFAULT 0,
          lockout_until INTEGER,
          biometric_enabled INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL
        )
      ''');

      // Мигрируем существующие данные auth_data (key-value → per-profile)
      final pinHashResult = await txn.query(
        'auth_data',
        where: "key = 'pin_hash'",
        limit: 1,
      );
      final pinSaltResult = await txn.query(
        'auth_data',
        where: "key = 'pin_salt'",
        limit: 1,
      );
      final createdAtResult = await txn.query(
        'auth_data',
        where: "key = 'pin_hash'",
        limit: 1,
      );

      final pinHash = pinHashResult.isNotEmpty ? pinHashResult.first['value'] as String? : null;
      final pinSalt = pinSaltResult.isNotEmpty ? pinSaltResult.first['value'] as String? : null;
      final createdAt = createdAtResult.isNotEmpty
          ? createdAtResult.first['created_at'] as int?
          : now;

      if (pinHash != null) {
        await txn.insert('auth_data_new', {
          'profile_id': 1,
          'pin_hash': pinHash,
          'pin_salt': pinSalt ?? '',
          'failed_attempts': 0,
          'series_index': 0,
          'lockout_until': null,
          'biometric_enabled': 0,
          'created_at': createdAt ?? now,
        });
      }

      await txn.execute('DROP TABLE auth_data');
      await txn.execute('ALTER TABLE auth_data_new RENAME TO auth_data');

      // 6. Создать новые индексы v4
      await txn.execute(
        'CREATE INDEX idx_password_entries_profile ON password_entries(profile_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_security_logs_profile ON security_logs(profile_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_password_history_profile ON password_history(profile_id)',
      );
      await txn.execute(
        'CREATE UNIQUE INDEX idx_auth_data_profile ON auth_data(profile_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_categories_profile ON categories(profile_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_password_configs_profile ON password_configs(profile_id)',
      );
    });
  }
}

/// Тип функции миграции
typedef MigrationFunction = Future<void> Function(Database db);
