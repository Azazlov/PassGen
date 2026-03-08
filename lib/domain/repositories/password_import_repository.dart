import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Интерфейс репозитория для импорта паролей
abstract class PasswordImportRepository {
  /// Импортирует пароли из JSON строки
  Future<Either<StorageFailure, bool>> importFromJson(String jsonString);

  /// Импортирует пароли из формата .passgen
  Future<Either<StorageFailure, bool>> importFromPassgen({
    required String data,
    required String masterPassword,
  });
}
