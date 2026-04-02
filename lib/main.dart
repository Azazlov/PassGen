import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'data/database/database_helper.dart';
import 'data/database/migration_from_shared_prefs.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/security_log_repository_impl.dart';
import 'domain/usecases/auth/setup_pin_usecase.dart';
import 'domain/usecases/auth/verify_pin_usecase.dart';
import 'domain/usecases/auth/change_pin_usecase.dart';
import 'domain/usecases/auth/remove_pin_usecase.dart';
import 'domain/usecases/auth/get_auth_state_usecase.dart';
import 'domain/usecases/log/log_event_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('=== [MAIN] Начало инициализации ===');

  // Инициализация фабрики баз данных
  DatabaseHelper.initFactory();
  debugPrint('[MAIN] DatabaseHelper.initFactory() вызван');

  // Инициализация базы данных
  debugPrint('[MAIN] Инициализация базы данных...');
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  debugPrint('[MAIN] База данных инициализирована: ${db.path}');
  
  // Проверяем существование таблицы auth_data
  debugPrint('[MAIN] Проверка существования таблицы auth_data...');
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='auth_data'",
  );
  
  if (tables.isEmpty) {
    debugPrint('[MAIN] Таблица auth_data не найдена, создаём...');
    await db.execute('''
      CREATE TABLE auth_data (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    debugPrint('[MAIN] Таблица auth_data создана');
  } else {
    debugPrint('[MAIN] Таблица auth_data существует');
  }

  // Выполнение миграции из SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final migration = MigrationFromSharedPreferences(
    dbHelper: dbHelper,
    prefs: prefs,
  );

  if (!await migration.isMigrationCompleted()) {
    final result = await migration.migrate();
    debugPrint('[MAIN] Миграция: ${result.message}');
    debugPrint('[MAIN] Мигрировано паролей: ${result.migratedPasswords}');
    debugPrint('[MAIN] Мигрировано конфигов: ${result.migratedConfigs}');
  } else {
    debugPrint('[MAIN] Миграция уже завершена ранее');
  }

  // Инициализация AuthLocalDataSource с готовой БД
  debugPrint('[MAIN] Создание AuthLocalDataSource...');
  final authDataSource = AuthLocalDataSource(database: db);
  debugPrint('[MAIN] AuthLocalDataSource создан');
  
  // Инициализация AuthRepositoryImpl с готовым AuthLocalDataSource
  debugPrint('[MAIN] Создание AuthRepositoryImpl...');
  final authRepository = AuthRepositoryImpl(authDataSource);
  debugPrint('[MAIN] AuthRepositoryImpl создан');
  
  // Создаём Use Cases с правильным репозиторием
  debugPrint('[MAIN] Создание Use Cases...');
  final securityLogRepository = SecurityLogRepositoryImpl();
  final setupPinUseCase = SetupPinUseCase(authRepository);
  final verifyPinUseCase = VerifyPinUseCase(authRepository);
  final changePinUseCase = ChangePinUseCase(authRepository);
  final removePinUseCase = RemovePinUseCase(authRepository);
  final getAuthStateUseCase = GetAuthStateUseCase(authRepository);
  final logEventUseCase = LogEventUseCase(securityLogRepository);
  debugPrint('[MAIN] Use Cases созданы');

  debugPrint('=== [MAIN] Запуск приложения ===');
  runApp(
    PasswordGeneratorApp(
      authDataSource: authDataSource,
      authRepository: authRepository,
      setupPinUseCase: setupPinUseCase,
      verifyPinUseCase: verifyPinUseCase,
      changePinUseCase: changePinUseCase,
      removePinUseCase: removePinUseCase,
      getAuthStateUseCase: getAuthStateUseCase,
      logEventUseCase: logEventUseCase,
    ),
  );
}
