import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Интерфейс репозитория для экспорта паролей
abstract class PasswordExportRepository {
  /// Экспортирует пароли в JSON строку
  Future<Either<StorageFailure, String>> exportToJson();

  /// Экспортирует пароли в формат .passgen
  Future<Either<StorageFailure, String>> exportToPassgen(String masterPassword);
}
