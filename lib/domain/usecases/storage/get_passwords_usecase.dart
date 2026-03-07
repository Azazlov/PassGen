import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_entry.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Получение списка паролей
class GetPasswordsUseCase {
  final StorageRepository repository;

  const GetPasswordsUseCase(this.repository);

  Future<Either<StorageFailure, List<PasswordEntry>>> execute() async {
    return await repository.getPasswords();
  }
}
