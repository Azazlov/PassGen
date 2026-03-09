import '../entities/password_config.dart';
import '../entities/password_entry.dart';

/// Интерфейс репозитория записей паролей
abstract class PasswordEntryRepository {
  /// Получение всех записей
  Future<List<PasswordEntry>> getAll();

  /// Получение записи по ID
  Future<PasswordEntry?> getById(int id);

  /// Получение записей по категории
  Future<List<PasswordEntry>> getByCategory(int categoryId);

  /// Поиск записей по названию сервиса
  Future<List<PasswordEntry>> searchByService(String query);

  /// Создание записи
  Future<PasswordEntry> create(PasswordEntry entry, {int? categoryId});

  /// Обновление записи
  Future<PasswordEntry> update(PasswordEntry entry);

  /// Удаление записи
  Future<void> delete(int id);

  /// Получение конфигурации для записи
  Future<PasswordConfig?> getConfig(int entryId);

  /// Сохранение конфигурации для записи
  Future<void> saveConfig(int entryId, PasswordConfig config);
}
