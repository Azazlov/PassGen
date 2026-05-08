# Implementation Plan (revised)

> **Ревизия:** v1.1, 21.04.2026.
> Правки внесены по результатам архитектурного ревью: убрана admin-роль, добавлена криптоизоляция профилей, переписана формула прогрессивной блокировки, прописан механизм биометрии через `flutter_secure_storage`, добавлена security-модель QR-обмена, детерминированное глитчирование, расширена миграция БД, desktop-ограничения биометрии, уточнён UX-поток аутентификации.

## [Overview]

Реализация биометрии, многопрофильности с криптографической изоляцией, глитчирования текста, QR-обмена, прогрессивной блокировки PIN и встроенных замеров производительности для кроссплатформенного менеджера паролей PassGen.

Проект использует Clean Architecture (presentation / domain / data / core / shared) на Dart/Flutter с SQLite в качестве локальной СУБД, ChaCha20-Poly1305 для шифрования и PBKDF2-HMAC-SHA256 (600 000 итераций) для деривации ключа. Текущая версия схемы БД — 3, приложение — 0.5.2. Состояние аутентификации управляется через PIN-код с фиксированной блокировкой после 5 неудачных попыток на 30 сек (заменяется на прогрессивную). Все чувствительные данные хранятся только в SQLite на устройстве пользователя.

В рамках данного плана необходимо:
1. Добавить биометрическую аутентификацию через пакет `local_auth` + `flutter_secure_storage` как второй фактор к PIN (mobile only: Android/iOS; на desktop/web опция скрывается).
2. Реализовать многопрофильность — поддержку нескольких **криптографически независимых** профилей на одном устройстве с изоляцией данных через `profile_id` и отдельной деривацией ключа на каждый профиль.
3. Создать модуль глитчирования текста — **детерминированное** преобразование осмысленной фразы пользователя в криптографически стойкий пароль.
4. Реализовать QR-обмен отдельными записями паролей между устройствами с шифрованием по одноразовому transfer PIN.
5. Заменить фиксированную блокировку 30 сек на прогрессивную задержку по сериям с потолком 7 суток.
6. Добавить страницу замеров производительности криптографических операций; результаты писать в журнал событий (существующая страница логов) и опционально экспортировать в CSV/JSON.
7. Провести ревью кода, статический анализ, покрытие тестами и декомпозицию длинных методов.

---

## [Cryptographic Isolation of Profiles] — критический раздел архитектуры

Ключевое требование многопрофильности: **компрометация PIN одного профиля не должна позволять расшифровать данные других профилей**. Это достигается **независимой деривацией ключа на каждый профиль** — нет общего мастер-ключа, объединяющего профили.

### Схема ключей (per-profile)

```
Profile i:
    user_pin_i  ──PBKDF2(600 000, salt_i)──▶  derived_key_i (32 байта)
    derived_key_i  ──ChaCha20-Poly1305──▶  шифрование password_entries.profile_id = i
    derived_key_i  хранится только в памяти при активном профиле, затирается при logout
```

### Следствия

- В `auth_data` хранится **строка на каждый профиль**: `(profile_id, pin_hash, pin_salt, biometric_ref_opt)`. Нет единого «глобального» PIN.
- При переключении профиля: текущий `derived_key` затирается, UI блокируется, запрашивается PIN нового профиля, деривация нового ключа.
- Фильтрация по `profile_id` в SQL — это UX-уровень. Даже если код ошибочно запросит чужие записи, **расшифровать их не получится** без PIN этого профиля — шифротекст останется шифротекстом.
- Биометрия включается **на каждый профиль отдельно**; при включении PIN (или derived-key wrapper) сохраняется в `flutter_secure_storage` под биометрическим гейтом ОС.

### Отражение в модели угроз (диплом v2, раздел 2.4.5)

Добавляется угроза **У-15 «Каскадная компрометация при компрометации одного профиля»** → противомера: независимая деривация ключей, отсутствие общего admin-ключа.

---

## [Types]

В систему добавляются новые типы данных, сущности и перечисления для поддержки многопрофильности, биометрии, глитчирования и QR-обмена.

### Новые entities

**`Profile` (`lib/domain/entities/profile.dart`)**
```dart
class Profile {
  final int? id;
  final String name;
  final String? avatarEmoji;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;

  const Profile({
    this.id,
    required this.name,
    this.avatarEmoji,
    required this.createdAt,
    this.lastAccessedAt,
  });
}
```

> Поле `isAdmin` удалено. Многопрофильность — это изоляция независимых контекстов, а не ролевая модель. Ролевая модель будет реализована только при появлении серверной части (в «Перспективы развития»).

**`GlitchResult` (`lib/domain/entities/glitch_result.dart`)**
```dart
class GlitchResult {
  final String originalText;
  final String glitchedPassword;
  final double strength;
  final String strengthLabel;
  final Map<String, dynamic> appliedRules;

  const GlitchResult({...});
}
```

**`QrTransferPayload` (`lib/domain/entities/qr_transfer_payload.dart`)**
```dart
class QrTransferPayload {
  final String version;          // '1'
  final String nonce;            // base64url(12 байт) — nonce для ChaCha20
  final String saltBase64;       // base64url(16 байт) — соль PBKDF2 для transfer PIN
  final int iterations;          // 100 000 — PBKDF2 итерации для transfer PIN
  final String ciphertextBase64; // base64url(зашифрованная запись)
  final String macBase64;        // base64url(Poly1305 MAC)
  final int createdAt;           // unix ms
  final int expirySeconds;       // TTL (по умолчанию 300 сек)

  const QrTransferPayload({...});

  Map<String, dynamic> toJson();
  factory QrTransferPayload.fromJson(Map<String, dynamic> json);
  String toBase64Url();
  factory QrTransferPayload.fromBase64Url(String data);

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch - createdAt > expirySeconds * 1000;
}
```

