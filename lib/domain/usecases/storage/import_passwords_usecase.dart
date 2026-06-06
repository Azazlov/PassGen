import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_data_repository.dart';

/// Использование: Импорт паролей из JSON
class ImportPasswordsUseCase {
  const ImportPasswordsUseCase(this.repository);
  final PasswordDataRepository repository;

  Future<Either<StorageFailure, bool>> execute(String jsonString, {int profileId = 1}) {
    return repository.importFromJson(jsonString, profileId: profileId);
  }
}
