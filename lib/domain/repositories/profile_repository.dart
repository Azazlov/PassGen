import '../entities/profile.dart';

/// Интерфейс репозитория профилей
abstract class ProfileRepository {
  /// Создаёт новый профиль
  Future<Profile> createProfile(String name, {String? avatarEmoji});

  /// Возвращает список всех профилей
  Future<List<Profile>> getProfiles();

  /// Возвращает профиль по ID
  Future<Profile?> getProfileById(int id);

  /// Обновляет профиль
  Future<bool> updateProfile(Profile profile);

  /// Удаляет профиль и все связанные данные
  Future<bool> deleteProfile(int id);

  /// Устанавливает активный профиль
  Future<bool> setActiveProfile(int id);

  /// Возвращает ID активного профиля (или null)
  Future<int?> getActiveProfileId();
}
