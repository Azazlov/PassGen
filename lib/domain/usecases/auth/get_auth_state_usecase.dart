import '../../entities/auth_state.dart';
import '../../repositories/auth_repository.dart';

/// Use case для получения состояния аутентификации
class GetAuthStateUseCase {
  const GetAuthStateUseCase(this.repository);
  final AuthRepository repository;

  Future<AuthState> execute() {
    return repository.getAuthState();
  }
}
