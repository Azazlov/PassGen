import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

/// Use case для удаления PIN
class RemovePinUseCase {
  final AuthRepository repository;

  RemovePinUseCase(this.repository);

  Future<Either<AuthFailure, bool>> execute(String pin) async {
    return await repository.removePin(pin);
  }
}
