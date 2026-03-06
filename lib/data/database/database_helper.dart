import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_schema.dart';

/// Синглтон для управления базой данных SQLite
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Инициализация фабрики баз данных (должна быть вызвана перед первым использованием)
  static void initFactory() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Получение пути к базе данных
  Future<String> get _dbPath async {
    final dbDir = await getDatabasesPath();
    return join(dbDir, 'passgen.db');
  }

  /// Получение экземпляра базы данных
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Инициализация базы данных
  Future<Database> _initDatabase() async {
    final path = await _dbPath;

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// Создание таблиц при первой инициализации
  Future<void> _onCreate(Database db, int version) async {
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

  /// Миграция при обновлении версии БД
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Здесь будут миграции между версиями
    if (oldVersion < newVersion) {
      // Миграция будет реализована в database_migrations.dart
    }
  }

  // ==================== CRUD операции ====================

  // ==================== CREATE ====================

  /// Вставка записи
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Вставка записи с заменой при конфликте
  Future<int> insertWithConflict(
    String table,
    Map<String, dynamic> data, {
    String? conflictColumn,
  }) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: conflictColumn != null
          ? ConflictAlgorithm.replace
          : ConflictAlgorithm.ignore,
    );
  }

  // ==================== READ ====================

  /// Получение всех записей из таблицы
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Получение записи по ID
  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// Получение записей с условиями
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Получение одной записи с условиями
  Future<Map<String, dynamic>?> queryFirst(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final results = await query(table, where: where, whereArgs: whereArgs, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // ==================== UPDATE ====================

  /// Обновление записи по ID
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required int id,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Обновление записей с условиями
  Future<int> updateWhere(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ==================== DELETE ====================

  /// Удаление записи по ID
  Future<int> deleteById(String table, int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удаление записей с условиями
  Future<int> deleteWhere(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Удаление всех записей из таблицы
  Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }

  // ==================== RAW OPERATIONS ====================

  /// Выполнение raw SQL запроса
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Выполнение raw SQL команды
  Future<void> rawExecute(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  // ==================== TRANSACTION ====================

  /// Выполнение транзакции
  Future<T?> transaction<T>(Future<T?> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await action(txn);
    });
  }

  /// Пакетное выполнение операций
  Future<List<dynamic>> batchExecute(List<BatchOperation> operations) async {
    final db = await database;
    final batch = db.batch();
    
    for (final op in operations) {
      switch (op.type) {
        case BatchOperationType.insert:
          batch.insert(op.table!, op.data!);
          break;
        case BatchOperationType.update:
          batch.update(
            op.table!,
            op.data!,
            where: op.where,
            whereArgs: op.whereArgs,
          );
          break;
        case BatchOperationType.delete:
          batch.delete(
            op.table!,
            where: op.where,
            whereArgs: op.whereArgs,
          );
          break;
      }
    }
    
    return await batch.commit();
  }

  // ==================== UTILS ====================

  /// Закрытие базы данных
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Удаление базы данных
  Future<void> deleteDatabaseFile() async {
    final path = await _dbPath;
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Проверка существования базы данных
  Future<bool> databaseExists() async {
    final path = await _dbPath;
    return await databaseFactory.databaseExists(path);
  }
}

/// Тип операции для пакетного выполнения
enum BatchOperationType { insert, update, delete }

/// Операция для пакетного выполнения
class BatchOperation {
  final BatchOperationType type;
  final String? table;
  final Map<String, dynamic>? data;
  final String? where;
  final List<dynamic>? whereArgs;

  BatchOperation.insert(this.data, {this.table})
      : type = BatchOperationType.insert,
        where = null,
        whereArgs = null;

  BatchOperation.update(
    this.data, {
    this.table,
    this.where,
    this.whereArgs,
  }) : type = BatchOperationType.update;

  BatchOperation.delete({
    this.table,
    this.where,
    this.whereArgs,
  })  : type = BatchOperationType.delete,
        data = null;
}
