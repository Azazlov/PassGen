import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_export_repository.dart';

/// Использование: Экспорт паролей в формат .passgen
class ExportPassgenUseCase {
  const ExportPassgenUseCase(this.repository);
  final PasswordExportRepository repository;

  Future<Either<StorageFailure, String>> execute(String masterPassword) async {
    return repository.exportToPassgen(masterPassword);
  }
}
