import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для смены PIN
class ChangePinUseCase {
  ChangePinUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<AuthFailure, bool>> execute(
    String oldPin,
    String newPin,
  ) async {
    return repository.changePin(oldPin, newPin);
  }
}
