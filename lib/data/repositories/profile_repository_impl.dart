import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

/// Реализация репозитория профилей
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource dataSource,
    SharedPreferences? prefs,
  })  : _dataSource = dataSource,
        _prefs = prefs;

  final ProfileLocalDataSource _dataSource;
  final SharedPreferences? _prefs;

  static const String _activeProfileKey = 'active_profile_id';

  @override
  Future<Profile> createProfile(String name, {String? avatarEmoji}) {
    return _dataSource.createProfile(name, avatarEmoji: avatarEmoji);
  }

  @override
  Future<List<Profile>> getProfiles() {
    return _dataSource.getProfiles();
  }

  @override
  Future<Profile?> getProfileById(int id) {
    return _dataSource.getProfileById(id);
  }

  @override
  Future<bool> updateProfile(Profile profile) {
    return _dataSource.updateProfile(profile);
  }

  @override
  Future<bool> deleteProfile(int id) async {
    final result = await _dataSource.deleteProfile(id);
    // Если удалили активный профиль — сбрасываем
    final activeId = await getActiveProfileId();
    if (activeId == id) {
      await _prefs?.remove(_activeProfileKey);
    }
    return result;
  }

  @override
  Future<bool> setActiveProfile(int id) async {
    try {
      await _dataSource.touchProfile(id);
      if (_prefs != null) {
        await _prefs.setInt(_activeProfileKey, id);
      }
      return true;
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка установки активного профиля');
    }
  }

  @override
  Future<int?> getActiveProfileId() async {
    try {
      return _prefs?.getInt(_activeProfileKey);
    } catch (e) {
      return null;
    }
  }
}
