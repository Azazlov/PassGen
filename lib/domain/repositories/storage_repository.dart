import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/password_entry.dart';

/// Интерфейс репозитория для хранилища паролей (только CRUD)
abstract class StorageRepository {
  /// Сохраняет список паролей
  Future<Either<StorageFailure, bool>> savePasswords(
    List<PasswordEntry> passwords, {
    int profileId = 1,
  });

  /// Получает список паролей
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords({
    int profileId = 1,
  });

  /// Удаляет пароль по индексу
  Future<Either<StorageFailure, bool>> removePasswordAt(int index, {
    int profileId = 1,
  });

  /// Обновляет существующую запись (по `id`).
  Future<Either<StorageFailure, bool>> updateEntry(PasswordEntry updated, {
    int profileId = 1,
  });

  /// Очищает всё хранилище
  Future<Either<StorageFailure, bool>> clearStorage();
}
