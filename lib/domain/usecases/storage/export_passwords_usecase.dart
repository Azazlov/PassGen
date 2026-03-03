import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Экспорт паролей
class ExportPasswordsUseCase {
  final StorageRepository repository;

  const ExportPasswordsUseCase(this.repository);

  Future<Either<StorageFailure, String>> execute() async {
    return await repository.exportPasswords();
  }
}
