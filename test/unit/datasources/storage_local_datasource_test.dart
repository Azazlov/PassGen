import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'package:pass_gen/data/database/database_helper.dart';
import 'package:pass_gen/data/database/database_schema.dart';
import 'package:pass_gen/data/datasources/storage_local_datasource.dart';
import 'package:pass_gen/domain/entities/password_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Создаёт свежую in-memory БД с актуальной схемой v4 +
/// дефолтным профилем и системными категориями.
Future<Database> _openFreshDb() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: DatabaseSchema.version),
  );
  for (final create in DatabaseSchema.createAllTables) {
    await db.execute(create);
  }
  await db.execute(DatabaseSchema.createAllIndexes());

  final now = DateTime.now().millisecondsSinceEpoch;
  await db.insert('profiles', {
    'id': 1,
    'name': 'Профиль по умолчанию',
    'created_at': now,
  });
  for (final category in DatabaseSchema.systemCategories) {
    await db.insert('categories', {
      'name': category['name'],
      'icon': category['icon'],
      'is_system': category['is_system'],
      'created_at': now,
    });
  }
  return db;
}

PasswordEntry _entry({
  required String service,
  String? login,
  String encryptedPassword = 'cGFzc3dvcmQtbWluaS1mb3JtYXQ=',
  String config = 'cfg.flags.rands',
  DateTime? createdAt,
}) {
  return PasswordEntry(
    service: service,
    login: login,
    encryptedPassword: encryptedPassword,
    config: config,
    createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late StorageLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await _openFreshDb();
    DatabaseHelper.databaseForTesting = db;
    dataSource = StorageLocalDataSource();
  });

  tearDown(() async {
    DatabaseHelper.databaseForTesting = null;
    await db.close();
  });

  group('PasswordEntry SQLite serialization', () {
    test('toMap/fromMap round-trip сохраняет основные поля', () {
      final original = _entry(service: 'github.com', login: 'user@example.com');
      final map = original.toMap(defaultProfileId: 1);

      // Эмулируем чтение строки SQLite (id появляется после INSERT).
      final readMap = Map<String, Object?>.from(map)..['id'] = 42;
      final restored = PasswordEntry.fromMap(
        readMap,
        encryptedConfigBytes: original.encryptedConfigBlob(),
      );

      expect(restored.id, 42);
      expect(restored.profileId, 1);
      expect(restored.service, 'github.com');
      expect(restored.login, 'user@example.com');
      expect(restored.encryptedPassword, original.encryptedPassword);
      expect(restored.config, original.config);
      expect(
        restored.createdAt.millisecondsSinceEpoch,
        original.createdAt.millisecondsSinceEpoch,
      );
    });

    test('encryptedConfigBlob возвращает null для пустого config', () {
      final entry = _entry(service: 'svc', config: '');
      expect(entry.encryptedConfigBlob(), isNull);
    });
  });

  group('savePasswords / getPasswords (SQLite)', () {
    test('пустое хранилище возвращает []', () async {
      final result = await dataSource.getPasswords();
      expect(result, isEmpty);
    });

    test('savePasswords + getPasswords возвращает те же данные', () async {
      final entries = [
        _entry(
          service: 'github.com',
          login: 'octocat',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
        _entry(
          service: 'gitlab.com',
          login: 'tanuki',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ];

      final ok = await dataSource.savePasswords(entries);
      expect(ok, isTrue);

      final loaded = await dataSource.getPasswords();
      expect(loaded, hasLength(2));
      expect(loaded[0].service, 'github.com');
      expect(loaded[0].login, 'octocat');
      expect(loaded[0].config, entries[0].config);
      expect(loaded[1].service, 'gitlab.com');
      expect(loaded[1].profileId, 1);
      expect(loaded.every((e) => e.id != null), isTrue);
    });

    test('savePasswords полностью заменяет содержимое профиля', () async {
      await dataSource.savePasswords([
        _entry(service: 'a.com'),
        _entry(service: 'b.com'),
      ]);
      await dataSource.savePasswords([_entry(service: 'c.com')]);

      final loaded = await dataSource.getPasswords();
      expect(loaded, hasLength(1));
      expect(loaded.single.service, 'c.com');

      // password_configs не должен накапливать висящие строки.
      final configRows = await db.query('password_configs');
      expect(configRows, hasLength(1));
    });

    test('removePasswordAt удаляет запись и связанный config', () async {
      await dataSource.savePasswords([
        _entry(
          service: 'a.com',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
        _entry(
          service: 'b.com',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
        _entry(
          service: 'c.com',
          createdAt: DateTime.fromMillisecondsSinceEpoch(3000),
        ),
      ]);

      final ok = await dataSource.removePasswordAt(1);
      expect(ok, isTrue);

      final loaded = await dataSource.getPasswords();
      expect(loaded.map((e) => e.service), ['a.com', 'c.com']);

      final configRows = await db.query('password_configs');
      expect(configRows, hasLength(2));
    });

    test('removePasswordAt с неверным индексом выдаёт StorageFailure',
        () async {
      await dataSource.savePasswords([_entry(service: 'a.com')]);
      expect(
        () => dataSource.removePasswordAt(5),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('SharedPreferences → SQLite миграция', () {
    test('переносит существующие пароли в SQLite и снимает legacy-ключ',
        () async {
      final legacyEntries = [
        _entry(
          service: 'legacy-a.com',
          login: 'user-a',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
        _entry(
          service: 'legacy-b.com',
          login: 'user-b',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ];
      SharedPreferences.setMockInitialValues({
        'saved_passwords': PasswordEntry.encodeList(legacyEntries),
      });

      final loaded = await dataSource.getPasswords();
      expect(loaded.map((e) => e.service),
          ['legacy-a.com', 'legacy-b.com']);
      expect(loaded.map((e) => e.login), ['user-a', 'user-b']);
      expect(loaded.every((e) => e.profileId == 1), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('saved_passwords'), isNull);
      expect(prefs.getBool('sp_to_sqlite_passwords_migrated'), isTrue);
    });

    test('идемпотентна — повторный вызов не дублирует записи', () async {
      final legacyEntries = [
        _entry(
          service: 'svc.com',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
      ];
      SharedPreferences.setMockInitialValues({
        'saved_passwords': PasswordEntry.encodeList(legacyEntries),
      });

      await dataSource.getPasswords();
      // Принудительно стираем флаг — но SharedPreferences ключа уже нет,
      // поэтому повторная миграция не должна задвоить существующие записи.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sp_to_sqlite_passwords_migrated', false);

      final secondLoad = await dataSource.getPasswords();
      expect(secondLoad, hasLength(1));
      expect(secondLoad.single.service, 'svc.com');
    });

    test('пустое хранилище: миграция помечает флаг и возвращает []',
        () async {
      SharedPreferences.setMockInitialValues({});

      final loaded = await dataSource.getPasswords();
      expect(loaded, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sp_to_sqlite_passwords_migrated'), isTrue);
    });

    test('сохраняет config из legacy-формата (Base64.Base64.Base64)',
        () async {
      final legacy = [
        _entry(
          service: 'cfg.com',
          config: 'MTI=.NA==.cmFuZG9tYnl0ZXM=',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
      ];
      SharedPreferences.setMockInitialValues({
        'saved_passwords': PasswordEntry.encodeList(legacy),
      });

      final loaded = await dataSource.getPasswords();
      expect(loaded.single.config, legacy.single.config);
    });
  });

  group('exportPasswords / importPasswords', () {
    test('round-trip через JSON сохраняет данные', () async {
      final entries = [
        _entry(
          service: 'svc1',
          login: 'u1',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
        _entry(
          service: 'svc2',
          login: 'u2',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ];
      await dataSource.savePasswords(entries);

      final exported = await dataSource.exportPasswords();
      final decoded = jsonDecode(exported) as List;
      expect(decoded, hasLength(2));

      // Очищаем и импортируем обратно.
      await dataSource.savePasswords([]);
      final ok = await dataSource.importPasswords(exported);
      expect(ok, isTrue);

      final loaded = await dataSource.getPasswords();
      expect(loaded, hasLength(2));
      expect(loaded.map((e) => e.service).toSet(), {'svc1', 'svc2'});
    });

    test('importPasswords обновляет дубликаты по (service+login)', () async {
      await dataSource.savePasswords([
        _entry(
          service: 'svc',
          login: 'u',
          encryptedPassword: 'b2xkLXBhc3N3b3Jk',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
      ]);

      final newJson = PasswordEntry.encodeList([
        _entry(
          service: 'svc',
          login: 'u',
          encryptedPassword: 'bmV3LXBhc3N3b3Jk',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ]);

      await dataSource.importPasswords(newJson);

      final loaded = await dataSource.getPasswords();
      expect(loaded, hasLength(1));
      expect(loaded.single.encryptedPassword, 'bmV3LXBhc3N3b3Jk');
    });
  });
}
