import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_export_repository.dart';

/// Использование: Экспорт паролей в формат .passgen
class ExportPassgenUseCase {
  final PasswordExportRepository repository;

  const ExportPassgenUseCase(this.repository);

  Future<Either<StorageFailure, String>> execute(String masterPassword) async {
    return await repository.exportToPassgen(masterPassword);
  }
}
