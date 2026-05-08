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
    5: _migrateToV5,
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
      // Вспомогательные утилиты
      Future<bool> tableExists(String name) async {
        final res = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [name],
        );
        return res.isNotEmpty;
      }

      Future<bool> columnExists(String tableName, String columnName) async {
        final cols = await txn.rawQuery('PRAGMA table_info($tableName)');
        return cols.any((c) => (c['name'] as String) == columnName);
      }

      Future<void> maybeAddColumn(String tableName, String columnDef) async {
        final columnName = columnDef.split(' ').first;
        if (!await tableExists(tableName)) return;
        if (await columnExists(tableName, columnName)) return;
        await txn.execute('ALTER TABLE $tableName ADD COLUMN $columnDef');
      }

      // 1. Создать таблицу profiles если её нет
      if (!await tableExists('profiles')) {
        await txn.execute(DatabaseSchema.profiles);
      }

      // 2. Создать дефолтный профиль если он отсутствует
      final now = DateTime.now().millisecondsSinceEpoch;
      if (!await tableExists('profiles')) {
        await txn.insert('profiles', {
          'id': 1,
          'name': 'Профиль по умолчанию',
          'created_at': now,
        });
      } else {
        final existing = await txn.query(
          'profiles',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        );
        if (existing.isEmpty) {
          await txn.insert('profiles', {
            'id': 1,
            'name': 'Профиль по умолчанию',
            'created_at': now,
          });
        }
      }

      // 3. Добавить profile_id в связанные таблицы аккуратно
      await maybeAddColumn(
        'password_entries',
        'profile_id INTEGER REFERENCES profiles(id)',
      );
      await maybeAddColumn(
        'security_logs',
        'profile_id INTEGER REFERENCES profiles(id)',
      );
      await maybeAddColumn(
        'password_history',
        'profile_id INTEGER REFERENCES profiles(id)',
      );
      await maybeAddColumn(
        'categories',
        'profile_id INTEGER REFERENCES profiles(id)',
      );
      await maybeAddColumn(
        'password_configs',
        'profile_id INTEGER REFERENCES profiles(id)',
      );

      // 4. Привязать существующие данные к дефолтному профилю если таблицы существуют
      if (await tableExists('password_entries')) {
        await txn.execute(
          'UPDATE password_entries SET profile_id = 1 WHERE profile_id IS NULL',
        );
      }
      if (await tableExists('security_logs')) {
        await txn.execute(
          'UPDATE security_logs SET profile_id = 1 WHERE profile_id IS NULL',
        );
      }
      if (await tableExists('password_history')) {
        await txn.execute(
          'UPDATE password_history SET profile_id = 1 WHERE profile_id IS NULL',
        );
      }
      if (await tableExists('categories')) {
        await txn.execute(
          'UPDATE categories SET profile_id = 1 WHERE profile_id IS NULL',
        );
      }
      if (await tableExists('password_configs')) {
        await txn.execute(
          'UPDATE password_configs SET profile_id = 1 WHERE profile_id IS NULL',
        );
      }

      // 5. Перестроить auth_data под per-profile схему только если auth_data существует
      if (await tableExists('auth_data')) {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS auth_data_new (
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

        final pinHash = pinHashResult.isNotEmpty
            ? pinHashResult.first['value'] as String?
            : null;
        final pinSalt = pinSaltResult.isNotEmpty
            ? pinSaltResult.first['value'] as String?
            : null;
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

        // Удаляем старую таблицу auth_data и переименовываем новую
        await txn.execute('DROP TABLE IF EXISTS auth_data');
        await txn.execute('ALTER TABLE auth_data_new RENAME TO auth_data');
      }

      // 6. Создать новые индексы v4 аккуратно
      if (await tableExists('password_entries')) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_password_entries_profile ON password_entries(profile_id)',
        );
      }
      if (await tableExists('security_logs')) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_security_logs_profile ON security_logs(profile_id)',
        );
      }
      if (await tableExists('password_history')) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_password_history_profile ON password_history(profile_id)',
        );
      }

      await txn.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_auth_data_profile ON auth_data(profile_id)',
      );

      if (await tableExists('categories')) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_categories_profile ON categories(profile_id)',
        );
      }
      if (await tableExists('password_configs')) {
        await txn.execute(
          'CREATE INDEX IF NOT EXISTS idx_password_configs_profile ON password_configs(profile_id)',
        );
      }
    });
  }

  /// Миграция к версии 5
  /// Полевое шифрование: добавляются BLOB-колонки encrypted_service и
  /// encrypted_login в `password_entries` и `password_history`.
  ///
  /// Реальное шифрование существующих plaintext-значений выполняется
  /// **лениво** при первом успешном unlock'е профиля (там есть PIN, без
  /// которого ключа шифрования взять негде). Здесь только меняется схема.
  static Future<void> _migrateToV5(Database db) async {
    await db.transaction((txn) async {
      Future<bool> tableExists(String name) async {
        final res = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [name],
        );
        return res.isNotEmpty;
      }

      Future<bool> columnExists(String tableName, String columnName) async {
        final cols = await txn.rawQuery('PRAGMA table_info($tableName)');
        return cols.any((c) => (c['name'] as String) == columnName);
      }

      Future<void> maybeAddColumn(String tableName, String columnDef) async {
        final columnName = columnDef.split(' ').first;
        if (!await tableExists(tableName)) return;
        if (await columnExists(tableName, columnName)) return;
        await txn.execute('ALTER TABLE $tableName ADD COLUMN $columnDef');
      }

      await maybeAddColumn('password_entries', 'encrypted_service BLOB');
      await maybeAddColumn('password_entries', 'encrypted_login BLOB');
      await maybeAddColumn('password_history', 'encrypted_service BLOB');
      await maybeAddColumn('password_history', 'encrypted_login BLOB');
    });
  }
}

/// Тип функции миграции
typedef MigrationFunction = Future<void> Function(Database db);
