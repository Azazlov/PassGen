import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_data_repository.dart';

/// Использование: Импорт паролей из формата .passgen
class ImportPassgenUseCase {
  const ImportPassgenUseCase(this.repository);
  final PasswordDataRepository repository;

  Future<Either<StorageFailure, bool>> execute({
    required String data,
    required String masterPassword,
    int profileId = 1,
  }) {
    return repository.importFromPassgen(
      data: data,
      masterPassword: masterPassword,
      profileId: profileId,
    );
  }
}
