import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/password_generator_repository.dart';

/// Использование: Сохранение пароля в хранилище
class SavePasswordUseCase {
  final PasswordGeneratorRepository repository;

  const SavePasswordUseCase(this.repository);

  Future<Either<PasswordGenerationFailure, Map<String, dynamic>>> execute({
    required String service,
    required String password,
    required String config,
    int? categoryId,
    String? login,
  }) async {
    return await repository.savePassword(
      service: service,
      password: password,
      config: config,
      categoryId: categoryId,
      login: login,
    );
  }
}
