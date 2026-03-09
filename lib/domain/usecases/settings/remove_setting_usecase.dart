import '../../repositories/app_settings_repository.dart';

/// Использование: Удаление настройки
class RemoveSettingUseCase {
  const RemoveSettingUseCase(this.repository);
  final AppSettingsRepository repository;

  Future<void> execute(String key) async {
    await repository.remove(key);
  }
}
