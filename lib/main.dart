import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/database/database_helper.dart';
import 'data/database/migration_from_shared_prefs.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/security_log_repository_impl.dart';
import 'domain/usecases/auth/change_pin_usecase.dart';
import 'domain/usecases/auth/get_auth_state_usecase.dart';
import 'domain/usecases/auth/remove_pin_usecase.dart';
import 'domain/usecases/auth/setup_pin_usecase.dart';
import 'domain/usecases/auth/verify_pin_usecase.dart';
import 'domain/usecases/log/log_event_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация фабрики баз данных
  DatabaseHelper.initFactory();

  // Инициализация базы данных
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;

  // Проверяем существование таблицы auth_data
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='auth_data'",
  );

  if (tables.isEmpty) {
    await db.execute('''
      CREATE TABLE auth_data (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Выполнение миграции из SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final migration = MigrationFromSharedPreferences(
    dbHelper: dbHelper,
    prefs: prefs,
  );

  if (!await migration.isMigrationCompleted()) {
    await migration.migrate();
  }

  // Инициализация AuthLocalDataSource с готовой БД
  final authDataSource = AuthLocalDataSource(database: db);

  // Инициализация AuthRepositoryImpl с готовым AuthLocalDataSource
  final authRepository = AuthRepositoryImpl(authDataSource);

  // Создаём Use Cases с правильным репозиторием
  final securityLogRepository = SecurityLogRepositoryImpl();
  final setupPinUseCase = SetupPinUseCase(authRepository);
  final verifyPinUseCase = VerifyPinUseCase(authRepository);
  final changePinUseCase = ChangePinUseCase(authRepository);
  final removePinUseCase = RemovePinUseCase(authRepository);
  final getAuthStateUseCase = GetAuthStateUseCase(authRepository);
  final logEventUseCase = LogEventUseCase(securityLogRepository);

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
