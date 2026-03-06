import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../entities/auth_result.dart';
import '../../repositories/auth_repository.dart';

/// Use case для проверки PIN
class VerifyPinUseCase {
  final AuthRepository repository;

  VerifyPinUseCase(this.repository);

  Future<Either<AuthFailure, AuthResult>> execute(String pin) async {
    return await repository.verifyPin(pin);
  }
}
