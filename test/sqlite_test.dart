import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pass_gen/data/database/database_helper.dart';

// Симуляция твоих данных из других модулей
class MockData {
  static const String config = "NTEy.NTE1.Ynl0ZXM="; // Пример твоего генератора
  static const String encryptedSecret = "base64_encrypted_blob_here";
}

class StorageTest {
  late Database db;

  // 1. Инициализация и создание 7 таблиц (Дипломный минимум)
  Future<void> init() async {
    db = await openDatabase(
      inMemoryDatabasePath, // База в оперативной памяти для тестов
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE categories (id INTEGER PRIMARY KEY, name TEXT)');
        await db.execute('CREATE TABLE passwords (id INTEGER PRIMARY KEY, category_id INTEGER, title TEXT)');
        await db.execute('CREATE TABLE encrypted_data (id INTEGER PRIMARY KEY, password_id INTEGER, cipher_text TEXT, nonce TEXT)');
        await db.execute('CREATE TABLE generator_configs (id INTEGER PRIMARY KEY, password_id INTEGER, config TEXT)');
        await db.execute('CREATE TABLE security_events (id INTEGER PRIMARY KEY, event TEXT, timestamp DATETIME)');
        await db.execute('CREATE TABLE app_settings (id INTEGER PRIMARY KEY, key TEXT, value TEXT)');
        await db.execute('CREATE TABLE password_history (id INTEGER PRIMARY KEY, password_id INTEGER, old_value TEXT)');
        
        print("✅ База данных инициализирована: 7 таблиц создано.");
      },
    );
  }

  // 2. Логика записи (Пример: сохранение нового пароля)
  Future<void> savePassword(String title, String categoryName) async {
    // Сначала создаем категорию
    int catId = await db.insert('categories', {'name': categoryName});
    
    // Создаем основную запись
    int pId = await db.insert('passwords', {
      'category_id': catId,
      'title': title
    });

    // Записываем конфиг генератора (из твоего модуля)
    await db.insert('generator_configs', {
      'password_id': pId,
      'config': MockData.config
    });

    // Записываем зашифрованные данные (из твоего модуля Encrypted)
    await db.insert('encrypted_data', {
      'password_id': pId,
      'cipher_text': MockData.encryptedSecret,
      'nonce': 'random_nonce_here'
    });

    // Логируем событие
    await db.insert('security_events', {
      'event': 'Created password: $title',
      'timestamp': DateTime.now().toString()
    });

    print("💾 Данные для '$title' успешно распределены по таблицам.");
  }

  // 3. Логика чтения (Сборка данных обратно)
  Future<void> readAndPrint() async {
    print("\n--- 📝 ОТЧЕТ ПО БАЗЕ ДАННЫХ ---");
    
    // Делаем JOIN, чтобы показать связь таблиц (красиво для диплома)
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT p.title, c.name as category, g.config, e.cipher_text
      FROM passwords p
      JOIN categories c ON p.category_id = c.id
      JOIN generator_configs g ON g.password_id = p.id
      JOIN encrypted_data e ON e.password_id = p.id
    ''');

    for (var row in result) {
      print("Запись: ${row['title']} | Категория: ${row['category']}");
      print("  └─ Конфиг генератора: ${row['config']}");
      print("  └─ Шифрованные байты: ${row['cipher_text']}");
    }

    // Проверяем логи
    List<Map<String, dynamic>> logs = await db.query('security_events');
    print("--- 🛡️ ЛОГИ БЕЗОПАСНОСТИ: ${logs.length} записей ---");
  }
}

void main() async {
  // Важно для sqflite в тестах/приложении
  // databaseFactory = databaseFactoryFfi; // Если запускаешь чисто на ПК (нужен sqflite_common_ffi)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final storage = StorageTest();
  await storage.init();
  
  await storage.savePassword("VK.com", "Social");
  await storage.savePassword("Work Email", "Job");
  
  await storage.readAndPrint();
}