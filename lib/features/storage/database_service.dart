import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passgen.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE password_configs (
        id $idType,
        version $intType,
        service $textType,
        lastUsageDate $textType,
        uuid $textType,
        category $textType,
        expireDays $intType,
        encr $textType,
        password $textType,
        strength $textType,
        config $textType,
        createdAt $textType
      )
    ''');
  }

  Future<int> savePasswordConfig(Map<String, dynamic> config) async {
    final db = await database;
    return await db.insert('password_configs', config);
  }

  Future<List<Map<String, dynamic>>> getAllConfigs() async {
    final db = await database;
    return await db.query('password_configs', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getConfigByUuid(String uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'password_configs',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> updateConfig(Map<String, dynamic> config) async {
    final db = await database;
    return await db.update(
      'password_configs',
      config,
      where: 'uuid = ?',
      whereArgs: [config['uuid']],
    );
  }

  Future<int> deleteConfig(String uuid) async {
    final db = await database;
    return await db.delete(
      'password_configs',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