### Изменённые entities

**`AuthState` (`lib/domain/entities/auth_state.dart`)** — добавляются поля:
- `int? currentProfileId` — ID текущего активного профиля.
- `bool isBiometricEnabled` — включена ли биометрия для текущего профиля.
- `bool isBiometricAvailable` — доступен ли биометрический сенсор на устройстве (всегда `false` для desktop/web).
- `int lockoutSeriesIndex` — текущая серия блокировок (0 = нет серии).

**`PasswordEntry` (`lib/domain/entities/password_entry.dart`)** — добавляется поле:
- `int? profileId` — внешний ключ на профиль.

**`SecurityLog` (`lib/domain/entities/security_log.dart`)** — добавляется поле:
- `int? profileId` — для изоляции логов по профилям.

### Новые перечисления

**`BiometricType` (`lib/domain/entities/biometric_type.dart`)**
- `fingerprint`
- `face`
- `unknown`

> Тип `iris` удалён: `local_auth` на практике возвращает только fingerprint / face / unknown; iris-сенсоры в экосистеме Flutter не поддерживаются.

**`GlitchRule` (`lib/domain/entities/glitch_rule.dart`)**
- `shiftChars` — смещение символов по фиксированному алфавиту на детерминированную величину.
- `visualSubstitute` — подстановка визуально схожих символов (a→@, e→3, …).
- `derivedSalt` — добавление солевых элементов, **детерминированно выведенных** из хэша входного текста (вместо случайной соли).
- `invertCase` — инверсия регистра по позициям.
- `leetSpeak` — базовый leet-спик.

---

## [Files]

### Новые файлы

| Путь | Назначение |
|---|---|
| `lib/domain/entities/profile.dart` | Сущность профиля пользователя |
| `lib/domain/entities/glitch_result.dart` | Результат глитчирования |
| `lib/domain/entities/qr_transfer_payload.dart` | Payload для QR-передачи |
| `lib/domain/entities/biometric_type.dart` | Перечисление типов биометрии |
| `lib/domain/entities/glitch_rule.dart` | Перечисление правил глитчирования |
| `lib/domain/repositories/profile_repository.dart` | Интерфейс репозитория профилей |
| `lib/domain/repositories/biometric_repository.dart` | Интерфейс репозитория биометрии |
| `lib/domain/repositories/qr_transfer_repository.dart` | Интерфейс репозитория QR-обмена |
| `lib/domain/usecases/profile/` | Use cases для профилей (CRUD, переключение) |
| `lib/domain/usecases/biometric/` | Use cases для биометрии (проверка, активация, аутентификация) |
| `lib/domain/usecases/glitch/` | Use cases для глитчирования текста |
| `lib/domain/usecases/qr/` | Use cases для QR-экспорта/импорта |
| `lib/domain/services/glitch_service.dart` | Доменный сервис глитчирования |
| `lib/domain/services/biometric_service.dart` | Доменный сервис биометрии |
| `lib/domain/services/performance_benchmark_service.dart` | Сервис замеров производительности |
| `lib/data/repositories/profile_repository_impl.dart` | Реализация репозитория профилей |
| `lib/data/repositories/biometric_repository_impl.dart` | Реализация репозитория биометрии |
| `lib/data/repositories/qr_transfer_repository_impl.dart` | Реализация репозитория QR-обмена |
| `lib/data/datasources/profile_local_datasource.dart` | Локальный источник данных профилей |
| `lib/data/datasources/biometric_local_datasource.dart` | Локальный источник биометрии (`local_auth` + `flutter_secure_storage`) |
| `lib/presentation/features/profiles/` | UI профилей (выбор, создание, переключение) |
| `lib/presentation/features/glitch/` | UI глитчирования текста |
| `lib/presentation/features/qr_transfer/` | UI QR-обмена (экспорт/импорт) |
| `lib/presentation/features/benchmark/` | UI замеров производительности |
| `lib/presentation/widgets/profile_selector.dart` | Виджет выбора профиля (с `Semantics`) |
| `lib/presentation/widgets/biometric_button.dart` | Кнопка биометрической аутентификации (с `Semantics`) |
| `lib/core/utils/glitch_transformer.dart` | Утилита детерминированной трансформации текста в пароль |
| `lib/core/utils/lockout_calculator.dart` | Калькулятор прогрессивной блокировки (по сериям) |
| `lib/core/utils/qr_payload_codec.dart` | Кодирование/декодирование QR-payload с шифрованием |
| `test/unit/glitch/` | Тесты глитчирования |
| `test/unit/biometric/` | Тесты биометрии |
| `test/unit/profile/` | Тесты профилей |
| `test/unit/qr/` | Тесты QR-обмена |
| `test/unit/benchmark/` | Тесты замеров производительности |
| `test/unit/auth/lockout_calculator_test.dart` | Тесты прогрессивной блокировки |

### Модифицируемые файлы

