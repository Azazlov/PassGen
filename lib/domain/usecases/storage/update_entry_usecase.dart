import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_entry.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Обновление метаданных существующей записи пароля.
///
/// Обновляет `service`, `login`, `url`, `notes`, `category_id`. Поля
/// `encrypted_password` / `config` не затрагиваются — для смены пароля
/// используется отдельный путь (генератор → SavePasswordUseCase).
class UpdateEntryUseCase {
  const UpdateEntryUseCase(this.repository);
  final StorageRepository repository;

  Future<Either<StorageFailure, bool>> execute(PasswordEntry updated) {
    return repository.updateEntry(updated);
  }
}
