import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_import_repository.dart';

/// Использование: Импорт паролей из формата .passgen
class ImportPassgenUseCase {
  final PasswordImportRepository repository;

  const ImportPassgenUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute({
    required String data,
    required String masterPassword,
  }) async {
    return await repository.importFromPassgen(
      data: data,
      masterPassword: masterPassword,
    );
  }
}