| Путь | Изменения |
|---|---|
| `pubspec.yaml` | Добавить `local_auth: ^2.3.0`, `flutter_secure_storage: ^9.2.2`, `qr_flutter: ^4.1.0`, `mobile_scanner: ^6.0.0` |
| `lib/data/database/database_schema.dart` | Добавить таблицу `profiles`, поле `profile_id` в `password_entries`, `security_logs`, `auth_data`; новые индексы; обновить version → 4 |
| `lib/data/database/database_migrations.dart` | Добавить миграцию `_migrateToV4` (см. раздел Migration Details) |
| `lib/data/datasources/auth_local_datasource.dart` | Рефакторинг под per-profile аутентификацию: хранение `auth_data` строкой на профиль; интеграция `LockoutCalculator` |
| `lib/data/datasources/storage_local_datasource.dart` | Фильтрация по `profile_id` (в памяти, т.к. SharedPreferences; миграция в SQLite — в «Перспективы развития») |
| `lib/data/datasources/encryptor_local_datasource.dart` | Модификация `_deriveKey` для приёма per-profile derived_key (32 байта) вместо raw PIN |
| `lib/data/repositories/security_log_repository_impl.dart` | Фильтрация по `profile_id` |
| `lib/domain/entities/auth_state.dart` | Добавить `currentProfileId`, `isBiometricEnabled`, `isBiometricAvailable`, `lockoutSeriesIndex` |
| `lib/domain/entities/password_entry.dart` | Добавить `profileId` |
| `lib/presentation/features/auth/auth_controller.dart` | Интеграция биометрии, выбор профиля, прогрессивная блокировка |
| `lib/presentation/features/auth/auth_screen.dart` | Селектор профиля на экране запуска + кнопка биометрии |
| `lib/presentation/features/settings/settings_screen.dart` | Секции «Профили», «Биометрия», «Замеры производительности» |
| `lib/app/app.dart` | Регистрация провайдеров для новых репозиториев, use cases, контроллеров |
| `lib/main.dart` | Инициализация новых datasource и репозиториев |
| `android/app/src/main/AndroidManifest.xml` | Разрешение `USE_BIOMETRIC` |
| `ios/Runner/Info.plist` | Ключ `NSFaceIDUsageDescription` |
| `README.MD` | Актуализация: фактические параметры PBKDF2 (v2 = 600 000 итераций), честный статус платформ (Web/iOS — сборка без функционального тестирования), удаление маркетинговых формулировок |

---

## [Functions]

### Новые функции

**`GlitchService.glitchText(String text, {List<GlitchRule>? rules})`**
- Файл: `lib/domain/services/glitch_service.dart`
- Назначение: **детерминированное** преобразование текста в стойкий пароль.
- Алгоритм:
  1. Нормализация входного текста (trim, NFC-нормализация Unicode).
  2. Применение правил по порядку: `shiftChars` → `visualSubstitute` → `leetSpeak` → `invertCase` → `derivedSalt`.
  3. Оценка стойкости через `zxcvbn`.
  4. Возврат `GlitchResult`.
- Инвариант: `glitchText(text) == glitchText(text)` — одинаковый вход всегда даёт одинаковый выход (тестируется в `glitch_service_test.dart`).

**`GlitchTransformer.applyShift(String input, int offset)`**
- Файл: `lib/core/utils/glitch_transformer.dart`
- Назначение: сдвиг каждого символа по фиксированному алфавиту на `offset` позиций; `offset` выводится из длины `input` (детерминированная функция).

**`GlitchTransformer.applyVisualSubstitution(String input)`**
- Файл: `lib/core/utils/glitch_transformer.dart`
- Назначение: замена символов на визуально схожие (a→@, e→3, i→1, o→0, s→$, и т.д.) по фиксированной таблице.

**`GlitchTransformer.applyDerivedSalt(String input, {int saltLength = 4})`**
- Файл: `lib/core/utils/glitch_transformer.dart`
- Назначение: добавление «солевых» символов, **детерминированно** выведенных из `SHA-256(input)`. Первые `saltLength` байт хэша отображаются на алфавит `[A-Za-z0-9!@#$%]` и вставляются в фиксированные позиции (начало и конец).
- Важно: это **не криптографическая соль** в строгом смысле, а «специи» для усиления пароля. Используется термин `derivedSalt`, чтобы не путать с `pin_salt` в PBKDF2.

**`LockoutCalculator.calculateDelay(int seriesIndex)`**
- Файл: `lib/core/utils/lockout_calculator.dart`
- Назначение: вычисление времени блокировки по прогрессивной формуле, индексируемой **сериями неудач**, не отдельными попытками.
- Формула:
  ```dart
  Duration calculateDelay(int seriesIndex) {
    if (seriesIndex <= 0) return Duration.zero;
    final seconds = (baseLockoutSeconds * pow(growthFactor, seriesIndex - 1)).toInt();
    return Duration(seconds: min(seconds, maxLockoutSeconds));
  }
  ```
  Константы:
  ```dart
  static const int baseLockoutSeconds = 30;
  static const double growthFactor = 6.0;
  static const int maxLockoutSeconds = 7 * 24 * 3600; // 7 суток
  static const int attemptsPerSeries = 5;
  ```
  Поведение:
  - После 5 неудач — серия 1, задержка 30 сек.
  - После следующих 5 неудач — серия 2, задержка 3 мин.
  - Серия 3 → 18 мин; серия 4 → ≈ 1,8 ч; серия 5 → ≈ 10,8 ч; серия 6+ → 7 суток (потолок).
- Счётчик попыток в серии и `seriesIndex` хранятся в `auth_data` на профиль.
- Сброс: успешный ввод PIN или биометрии обнуляет и `failedAttempts`, и `seriesIndex`.

**`BiometricLocalDataSource.isAvailable()`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Назначение: возвращает `false` на desktop (Windows/Linux/macOS) и web; на Android/iOS — через `local_auth.canCheckBiometrics && local_auth.isDeviceSupported`.

**`BiometricLocalDataSource.authenticate({required String localizedReason})`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Назначение: вызов `local_auth.authenticate` с корректной локализацией; возвращает `bool`.

**`BiometricLocalDataSource.enableForProfile(int profileId, String pin)`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Назначение: сохраняет PIN профиля в `flutter_secure_storage` с ключом `biometric_pin_<profileId>` и опциями платформенного биометрического гейта (`AndroidOptions(encryptedSharedPreferences: true)`, `IOSOptions(accessibility: KeychainAccessibility.whenPasscodeSetThisDeviceOnly)`).

