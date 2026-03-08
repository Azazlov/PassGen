import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_export_repository.dart';

/// Использование: Экспорт паролей в JSON
class ExportPasswordsUseCase {
  final PasswordExportRepository repository;

  const ExportPasswordsUseCase(this.repository);

  Future<Either<StorageFailure, String>> execute() async {
    return await repository.exportToJson();
  }
}
