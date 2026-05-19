import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Реализация репозитория аутентификации (per-profile)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;
  int? _currentProfileId;

  int get _profileId => _currentProfileId ?? 1;

  @override
  void setCurrentProfileId(int? profileId) {
    _currentProfileId = profileId;
  }

  @override
  Future<bool> isPinSetup() {
    return _dataSource.isPinSetup(profileId: _profileId);
  }

  @override
  Future<Either<AuthFailure, bool>> setupPin(String pin) async {
    try {
      if (!_dataSource.isValidPinFormat(pin)) {
        return left(
          const AuthFailure(
            message: 'PIN должен содержать от 4 до 8 цифр',
            type: AuthFailureType.validation,
          ),
        );
      }
      final result = await _dataSource.setupPin(pin, profileId: _profileId);
      return right(result);
    } on ValidationFailure catch (e) {
      return left(AuthFailure(message: e.message, type: AuthFailureType.validation));
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    } catch (e) {
      return left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthResult>> verifyPin(String pin) async {
    try {
      final result = await _dataSource.verifyPin(pin, profileId: _profileId);
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
      if (!_dataSource.isValidPinFormat(newPin)) {
        return left(
          const AuthFailure(
            message: 'PIN должен содержать от 4 до 8 цифр',
            type: AuthFailureType.validation,
          ),
        );
      }
      final result = await _dataSource.changePin(
        oldPin,
        newPin,
        profileId: _profileId,
      );
      return right(result);
    } on ValidationFailure catch (e) {
      return left(AuthFailure(message: e.message, type: AuthFailureType.validation));
    } on AuthFailure catch (e) {
      return left(e);
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> removePin(String pin) async {
    try {
      final result = await _dataSource.removePin(pin, profileId: _profileId);
      return right(result);
    } on AuthFailure catch (e) {
      return left(e);
    } on StorageFailure catch (e) {
      return left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<AuthState> getAuthState() async {
    final state = await _dataSource.getAuthState(profileId: _profileId);
    return AuthState(
      isPinSetup: state['isPinSetup'] as bool,
      isLocked: state['isLocked'] as bool,
      remainingAttempts: state['remainingAttempts'] as int?,
      lockoutUntil: state['lockoutUntil'] as DateTime?,
      lockoutSeriesIndex: (state['seriesIndex'] as int?) ?? 0,
      currentProfileId: _profileId,
      isBiometricEnabled: state['biometricEnabled'] as bool? ?? false,
    );
  }

  @override
  void resetAuthState() {
    _dataSource.resetAuthState(profileId: _profileId);
  }
}
