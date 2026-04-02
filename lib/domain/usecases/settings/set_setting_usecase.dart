import '../../repositories/app_settings_repository.dart';

/// Использование: Сохранение настройки
class SetSettingUseCase {
  const SetSettingUseCase(this.repository);
  final AppSettingsRepository repository;

  Future<void> execute(
    String key,
    String value, {
    bool encrypted = false,
  }) async {
    await repository.setValue(key, value, encrypted: encrypted);
  }
}
