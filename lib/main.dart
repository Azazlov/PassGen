import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/database/database_helper.dart';
import 'data/database/migration_from_shared_prefs.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/biometric_local_datasource.dart';
import 'data/datasources/profile_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/biometric_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/qr_transfer_repository_impl.dart';
import 'data/repositories/security_log_repository_impl.dart';
import 'domain/services/glitch_service.dart';
import 'domain/services/performance_benchmark_service.dart';
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

  // Выполнение миграции из SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final migration = MigrationFromSharedPreferences(
    dbHelper: dbHelper,
    prefs: prefs,
  );

  if (!await migration.isMigrationCompleted()) {
    await migration.migrate();
  }

  // Инициализация data sources
  final authDataSource = AuthLocalDataSource(database: db);
  final profileDataSource = ProfileLocalDataSource(database: db);
  final biometricDataSource = BiometricLocalDataSource();

  // Инициализация репозиториев
  final authRepository = AuthRepositoryImpl(authDataSource);
  final profileRepository = ProfileRepositoryImpl(
    dataSource: profileDataSource,
    prefs: prefs,
  );
  final biometricRepository = BiometricRepositoryImpl(biometricDataSource);
  final qrTransferRepository = QrTransferRepositoryImpl();
  final securityLogRepository = SecurityLogRepositoryImpl();

  // Сервисы
  const glitchService = GlitchService();
  final benchmarkService = PerformanceBenchmarkService(
    logRepository: securityLogRepository,
  );

  // Use Cases
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
      profileRepository: profileRepository,
      biometricRepository: biometricRepository,
      qrTransferRepository: qrTransferRepository,
      glitchService: glitchService,
      benchmarkService: benchmarkService,
      setupPinUseCase: setupPinUseCase,
      verifyPinUseCase: verifyPinUseCase,
      changePinUseCase: changePinUseCase,
      removePinUseCase: removePinUseCase,
      getAuthStateUseCase: getAuthStateUseCase,
      logEventUseCase: logEventUseCase,
    ),
  );
}
