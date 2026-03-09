import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_import_repository.dart';

/// Использование: Импорт паролей из JSON
class ImportPasswordsUseCase {
  const ImportPasswordsUseCase(this.repository);
  final PasswordImportRepository repository;

  Future<Either<StorageFailure, bool>> execute(String jsonString) async {
    return repository.importFromJson(jsonString);
  }
}
