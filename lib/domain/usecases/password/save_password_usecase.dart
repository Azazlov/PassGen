import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_generator_repository.dart';
import '../../repositories/password_history_repository.dart';

/// Использование: Сохранение пароля в хранилище
///
/// Добавлена бизнес-логика валидации перед сохранением.
/// Сохраняет предыдущую версию пароля в историю при обновлении.
class SavePasswordUseCase {
  const SavePasswordUseCase(this.repository, [this.historyRepository]);
  final PasswordGeneratorRepository repository;
  final PasswordHistoryRepository? historyRepository;

  /// Сохраняет пароль в хранилище с предварительной валидацией
  ///
  /// Проверяет:
  /// - Длина пароля (минимум 4 символа)
  /// - Название сервиса (не пустое)
  /// - Конфигурация (не пустая)
  ///
  /// Если [entryId] предоставлен и [historyRepository] инициализирован,
  /// сохраняет предыдущую версию пароля в историю.
  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> execute({
    required String service,
    required String password,
    required String config,
    String? masterPassword,
    int? categoryId,
    String? login,
    int? entryId,
    String? encryptedPassword,
    String? nonce,
    String? reason,
    int? expireDays,
    int profileId = 1,
  }) async {
    // Валидация входных данных
    final validationFailure = _validate(service, password, config);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Если это обновление существующего пароля и есть репозиторий истории
    if (entryId != null &&
        historyRepository != null &&
        encryptedPassword != null &&
        nonce != null) {
      // Сохраняем текущую версию в историю перед обновлением
      await historyRepository!.saveHistoryEntry(
        entryId: entryId,
        service: service,
        encryptedPassword: encryptedPassword,
        nonce: nonce,
        config: config,
        login: login,
        reason: reason ?? 'Обновление пароля',
      );
    }

    // Сохранение в репозиторий
    return repository.savePassword(
      service: service,
      password: password,
      config: config,
      masterPassword: masterPassword,
      categoryId: categoryId,
      login: login,
      expireDays: expireDays,
      profileId: profileId,
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
      return const PasswordGenerationFailure(
        message: 'Пароль слишком короткий (минимум 4 символа)',
      );
    }

    // Проверка названия сервиса
    if (service.trim().isEmpty) {
      return const PasswordGenerationFailure(
        message: 'Название сервиса не может быть пустым',
      );
    }

    // Проверка конфигурации
    if (config.isEmpty) {
      return const PasswordGenerationFailure(
        message: 'Конфигурация пароля не может быть пустой',
      );
    }

    return null;
  }
}
