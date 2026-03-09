import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Реализация репозитория аутентификации
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.dataSource);
  final AuthLocalDataSource dataSource;

  @override
  Future<bool> isPinSetup() async {
    return dataSource.isPinSetup();
  }

  @override
  Future<Either<AuthFailure, bool>> setupPin(String pin) async {
    try {
      if (!dataSource.isValidPinFormat(pin)) {
        return left(
          const AuthFailure(
            message: 'PIN должен содержать от 4 до 8 цифр',
            type: AuthFailureType.validation,
          ),
        );
      }

      final result = await dataSource.setupPin(pin);
      return right(result);
    } on ValidationFailure catch (e) {
      return left(
        AuthFailure(message: e.message, type: AuthFailureType.validation),
      );
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<AuthFailure, AuthResult>> verifyPin(String pin) async {
    try {
      final result = await dataSource.verifyPin(pin);
      final resultString = result['result'] as String;

      final authResult = switch (resultString) {
        'success' => AuthResult.success,
        'wrongPin' => AuthResult.wrongPin,
        'locked' => AuthResult.locked,
        'notSetup' => AuthResult.notSetup,
        _ => AuthResult.wrongPin,
      };

      return right(authResult);
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> changePin(
    String oldPin,
    String newPin,
  ) async {
    try {
      if (!dataSource.isValidPinFormat(newPin)) {
        return left(
          const AuthFailure(
            message: 'PIN должен содержать от 4 до 8 цифр',
            type: AuthFailureType.validation,
          ),
        );
      }

      final result = await dataSource.changePin(oldPin, newPin);
      return right(result);
    } on ValidationFailure catch (e) {
      return left(
        AuthFailure(message: e.message, type: AuthFailureType.validation),
      );
    } on AuthFailure catch (e) {
      return left(e);
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> removePin(String pin) async {
    try {
      final result = await dataSource.removePin(pin);
      return right(result);
    } on AuthFailure catch (e) {
      return left(e);
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<AuthState> getAuthState() async {
    final state = await dataSource.getAuthState();

    return AuthState(
      isPinSetup: state['isPinSetup'] as bool,
      isLocked: state['isLocked'] as bool,
      remainingAttempts: state['remainingAttempts'] as int?,
      lockoutUntil: state['lockoutUntil'] as DateTime?,
    );
  }

  @override
  void resetAuthState() {
    dataSource.resetAuthState();
  }

  @override
  Future<bool> checkLockoutExpired() async {
    return dataSource.checkLockoutExpired();
  }
}
