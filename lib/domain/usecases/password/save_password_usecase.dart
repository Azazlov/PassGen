import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_generator_repository.dart';

/// Использование: Сохранение пароля в хранилище
/// 
/// Добавлена бизнес-логика валидации перед сохранением.
class SavePasswordUseCase {
  const SavePasswordUseCase(this.repository);
  final PasswordGeneratorRepository repository;

  /// Сохраняет пароль в хранилище с предварительной валидацией
  /// 
  /// Проверяет:
  /// - Длина пароля (минимум 4 символа)
  /// - Название сервиса (не пустое)
  /// - Конфигурация (не пустая)
  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> execute({
    required String service,
    required String password,
    required String config,
    int? categoryId,
    String? login,
  }) async {
    // Валидация входных данных
    final validationFailure = _validate(service, password, config);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Сохранение в репозиторий
    return await repository.savePassword(
      service: service,
      password: password,
      config: config,
      categoryId: categoryId,
      login: login,
    );
  }

  /// Валидирует данные перед сохранением
  PasswordGenerationFailure? _validate(
    String service,
    String password,
    String config,
  ) {
    // Проверка длины пароля
    if (password.length < 4) {
      return PasswordGenerationFailure(
        message: 'Пароль слишком короткий (минимум 4 символа)',
      );
    }

    // Проверка названия сервиса
    if (service.trim().isEmpty) {
      return PasswordGenerationFailure(
        message: 'Название сервиса не может быть пустым',
      );
    }

    // Проверка конфигурации
    if (config.isEmpty) {
      return PasswordGenerationFailure(
        message: 'Конфигурация пароля не может быть пустой',
      );
    }

    return null;
  }
}
