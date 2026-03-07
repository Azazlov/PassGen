import '../../entities/auth_state.dart';
import '../../repositories/auth_repository.dart';

/// Use case для получения состояния аутентификации
class GetAuthStateUseCase {
  final AuthRepository repository;

  GetAuthStateUseCase(this.repository);

  Future<AuthState> execute() async {
    return await repository.getAuthState();
  }
}
