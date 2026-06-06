import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../datasources/storage_local_datasource.dart';

/// Реализация репозитория хранилища (только CRUD)
class StorageRepositoryImpl implements StorageRepository {
  const StorageRepositoryImpl(this.dataSource);
  final StorageLocalDataSource dataSource;

  @override
  Future<Either<StorageFailure, bool>> savePasswords(
    List<PasswordEntry> passwords, {
    int profileId = 1,
  }) async {
    try {
      final result = await dataSource.savePasswords(passwords, profileId: profileId);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка сохранения: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords({int profileId = 1}) async {
    try {
      final result = await dataSource.getPasswords(profileId: profileId);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка чтения: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> removePasswordAt(int index, {int profileId = 1}) async {
    try {
      final result = await dataSource.removePasswordAt(index, profileId: profileId);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка удаления: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> updateEntry(PasswordEntry updated, {int profileId = 1}) async {
    try {
      final result = await dataSource.updateEntry(updated, profileId: profileId);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка обновления: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> clearStorage() async {
    try {
      final result = await dataSource.clearStorage('');
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка очистки: $e'));
    }
  }
}
