import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/security/vault_key_session.dart';
import '../../domain/entities/password_entry.dart';
import '../database/database_helper.dart';
import 'encryptor_local_datasource.dart';

/// Локальный источник данных для хранилища.
///
/// Пароли хранятся в SQLite (таблицы `password_entries` + `password_configs`).
/// Прочие конфиги (списки строк генератора и т.п.) — в `SharedPreferences`.
///
/// Один раз при первом запуске после обновления выполняется миграция
/// `SharedPreferences['saved_passwords']` → SQLite. Флаг `_migrationFlagKey`
/// в `SharedPreferences` помечает успешное завершение.
///
/// Полевое шифрование (схема v5): если в [VaultKeySession] есть активный ключ
/// для текущего профиля, `service`/`login` шифруются при записи и
/// дешифруются при чтении. Без ключа (в тестах, до первого unlock'а)
/// работаем с plaintext-колонками — функциональность не ломается.
class StorageLocalDataSource {
  StorageLocalDataSource({
    DatabaseHelper? db,
    EncryptorLocalDataSource? encryptor,
  })  : _db = db ?? DatabaseHelper(),
        _encryptor = encryptor ?? EncryptorLocalDataSource();

  final DatabaseHelper _db;
  final EncryptorLocalDataSource _encryptor;

  /// Старый ключ паролей в SharedPreferences (миграция → SQLite).
  static const String _legacyPasswordsKey = 'saved_passwords';

  /// Флаг успешной миграции SharedPreferences → SQLite.
  static const String _migrationFlagKey = 'sp_to_sqlite_passwords_migrated';

  /// id профиля по умолчанию (соответствует строке, создаваемой
  /// миграцией v3→v4 в `database_migrations.dart`).
  static const int _defaultProfileId = 1;

  // ==================== KEY-VALUE (SharedPreferences) ====================

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

  /// Очищает хранилище по ключу (k-v слой). Для очистки паролей
  /// используется отдельный путь (DELETE FROM password_entries).
  Future<bool> clearStorage(String key) {
    return removeConfigs(key);
  }

  // ==================== ПАРОЛИ (SQLite) ====================

  /// Сохраняет список паролей. Полностью заменяет содержимое профиля
  /// по умолчанию: удаляет все существующие записи и вставляет переданные.
  ///
  /// Такая семантика сохраняет совместимость со старым API
  /// (`SharedPreferences.setString` затирал всю строку), а вызовы
  /// add/update в верхних слоях обычно построены как
  /// «получить список → изменить → сохранить полностью».
  Future<bool> savePasswords(List<PasswordEntry> passwords) async {
    try {
      await _ensurePasswordsMigrated();
      final database = await _db.database;
      final keyBytes = VaultKeySession.getForProfile(_defaultProfileId);
      final entriesToInsert = <PasswordEntry>[];
      for (final entry in passwords) {
        entriesToInsert.add(
          keyBytes != null ? await _encryptEntry(entry, keyBytes) : entry,
        );
      }
      await database.transaction((txn) async {
        await _ensureDefaultProfile(txn);
        await txn.delete(
          'password_configs',
          where: 'profile_id = ?',
          whereArgs: [_defaultProfileId],
        );
        await txn.delete(
          'password_entries',
          where: 'profile_id = ?',
          whereArgs: [_defaultProfileId],
        );
        for (final entry in entriesToInsert) {
          await _insertEntry(txn, entry);
        }
      });
      return true;
    } catch (e) {
      throw StorageFailure(message: 'Ошибка сохранения паролей: $e');
    }
  }

