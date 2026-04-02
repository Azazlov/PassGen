import 'dart:developer' as dev;

import '../../entities/auth_state.dart';
import '../../repositories/auth_repository.dart';

/// Use case для получения состояния аутентификации
class GetAuthStateUseCase {
  GetAuthStateUseCase(this.repository);
  final AuthRepository repository;

  Future<AuthState> execute() async {
    dev.log('[GetAuthStateUseCase] execute вызван');
    dev.log('[GetAuthStateUseCase] repository = $repository');
    
    final isPinSetup = await repository.isPinSetup();
    dev.log('[GetAuthStateUseCase] isPinSetup = $isPinSetup');
    
    return AuthState(
      isPinSetup: isPinSetup,
      isAuthenticated: false,
      isLocked: false,
    );
  }
}
