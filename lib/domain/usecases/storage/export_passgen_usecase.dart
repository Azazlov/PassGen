import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Экспорт паролей в формат .passgen
class ExportPassgenUseCase {
  final StorageRepository repository;

  const ExportPassgenUseCase(this.repository);

  Future<Either<StorageFailure, String>> execute(String masterPassword) async {
    return await repository.exportPassgen(masterPassword);
  }
}
