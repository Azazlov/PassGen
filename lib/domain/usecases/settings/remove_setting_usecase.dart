import '../../repositories/app_settings_repository.dart';

/// Использование: Удаление настройки
class RemoveSettingUseCase {
  final AppSettingsRepository repository;

  const RemoveSettingUseCase(this.repository);

  Future<void> execute(String key) async {
    await repository.remove(key);
  }
}
