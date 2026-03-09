import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_data_repository.dart';

/// Использование: Экспорт паролей в JSON
class ExportPasswordsUseCase {
  const ExportPasswordsUseCase(this.repository);
  final PasswordDataRepository repository;

  Future<Either<StorageFailure, String>> execute() async {
    return repository.exportToJson();
  }
}
