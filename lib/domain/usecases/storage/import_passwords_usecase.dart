import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Импорт паролей
class ImportPasswordsUseCase {
  final StorageRepository repository;

  const ImportPasswordsUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute(String jsonString) async {
    return await repository.importPasswords(jsonString);
  }
}
