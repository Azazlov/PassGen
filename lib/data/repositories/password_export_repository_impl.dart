import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/password_export_repository.dart';
import '../datasources/storage_local_datasource.dart';
import '../formats/passgen_format.dart';
import 'dart:convert';

/// Реализация репозитория экспорта паролей
class PasswordExportRepositoryImpl implements PasswordExportRepository {
  final StorageLocalDataSource dataSource;
  final PassgenFormat passgenFormat;

  const PasswordExportRepositoryImpl(this.dataSource, this.passgenFormat);

  @override
  Future<Either<StorageFailure, String>> exportToJson() async {
    try {
      final passwords = await dataSource.getPasswords();
      if (passwords == null) {
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
      if (passwords == null) {
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
}
