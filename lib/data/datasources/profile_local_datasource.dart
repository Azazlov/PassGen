import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/profile.dart';
import '../../../core/errors/failures.dart';

/// Локальный источник данных профилей (SQLite)
class ProfileLocalDataSource {
  ProfileLocalDataSource({required Database database}) : _database = database;

  final Database _database;

  /// Создаёт новый профиль
  Future<Profile> createProfile(String name, {String? avatarEmoji}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await _database.insert('profiles', {
        'name': name,
        'avatar_emoji': avatarEmoji,
        'created_at': now,
        'last_accessed_at': now,
      });
      return Profile(
        id: id,
        name: name,
        avatarEmoji: avatarEmoji,
        createdAt: DateTime.fromMillisecondsSinceEpoch(now),
        lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(now),
      );
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка создания профиля');
    }
  }

  /// Возвращает список всех профилей
  Future<List<Profile>> getProfiles() async {
    try {
      final results = await _database.query(
        'profiles',
        orderBy: 'created_at ASC',
      );
      return results.map((row) => _mapToProfile(row)).toList();
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка чтения профилей');
    }
  }

  /// Возвращает профиль по ID
  Future<Profile?> getProfileById(int id) async {
    try {
      final results = await _database.query(
        'profiles',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return _mapToProfile(results.first);
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка чтения профиля');
    }
  }

  /// Обновляет профиль
  Future<bool> updateProfile(Profile profile) async {
    try {
      if (profile.id == null) return false;
      final count = await _database.update(
        'profiles',
        {
          'name': profile.name,
          'avatar_emoji': profile.avatarEmoji,
          'last_accessed_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [profile.id],
      );
      return count > 0;
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка обновления профиля');
    }
  }

  /// Удаляет профиль и каскадно все связанные данные
  Future<bool> deleteProfile(int id) async {
    try {
      // SQLite с ON DELETE CASCADE удалит связанные записи автоматически
      // если FK включены (PRAGMA foreign_keys = ON)
      await _database.execute('PRAGMA foreign_keys = ON');
      final count = await _database.delete(
        'profiles',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw const StorageFailure(message: 'Ошибка удаления профиля');
    }
  }

  /// Обновляет last_accessed_at профиля
  Future<bool> touchProfile(int id) async {
    try {
      final count = await _database.update(
        'profiles',
        {'last_accessed_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Profile _mapToProfile(Map<String, dynamic> row) {
    return Profile(
      id: row['id'] as int,
      name: row['name'] as String,
      avatarEmoji: row['avatar_emoji'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      lastAccessedAt: row['last_accessed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['last_accessed_at'] as int)
          : null,
    );
  }
}