**`BiometricLocalDataSource.retrievePinForProfile(int profileId)`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Назначение: читает PIN из secure storage; вызывается **после** успешной биометрической аутентификации.

**`BiometricLocalDataSource.disableForProfile(int profileId)`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Назначение: удаляет PIN из secure storage для указанного профиля.

**`PerformanceBenchmarkService.runPbkdf2Benchmark()`**
- Файл: `lib/domain/services/performance_benchmark_service.dart`
- Назначение: замер времени выполнения PBKDF2 с 600 000 итераций; результат — `BenchmarkResult(operation, durationMs, device)`.

**`PerformanceBenchmarkService.runGenerationBenchmark({int count = 1000})`**
- Файл: `lib/domain/services/performance_benchmark_service.dart`
- Назначение: замер генерации `count` паролей длиной 20 символов.

**`PerformanceBenchmarkService.runEncryptionBenchmark({int count = 1000})`**
- Файл: `lib/domain/services/performance_benchmark_service.dart`
- Назначение: замер шифрования/расшифровки `count` записей.

**`PerformanceBenchmarkService.runAllBenchmarks()`**
- Файл: `lib/domain/services/performance_benchmark_service.dart`
- Назначение: прогон всех трёх бенчмарков; каждый результат **пишется в `security_logs`** (в существующую страницу журнала, откуда пользователь может скопировать) и возвращается списком.

**`PerformanceBenchmarkService.exportResults(List<BenchmarkResult> results, {BenchmarkExportFormat format = BenchmarkExportFormat.csv})`**
- Назначение: дополнительный экспорт в CSV или JSON (опционально; основная запись — в журнал событий).

**`QrTransferRepositoryImpl.createExportPayload(PasswordEntry entry, String transferPin, {int ttlSeconds = 300})`**
- Файл: `lib/data/repositories/qr_transfer_repository_impl.dart`
- Назначение: создание зашифрованного payload для QR-кода (см. раздел «QR Transfer Security Model»).

**`QrTransferRepositoryImpl.decodePayload(String qrData, String transferPin)`**
- Назначение: декодирование и проверка payload; возвращает `Either<Failure, PasswordEntry>`.

### Модифицированные функции

**`AuthLocalDataSource.verifyPin(String pin, {required int profileId})`**
- Текущий файл: `lib/data/datasources/auth_local_datasource.dart`
- Изменения: **обязательный** параметр `profileId`; чтение `pin_hash` / `pin_salt` из строки `auth_data` этого профиля; при неудаче — увеличение `failedAttempts`; при `failedAttempts >= 5` — увеличение `seriesIndex`, сброс `failedAttempts`, вызов `LockoutCalculator.calculateDelay(seriesIndex)` и запись `lockout_until`.

**`AuthLocalDataSource.setupPin(String pin, {required int profileId})`**
- Изменения: сохраняет PIN с уникальной `pin_salt` **на каждый профиль**; `derived_key` для шифрования `password_entries` этого профиля получается из `PBKDF2(pin, pin_salt, 600000)`.

**`AuthController.verifyPin()`**
- Текущий файл: `lib/presentation/features/auth/auth_controller.dart`
- Изменения: учёт `currentProfileId`; после неудачи — если биометрия включена и сенсор доступен, предложить биометрический вход; обновление `AuthState.lockoutSeriesIndex`.

**`AuthController.authenticateWithBiometric()`** (новый метод)
- Вызов `biometricRepository.authenticate()` → при успехе `retrievePinForProfile(currentProfileId)` → `verifyPin(retrievedPin)` → обычная логика разблокировки.

**`DatabaseSchema.createAllTables` / `DatabaseSchema.indexes`**
- Добавить таблицу `profiles`; добавить индексы: `idx_password_entries_profile`, `idx_security_logs_profile`, `idx_auth_data_profile` (unique), `idx_password_history_profile`.

**`PasswordEntry.fromJson` / `PasswordEntry.toJson`**
- Сериализация/десериализация `profile_id`.

---

## [Classes]

### Новые классы

**`ProfileRepository` (interface)**
- Файл: `lib/domain/repositories/profile_repository.dart`
- Методы: `createProfile`, `getProfiles`, `getProfileById`, `updateProfile`, `deleteProfile`, `setActiveProfile`, `getActiveProfile`.

**`ProfileRepositoryImpl`**
- Файл: `lib/data/repositories/profile_repository_impl.dart`
- Реализация через `ProfileLocalDataSource`.

**`ProfileLocalDataSource`**
- Файл: `lib/data/datasources/profile_local_datasource.dart`
- Методы: CRUD операции с таблицей `profiles` в SQLite.

**`BiometricRepository` (interface)**
- Файл: `lib/domain/repositories/biometric_repository.dart`
- Методы: `isAvailable`, `authenticate`, `enableForProfile`, `disableForProfile`, `isEnabledForProfile`, `retrievePinForProfile`.

**`BiometricRepositoryImpl`**
- Файл: `lib/data/repositories/biometric_repository_impl.dart`
- Реализация через `BiometricLocalDataSource`.

**`BiometricLocalDataSource`**
- Файл: `lib/data/datasources/biometric_local_datasource.dart`
- Внутренности: обёртка над `local_auth` (да/нет сигнал) + `flutter_secure_storage` (хранение PIN под биометрическим гейтом ОС).
- Методы: см. раздел Functions.

**`QrTransferRepository` (interface)**
- Файл: `lib/domain/repositories/qr_transfer_repository.dart`
- Методы: `createExportPayload`, `decodePayload`, `validatePayload` (проверка TTL и MAC перед декодированием).

