import '../entities/password_config.dart';
import '../entities/password_generation_settings.dart';
import '../entities/password_result.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Интерфейс репозитория для генерации паролей
abstract class PasswordGeneratorRepository {
  /// Генерирует новый пароль по настройкам
  Future<Either<PasswordGenerationFailure, PasswordResult>> generatePassword(
    PasswordGenerationSettings settings,
  );

  /// Восстанавливает пароль из конфига
  Future<Either<PasswordGenerationFailure, PasswordResult>> restorePassword(
    String config,
  );

  /// Создаёт конфигурацию генерации
  Future<Either<PasswordGenerationFailure, PasswordConfig>> createPasswordConfig({
    required String service,
    required String masterPassword,
    required PasswordGenerationSettings settings,
  });

  /// Восстанавливает пароль из сохранённой конфигурации
  Future<Either<PasswordGenerationFailure, String>> decryptPassword(
    PasswordConfig config,
    String masterPassword,
  );

  /// Сохраняет пароль в хранилище
  /// Возвращает Map с результатом: {'success': bool, 'updated': bool, 'error': String?}
  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> savePassword({
    required String service,
    required String password,
    required String config,
  });
}
