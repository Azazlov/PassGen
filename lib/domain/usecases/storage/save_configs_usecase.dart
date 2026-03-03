import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Сохранение конфигов в хранилище
class SaveConfigsUseCase {
  final StorageRepository repository;

  const SaveConfigsUseCase(this.repository);

  Future<Either<StorageFailure, bool>> execute({
    required String key,
    required List<String> configs,
  }) async {
    return await repository.saveConfigs(key, configs);
  }
}