**`QrTransferRepositoryImpl`**
- Файл: `lib/data/repositories/qr_transfer_repository_impl.dart`
- Реализация шифрования/дешифрования payload (см. «QR Transfer Security Model»).

**`GlitchService`**
- Файл: `lib/domain/services/glitch_service.dart`
- Методы: `glitchText`, `getAvailableRules`, `estimateStrength`.
- Контракт: детерминированный — одинаковый вход даёт одинаковый выход.

**`PerformanceBenchmarkService`**
- Файл: `lib/domain/services/performance_benchmark_service.dart`
- Методы: `runAllBenchmarks`, `runPbkdf2Benchmark`, `runGenerationBenchmark`, `runEncryptionBenchmark`, `exportResults`.
- Побочный эффект: каждый прогон пишется в `security_logs` через `SecurityLogRepository`.

**`LockoutCalculator`**
- Файл: `lib/core/utils/lockout_calculator.dart`
- Методы: `calculateDelay(int seriesIndex)`.
- Константы выведены в сам класс (`baseLockoutSeconds`, `growthFactor`, `maxLockoutSeconds`, `attemptsPerSeries`).

**`ProfilesController` / `GlitchController` / `QrTransferController` / `BenchmarkController`**
- `ChangeNotifier`-контроллеры для соответствующих экранов.

**`ProfileSelectorWidget`**
- Файл: `lib/presentation/widgets/profile_selector.dart`
- Semantics: `Semantics(label: 'Выбор профиля ${profile.name}')`.

**`BiometricAuthButton`**
- Файл: `lib/presentation/widgets/biometric_button.dart`
- Semantics: `Semantics(button: true, label: 'Вход по биометрии')`.

### Модифицированные классы

**`AuthState`** — поля добавлены в разделе Types.
**`AuthLocalDataSource`** — рефакторинг per-profile, интеграция `LockoutCalculator`.
**`AuthController`** — интеграция `BiometricRepository`, `ProfileRepository`.
**`AuthScreen`** — `ProfileSelectorWidget` и `BiometricAuthButton`.
**`SettingsScreen`** — секции «Профили», «Биометрия», «Замеры производительности».
**`DatabaseSchema`** — version → 4, таблица `profiles`, индексы.
**`DatabaseMigrations`** — `_migrateToV4` (см. ниже).
**`PasswordEntry`** — добавить `profileId`.
**`StorageLocalDataSource`** — фильтрация по `profile_id`.
**`SecurityLogRepositoryImpl`** — фильтрация по `profile_id`.
**`PasswordGeneratorApp`** — регистрация провайдеров новых модулей.

---

## [Authentication UX Flow]

**Выбор варианта: A — «Профиль → PIN этого профиля».**

Обоснование: проще в реализации, понятнее пользователю, не скрывает информацию, не являющуюся чувствительной (количество профилей на личном устройстве не является секретом). Вариант B (единое поле PIN, приложение пробует все профили) отложен как возможное усиление; он требует `N × PBKDF2(600 000)` попыток, что при 5 профилях даёт ~1,5 сек латентности на каждый ввод — неприемлемо с точки зрения UX.

Поток:

```
Запуск приложения
  ↓
Экран выбора профиля (если профилей > 1)
  ↓
Экран ввода PIN выбранного профиля
  ↓
 ├─ Если биометрия включена для профиля → кнопка «Войти по биометрии»
 │     ↓ успех: retrievePinForProfile → verifyPin → разблокировка
 │     ↓ неудача: fallback на PIN
 ↓
PIN введён → PBKDF2 с pin_salt профиля → derived_key → проверка pin_hash через constant-time comparison
  ↓
Успех: derived_key в памяти, данные профиля разблокированы, логаут других профилей гарантирован
```

---

## [QR Transfer Security Model]

Ни одно из устройств-участников не знает общий ключ заранее. Безопасность обеспечивается **одноразовым transfer PIN**, который отправитель сообщает получателю **вне канала QR** (голос, личное сообщение, мессенджер).

### Экспорт (отправитель)

1. Пользователь выбирает запись `PasswordEntry` для отправки.
2. Приложение генерирует:
   - `nonce = Random.secure().nextBytes(12)`
   - `salt = Random.secure().nextBytes(16)`
   - Отображает диалог ввода transfer PIN (4–6 цифр, генерируется автоматически или задаётся пользователем).
3. `transfer_key = PBKDF2-HMAC-SHA256(transferPin, salt, iterations=100000, keyLength=32)`.
   - 100 000 итераций (не 600 000), потому что TTL = 300 сек ограничивает окно атаки даже при утечке QR-кода.
4. `ciphertext + mac = ChaCha20-Poly1305.encrypt(transfer_key, nonce, serialize(entry))`.
5. `QrTransferPayload` упаковывается в JSON → base64url → QR-код.
6. Приложение отображает QR + transfer PIN **раздельно**, напоминает сообщить PIN получателю вне канала QR.

### Импорт (получатель)

1. Сканирует QR → декодирует base64url → получает `QrTransferPayload`.
2. **Первая проверка — TTL:** `payload.isExpired` → отказ с сообщением «QR истёк».
3. Ввод transfer PIN, полученного от отправителя.
4. `transfer_key = PBKDF2-HMAC-SHA256(transferPin, payload.salt, payload.iterations, 32)`.
5. `entry_bytes = ChaCha20-Poly1305.decrypt(transfer_key, payload.nonce, payload.ciphertext, payload.mac)`.
   - При неверном PIN — MAC не сойдётся, возвращается `AuthenticationError`. Сервис показывает «Неверный PIN», не даёт автоматический перебор (встроенная защита Poly1305).
