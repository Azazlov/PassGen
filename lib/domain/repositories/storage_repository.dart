import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/password_entry.dart';

/// Интерфейс репозитория для хранилища паролей (только CRUD)
abstract class StorageRepository {
  /// Сохраняет список паролей
  Future<Either<StorageFailure, bool>> savePasswords(
    List<PasswordEntry> passwords,
  );

  /// Получает список паролей
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords();

  /// Удаляет пароль по индексу
  Future<Either<StorageFailure, bool>> removePasswordAt(int index);

  /// Очищает всё хранилище
  Future<Either<StorageFailure, bool>> clearStorage();
}
