import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/password_config.dart';
import '../../../../domain/entities/password_generation_settings.dart';
import '../../../../domain/entities/password_result.dart';
import '../../../../domain/repositories/password_generator_repository.dart';
import '../datasources/password_generator_local_datasource.dart';

/// Реализация репозитория генерации паролей
class PasswordGeneratorRepositoryImpl implements PasswordGeneratorRepository {
  final PasswordGeneratorLocalDataSource dataSource;

  const PasswordGeneratorRepositoryImpl(this.dataSource);

  @override
  Future<Either<PasswordGenerationFailure, PasswordResult>> generatePassword(
    PasswordGenerationSettings settings,
  ) async {
    try {
      final result = dataSource.generate(
        lengthRange: settings.lengthRange,
        flags: settings.flags,
      );

      if (result['error'] != null) {
        return Left(PasswordGenerationFailure(message: result['error']!));
      }

      return Right(PasswordResult(
        password: result['password'] ?? '',
        strength: double.tryParse(result['strength'] ?? '0') ?? 0.0,
        config: result['config'] ?? '',
      ));
    } catch (e) {
      return Left(PasswordGenerationFailure(message: 'Ошибка генерации: $e'));
    }
  }

  @override
  Future<Either<PasswordGenerationFailure, PasswordResult>> restorePassword(
    String config,
  ) async {
    try {
      final result = dataSource.restoreFromConfig(config);

      if (result['error'] != null) {
        return Left(PasswordGenerationFailure(message: result['error']!));
      }

      return Right(PasswordResult(
        password: result['password'] ?? '',
        strength: double.tryParse(result['strength'] ?? '0') ?? 0.0,
        config: config,
      ));
    } catch (e) {
      return Left(PasswordGenerationFailure(message: 'Ошибка восстановления: $e'));
    }
  }

  @override
  Future<Either<PasswordGenerationFailure, PasswordConfig>> createPasswordConfig({
    required String service,
    required String masterPassword,
    required PasswordGenerationSettings settings,
  }) async {
    try {
      // Генерируем пароль
      final passwordResult = await generatePassword(settings);

      return passwordResult.fold(
        (failure) => Left(PasswordGenerationFailure(
          message: 'Не удалось сгенерировать пароль: ${failure.message}',
        )),
        (result) async {
          // Шифруем конфиг генерации
          final encryptedConfig = await dataSource.createEncryptedConfig(
            passwordConfig: result.config,
            masterPassword: masterPassword,
          );

          final config = PasswordConfig(
            version: 1,
            service: service,
            lastUsageDate: DateTime.now(),
            uuid: dataSource.generateUuid(),
            category: 'Default',
            expireDays: 30,
            encryptedConfig: encryptedConfig,
          );

          return Right(config);
        },
      );
    } catch (e) {
      return Left(PasswordGenerationFailure(message: 'Ошибка создания конфига: $e'));
    }
  }

  @override
  Future<Either<PasswordGenerationFailure, String>> decryptPassword(
    PasswordConfig config,
    String masterPassword,
  ) async {
    try {
      // Расшифровываем конфиг генерации
      final passwordConfig = await dataSource.decryptConfig(
        encryptedConfig: config.encryptedConfig,
        masterPassword: masterPassword,
      );

      // Восстанавливаем пароль из конфига
      final result = dataSource.restoreFromConfig(passwordConfig);

      if (result['error'] != null) {
        return Left(PasswordGenerationFailure(message: result['error']!));
      }

      return Right(result['password'] ?? '');
    } catch (e) {
      return Left(PasswordGenerationFailure(message: 'Ошибка дешифрования: $e'));
    }
  }

  @override
  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> savePassword({
    required String service,
    required String password,
    required String config,
    int? categoryId,
    String? login,
  }) async {
    try {
      // Сохраняем пароль через dataSource
      final result = await dataSource.savePassword(
        service: service,
        password: password,
        config: config,
        categoryId: categoryId,
        login: login,
      );

      if (result['error'] != null) {
        return Left(PasswordGenerationFailure(message: result['error']!));
      }

      return Right(result);
    } catch (e) {
      return Left(PasswordGenerationFailure(message: 'Ошибка сохранения: $e'));
    }
  }
}
