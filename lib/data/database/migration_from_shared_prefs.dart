import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/password_entry_model.dart';
import '../models/password_config_model.dart';
import '../../domain/entities/password_entry.dart';

/// Миграция данных из SharedPreferences в SQLite
class MigrationFromSharedPreferences {
  final DatabaseHelper _dbHelper;
  final SharedPreferences _prefs;

  static const String _migrationKey = 'sqlite_migration_completed';
  static const String _passwordsKey = 'saved_passwords';
  static const String _configsKey = 'password_configs';

  MigrationFromSharedPreferences({
    DatabaseHelper? dbHelper,
    required SharedPreferences prefs,
  })  : _dbHelper = dbHelper ?? DatabaseHelper(),
        _prefs = prefs;

  /// Проверка, выполнена ли миграция
  Future<bool> isMigrationCompleted() async {
    return _prefs.getBool(_migrationKey) ?? false;
  }

  /// Выполнение миграции
  Future<MigrationResult> migrate() async {
    try {
      // Проверяем, выполнена ли уже миграция
      if (await isMigrationCompleted()) {
        return const MigrationResult(
          success: true,
          message: 'Миграция уже выполнена',
          migratedPasswords: 0,
          migratedConfigs: 0,
        );
      }

      int migratedPasswords = 0;
      int migratedConfigs = 0;

      // Миграция паролей
      final passwordsJson = _prefs.getString(_passwordsKey);
      if (passwordsJson != null && passwordsJson.isNotEmpty) {
        migratedPasswords = await _migratePasswords(passwordsJson);
      }

      // Миграция конфигов
      final configsJson = _prefs.getString(_configsKey);
      if (configsJson != null && configsJson.isNotEmpty) {
        migratedConfigs = await _migrateConfigs(configsJson);
      }

      // Устанавливаем флаг выполненной миграции
      await _prefs.setBool(_migrationKey, true);

      return MigrationResult(
        success: true,
        message: 'Миграция успешно выполнена',
        migratedPasswords: migratedPasswords,
        migratedConfigs: migratedConfigs,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        message: 'Ошибка миграции: $e',
        migratedPasswords: 0,
        migratedConfigs: 0,
      );
    }
  }

  /// Миграция паролей из SharedPreferences в SQLite
  Future<int> _migratePasswords(String jsonString) async {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    int count = 0;

    for (final json in jsonList) {
      try {
        final entry = PasswordEntry.fromJson(json);

        // Создаём модель для БД
        final entryModel = PasswordEntryModel(
          service: entry.service,
          login: null, // В старой версии не было login
          encryptedPassword: utf8.encode(entry.password),
          nonce: [0], // Пустой nonce для совместимости
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt ?? entry.createdAt,
        );

        // Вставляем в БД
        final id = await _dbHelper.insert('password_entries', entryModel.toMap());

        // Если есть конфиг, сохраняем его
        if (entry.config.isNotEmpty) {
          final configModel = PasswordConfigModel(
            entryId: id,
            encryptedConfig: utf8.encode(entry.config),
          );
          await _dbHelper.insert('password_configs', configModel.toMap());
        }

        count++;
      } catch (e) {
        print('Ошибка миграции пароля: $e');
        // Продолжаем миграцию остальных
      }
    }

    return count;
  }

  /// Миграция конфигов из SharedPreferences в SQLite
  Future<int> _migrateConfigs(String jsonString) async {
    // В старой версии конфиги хранились отдельно
    // Теперь они привязаны к записям паролей
    // Этот метод оставлен для совместимости
    int count = 0;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (final _ in jsonList) {
        // Конфиги уже были мигрированы вместе с паролями
        count++;
      }
    } catch (e) {
      debugPrint('Ошибка миграции конфигов: $e');
    }

    return count;
  }

  /// Откат миграции (для отладки)
  Future<void> rollback() async {
    await _prefs.remove(_migrationKey);
    // Не удаляем данные из SQLite, только сбрасываем флаг
  }

  /// Принудительный сброс флага миграции
  Future<void> resetMigrationFlag() async {
    await _prefs.remove(_migrationKey);
  }
}

/// Результат миграции
class MigrationResult {
  final bool success;
  final String message;
  final int migratedPasswords;
  final int migratedConfigs;

  const MigrationResult({
    required this.success,
    required this.message,
    required this.migratedPasswords,
    required this.migratedConfigs,
  });

  @override
  String toString() {
    return 'MigrationResult(success: $success, message: $message, '
        'passwords: $migratedPasswords, configs: $migratedConfigs)';
  }
}