6. `entry = PasswordEntry.deserialize(entry_bytes)`.
7. Пользователь подтверждает импорт в текущий профиль.

### Защищаемые угрозы

- **Перехват QR при физической съёмке:** без PIN — бесполезно.
- **Повторное использование QR:** TTL 300 сек + проверка на стороне получателя.
- **Подмена payload:** Poly1305 MAC, любая модификация ведёт к `AuthenticationError`.
- **Слабый PIN (4 цифры):** 10 000 вариантов × 100 000 PBKDF2 итераций ≈ 50 000 секунд CPU на полный перебор — при TTL 300 сек вскрыть невозможно.

---

## [Dependencies]

В `pubspec.yaml` добавить:

```yaml
dependencies:
  # Существующие зависимости оставить без изменений
  local_auth: ^2.3.0              # Биометрическая аутентификация (Android/iOS)
  flutter_secure_storage: ^9.2.2  # Платформенное защищённое хранилище для PIN под биометрией
  qr_flutter: ^4.1.0              # Генерация QR-кодов
  mobile_scanner: ^6.0.0          # Сканирование QR-кодов
```

**Требования к версиям:**
- `local_auth: ^2.3.0` — Android 14+ BiometricPrompt, iOS LocalAuthentication.
- `flutter_secure_storage: ^9.2.2` — EncryptedSharedPreferences на Android, Keychain Services на iOS.
- `qr_flutter: ^4.1.0` — null-safety, совместимость с Flutter 3.24+.
- `mobile_scanner: ^6.0.0` — minSdk 21 (Android), iOS 11+.

**Платформенные конфигурации:**
- **Android:** `AndroidManifest.xml` — разрешение `USE_BIOMETRIC` и `CAMERA` (для `mobile_scanner`). Проверить `minSdk` в `android/app/build.gradle.kts`: `flutter_secure_storage` с `encryptedSharedPreferences: true` требует **minSdk 23**. При `minSdk < 23` использовать fallback:
  ```dart
  AndroidOptions(
    encryptedSharedPreferences: Platform.isAndroid && sdkInt >= 23,
  )
  ```
- **iOS:** `Info.plist` — ключи `NSFaceIDUsageDescription` и `NSCameraUsageDescription`.
- **Desktop (Windows/Linux/macOS) и Web:** биометрия недоступна; `BiometricLocalDataSource.isAvailable()` возвращает `false`; UI-секция биометрии скрыта. QR-обмен: экспорт работает на всех платформах; импорт на desktop реализуется через **ручной ввод base64url-строки** или вставку из буфера обмена (вместо камеры), т.к. `mobile_scanner` не поддерживает desktop.

---

## [Migration Details]

### `_migrateToV4` (v3 → v4)

Выполняется в транзакции. Псевдокод:

```sql
BEGIN TRANSACTION;

-- 1. Создать таблицу profiles
CREATE TABLE profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  avatar_emoji TEXT,
  created_at INTEGER NOT NULL,
  last_accessed_at INTEGER
);

-- 2. Создать дефолтный профиль
INSERT INTO profiles (id, name, created_at)
VALUES (1, 'Профиль по умолчанию', strftime('%s', 'now'));

-- 3. Добавить profile_id в связанные таблицы
ALTER TABLE password_entries ADD COLUMN profile_id INTEGER REFERENCES profiles(id);
ALTER TABLE security_logs    ADD COLUMN profile_id INTEGER REFERENCES profiles(id);
ALTER TABLE password_history ADD COLUMN profile_id INTEGER REFERENCES profiles(id);
ALTER TABLE categories       ADD COLUMN profile_id INTEGER REFERENCES profiles(id);
ALTER TABLE password_configs ADD COLUMN profile_id INTEGER REFERENCES profiles(id);

-- 4. Привязать существующие данные к дефолтному профилю
UPDATE password_entries SET profile_id = 1 WHERE profile_id IS NULL;
UPDATE security_logs    SET profile_id = 1 WHERE profile_id IS NULL;
UPDATE password_history SET profile_id = 1 WHERE profile_id IS NULL;
UPDATE categories       SET profile_id = 1 WHERE profile_id IS NULL;
UPDATE password_configs SET profile_id = 1 WHERE profile_id IS NULL;

-- 5. Перестроить auth_data под per-profile схему
-- SQLite не поддерживает ALTER TABLE ADD COLUMN с UNIQUE constraint,
-- поэтому выполняем реструктуризацию через временную таблицу.
CREATE TABLE auth_data_new (
  profile_id INTEGER NOT NULL PRIMARY KEY,
  pin_hash TEXT NOT NULL,
  pin_salt TEXT NOT NULL,
  failed_attempts INTEGER DEFAULT 0,
  series_index INTEGER DEFAULT 0,
  lockout_until INTEGER,
  biometric_enabled INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);
INSERT INTO auth_data_new (profile_id, pin_hash, pin_salt, failed_attempts, series_index, lockout_until, biometric_enabled, created_at)
SELECT 1, value, '', 0, 0, NULL, 0, created_at FROM auth_data WHERE key = 'pin_hash';
UPDATE auth_data_new SET pin_salt = (SELECT value FROM auth_data WHERE key = 'pin_salt');
DROP TABLE auth_data;
ALTER TABLE auth_data_new RENAME TO auth_data;

-- 6. Индексы
CREATE INDEX idx_password_entries_profile ON password_entries(profile_id);
CREATE INDEX idx_security_logs_profile    ON security_logs(profile_id);
CREATE INDEX idx_password_history_profile ON password_history(profile_id);
CREATE UNIQUE INDEX idx_auth_data_profile ON auth_data(profile_id);

COMMIT;
```

> Примечание: в тексте диплома миграция **не описывается** (по договорённости: v1/v2/v3 никем не использовались). Код миграции нужен для развёртывания приложения на машинах разработчика с существующими тестовыми данными.

