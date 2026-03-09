import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_import_repository.dart';

/// Использование: Импорт паролей из формата .passgen
class ImportPassgenUseCase {
  const ImportPassgenUseCase(this.repository);
  final PasswordImportRepository repository;

  Future<Either<StorageFailure, bool>> execute({
    required String data,
    required String masterPassword,
  }) async {
    return repository.importFromPassgen(
      data: data,
      masterPassword: masterPassword,
    );
  }
}
