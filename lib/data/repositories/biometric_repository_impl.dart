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
  Future<bool> authenticate({
    String localizedReason = 'Подтвердите личность',
    bool biometricOnly = true,
  }) {
    return _dataSource.authenticate(
      localizedReason: localizedReason,
      biometricOnly: biometricOnly,
    );
  }

  @override
  Future<bool> enableForProfile(int profileId, String pin) async {
    if (!await isAvailable()) {
      throw const AuthFailure(
        message: 'Биометрия недоступна на устройстве',
        type: AuthFailureType.general,
      );
    }

    // 1) Биометрическая авторизация
    bool authorized;
    try {
      authorized = await authenticate(
        localizedReason:
            'Подтвердите биометрией или кодом устройства включение входа в приложение',
        biometricOnly: false,
      );
    } on StorageFailure catch (e) {
      // Теоретически сюда StorageFailure не должен попадать (т.к. это auth),
      // но оставляем для полноты.
      throw AuthFailure(message: e.message, type: AuthFailureType.general);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(
        message: 'Ошибка биометрической аутентификации: $e',
        type: AuthFailureType.general,
      );
    }

    if (!authorized) return false;

    // 2) Запись PIN под биометрическим гейтом ОС
    try {
      await _dataSource.enableForProfile(profileId, pin);
      return true;
    } on StorageFailure catch (e) {
      // Важно: показываем, что именно упало при сохранении.
      throw AuthFailure(
        message: 'Ошибка сохранения PIN для биометрии: ${e.message}',
        type: AuthFailureType.general,
      );
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(
        message: 'Ошибка сохранения PIN для биометрии: $e',
        type: AuthFailureType.general,
      );
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
  Future<bool> updatePinForProfile(int profileId, String pin) async {
    try {
      await _dataSource.updatePinForProfile(profileId, pin);
      return true;
    } on StorageFailure catch (e) {
      throw AuthFailure(message: e.message, type: AuthFailureType.general);
    } catch (e) {
      throw const AuthFailure(message: 'Ошибка обновления PIN для биометрии');
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