---

## [Testing]

### Новые тестовые файлы

| Путь | Что тестируется |
|---|---|
| `test/unit/glitch/glitch_transformer_test.dart` | Корректность каждого правила трансформации, **детерминированность** (`glitchText(x) == glitchText(x)`), оценка стойкости |
| `test/unit/glitch/glitch_service_test.dart` | Интеграция правил, edge cases (пустая строка, юникод, спецсимволы, длинный вход) |
| `test/unit/biometric/biometric_local_datasource_test.dart` | Мок `local_auth` + `flutter_secure_storage`, проверка доступности, аутентификация, обработка ошибок, desktop → `false` |
| `test/unit/profile/profile_repository_test.dart` | CRUD профилей, переключение активного профиля, **криптографическая изоляция данных** (PIN профиля A не расшифровывает записи профиля B) |
| `test/unit/qr/qr_transfer_repository_test.dart` | Сериализация/десериализация payload, шифрование/расшифровка, валидация TTL, проверка MAC, неверный transfer PIN → отказ |
| `test/unit/benchmark/performance_benchmark_service_test.dart` | Замеры возвращают положительные значения, запись в `security_logs`, экспорт в CSV/JSON |
| `test/unit/auth/lockout_calculator_test.dart` | Серии 0, 1, 2, 5, 10 → корректные задержки; потолок 7 суток; сброс при успехе |
| `test/usecases/profile/` | Use cases для профилей |
| `test/usecases/biometric/` | Use cases для биометрии |
| `test/usecases/glitch/` | Use cases для глитчирования |
| `test/widgets/profiles_screen_test.dart` | Виджет-тест экрана профилей |
| `test/widgets/glitch_screen_test.dart` | Виджет-тест экрана глитчирования |
| `test/widgets/qr_transfer_screen_test.dart` | Виджет-тест QR-экрана |

### Модификация существующих тестов

| Путь | Изменения |
|---|---|
| `test/usecases/auth/verify_pin_usecase_test.dart` | Тесты с `profileId`, прогрессивная блокировка по сериям |
| `test/usecases/auth/setup_pin_usecase_test.dart` | Тесты с `profileId`, per-profile salt |
| `test/unit/auth/auth_local_datasource_test.dart` | Поддержка `profileId`, новая логика блокировки |

### Валидационные стратегии

1. **Unit-тесты:** покрытие всех новых сервисов, datasource, утилит (цель: 80%+ покрытие нового кода).
2. **Widget-тесты:** ключевые сценарии UI (создание профиля, глитчирование, QR-сканирование).
3. **Интеграционные тесты:** сквозной сценарий — создание профиля → установка PIN → включение биометрии → создание записи → экспорт в QR → импорт в другой профиль. Доказать, что данные профиля A не видны из профиля B даже при прямом SQL-запросе.
4. **Security-тесты:**
   - Изоляция: данные профиля A зашифрованы ключом A; расшифровка через ключ B возвращает `AuthenticationError` от Poly1305.
   - Стойкость глитчирования: zxcvbn score ≥ 3 на реалистичных входах длиной ≥ 8 символов.
   - Прогрессивная блокировка: после 30 неудач задержка ≥ 1 час.
   - QR: подменённый payload → `AuthenticationError`; просроченный payload → отказ.

---

## [Implementation Order]

### 1. Подготовка инфраструктуры
- Добавить зависимости в `pubspec.yaml` (`local_auth`, `flutter_secure_storage`, `qr_flutter`, `mobile_scanner`).
- Настроить платформенные разрешения (`AndroidManifest.xml`, `Info.plist`).
- Обновить `DatabaseSchema` (версия 4, таблица `profiles`, поля `profile_id`, индексы).

### 2. Прогрессивная блокировка
- Создать `LockoutCalculator` с констатами и формулой по сериям.
- Модифицировать `AuthLocalDataSource` для использования `LockoutCalculator` вместо фиксированной блокировки.
- Ввести `seriesIndex` в `auth_data`.
- Обновить/добавить тесты аутентификации.

### 3. Многопрофильность

**3a. Миграция БД**
- Реализовать `_migrateToV4` с созданием дефолтного профиля и привязкой существующих данных.
- Интеграционный тест миграции на тестовой БД.

**3b. Профили (data layer)**
- Создать entity `Profile`, `ProfileLocalDataSource`, `ProfileRepository` (interface + impl).
- Создать use cases (`CreateProfileUseCase`, `ListProfilesUseCase`, `SwitchProfileUseCase`, `DeleteProfileUseCase`).
- Unit-тесты.

**3c. Криптографическая изоляция**
- Рефакторинг `AuthLocalDataSource`: хранение `auth_data` построчно на профиль (per-profile `pin_hash`, `pin_salt`).
- Per-profile деривация `derived_key` через PBKDF2.
- Модификация шифрования `password_entries` для использования ключа активного профиля.
- Security-тесты изоляции: данные профиля A не расшифровываются ключом B.

**3d. Интеграция на уровне datasource**
- `StorageLocalDataSource`, `SecurityLogRepositoryImpl`, `PasswordHistoryRepository` — фильтрация по `profile_id` + шифрование под ключом активного профиля.

### 4. Профили (presentation layer)
- Создать `ProfilesController`, UI экрана профилей (список, создание, удаление).
- Создать `ProfileSelectorWidget` с `Semantics`.
- Интегрировать в `AuthScreen` (поток «Профиль → PIN этого профиля»).
- Обновить `SettingsScreen` — секция «Профили».

