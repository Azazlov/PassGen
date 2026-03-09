import '../../domain/repositories/app_settings_repository.dart';
import '../database/database_helper.dart';
import '../models/app_settings_model.dart';

/// Реализация репозитория настроек приложения для SQLite
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  @override
  Future<String?> getValue(String key) async {
    final map = await _dbHelper.queryFirst(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (map == null) return null;
    return map['value'] as String;
  }

  @override
  Future<String> getValueOrDefault(String key, String defaultValue) async {
    final value = await getValue(key);
    return value ?? defaultValue;
  }

  @override
  Future<void> setValue(
    String key,
    String value, {
    bool encrypted = false,
  }) async {
    final model = AppSettingsModel(
      key: key,
      value: value,
      encrypted: encrypted,
    );
    await _dbHelper.insertWithConflict(
      'app_settings',
      model.toMap(),
      conflictColumn: 'key',
    );
  }

  @override
  Future<void> remove(String key) async {
    await _dbHelper.deleteWhere(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<Map<String, String>> getAll() async {
    final maps = await _dbHelper.queryAll('app_settings');
    return maps.fold<Map<String, String>>({}, (acc, map) {
      acc[map['key'] as String] = map['value'] as String;
      return acc;
    });
  }

  @override
  Future<void> clear() async {
    await _dbHelper.deleteAll('app_settings');
  }
}
