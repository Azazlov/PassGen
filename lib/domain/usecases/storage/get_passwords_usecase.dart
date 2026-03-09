import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_entry.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Получение списка паролей
class GetPasswordsUseCase {
  const GetPasswordsUseCase(this.repository);
  final StorageRepository repository;

  Future<Either<StorageFailure, List<PasswordEntry>>> execute() async {
    return repository.getPasswords();
  }
}
