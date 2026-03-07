import '../../repositories/app_settings_repository.dart';

/// Использование: Получение настройки
class GetSettingUseCase {
  final AppSettingsRepository repository;

  const GetSettingUseCase(this.repository);

  Future<String?> execute(String key) async {
    return await repository.getValue(key);
  }
}
