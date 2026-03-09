import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/password_entry.dart';
import '../../../../domain/repositories/password_data_repository.dart';
import '../datasources/storage_local_datasource.dart';
import '../formats/passgen_format.dart';
import 'dart:convert';

/// Реализация репозитория импорта/экспорта паролей
class PasswordDataRepositoryImpl implements PasswordDataRepository {
  final StorageLocalDataSource dataSource;
  final PassgenFormat passgenFormat;

  const PasswordDataRepositoryImpl(this.dataSource, this.passgenFormat);

  @override
  Future<Either<StorageFailure, String>> exportToJson() async {
    try {
      final passwords = await dataSource.getPasswords();
      if (passwords.isEmpty) {
        return Left(StorageFailure(message: 'Нет паролей для экспорта'));
      }

      final jsonList = passwords.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return Right(jsonString);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка экспорта: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, String>> exportToPassgen(String masterPassword) async {
    try {
      final passwords = await dataSource.getPasswords();
      if (passwords.isEmpty) {
        return Left(StorageFailure(message: 'Нет паролей для экспорта'));
      }

      final data = passwords.map((p) => p.toJson()).toList();
      final encrypted = await passgenFormat.exportToJson(
        data: data,
        masterPassword: masterPassword,
      );
      return Right(encrypted);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка экспорта .passgen: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> importFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded == null || decoded is! List) {
        return Left(StorageFailure(message: 'Неверный формат JSON'));
      }

      final passwords = decoded
          .map((e) => PasswordEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final existing = await dataSource.getPasswords();
      existing.addAll(passwords);

      await dataSource.savePasswords(existing);
      return Right(true);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка импорта: $e'));
    }
  }

  @override
  Future<Either<StorageFailure, bool>> importFromPassgen({
    required String data,
    required String masterPassword,
  }) async {
    try {
      final decrypted = await passgenFormat.importFromJson(
        base64Data: data,
        masterPassword: masterPassword,
      );

      final passwords = (decrypted as List)
          .map((e) => PasswordEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final existing = await dataSource.getPasswords();
      existing.addAll(passwords);

      await dataSource.savePasswords(existing);
      return Right(true);
    } catch (e) {
      if (e is StorageFailure) {
        return Left(e);
      }
      return Left(StorageFailure(message: 'Ошибка импорта .passgen: $e'));
    }
  }
}
