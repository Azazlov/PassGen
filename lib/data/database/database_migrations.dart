import 'package:sqflite/sqflite.dart';
import 'database_schema.dart';

/// Миграции базы данных
class DatabaseMigrations {
  /// Карта миграций: версия → функция миграции
  static final Map<int, MigrationFunction> _migrations = {
    1: _migrateToV1,
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
  static Future<void> applyMigration(
    Database db,
    int version,
  ) async {
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
    // Создаём таблицы
    for (final table in DatabaseSchema.createAllTables) {
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

  // ==================== ПРИМЕРЫ БУДУЩИХ МИГРАЦИЙ ====================

  /// Миграция к версии 2 (пример)
  /// static Future<void> _migrateToV2(Database db) async {
  ///   await db.execute('''
  ///     ALTER TABLE password_entries ADD COLUMN notes TEXT
  ///   ''');
  /// }

  /// Миграция к версии 3 (пример)
  /// static Future<void> _migrateToV3(Database db) async {
  ///   await db.execute('''
  ///     CREATE TABLE tags (
  ///       id INTEGER PRIMARY KEY AUTOINCREMENT,
  ///       name TEXT NOT NULL UNIQUE,
  ///       color TEXT
  ///     )
  ///   ''');
  /// }
}

/// Тип функции миграции
typedef MigrationFunction = Future<void> Function(Database db);
