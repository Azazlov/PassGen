import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для установки PIN
class SetupPinUseCase {
  SetupPinUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<AuthFailure, bool>> execute(String pin) async {
    return repository.setupPin(pin);
  }
}