  /// Получает список паролей профиля по умолчанию.
  ///
  /// Если в [VaultKeySession] есть активный ключ и у записи заполнено
  /// `encrypted_service` / `encrypted_login`, поля расшифровываются в памяти
  /// и в возвращаемом [PasswordEntry] попадают как обычный plaintext
  /// (`service` / `login`). Без активного ключа возвращаются значения из
  /// plaintext-колонок — это нужно для совместимости со старыми записями
  /// и для работы тестов, не поднимающих сессию.
  Future<List<PasswordEntry>> getPasswords() async {
    try {
      await _ensurePasswordsMigrated();
      final database = await _db.database;

      final entryRows = await database.query(
        'password_entries',
        where: 'profile_id = ?',
        whereArgs: [_defaultProfileId],
        orderBy: 'created_at ASC, id ASC',
      );
      if (entryRows.isEmpty) return [];

      final configRows = await database.query(
        'password_configs',
        where: 'profile_id = ?',
        whereArgs: [_defaultProfileId],
      );
      final configByEntryId = <int, Uint8List?>{};
      for (final row in configRows) {
        final entryId = row['entry_id'] as int?;
        if (entryId == null) continue;
        final raw = row['encrypted_config'];
        Uint8List? bytes;
        if (raw is Uint8List) {
          bytes = raw;
        } else if (raw is List<int>) {
          bytes = Uint8List.fromList(raw);
        }
        configByEntryId[entryId] = bytes;
      }

      final keyBytes = VaultKeySession.getForProfile(_defaultProfileId);
      final result = <PasswordEntry>[];
      for (final row in entryRows) {
        final entryId = row['id'] as int?;
        final cfg = entryId != null ? configByEntryId[entryId] : null;
        final base = PasswordEntry.fromMap(row, encryptedConfigBytes: cfg);
        result.add(
          keyBytes != null ? await _decryptEntry(base, keyBytes) : base,
        );
      }
      return result;
    } catch (e) {
      throw StorageFailure(message: 'Ошибка чтения паролей: $e');
    }
  }

