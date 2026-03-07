/// Интерфейс репозитория настроек приложения
abstract class AppSettingsRepository {
  /// Получение настройки по ключу
  Future<String?> getValue(String key);

  /// Получение настройки по ключу со значением по умолчанию
  Future<String> getValueOrDefault(String key, String defaultValue);

  /// Сохранение настройки
  Future<void> setValue(String key, String value, {bool encrypted = false});

  /// Удаление настройки
  Future<void> remove(String key);

  /// Получение всех настроек
  Future<Map<String, String>> getAll();

  /// Очистка всех настроек
  Future<void> clear();
}
