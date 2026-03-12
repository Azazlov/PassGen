import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/password_entry.dart';

/// Локальный источник данных для хранилища
class StorageLocalDataSource {
  static const String _passwordsKey = 'saved_passwords';

  /// Сохраняет список строк по ключу
  Future<bool> saveConfig(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(key, value);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка сохранения: $e');
    }
  }

  /// Получает список строк по ключу
  Future<List<String>?> getConfigs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка чтения: $e');
    }
  }

  /// Удаляет всё хранилище по ключу
  Future<bool> removeConfigs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка удаления: $e');
    }
  }

  /// Удаляет конфиг по индексу
  Future<bool> removeConfigAt(String key, int index) async {
    try {
      final configs = await getConfigs(key);
      if (configs == null || configs.isEmpty) {
        throw const StorageFailure(message: 'Хранилище пустое');
      }

      final newConfigs = <String>[];
      for (int i = 0; i < configs.length; i++) {
        if (i != index) {
          newConfigs.add(configs[i]);
        }
      }

      return await saveConfig(key, newConfigs);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка удаления конфига: $e');
    }
  }

  /// Очищает всё хранилище
  Future<bool> clearStorage(String key) async {
    return removeConfigs(key);
  }

  /// Сохраняет список паролей
  Future<bool> savePasswords(List<PasswordEntry> passwords) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = PasswordEntry.encodeList(passwords);
      return await prefs.setString(_passwordsKey, jsonString);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка сохранения паролей: $e');
    }
  }

  /// Получает список паролей
  Future<List<PasswordEntry>> getPasswords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_passwordsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      return PasswordEntry.decodeList(jsonString);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка чтения паролей: $e');
    }
  }

  /// Удаляет пароль по индексу
  Future<bool> removePasswordAt(int index) async {
    try {
      final passwords = await getPasswords();
      if (passwords.isEmpty) {
        throw const StorageFailure(message: 'Хранилище паролей пустое');
      }

      final newPasswords = <PasswordEntry>[];
      for (int i = 0; i < passwords.length; i++) {
        if (i != index) {
          newPasswords.add(passwords[i]);
        }
      }

      return await savePasswords(newPasswords);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка удаления пароля: $e');
    }
  }

  /// Экспортирует пароли в JSON строку
  Future<String> exportPasswords() async {
    try {
      final passwords = await getPasswords();
      return PasswordEntry.encodeList(passwords);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка экспорта паролей: $e');
    }
  }

  /// Импортирует пароли из JSON строки
  ///
  /// v0.5.1: Добавлена проверка дубликатов (service + login)
  /// v0.5.1: Обработка ошибок с rollback
  Future<bool> importPasswords(String jsonString) async {
    List<PasswordEntry>? originalPasswords;
    
    try {
      final newPasswords = PasswordEntry.decodeList(jsonString);
      final currentPasswords = await getPasswords();
      
      // Сохраняем оригинальные пароли для rollback (v0.5.1)
      originalPasswords = List<PasswordEntry>.from(currentPasswords);

      // Объединяем пароли, избегая дубликатов по service + login (v0.5.1)
      final mergedPasswords = List<PasswordEntry>.from(currentPasswords);
      int duplicateCount = 0;
      
      for (final newPassword in newPasswords) {
        final existingIndex = mergedPasswords.indexWhere(
          (e) => 
            e.service.toLowerCase() == newPassword.service.toLowerCase() &&
            e.login == newPassword.login,
        );
        if (existingIndex != -1) {
          // Обновляем существующий (v0.5.1)
          mergedPasswords[existingIndex] = newPassword;
          duplicateCount++;
        } else {
          // Добавляем новый
          mergedPasswords.add(newPassword);
        }
      }

      // Логируем количество обновлённых дубликатов
      if (duplicateCount > 0) {
        print('Импорт: обновлено $duplicateCount дубликатов');
      }

      return await savePasswords(mergedPasswords);
    } catch (e) {
      // Rollback при ошибке (v0.5.1)
      if (originalPasswords != null) {
        try {
          await savePasswords(originalPasswords);
          print('Импорт: выполнен rollback после ошибки');
        } catch (rollbackError) {
          print('Импорт: ошибка rollback: $rollbackError');
        }
      }
      throw StorageFailure(message: 'Ошибка импорта паролей: $e');
    }
  }
}
