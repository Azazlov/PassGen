import '../entities/biometric_type.dart';

/// Интерфейс репозитория биометрии
abstract class BiometricRepository {
  /// Проверяет доступность биометрии на устройстве
  Future<bool> isAvailable();

  /// Выполняет биометрическую аутентификацию
  Future<bool> authenticate({String localizedReason = 'Подтвердите личность'});

  /// Включает биометрию для профиля
  Future<bool> enableForProfile(int profileId, String pin);

  /// Отключает биометрию для профиля
  Future<bool> disableForProfile(int profileId);

  /// Проверяет, включена ли биометрия для профиля
  Future<bool> isEnabledForProfile(int profileId);

  /// Получает PIN профиля из secure storage (после успешной биометрии)
  Future<String?> retrievePinForProfile(int profileId);

  /// Возвращает тип доступной биометрии
  Future<BiometricType> getBiometricType();
}
