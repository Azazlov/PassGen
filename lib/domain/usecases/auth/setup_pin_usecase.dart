import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для установки PIN
class SetupPinUseCase {
  final AuthRepository repository;

  SetupPinUseCase(this.repository);

  Future<Either<AuthFailure, bool>> execute(String pin) async {
    return await repository.setupPin(pin);
  }
}
