import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_import_repository.dart';

/// Использование: Импорт паролей из JSON
class ImportPasswordsUseCase {
  final PasswordImportRepository repository;

  const ImportPasswordsUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute(String jsonString) async {
    return await repository.importFromJson(jsonString);
  }
}
