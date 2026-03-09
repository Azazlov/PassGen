import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'data/database/database_helper.dart';
import 'data/database/migration_from_shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация фабрики баз данных
  DatabaseHelper.initFactory();

  // Инициализация базы данных
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Выполнение миграции из SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final migration = MigrationFromSharedPreferences(
    dbHelper: dbHelper,
    prefs: prefs,
  );

  if (!await migration.isMigrationCompleted()) {
    final result = await migration.migrate();
    debugPrint('Миграция: ${result.message}');
    debugPrint('Мигрировано паролей: ${result.migratedPasswords}');
    debugPrint('Мигрировано конфигов: ${result.migratedConfigs}');
  }

  runApp(const PasswordGeneratorApp());
}
