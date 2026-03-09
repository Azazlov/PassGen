import '../../repositories/app_settings_repository.dart';

/// Использование: Получение настройки
class GetSettingUseCase {
  const GetSettingUseCase(this.repository);
  final AppSettingsRepository repository;

  Future<String?> execute(String key) async {
    return repository.getValue(key);
  }
}
