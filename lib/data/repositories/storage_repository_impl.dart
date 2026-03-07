import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/password_entry.dart';
import '../../../../domain/repositories/storage_repository.dart';
import '../datasources/storage_local_datasource.dart';
import '../formats/passgen_format.dart';

/// Реализация репозитория хранилища
class StorageRepositoryImpl implements StorageRepository {
  final StorageLocalDataSource dataSource;

  const StorageRepositoryImpl(this.dataSource);

  @override
  Future<Either<StorageFailure, bool>> saveConfigs(
    String key,
    List<String> configs,
  ) async {
    try {
      final result = await dataSource.saveConfig(key, configs);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка сохранения: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, List<String>>> getConfigs(String key) async {
    try {
      final result = await dataSource.getConfigs(key);
      return Right(result ?? []);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка чтения: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> removeConfigAt(
    String key,
    int index,
  ) async {
    try {
      final result = await dataSource.removeConfigAt(key, index);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка удаления: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> clearStorage(String key) async {
    try {
      final result = await dataSource.clearStorage(key);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка очистки: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> savePasswords(List<PasswordEntry> passwords) async {
    try {
      final result = await dataSource.savePasswords(passwords);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка сохранения паролей: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, List<PasswordEntry>>> getPasswords() async {
    try {
      final result = await dataSource.getPasswords();
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка чтения паролей: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> removePasswordAt(int index) async {
    try {
      final result = await dataSource.removePasswordAt(index);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка удаления пароля: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, String>> exportPasswords() async {
    try {
      final result = await dataSource.exportPasswords();
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка экспорта паролей: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> importPasswords(String jsonString) async {
    try {
      final result = await dataSource.importPasswords(jsonString);
      return Right(result);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка импорта паролей: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, String>> exportPassgen(String masterPassword) async {
    try {
      final passwords = await dataSource.getPasswords();
      final passgenFormat = PassgenFormat();
      
      final data = passwords.map((p) => p.toJson()).toList();
      final base64Data = await passgenFormat.exportToJson(
        data: data,
        masterPassword: masterPassword,
      );
      
      return Right(base64Data);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка экспорта .passgen: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> importPassgen({
    required String data,
    required String masterPassword,
  }) async {
    try {
      final passgenFormat = PassgenFormat();
      final importedData = await passgenFormat.importFromJson(
        base64Data: data,
        masterPassword: masterPassword,
      );

      final currentPasswords = await dataSource.getPasswords();
      
      // Объединяем пароли, избегая дубликатов по сервису
      final mergedPasswords = List<Map<String, dynamic>>.from(
        currentPasswords.map((p) => p.toJson()),
      );
      
      for (final newEntry in importedData) {
        final existingIndex = mergedPasswords.indexWhere(
          (e) => e['service'].toString().toLowerCase() == newEntry['service'].toString().toLowerCase(),
        );
        if (existingIndex != -1) {
          mergedPasswords[existingIndex] = newEntry;
        } else {
          mergedPasswords.add(newEntry);
        }
      }

      final newPasswords = mergedPasswords
          .map((e) => PasswordEntry.fromJson(e))
          .toList();
      
      await dataSource.savePasswords(newPasswords);
      return const Right(true);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка импорта .passgen: $e'));
    }
  }
}