### 5. Биометрия (data layer)
- Создать `BiometricLocalDataSource` (обёртка над `local_auth` + `flutter_secure_storage`).
- Desktop/web: `isAvailable` возвращает `false`.
- Создать `BiometricRepository` (interface + impl).
- Создать use cases: `IsBiometricAvailableUseCase`, `EnableBiometricUseCase`, `DisableBiometricUseCase`, `AuthenticateWithBiometricUseCase`.
- Unit-тесты с моками.

### 6. Биометрия (presentation layer)
- Создать `BiometricAuthButton` с `Semantics`.
- Расширить `AuthController` — `authenticateWithBiometric()`, fallback на PIN при неудаче.
- Модифицировать `AuthScreen` — отображение кнопки только если `isBiometricAvailable && isBiometricEnabled`.
- Добавить переключатель в `SettingsScreen`.

### 7. Глитчирование текста
- Создать `GlitchTransformer` с детерминированными правилами (`derivedSalt` из хэша входа).
- Создать `GlitchService`.
- Создать use cases и `GlitchController`.
- UI экрана глитчирования (ввод → превью результата → оценка стойкости → кнопка «Сохранить как пароль»).
- Unit-тесты на **детерминированность** и стойкость (zxcvbn ≥ 3).

### 8. QR-обмен
- Создать `QrTransferPayload` entity с `nonce`, `salt`, `iterations`, `ciphertext`, `mac`, `createdAt`, `expirySeconds`.
- Создать `QrPayloadCodec` в core.
- Создать `QrTransferRepository` (interface + impl) с шифрованием через transfer PIN.
- Создать use cases `ExportEntryToQrUseCase`, `ImportEntryFromQrUseCase`.
- Создать `QrTransferController` и UI: экран экспорта (выбор записи → диалог transfer PIN → QR + PIN раздельно) + экран импорта (сканер → диалог PIN → подтверждение импорта).
- Unit-тесты: корректность round-trip, проверка TTL, неверный PIN → ошибка, подменённый payload → ошибка.

### 9. Замеры производительности
- Создать `PerformanceBenchmarkService` с тремя бенчмарками.
- Интеграция записи результатов в `security_logs` через существующий `SecurityLogRepository`.
- Создать `BenchmarkController` и UI страницы (кнопки прогона, таблица результатов, кнопка экспорта в CSV/JSON).
- Добавить пункт в `SettingsScreen`.
- Провести замеры на 4 платформах: Linux, Windows, macOS, Android-эмулятор — результаты для приложения И диплома.

### 10. Интеграция и DI
- Обновить `main.dart` с инициализацией новых datasource.
- Обновить `PasswordGeneratorApp` с провайдерами новых репозиториев и контроллеров.
- Добавить новые экраны в навигацию `SettingsScreen`.

### 11. Тестирование
- Все unit-тесты для новых модулей.
- Widget-тесты для новых экранов.
- Интеграционное тестирование сквозных сценариев.
- Security-тесты криптографической изоляции профилей.
- Прогон `flutter test --coverage` — проверить целевые 80%+ по новому коду.

### 12. Документация и ревью
- Актуализировать `README.MD`:
  - PBKDF2 **600 000** итераций (v2), не 10 000.
  - Статус платформ: Web/iOS — «сборка проходит, функциональное тестирование не проводилось».
  - Удалить маркетинговые формулировки «100% готово».
  - Добавить раздел про многопрофильность, биометрию, QR-обмен, глитчирование.
- Обновить `DEVELOPER.md` с новыми модулями.
- Документировать публичные API новых сервисов: DartDoc-комментарии + пример использования в заголовке файла.
- Статический анализ (`flutter analyze`).
- `dart format` на всех новых файлах.
- Декомпозиция методов > 50 строк.
- Обновить `CHANGELOG.md`.

---

*План подготовлен на основе анализа кодовой базы PassGen v0.5.2, требований дипломного плана v2.0 и архитектурного ревью от 21.04.2026.*

## [Changelog of this plan]

**v1.1 (21.04.2026) — ревью-правки:**
1. Удалено поле `Profile.isAdmin`. Ролевая модель отложена в «Перспективы развития» (серверная часть).
2. Добавлен раздел **Cryptographic Isolation of Profiles** — per-profile деривация ключа.
3. Переписана формула `LockoutCalculator`: индекс **серий** (не попыток), коэффициент роста 6, потолок 7 суток, константы вынесены в класс.
4. Добавлена зависимость `flutter_secure_storage`. Механизм биометрии теперь явно хранит PIN под биометрическим гейтом ОС; `local_auth` — только сигнал «да/нет».
5. Добавлено: биометрия недоступна на desktop/web, `isAvailable()` возвращает `false`.
6. Добавлен раздел **QR Transfer Security Model** — transfer PIN out-of-band, PBKDF2(100 000) + ChaCha20-Poly1305, TTL 300 сек.
7. Глитчирование: случайная соль → **детерминированная** `derivedSalt` из `SHA-256(input)`, чтобы функция оставалась обратимой для пользователя.
8. Добавлен раздел **Migration Details** — полный `_migrateToV4` с созданием дефолтного профиля.
9. Удалён `BiometricType.iris`.
10. Добавлен раздел **Authentication UX Flow** с выбранным вариантом A («Профиль → PIN»).
11. Добавлен индекс `idx_auth_data_profile` (unique).
12. Бенчмарки пишутся в существующий `security_logs`; CSV/JSON — опциональный экспорт.
13. Добавлены `Semantics`-обёртки для новых виджетов.
14. Добавлена документация публичных API (DartDoc) в шаг ревью.
15. Шаг «Многопрофильность» разбит на 3a/3b/3c/3d — отдельно выделен шаг криптографической изоляции.
16. Добавлен шаг актуализации `README.MD` (исправление PBKDF2 итераций, статуса платформ, удаление маркетинга).
