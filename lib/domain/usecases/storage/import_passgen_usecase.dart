import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Импорт паролей из формата .passgen
class ImportPassgenUseCase {
  final StorageRepository repository;

  const ImportPassgenUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute({
    required String data,
    required String masterPassword,
  }) async {
    return await repository.importPassgen(
      data: data,
      masterPassword: masterPassword,
    );
  }
}
