import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Удаление пароля
class DeletePasswordUseCase {
  const DeletePasswordUseCase(this.repository);
  final StorageRepository repository;

  Future<Either<StorageFailure, bool>> execute(int index, {int profileId = 1}) {
    return repository.removePasswordAt(index, profileId: profileId);
  }
}
