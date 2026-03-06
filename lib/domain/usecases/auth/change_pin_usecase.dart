import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для смены PIN
class ChangePinUseCase {
  final AuthRepository repository;

  ChangePinUseCase(this.repository);

  Future<Either<AuthFailure, bool>> execute(String oldPin, String newPin) async {
    return await repository.changePin(oldPin, newPin);
  }
}
