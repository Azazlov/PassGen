import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для удаления PIN
class RemovePinUseCase {
  const RemovePinUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<AuthFailure, bool>> execute(String pin) {
    return repository.removePin(pin);
  }
}
