import '../../core/errors/failures.dart';
import '../../domain/entities/biometric_type.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../datasources/biometric_local_datasource.dart';

/// Реализация репозитория биометрии
class BiometricRepositoryImpl implements BiometricRepository {
  BiometricRepositoryImpl(this._dataSource);

  final BiometricLocalDataSource _dataSource;

  @override
  Future<bool> isAvailable() => _dataSource.isAvailable();

  @override
  Future<bool> authenticate({String localizedReason = 'Подтвердите личность'}) {
    return _dataSource.authenticate(localizedReason: localizedReason);
  }

  @override
  Future<bool> enableForProfile(int profileId, String pin) async {
    try {
      await _dataSource.enableForProfile(profileId, pin);
      return true;
    } on StorageFailure catch (e) {
      throw AuthFailure(message: e.message, type: AuthFailureType.general);
    } catch (e) {
      throw const AuthFailure(message: 'Ошибка включения биометрии');
    }
  }

  @override
  Future<bool> disableForProfile(int profileId) async {
    try {
      await _dataSource.disableForProfile(profileId);
      return true;
    } on StorageFailure catch (e) {
      throw AuthFailure(message: e.message, type: AuthFailureType.general);
    } catch (e) {
      throw const AuthFailure(message: 'Ошибка отключения биометрии');
    }
  }

  @override
  Future<bool> isEnabledForProfile(int profileId) {
    return _dataSource.isEnabledForProfile(profileId);
  }

  @override
  Future<String?> retrievePinForProfile(int profileId) {
    return _dataSource.retrievePinForProfile(profileId);
  }

  @override
  Future<BiometricType> getBiometricType() => _dataSource.getBiometricType();
}
