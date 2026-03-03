import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/password_entry.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Удаление пароля
class DeletePasswordUseCase {
  final StorageRepository repository;

  const DeletePasswordUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute(int index) async {
    return await repository.removePasswordAt(index);
  }
}
