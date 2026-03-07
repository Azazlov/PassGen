import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/storage_repository.dart';

/// Использование: Получение конфигов из хранилища
class GetConfigsUseCase {
  final StorageRepository repository;

  const GetConfigsUseCase(this.repository);

  Future<Either<StorageFailure, List<String>>> execute(String key) async {
    return await repository.getConfigs(key);
  }
}
