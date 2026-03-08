import 'package:dartz/dartz.dart';
import 'dart:convert';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/repositories/password_import_repository.dart';
import '../datasources/storage_local_datasource.dart';
import '../formats/passgen_format.dart';

/// Реализация репозитория импорта паролей
class PasswordImportRepositoryImpl implements PasswordImportRepository {
  final StorageLocalDataSource dataSource;
  final PassgenFormat passgenFormat;

  const PasswordImportRepositoryImpl(this.dataSource, this.passgenFormat);

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

      // ignore: dead_null_aware_expression
      final existing = await dataSource.getPasswords() ?? [];
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

      // ignore: dead_null_aware_expression
      final existing = await dataSource.getPasswords() ?? [];
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
