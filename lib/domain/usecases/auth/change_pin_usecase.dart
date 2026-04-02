import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для смены PIN
class ChangePinUseCase {
  const ChangePinUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<AuthFailure, bool>> execute(String oldPin, String newPin) {
    return repository.changePin(oldPin, newPin);
  }
}