  /// Лениво шифрует ранее записанные plaintext-метаданные текущего профиля.
  ///
  /// Идея: при первом успешном unlock'е профиля у нас впервые появляется
  /// vault-ключ, и мы можем зашифровать строки, которые до v5 (или до этого
  /// момента) лежали в plaintext-колонках `service`/`login`. Метод
  /// идемпотентен — строки с уже не пустым `encrypted_service` пропускаются.
  ///
  /// Возвращает количество фактически зашифрованных строк.
  Future<int> runLazyFieldEncryption({int? profileId}) async {
    final pid = profileId ?? _defaultProfileId;
    final keyBytes = VaultKeySession.getForProfile(pid);
    if (keyBytes == null) return 0;

    await _ensurePasswordsMigrated();
    final database = await _db.database;
    final rows = await database.query(
      'password_entries',
      where: 'profile_id = ? AND encrypted_service IS NULL',
      whereArgs: [pid],
    );
    if (rows.isEmpty) return 0;

    var migrated = 0;
    await database.transaction((txn) async {
      for (final row in rows) {
        final id = row['id'] as int?;
        if (id == null) continue;
        final servicePlain = (row['service'] as String?) ?? '';
        final loginPlain = row['login'] as String?;

        final encryptedService = await _encryptor.encryptFieldWithKey(
          message: utf8.encode(servicePlain),
          keyBytes: keyBytes,
        );
        final values = <String, Object?>{
          'service': '',
          'encrypted_service': Uint8List.fromList(encryptedService),
        };
        if (loginPlain != null) {
          final encryptedLogin = await _encryptor.encryptFieldWithKey(
            message: utf8.encode(loginPlain),
            keyBytes: keyBytes,
          );
          values['login'] = null;
          values['encrypted_login'] = Uint8List.fromList(encryptedLogin);
        }
        await txn.update(
          'password_entries',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
        migrated++;
      }
    });
    return migrated;
  }

  /// Удаляет пароль по индексу в списке (упорядоченном по `created_at, id`).
  ///
  /// Индексы используются legacy-вызовами в presentation-слое; при наличии
  /// `entry.id` физически удаляется конкретная строка SQLite.
  Future<bool> removePasswordAt(int index) async {
    try {
      await _ensurePasswordsMigrated();
      final passwords = await getPasswords();
      if (passwords.isEmpty) {
        throw const StorageFailure(message: 'Хранилище паролей пустое');
      }
      if (index < 0 || index >= passwords.length) {
        throw const StorageFailure(message: 'Неверный индекс пароля');
      }

      final target = passwords[index];
      if (target.id != null) {
        final database = await _db.database;
        await database.transaction((txn) async {
          await txn.delete(
            'password_configs',
            where: 'entry_id = ?',
            whereArgs: [target.id],
          );
          await txn.delete(
            'password_entries',
            where: 'id = ?',
            whereArgs: [target.id],
          );
        });
        return true;
      }

      // Fallback (id == null): пересохранение без записи под индексом.
      final newPasswords = <PasswordEntry>[];
      for (int i = 0; i < passwords.length; i++) {
        if (i != index) {
          newPasswords.add(passwords[i]);
        }
      }
      return await savePasswords(newPasswords);
    } catch (e) {
      if (e is StorageFailure) rethrow;
      throw StorageFailure(message: 'Ошибка удаления пароля: $e');
    }
  }

  /// Обновляет метаданные существующей записи (id обязателен).
  ///
  /// Поля `service` / `login` шифруются, если для профиля доступен
  /// vault-ключ (`VaultKeySession`). `url` / `notes` сохраняются как
  /// plaintext (шифрование этих полей вынесено в отдельный этап).
  ///
  /// Поля `encrypted_password` / `nonce` / `config` не затрагиваются.
  Future<bool> updateEntry(PasswordEntry updated) async {
    if (updated.id == null) {
      throw const StorageFailure(
        message: 'Невозможно обновить запись без id',
      );
    }
    try {
      await _ensurePasswordsMigrated();
      final database = await _db.database;
      final keyBytes = VaultKeySession.getForProfile(_defaultProfileId);

      List<int>? encryptedServiceBlob;
      List<int>? encryptedLoginBlob;
      if (keyBytes != null) {
        encryptedServiceBlob = await _encryptor.encryptFieldWithKey(
          message: utf8.encode(updated.service),
          keyBytes: keyBytes,
        );
        if (updated.login != null) {
          encryptedLoginBlob = await _encryptor.encryptFieldWithKey(
            message: utf8.encode(updated.login!),
            keyBytes: keyBytes,
          );
        }
      }

      final servicePlain = encryptedServiceBlob != null ? '' : updated.service;
      final loginPlain = encryptedLoginBlob != null ? null : updated.login;
      final now = DateTime.now().millisecondsSinceEpoch;

      final values = <String, Object?>{
        'service': servicePlain,
        'login': loginPlain,
        'url': updated.url,
        'notes': updated.notes,
        'category_id': updated.categoryId,
        'updated_at': now,
        if (encryptedServiceBlob != null)
          'encrypted_service': Uint8List.fromList(encryptedServiceBlob),
        if (encryptedLoginBlob != null)
          'encrypted_login': Uint8List.fromList(encryptedLoginBlob),
      };

      final count = await database.update(
        'password_entries',
        values,
        where: 'id = ? AND profile_id = ?',
        whereArgs: [updated.id, _defaultProfileId],
      );
      return count > 0;
    } catch (e) {
      if (e is StorageFailure) rethrow;
      throw StorageFailure(message: 'Ошибка обновления записи: $e');
    }
  }

  /// Экспортирует пароли в JSON строку (формат совместим с `importPasswords`).
  Future<String> exportPasswords() async {
    try {
      final passwords = await getPasswords();
      return PasswordEntry.encodeList(passwords);
    } catch (e) {
      throw StorageFailure(message: 'Ошибка экспорта паролей: $e');
    }
  }

  /// Импортирует пароли из JSON строки.
  ///
  /// Сохраняется поведение v0.5.1:
  /// - дубликаты по (service + login) обновляются, а не дублируются;
  /// - при ошибке выполняется rollback к предыдущему состоянию.
  Future<bool> importPasswords(String jsonString) async {
    List<PasswordEntry>? originalPasswords;

    try {
      final newPasswords = PasswordEntry.decodeList(jsonString);
      final currentPasswords = await getPasswords();

      originalPasswords = List<PasswordEntry>.from(currentPasswords);

      final mergedPasswords = List<PasswordEntry>.from(currentPasswords);

      for (final newPassword in newPasswords) {
        final existingIndex = mergedPasswords.indexWhere(
          (e) =>
              e.service.toLowerCase() == newPassword.service.toLowerCase() &&
              e.login == newPassword.login,
        );
        if (existingIndex != -1) {
          mergedPasswords[existingIndex] = newPassword;
        } else {
          mergedPasswords.add(newPassword);
        }
      }

      return await savePasswords(mergedPasswords);
    } catch (e) {
      if (originalPasswords != null) {
        try {
          await savePasswords(originalPasswords);
        } catch (_) {
          // Rollback failed, but don't mask the original error
        }
      }
      throw StorageFailure(message: 'Ошибка импорта паролей: $e');
    }
  }

  // ==================== ВНУТРЕННИЕ HELPER'Ы ====================

  /// Вставляет одну запись в таблицы `password_entries` + `password_configs`
  /// внутри переданной транзакции. Возвращает `id` вставленной записи.
  Future<int> _insertEntry(Transaction txn, PasswordEntry entry) async {
    final entryMap = entry.toMap(defaultProfileId: _defaultProfileId);
    // При полной перезаписи списка id предыдущих записей всё равно
    // были удалены — оставляем AUTOINCREMENT'у назначить новые.
    entryMap.remove('id');

    final entryId = await txn.insert('password_entries', entryMap);

    final configBytes = entry.encryptedConfigBlob();
    if (configBytes != null) {
      await txn.insert('password_configs', {
        'profile_id': entry.profileId ?? _defaultProfileId,
        'entry_id': entryId,
        'encrypted_config': configBytes,
      });
    }

    return entryId;
  }

  /// Шифрует service/login в переданной записи (в памяти) и возвращает
  /// копию, у которой заполнены `encryptedServiceBlob` / `encryptedLoginBlob`,
  /// а plaintext-поля при записи в базу будут забланчены (см. [PasswordEntry.toMap]).
  Future<PasswordEntry> _encryptEntry(
    PasswordEntry entry,
    List<int> keyBytes,
  ) async {
    final encryptedService = await _encryptor.encryptFieldWithKey(
      message: utf8.encode(entry.service),
      keyBytes: keyBytes,
    );
    List<int>? encryptedLogin;
    if (entry.login != null) {
      encryptedLogin = await _encryptor.encryptFieldWithKey(
        message: utf8.encode(entry.login!),
        keyBytes: keyBytes,
      );
    }
    return entry.copyWith(
      encryptedServiceBlob: encryptedService,
      encryptedLoginBlob: encryptedLogin,
    );
  }

  /// Дешифрует service/login, если у [entry] есть зашифрованные BLOB'ы.
  /// Плайнтекст попадает в обычные поля результата.
  Future<PasswordEntry> _decryptEntry(
    PasswordEntry entry,
    List<int> keyBytes,
  ) async {
    if (entry.encryptedServiceBlob == null &&
        entry.encryptedLoginBlob == null) {
      return entry;
    }
    String service = entry.service;
    String? login = entry.login;
    if (entry.encryptedServiceBlob != null) {
      try {
        final bytes = await _encryptor.decryptFieldWithKey(
          blob: entry.encryptedServiceBlob!,
          keyBytes: keyBytes,
        );
        service = utf8.decode(bytes);
      } catch (_) {
        // При ошибке дешифрования (неверный ключ, повреждённый BLOB)
        // остаёмся на plaintext-колонке (она скорее всего пуста, но лучше
        // показать пустое имя сервиса, чем уронить весь список).
      }
    }
    if (entry.encryptedLoginBlob != null) {
      try {
        final bytes = await _encryptor.decryptFieldWithKey(
          blob: entry.encryptedLoginBlob!,
          keyBytes: keyBytes,
        );
        login = utf8.decode(bytes);
      } catch (_) {
        // см. выше
      }
    }
    return entry.copyWith(
      service: service,
      login: login,
      clearEncryptedServiceBlob: true,
      clearEncryptedLoginBlob: true,
    );
  }

  /// Гарантирует существование строки `profiles.id = 1`. Без неё
  /// FK на `password_entries.profile_id` оставался бы висящим (для свежих
  /// инсталляций, где `_onCreate` не вставляет дефолтный профиль).
  Future<void> _ensureDefaultProfile(Transaction txn) async {
    final existing = await txn.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [_defaultProfileId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await txn.insert('profiles', {
        'id': _defaultProfileId,
        'name': 'Профиль по умолчанию',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// One-time миграция: переносит `SharedPreferences['saved_passwords']`
  /// в SQLite (`password_entries` + `password_configs`) с `profile_id = 1`.
  /// Идемпотентна — после успеха помечается флагом и больше не выполняется.
  Future<void> _ensurePasswordsMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationFlagKey) ?? false) {
      return;
    }

    final legacyJson = prefs.getString(_legacyPasswordsKey);
    if (legacyJson != null && legacyJson.isNotEmpty) {
      final legacyPasswords = PasswordEntry.decodeList(legacyJson);
      if (legacyPasswords.isNotEmpty) {
        final database = await _db.database;
        await database.transaction((txn) async {
          await _ensureDefaultProfile(txn);
          for (final entry in legacyPasswords) {
            await _insertEntry(txn, entry);
          }
        });
      }
      await prefs.remove(_legacyPasswordsKey);
    }

    await prefs.setBool(_migrationFlagKey, true);
  }
}
