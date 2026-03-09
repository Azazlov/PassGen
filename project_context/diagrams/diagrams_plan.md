# 📊 План создания диаграмм для PassGen v0.5.0

**Дата создания:** 8 марта 2026 г.  
**Версия документа:** 1.0

---

## 📋 Содержание

1. [Диаграмма вариантов использования (Use Case)](#1-диаграмма-вариантов-использования-use-case)
2. [Диаграмма классов (Class Diagram)](#2-диаграмма-классов-class-diagram)
3. [Диаграмма последовательности (Sequence Diagram)](#3-диаграмма-последовательности-sequence-diagram)
4. [Диаграмма компонентов (Component Diagram)](#4-диаграмма-компонентов-component-diagram)
5. [Диаграмма развёртывания (Deployment Diagram)](#5-диаграмма-развёртывания-deployment-diagram)
6. [ER-диаграмма базы данных (Entity-Relationship)](#6-er-диаграмма-базы-данных-entity-relationship)
7. [Диаграмма состояний (State Diagram)](#7-диаграмма-состояний-state-diagram)
8. [Диаграмма активности (Activity Diagram)](#8-диаграмма-активности-activity-diagram)

---

## 1. Диаграмма вариантов использования (Use Case)

### Акторы

| Актор | Описание |
|-------|----------|
| **Пользователь** | Основной пользователь приложения |

### Сценарии использования (25+)

#### 🔐 Аутентификация

| Use Case | Связи | Описание |
|----------|-------|----------|
| Установить PIN | include → Ввести PIN | Установка PIN-кода (4-8 цифр) |
| Проверить PIN | include → Ввести PIN | Верификация PIN при входе |
| Сменить PIN | include → Ввести старый PIN, Ввести новый PIN | Изменение PIN-кода |
| Удалить PIN | include → Ввести PIN | Отключение аутентификации |
| Разблокировать приложение | | Снятие блокировки после неактивности |

#### 🔑 Генерация паролей

| Use Case | Связи | Описание |
|----------|-------|----------|
| Сгенерировать пароль | include → Настроить сложность | Генерация нового пароля |
| Настроить сложность | | Выбор из 5 уровней сложности |
| Настроить длину пароля | | Установка диапазона (1-64 символа) |
| Исключить похожие символы | | Опция исключения (1, l, I, O, 0) |
| Без повторяющихся символов | | Опция уникальности символов |
| Сохранить пароль | extend → Сгенерировать пароль | Сохранение в хранилище с категорией |

#### 📦 Хранилище паролей

| Use Case | Связи | Описание |
|----------|-------|----------|
| Просмотреть пароли | | Карусельный просмотр всех записей |
| Фильтровать по категории | | Выбор категории из 7 системных + пользовательские |
| Поиск по сервису | | Поиск по названию сервиса |
| Удалить пароль | | Удаление записи из хранилища |
| Экспорт в JSON | | Экспорт всех паролей в JSON |
| Импорт из JSON | | Импорт паролей из JSON |
| Экспорт в .passgen | include → Ввести мастер-пароль | Фирменный формат с шифрованием |
| Импорт из .passgen | include → Ввести мастер-пароль | Импорт из .passgen формата |

#### 🔒 Шифратор сообщений

| Use Case | Связи | Описание |
|----------|-------|----------|
| Зашифровать сообщение | | Шифрование текста паролем (ChaCha20-Poly1305) |
| Расшифровать сообщение | | Дешифрование текста паролем |

#### 📂 Категории

| Use Case | Связи | Описание |
|----------|-------|----------|
| Просмотреть категории | | Просмотр всех категорий |
| Создать категорию | | Добавление пользовательской категории |
| Редактировать категорию | | Изменение имени/иконки |
| Удалить категорию | | Удаление (кроме системных) |

#### 📊 Логи безопасности

| Use Case | Связи | Описание |
|----------|-------|----------|
| Просмотреть логи | | Просмотр журнала событий |
| Фильтровать по дате | | Фильтрация по дате |
| Фильтровать по типу события | | Фильтрация по типу (AUTH, PWD, и т.д.) |

#### ⚙️ Настройки

| Use Case | Связи | Описание |
|----------|-------|----------|
| Сменить PIN | | Изменение PIN-кода |
| Удалить PIN | | Отключение аутентификации |
| Просмотреть количество логов | | Статистика событий |

---

## 2. Диаграмма классов (Class Diagram)

### 2.1 Domain Layer — Сущности (8 классов)

```
┌─────────────────────────────────────────────────────────┐
│                    PasswordEntry                        │
├─────────────────────────────────────────────────────────┤
│ - id: int?                                              │
│ - categoryId: int?                                      │
│ - service: String                                       │
│ - login: String?                                        │
│ - password: String                                      │
│ - config: String                                        │
│ - createdAt: DateTime                                   │
│ - updatedAt: DateTime?                                  │
├─────────────────────────────────────────────────────────┤
│ + copyWith(...): PasswordEntry                          │
│ + toJson(): Map<String, dynamic>                        │
│ + fromJson(Map): PasswordEntry                          │
│ + encodeList(List<PasswordEntry>): String               │
│ + decodeList(String): List<PasswordEntry>               │
│ + existsForService(...): bool                           │
│ + findByService(...): PasswordEntry?                    │
└─────────────────────────────────────────────────────────┘
                            ▲
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────────────┐  ┌────────────────┐  ┌──────────────────┐
│   Category    │  │ PasswordConfig │  │  SecurityLog     │
├───────────────┤  ├────────────────┤  ├──────────────────┤
│ - id: int?    │  │ - id: int?     │  │ - id: int?       │
│ - name: String│  │ - entryId: int │  │ - actionType: Str│
│ - icon: String│  │ - strength: int│  │ - timestamp: Date│
│ - isSystem: int│ │ - minLen: int  │  │ - details: Map?  │
│ - createdAt: D│  │ - maxLen: int  │  │                  │
├───────────────┤  │ - flags: int   │  ├──────────────────┤
│ + copyWith()  │  │ - reqUnique: b │  │ + copyWith()     │
│ + systemCate..│  │ - encConfig: b │  │ + toJson()       │
└───────────────┘  └────────────────┘  └──────────────────┘

┌─────────────────────────────────────────────────────────┐
│              PasswordGenerationSettings                 │
├─────────────────────────────────────────────────────────┤
│ - strength: int (0-4)                                   │
│ - lengthRange: List<int>                                │
│ - flags: int                                            │
│ - requireUppercase: bool                                │
│ - requireLowercase: bool                                │
│ - requireDigits: bool                                   │
│ - requireSymbols: bool                                  │
│ - allUnique: bool                                       │
│ - excludeSimilar: bool                                  │
│ - customCharacters: String?                             │
│ - useCustomLowercase: bool                              │
│ - useCustomUppercase: bool                              │
│ - useCustomDigits: bool                                 │
│ - useCustomSymbols: bool                                │
├─────────────────────────────────────────────────────────┤
│ + copyWith(...): PasswordGenerationSettings             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   PasswordResult                        │
├─────────────────────────────────────────────────────────┤
│ - password: String                                      │
│ - strength: double                                      │
│ - config: String                                        │
│ - error: String?                                        │
├─────────────────────────────────────────────────────────┤
│ + hasError(): bool                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                      AuthState                          │
├─────────────────────────────────────────────────────────┤
│ - isAuthenticated: bool                                 │
│ - isPinSetup: bool                                      │
│ - isLocked: bool                                        │
│ - remainingAttempts: int?                               │
│ - lockoutUntil: DateTime?                               │
├─────────────────────────────────────────────────────────┤
│ + copyWith(...): AuthState                              │
│ + lockoutSecondsRemaining: int                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                     AuthResult                          │
├─────────────────────────────────────────────────────────┤
│ - success: bool                                         │
│ - message: String                                       │
├─────────────────────────────────────────────────────────┤
│ + static success: AuthResult                            │
│ + static wrongPin: AuthResult                           │
│ + static locked: AuthResult                             │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Domain Layer — Репозитории (10 интерфейсов)

```
┌─────────────────────────────────────────────────────────┐
│              AuthRepository (interface)                 │
├─────────────────────────────────────────────────────────┤
│ + setupPin(String): Either<AuthFailure, bool>           │
│ + verifyPin(String): Either<AuthFailure, AuthResult>    │
│ + changePin(String, String): Either<...>                │
│ + removePin(String): Either<...>                        │
│ + getAuthState(): Either<AuthFailure, AuthState>        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           PasswordEntryRepository (interface)           │
├─────────────────────────────────────────────────────────┤
│ + getAll(): Either<Failure, List<PasswordEntry>>        │
│ + getById(int): Either<Failure, PasswordEntry?>         │
│ + getByCategory(int): Either<Failure, List<...>>        │
│ + searchByService(String): Either<Failure, List<...>>   │
│ + create(PasswordEntry): Either<Failure, Map>           │
│ + update(PasswordEntry): Either<Failure, bool>          │
│ + delete(int): Either<Failure, bool>                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          PasswordGeneratorRepository (interface)        │
├─────────────────────────────────────────────────────────┤
│ + generatePassword(settings): Either<Failure, Result>   │
│ + restorePassword(config, password): Either<...>        │
│ + createPasswordConfig(settings): String                │
│ + decryptPassword(config, password): Either<...>        │
│ + savePassword(entry, config): Either<Failure, Map>     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│             EncryptorRepository (interface)             │
├─────────────────────────────────────────────────────────┤
│ + encrypt(String, String): Either<Failure, String>      │
│ + decrypt(String, String): Either<Failure, String>      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│            CategoryRepository (interface)               │
├─────────────────────────────────────────────────────────┤
│ + getAll(): List<Category>                              │
│ + getById(int): Category?                               │
│ + create(Category): Category                            │
│ + update(Category): Category                            │
│ + delete(int): void                                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           SecurityLogRepository (interface)             │
├─────────────────────────────────────────────────────────┤
│ + logEvent(String, Map?): void                          │
│ + getLogs(int): List<SecurityLog>                       │
│ + getLogsByType(String): List<SecurityLog>              │
│ + clearOldLogs(int): void                               │
│ + count(): int                                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           AppSettingsRepository (interface)             │
├─────────────────────────────────────────────────────────┤
│ + getValue(String): String?                             │
│ + setValue(String, String, bool): void                  │
│ + remove(String): void                                  │
│ + getAll(): Map<String, String>                         │
│ + clear(): void                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           StorageRepository (interface)                 │
├─────────────────────────────────────────────────────────┤
│ + getAll(): Either<Failure, List<PasswordEntry>>        │
│ + getByCategory(int): Either<Failure, List<...>>        │
│ + searchByService(String): Either<Failure, List<...>>   │
│ + create(PasswordEntry): Either<Failure, Map>           │
│ + update(PasswordEntry): Either<Failure, bool>          │
│ + delete(int): Either<Failure, bool>                    │
│ + exportJson(): Either<Failure, String>                 │
│ + importJson(String): Either<Failure, bool>             │
│ + exportPassgen(String): Either<Failure, String>        │
│ + importPassgen(String, String): Either<Failure, bool>  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          PasswordExportRepository (interface)           │
├─────────────────────────────────────────────────────────┤
│ + exportJson(): Either<Failure, String>                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          PasswordImportRepository (interface)           │
├─────────────────────────────────────────────────────────┤
│ + importJson(String): Either<Failure, bool>             │
└─────────────────────────────────────────────────────────┘
```

### 2.3 Domain Layer — Use Cases (25+)

```
┌─────────────────────────────────────────────────────────┐
│                    Use Cases                            │
├─────────────────────────────────────────────────────────┤
│ Auth:                                                   │
│   - SetupPinUseCase                                     │
│   - VerifyPinUseCase                                    │
│   - ChangePinUseCase                                    │
│   - RemovePinUseCase                                    │
│   - GetAuthStateUseCase                                 │
├─────────────────────────────────────────────────────────┤
│ Generator:                                              │
│   - GeneratePasswordUseCase                             │
│   - SavePasswordUseCase                                 │
│   - ValidateGeneratorSettingsUseCase                    │
├─────────────────────────────────────────────────────────┤
│ Storage:                                                │
│   - GetPasswordsUseCase                                 │
│   - DeletePasswordUseCase                               │
│   - ExportPasswordsUseCase                              │
│   - ImportPasswordsUseCase                              │
│   - ExportPassgenUseCase                                │
│   - ImportPassgenUseCase                                │
│   - GetConfigsUseCase                                   │
│   - SaveConfigsUseCase                                  │
├─────────────────────────────────────────────────────────┤
│ Category:                                               │
│   - GetCategoriesUseCase                                │
│   - CreateCategoryUseCase                               │
│   - UpdateCategoryUseCase                               │
│   - DeleteCategoryUseCase                               │
├─────────────────────────────────────────────────────────┤
│ Encryptor:                                              │
│   - EncryptMessageUseCase                               │
│   - DecryptMessageUseCase                               │
├─────────────────────────────────────────────────────────┤
│ Log:                                                    │
│   - LogEventUseCase                                     │
│   - GetLogsUseCase                                      │
├─────────────────────────────────────────────────────────┤
│ Settings:                                               │
│   - GetSettingUseCase                                   │
│   - SetSettingUseCase                                   │
│   - RemoveSettingUseCase                                │
└─────────────────────────────────────────────────────────┘
```

### 2.4 Presentation Layer — Контроллеры (7 классов)

```
┌─────────────────────────────────────────────────────────┐
│                  AuthController                         │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - authState: AuthState                                  │
│ - isLoading: bool                                       │
│ - error: String?                                        │
│ - isSetupMode: bool                                     │
│ - pinController: TextEditingController                  │
│ - enteredPin: String                                    │
│ - inactivityTimer: Timer?                               │
├─────────────────────────────────────────────────────────┤
│ + addDigit(String): void                                │
│ + removeDigit(): void                                   │
│ + clearPin(): void                                      │
│ + setupPin(): Future<bool>                              │
│ + verifyPin(): Future<AuthResult>                       │
│ + changePin(String, String): Future<bool>               │
│ + removePin(String): Future<bool>                       │
│ + startInactivityTimer(): void                          │
│ + resetInactivityTimer(): void                          │
│ + refreshState(): Future<void>                          │
└─────────────────────────────────────────────────────────┘
              ▲
              │ зависит от
              │
┌─────────────────────────────────────────────────────────┐
│              Auth Use Cases                             │
│   - setupPinUseCase                                     │
│   - verifyPinUseCase                                    │
│   - changePinUseCase                                    │
│   - removePinUseCase                                    │
│   - getAuthStateUseCase                                 │
│   - logEventUseCase                                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               GeneratorController                       │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - settings: PasswordGenerationSettings                  │
│ - lastResult: PasswordResult?                           │
│ - isLoading: bool                                       │
│ - error: String?                                        │
│ - strength: int (0-4)                                   │
│ - selectedCategoryId: int?                              │
│ - serviceController: TextEditingController              │
│ - minLengthController: TextEditingController            │
│ - maxLengthController: TextEditingController            │
├─────────────────────────────────────────────────────────┤
│ + updateStrength(int): void                             │
│ + toggleExcludeSimilar(bool): void                      │
│ + toggleAllUnique(bool): void                           │
│ + toggleUseLowercase(bool): void                        │
│ + toggleUseUppercase(bool): void                        │
│ + toggleUseDigits(bool): void                           │
│ + toggleUseSymbols(bool): void                          │
│ + updateLengthRange(int, int): void                     │
│ + generatePassword(): Future<void>                      │
│ + savePassword(): Future<Map<String, dynamic>>          │
│ + updateSelectedCategoryId(int?): void                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               StorageController                         │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - allPasswords: List<PasswordEntry>                     │
│ - passwords: List<PasswordEntry>                        │
│ - currentIndex: int                                     │
│ - selectedCategoryId: int?                              │
│ - searchQuery: String                                   │
│ - isLoading: bool                                       │
│ - error: String?                                        │
├─────────────────────────────────────────────────────────┤
│ + loadPasswords(): Future<void>                         │
│ + nextPassword(): void                                  │
│ + prevPassword(): void                                  │
│ + deleteCurrentPassword(): Future<void>                 │
│ + setCategoryFilter(int?): void                         │
│ + setSearchQuery(String): void                          │
│ + clearFilters(): void                                  │
│ + exportPasswords(): Future<void>                       │
│ + importPasswords(): Future<void>                       │
│ + exportPassgen(): Future<void>                         │
│ + importPassgen(): Future<void>                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              EncryptorController                        │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - result: String                                        │
│ - isLoading: bool                                       │
│ - isEncryptMode: bool                                   │
│ - messageController: TextEditingController              │
│ - passwordController: TextEditingController             │
├─────────────────────────────────────────────────────────┤
│ + encrypt(): Future<void>                               │
│ + decrypt(): Future<void>                               │
│ + toggleMode(): void                                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              SettingsController                         │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ + getSetting(String): Future<String?>                   │
│ + setSetting(String, String, bool): Future<void>        │
│ + changePin(String, String): Future<bool>               │
│ + removePin(String): Future<bool>                       │
│ + getLogsCount(): int                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              CategoriesController                       │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - categories: List<Category>                            │
├─────────────────────────────────────────────────────────┤
│ + loadCategories(): Future<void>                        │
│ + createCategory(String, String): Future<void>          │
│ + updateCategory(Category): Future<void>                │
│ + deleteCategory(int): Future<void>                     │
│ + getSystemCategories(): List<Category>                 │
│ + getUserCategories(): List<Category>                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                 LogsController                          │
│                    (ChangeNotifier)                     │
├─────────────────────────────────────────────────────────┤
│ - logs: List<SecurityLog>                               │
├─────────────────────────────────────────────────────────┤
│ + loadLogs(): Future<void>                              │
│ + getLogsByDate(DateTime): List<SecurityLog>            │
│ + getEventIcon(String): IconData                        │
│ + getEventColor(String): Color                          │
└─────────────────────────────────────────────────────────┘
```

### 2.5 Data Layer — Источники данных (4 класса)

```
┌─────────────────────────────────────────────────────────┐
│            EncryptorLocalDataSource                     │
├─────────────────────────────────────────────────────────┤
│ - algorithm: Chacha20Poly1305                           │
├─────────────────────────────────────────────────────────┤
│ + generateRandomBytes(int, List<int>): List<int>        │
│ + generateRandomInt(int, int): int                      │
│ + encrypt(message, password): Future<Map>               │
│ + decrypt(encryptedData, password): Future<List<int>>   │
│ + encryptToMini(message, password): Future<String>      │
│ + decryptFromMini(miniEnc, password): Future<List<int>> │
│ + toJsonString(Map): String                             │
│ + fromJsonString(String): Map                           │
├─────────────────────────────────────────────────────────┤
│ Зависимости:                                            │
│   - cryptography: Chacha20, Pbkdf2, Hmac, SecretBox    │
│   - CryptoUtils (encode/decode Base64)                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              AuthLocalDataSource                        │
├─────────────────────────────────────────────────────────┤
│ - sharedPreferences: SharedPreferences                  │
├─────────────────────────────────────────────────────────┤
│ + isValidPinFormat(String): bool                        │
│ + isPinSetup(): Future<bool>                            │
│ + setupPin(String): Future<bool>                        │
│ + verifyPin(String): Future<AuthResult>                 │
│ + changePin(String, String): Future<bool>               │
│ + removePin(String): Future<bool>                       │
│ + getAuthState(): Future<AuthState>                     │
├─────────────────────────────────────────────────────────┤
│ Зависимости:                                            │
│   - shared_preferences                                  │
│   - cryptography: Pbkdf2, Hmac.sha256()                 │
│   - PBKDF2: 10,000 итераций, HMAC-SHA256               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         PasswordGeneratorLocalDataSource                │
├─────────────────────────────────────────────────────────┤
│ - encryptorDataSource: EncryptorLocalDataSource         │
│ - storageDataSource: StorageLocalDataSource             │
├─────────────────────────────────────────────────────────┤
│ + generate(settings): Future<PasswordResult>            │
│ + restoreFromConfig(config, masterPwd): Future<String>  │
│ + savePassword(entry, config): Future<Map>              │
├─────────────────────────────────────────────────────────┤
│ Зависимости:                                            │
│   - EncryptorLocalDataSource                            │
│   - StorageLocalDataSource                              │
│   - PasswordUtils.evaluateStrength()                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│             StorageLocalDataSource                      │
├─────────────────────────────────────────────────────────┤
│ - sharedPreferences: SharedPreferences                  │
├─────────────────────────────────────────────────────────┤
│ + saveConfig(String, String): Future<bool>              │
│ + getConfigs(String): Future<List<String>>              │
│ + savePasswords(List<PasswordEntry>): Future<bool>      │
│ + getPasswords(): Future<List<PasswordEntry>>           │
│ + exportPasswords(): Future<String>                     │
│ + importPasswords(String): Future<bool>                 │
├─────────────────────────────────────────────────────────┤
│ Зависимости:                                            │
│   - shared_preferences                                  │
└─────────────────────────────────────────────────────────┘
```

### 2.6 Data Layer — Репозитории (9 реализаций)

```
┌─────────────────────────────────────────────────────────┐
│            AuthRepositoryImpl                           │
│ implements AuthRepository                               │
├─────────────────────────────────────────────────────────┤
│ - dataSource: AuthLocalDataSource                       │
│ - logRepository: SecurityLogRepository                  │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы AuthRepository                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│        PasswordGeneratorRepositoryImpl                  │
│ implements PasswordGeneratorRepository                  │
├─────────────────────────────────────────────────────────┤
│ - dataSource: PasswordGeneratorLocalDataSource          │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы PasswordGeneratorRepository        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           EncryptorRepositoryImpl                       │
│ implements EncryptorRepository                          │
├─────────────────────────────────────────────────────────┤
│ - dataSource: EncryptorLocalDataSource                  │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы EncryptorRepository                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          StorageRepositoryImpl                          │
│ implements StorageRepository                            │
├─────────────────────────────────────────────────────────┤
│ - entryRepository: PasswordEntryRepository              │
│ - configRepository: PasswordConfigRepository            │
│ - exportRepository: PasswordExportRepository            │
│ - importRepository: PasswordImportRepository            │
│ - passgenFormat: PassgenFormat                        │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы StorageRepository                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│        CategoryRepositoryImpl                           │
│ implements CategoryRepository                           │
├─────────────────────────────────────────────────────────┤
│ - dbHelper: DatabaseHelper                              │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы CategoryRepository                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│        SecurityLogRepositoryImpl                        │
│ implements SecurityLogRepository                        │
├─────────────────────────────────────────────────────────┤
│ - dbHelper: DatabaseHelper                              │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы SecurityLogRepository              │
│ Автоочистка старых логов (>100 записей)                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│        AppSettingsRepositoryImpl                        │
│ implements AppSettingsRepository                        │
├─────────────────────────────────────────────────────────┤
│ - dbHelper: DatabaseHelper                              │
├─────────────────────────────────────────────────────────┤
│ Реализует все методы AppSettingsRepository              │
└─────────────────────────────────────────────────────────┘
```

### 2.7 Core Layer — Утилиты и ошибки

```
┌─────────────────────────────────────────────────────────┐
│                    CryptoUtils                          │
├─────────────────────────────────────────────────────────┤
│ + static encodeBase64(String): String                   │
│ + static decodeBase64(String): String                   │
│ + static encodeBytesBase64(List<int>): String           │
│ + static decodeBytesBase64(String): List<int>           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   PasswordUtils                         │
├─────────────────────────────────────────────────────────┤
│ + static evaluateStrength(String): double               │
├─────────────────────────────────────────────────────────┤
│ Зависимости:                                            │
│   - zxcvbn                                              │
│   - password_strength                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                      Failure                            │
│                   (abstract class)                      │
├─────────────────────────────────────────────────────────┤
│ - message: String                                       │
├─────────────────────────────────────────────────────────┤
│ + constructor(message)                                  │
└─────────────────────────────────────────────────────────┘
              ▲
              │ наследуют
    ┌─────────┼─────────┬────────────┬──────────────┐
    │         │         │            │              │
┌────────┐ ┌────────┐ ┌─────────┐ ┌──────────┐ ┌─────────┐
│Encryption│ │Password│ │ Storage │ │   Auth   │ │  Other  │
│ Failure  │ │Generat.│ │ Failure │ │ Failure  │ │ Failure │
│        │ │Failure │ │         │ │          │ │         │
└────────┘ └────────┘ └─────────┘ └──────────┘ └─────────┘
```

### 2.8 Database — Схема (5 таблиц)

```
┌─────────────────────────────────────────────────────────┐
│                    categories                           │
├─────────────────────────────────────────────────────────┤
│ PK id: INTEGER                                          │
│    name: TEXT NOT NULL                                  │
│    icon: TEXT                                           │
│    is_system: INTEGER DEFAULT 0                         │
│    created_at: INTEGER NOT NULL                         │
└─────────────────────────────────────────────────────────┘
              ▲
              │ 1
              │
              │ N
┌─────────────────────────────────────────────────────────┐
│                 password_entries                        │
├─────────────────────────────────────────────────────────┤
│ PK id: INTEGER                                          │
│ FK category_id: INTEGER REFERENCES categories(id)       │
│    service: TEXT NOT NULL                               │
│    login: TEXT                                          │
│    encrypted_password: BLOB NOT NULL                    │
│    nonce: BLOB NOT NULL                                 │
│    created_at: INTEGER NOT NULL                         │
│    updated_at: INTEGER NOT NULL                         │
├─────────────────────────────────────────────────────────┤
│ Индексы: idx_category, idx_service                      │
└─────────────────────────────────────────────────────────┘
              ▲
              │ 1
              │
              │ 1
┌─────────────────────────────────────────────────────────┐
│                 password_configs                        │
├─────────────────────────────────────────────────────────┤
│ PK id: INTEGER                                          │
│ UK entry_id: INTEGER UNIQUE REFERENCES password_entries │
│    strength: INTEGER                                    │
│    min_length: INTEGER                                  │
│    max_length: INTEGER                                  │
│    flags: INTEGER                                       │
│    require_unique: INTEGER DEFAULT 0                    │
│    encrypted_config: BLOB                               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   security_logs                         │
├─────────────────────────────────────────────────────────┤
│ PK id: INTEGER                                          │
│    action_type: TEXT NOT NULL                           │
│    timestamp: INTEGER NOT NULL                          │
│    details: TEXT                                        │
├─────────────────────────────────────────────────────────┤
│ Индексы: idx_action_type, idx_timestamp                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   app_settings                          │
├─────────────────────────────────────────────────────────┤
│ PK key: TEXT                                            │
│    value: TEXT NOT NULL                                 │
│    encrypted: INTEGER DEFAULT 0                         │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Диаграмма последовательности (Sequence Diagram)

### 3.1 Генерация и сохранение пароля

```
┌──────┐  ┌────────────────┐  ┌──────────────────┐  ┌───────────────────┐  ┌────────────────────┐  ┌──────────────────┐  ┌──────────┐
│ User │  │GeneratorScreen │  │GeneratorController│  │GeneratePasswordUC │  │PasswordGeneratorRep│  │EncryptorLocalDS │  │PasswordUtils│
└──┬───┘  └───────┬────────┘  └────────┬─────────┘  └─────────┬─────────┘  └──────────┬─────────┘  └────────┬─────────┘  └────┬─────┘
   │             │                     │                       │                      │                     │                 │
   │ Нажать      │                     │                       │                      │                     │                 │
   │ "Сгенерировать"                   │                       │                      │                     │                 │
   │────────────>│                     │                       │                      │                     │                 │
   │             │ generatePassword()  │                       │                      │                     │                 │
   │             │────────────────────>│                       │                      │                     │                 │
   │             │                     │ validateSettings()    │                      │                     │                 │
   │             │                     │──────────────────────>│                      │                     │                 │
   │             │                     │                       │                      │                     │                 │
   │             │                     │                       │ generatePassword()   │                     │                 │
   │             │                     │                       │─────────────────────>│                     │                 │
   │             │                     │                       │                      │ generate()          │                 │
   │             │                     │                       │                      │────────────────────>│                 │
   │             │                     │                       │                      │ Random.secure()     │                 │
   │             │                     │                       │                      │────────────────────>│                 │
   │             │                     │                       │                      │                     │ evaluateStrength()│
   │             │                     │                       │                      │                     │────────────────>│
   │             │                     │                       │                      │                     │                 │
   │             │                     │                       │                      │ PasswordResult      │                 │
   │             │                     │                       │                      │<────────────────────│                 │
   │             │                     │                       │ PasswordResult       │                     │                 │
   │             │                     │                       │<─────────────────────│                     │                 │
   │             │                     │ _lastResult = result  │                      │                     │                 │
   │             │                     │<──────────────────────│                      │                     │                 │
   │             │ notifyListeners()   │                       │                      │                     │                 │
   │             │<────────────────────│                       │                      │                     │                 │
   │             │                     │                       │                      │                     │                 │
   │ Нажать      │                     │                       │                      │                     │                 │
   │ "Сохранить" │                     │                       │                      │                     │                 │
   │────────────>│                     │                       │                      │                     │                 │
   │             │ savePassword()      │                       │                      │                     │                 │
   │             │────────────────────>│                       │                      │                     │                 │
   │             │                     │ savePasswordUseCase   │                      │                     │                 │
   │             │                     │──────────────────────>│                      │                     │                 │
   │             │                     │                       │ savePassword()       │                     │                 │
   │             │                     │                       │─────────────────────>│                     │                 │
   │             │                     │                       │                      │ encrypt()           │                 │
   │             │                     │                       │                      │────────────────────>│                 │
   │             │                     │                       │                      │ ChaCha20-Poly1305   │                 │
   │             │                     │                       │                      │────────────────────>│                 │
   │             │                     │                       │                      │                     │                 │
   │             │                     │                       │                      │ encryptedPassword   │                 │
   │             │                     │                       │                      │<────────────────────│                 │
   │             │                     │                       │ LogEventUseCase      │                     │                 │
   │             │                     │                       │─────────────────────>│                     │                 │
   │             │                     │                       │ logEvent(PWD_CREATED)│                     │                 │
   │             │                     │                       │─────────────────────>│                     │                 │
   │             │                     │                       │                      │ INSERT INTO         │                 │
   │             │                     │                       │                      │ password_entries    │                 │
   │             │                     │                       │                      │────────────────────>│                 │
   │             │                     │                       │                      │                     │                 │
   │             │                     │                       │ Map{success, id}     │                     │                 │
   │             │                     │                       │<─────────────────────│                     │                 │
   │             │                     │                       │<──────────────────────│                     │                 │
   │             │                     │ notifyListeners()     │                      │                     │                 │
   │             │<────────────────────│                       │                      │                     │                 │
   │<────────────│                     │                       │                      │                     │                 │
```

### 3.2 Аутентификация с таймером неактивности

```
┌──────┐  ┌───────────┐  ┌────────────────┐  ┌───────────────┐  ┌─────────────────┐  ┌──────────────────┐  ┌──────────┐
│ User │  │AuthScreen │  │AuthController  │  │VerifyPinUseCase│  │AuthRepository   │  │AuthLocalDataSource│  │SecurityLogRep│
└──┬───┘  └────┬──────┘  └───────┬────────┘  └───────┬───────┘  └────────┬────────┘  └────────┬─────────┘  └─────┬────┘
   │          │                  │                    │                   │                   │                  │
   │ Ввод PIN │                  │                    │                   │                   │                  │
   │─────────>│                  │                    │                   │                   │                  │
   │          │ addDigit(digit)  │                    │                   │                   │                  │
   │          │─────────────────>│                    │                   │                   │                  │
   │          │ HapticFeedback   │                    │                   │                   │                  │
   │          │<─────────────────│                    │                   │                   │                  │
   │          │                  │                    │                   │                   │                  │
   │ Нажать   │                  │                    │                   │                   │                  │
   │ "Войти"  │                  │                    │                   │                   │                  │
   │─────────>│                  │                    │                   │                   │                  │
   │          │ verifyPin()      │                    │                   │                   │                  │
   │          │─────────────────>│                    │                   │                   │                  │
   │          │                  │ execute(pin)       │                   │                   │                  │
   │          │                  │───────────────────>│                   │                   │                  │
   │          │                  │                    │ verifyPin(pin)    │                   │                  │
   │          │                  │                    │──────────────────>│                   │                  │
   │          │                  │                    │                   │ verifyPin(pin)    │                  │
   │          │                  │                    │                   │──────────────────>│                  │
   │          │                  │                    │                   │                   │                  │
   │          │                  │                    │                   │ PBKDF2 deriveKey  │                  │
   │          │                  │                    │                   │ iterations: 10000 │                  │
   │          │                  │                    │                   │ HMAC-SHA256       │                  │
   │          │                  │                    │                   │──────────────────>│                  │
   │          │                  │                    │                   │                   │                  │
   │          │                  │                    │                   │ AuthResult        │                  │
   │          │                  │                    │                   │<──────────────────│                  │
   │          │                  │                    │ AuthResult        │                   │                  │
   │          │                  │                    │<──────────────────│                   │                  │
   │          │                  │ AuthResult         │                   │                   │                  │
   │          │                  │<───────────────────│                   │                   │                  │
   │          │                  │                    │                   │                   │                  │
   │          │                  │ [success]          │                   │                   │                  │
   │          │                  │ logEvent(AUTH_SUCCESS)                 │                   │                  │
   │          │                  │────────────────────────────────────────────────────────────────────────────>│
   │          │                  │                    │                   │                   │ logEvent()       │
   │          │                  │                    │                   │                   │─────────────────>│
   │          │                  │                    │                   │                   │                  │
   │          │                  │ startInactivityTimer()                 │                   │                  │
   │          │                  │ Timer(5 min)       │                   │                   │                  │
   │          │                  │<───────────────────│                   │                   │                  │
   │          │ notifyListeners()│                    │                   │                   │                  │
   │          │<─────────────────│                    │                   │                   │                  │
   │<─────────│                  │                    │                   │                   │                  │
   │          │                  │                    │                   │                   │                  │
   │          │                  │ [timeout 5 min]    │                   │                   │                  │
   │          │                  │ _lockApp()         │                   │                   │                  │
   │          │                  │ authState = locked │                   │                   │                  │
   │          │                  │ logEvent(AUTH_FAILURE)                 │                   │                  │
   │          │                  │────────────────────────────────────────────────────────────────────────────>│
   │          │ notifyListeners()│                    │                   │                   │                  │
   │          │<─────────────────│                    │                   │                   │                  │
   │          │                  │                    │                   │                   │                  │
```

### 3.3 Экспорт в формате .passgen

```
┌──────┐  ┌───────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────┐  ┌─────────────────┐  ┌──────────────┐
│ User │  │StorageScrn│  │StorageController│  │ExportPassgenUC  │  │StorageRepository │  │PassgenFormat    │  │EncryptorLocalDS│
└──┬───┘  └────┬──────┘  └────────┬────────┘  └────────┬────────┘  └────────┬─────────┘  └────────┬────────┘  └──────┬───────┘
   │          │                   │                    │                   │                   │                   │
   │ Нажать   │                   │                    │                   │                   │                   │
   │ "Экспорт │                   │                    │                   │                   │                   │
   │ .passgen"│                   │                    │                   │                   │                   │
   │─────────>│                   │                    │                   │                   │                   │
   │          │ exportPassgen()   │                    │                   │                   │                   │
   │          │──────────────────>│                    │                   │                   │                   │
   │          │                   │ execute(masterPwd) │                   │                   │                   │
   │          │                   │───────────────────>│                   │                   │                   │
   │          │                   │                    │ exportPassgen(pwd)│                   │                   │
   │          │                   │                    │──────────────────>│                   │                   │
   │          │                   │                    │                   │ getAllPasswords()   │                   │
   │          │                   │                    │                   │───────────────────>│                   │
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ List<PasswordEntry> │                   │
   │          │                   │                    │                   │<───────────────────│                   │
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ export(entries)     │                   │
   │          │                   │                    │                   │───────────────────>│                   │
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ HEADER: "PASSGEN_V1"│                   │
   │          │                   │                    │                   │ VERSION: 1          │                   │
   │          │                   │                    │                   │ FLAGS: 0            │                   │
   │          │                   │                    │                   │ NONCE: random 32    │                   │
   │          │                   │                    │                   │───────────────────>│                   │
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ ChaCha20-Poly1305   │                   │
   │          │                   │                    │                   │ encrypt(JSON data)  │                   │
   │          │                   │                    │                   │────────────────────────────────────>│
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ encrypted + MAC(16) │                   │
   │          │                   │                    │                   │<────────────────────────────────────│
   │          │                   │                    │                   │                   │                   │
   │          │                   │                    │                   │ .passgen bytes      │                   │
   │          │                   │                    │                   │<───────────────────│                   │
   │          │                   │                    │ Base64 string     │                   │                   │
   │          │                   │                    │<──────────────────│                   │                   │
   │          │                   │ String             │                   │                   │                   │
   │          │                   │<───────────────────│                   │                   │                   │
   │          │ notifyListeners()│                    │                   │                   │                   │
   │          │<─────────────────│                    │                   │                   │                   │
   │<─────────│                   │                    │                   │                   │                   │
   │          │                   │                    │                   │                   │                   │
```

---

## 4. Диаграмма компонентов (Component Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    App Layer (lib/app/)                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  PasswordGeneratorApp                                                                       │   │
│  │  - ProviderScope (7 Controllers, 10 Repositories, 25 Use Cases, 4 DataSources)             │   │
│  │  - TabScaffold (5 вкладок: Generator, Storage, Encryptor, Settings, Logs)                  │   │
│  │  - AuthWrapper (проверка аутентификации)                                                    │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ использует
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               Presentation Layer (lib/presentation/)                                │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │   Auth       │ │  Generator   │ │   Storage    │ │  Encryptor   │ │  Settings    │             │
│  │  Controller  │ │  Controller  │ │  Controller  │ │  Controller  │ │  Controller  │             │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘             │
│         │                │                │                │                │                       │
│  ┌──────▼───────┐ ┌──────▼───────┐ ┌──────▼───────┐ ┌──────▼───────┐ ┌──────▼───────┐             │
│  │  AuthScreen  │ │GeneratorScreen│ │StorageScreen │ │EncryptorScreen│ │SettingsScreen│            │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘             │
│                                                                                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                                                │
│  │  Categories  │ │    Logs      │ │    About     │                                                │
│  │  Controller  │ │  Controller  │ │   Screen     │                                                │
│  └──────┬───────┘ └──────┬───────┘ └──────────────┘                                                │
│         │                │                                                                          │
│  ┌──────▼───────┐ ┌──────▼───────┐                                                                │
│  │CategoriesScrn│ │  LogsScreen  │                                                                │
│  └──────────────┘ └──────────────┘                                                                │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Widgets: AppButton, AppDialogs, AppSwitch, AppTextField, CopyablePassword                 │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ зависит от
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 Domain Layer (lib/domain/)                                          │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Use Cases (25+)                                                                            │   │
│  │  - Auth: SetupPin, VerifyPin, ChangePin, RemovePin, GetAuthState                           │   │
│  │  - Generator: GeneratePassword, SavePassword, ValidateGeneratorSettings                    │   │
│  │  - Storage: GetPasswords, DeletePassword, Export/Import (JSON, .passgen)                   │   │
│  │  - Category: Get, Create, Update, Delete                                                    │   │
│  │  - Encryptor: EncryptMessage, DecryptMessage                                                │   │
│  │  - Log: LogEvent, GetLogs                                                                   │   │
│  │  - Settings: GetSetting, SetSetting, RemoveSetting                                          │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                              │                                                    │
│                                              │ используют                                         │
│                                              ▼                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Repository Interfaces (10)                                                                 │   │
│  │  AuthRepository, PasswordEntryRepository, PasswordGeneratorRepository,                      │   │
│  │  EncryptorRepository, CategoryRepository, SecurityLogRepository,                            │   │
│  │  AppSettingsRepository, StorageRepository, PasswordExportRepository,                        │   │
│  │  PasswordImportRepository                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                              │                                                    │
│                                              │ абстрагируют                                       │
│                                              ▼                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Entities (8)                                                                               │   │
│  │  PasswordEntry, Category, PasswordConfig, PasswordGenerationSettings,                       │   │
│  │  PasswordResult, AuthState, AuthResult, SecurityLog                                         │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ реализуют
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  Data Layer (lib/data/)                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Repository Implementations (9)                                                             │   │
│  │  AuthRepositoryImpl, PasswordGeneratorRepositoryImpl, EncryptorRepositoryImpl,              │   │
│  │  StorageRepositoryImpl, CategoryRepositoryImpl, SecurityLogRepositoryImpl,                  │   │
│  │  AppSettingsRepositoryImpl, PasswordExportRepositoryImpl, PasswordImportRepositoryImpl      │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                              │                                                    │
│                                              │ используют                                         │
│                                              ▼                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Data Sources (4)                                                                           │   │
│  │  - AuthLocalDataSource (SharedPreferences, PBKDF2)                                         │   │
│  │  - EncryptorLocalDataSource (ChaCha20-Poly1305, CSPRNG)                                    │   │
│  │  - PasswordGeneratorLocalDataSource (зависит от Encryptor, Storage)                        │   │
│  │  - StorageLocalDataSource (SharedPreferences)                                               │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                              │                                                    │
│                                              │ используют                                         │
│                                              ▼                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Database (SQLite)                                                                          │   │
│  │  - DatabaseHelper (синглтон, CRUD, транзакции)                                             │   │
│  │  - DatabaseSchema (5 таблиц, 4 индекса, 7 системных категорий)                             │   │
│  │  - DatabaseMigrations (версионирование)                                                     │   │
│  │  - MigrationFromSharedPreferences (миграция данных)                                        │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Formats                                                                                    │   │
│  │  - PassgenFormat (.passgen экспорт/импорт)                                                 │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ использует
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  Core Layer (lib/core/)                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                                  │
│  │   Constants      │  │     Errors       │  │     Utils        │                                  │
│  │  - AppConstants  │  │  - Failure       │  │  - CryptoUtils   │                                  │
│  │  - EventTypes    │  │  - Encryption..  │  │  - PasswordUtils │                                  │
│  │                  │  │  - Storage..     │  │                  │                                  │
│  │                  │  │  - Auth..        │  │                  │                                  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Диаграмма развёртывания (Deployment Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Мобильное устройство (Android)                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  PassGen APK                                                                                │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Flutter Runtime                                                                      │ │   │
│  │  │  - Dart VM                                                                            │ │   │
│  │  │  - Material 3 UI                                                                      │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Приложение                                                                           │ │   │
│  │  │  - 7 Controllers (ChangeNotifier)                                                     │ │   │
│  │  │  - 25 Use Cases                                                                       │ │   │
│  │  │  - 9 Repository Implementations                                                       │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Локальное хранилище                                                                  │ │   │
│  │  │  - SQLite Database (passgen.db)                                                       │ │   │
│  │  │    * categories (7 системных + пользовательские)                                      │ │   │
│  │  │    * password_entries (зашифрованные пароли)                                          │ │   │
│  │  │    * password_configs (конфигурации генерации)                                        │ │   │
│  │  │    * security_logs (аудит событий)                                                    │ │   │
│  │  │    * app_settings (настройки)                                                         │ │   │
│  │  │  - SharedPreferences                                                                  │ │   │
│  │  │    * PIN hash (PBKDF2)                                                                │ │   │
│  │  │    * Auth state                                                                       │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Десктоп (Windows / Linux)                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  PassGen Executable                                                                         │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Flutter Desktop                                                                      │ │   │
│  │  │  - Windows: Win32 API                                                                 │ │   │
│  │  │  - Linux: GTK                                                                         │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Приложение (аналогично mobile)                                                       │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  │  ┌───────────────────────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Локальное хранилище                                                                  │ │   │
│  │  │  - SQLite Database (passgen.db)                                                       │ │   │
│  │  │  - SharedPreferences (эмуляция через файлы)                                           │ │   │
│  │  └───────────────────────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Внешние зависимости                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  cryptography                                                                               │   │
│  │  - ChaCha20-Poly1305 (AEAD шифрование)                                                     │   │
│  │  - PBKDF2 (key derivation: 10,000 итераций, HMAC-SHA256)                                   │   │
│  │  - CSPRNG (Random.secure())                                                                │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  sqflite                                                                                    │   │
│  │  - SQLite3                                                                                  │   │
│  │  - SQL queries, транзакции, индексы                                                        │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  shared_preferences                                                                         │   │
│  │  - Ключ-значение хранилище                                                                  │   │
│  │  - Android: SharedPreferences                                                               │   │
│  │  - Desktop: эмуляция через файлы                                                           │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  zxcvbn, password_strength                                                                  │   │
│  │  - Оценка надёжности паролей                                                                │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. ER-диаграмма базы данных (Entity-Relationship)

### 6.1 Таблицы и связи

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         categories                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PK  id            INTEGER  (AUTOINCREMENT)                                                  │  │
│  │      name          TEXT     NOT NULL                                                         │  │
│  │      icon          TEXT                                                                      │  │
│  │      is_system     INTEGER  DEFAULT 0  (0=пользовательская, 1=системная)                     │  │
│  │      created_at    INTEGER  NOT NULL  (timestamp)                                            │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                       │
│  Системные категории (7):                                                                            │
│  - Соцсети 👥, Почта 📧, Банки 🏦, Магазины 🛒, Работа 💼, Развлечения 🎮, Другое 📁              │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                    │ 1
                                    │
                                    │ N
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      password_entries                                               │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PK  id                    INTEGER  (AUTOINCREMENT)                                          │  │
│  │  FK  category_id           INTEGER  REFERENCES categories(id)                                │  │
│  │      service               TEXT     NOT NULL                                                 │  │
│  │      login                 TEXT                                                              │  │
│  │      encrypted_password    BLOB     NOT NULL  (ChaCha20-Poly1305)                            │  │
│  │      nonce                 BLOB     NOT NULL                                                 │  │
│  │      created_at            INTEGER  NOT NULL  (timestamp)                                    │  │
│  │      updated_at            INTEGER  NOT NULL  (timestamp)                                    │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                       │
│  Индексы:                                                                                            │
│  - idx_password_entries_category (category_id) — для фильтрации по категории                        │
│  - idx_password_entries_service (service) — для поиска по сервису                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                    │ 1
                                    │
                                    │ 1
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      password_configs                                               │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PK  id                    INTEGER  (AUTOINCREMENT)                                          │  │
│  │  UK  entry_id              INTEGER  UNIQUE REFERENCES password_entries(id)                   │  │
│  │      strength              INTEGER                                                           │  │
│  │      min_length            INTEGER                                                           │  │
│  │      max_length            INTEGER                                                           │  │
│  │      flags                 INTEGER                                                           │  │
│  │      require_unique        INTEGER  DEFAULT 0                                                │  │
│  │      encrypted_config      BLOB                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                       │
│  Связь 1:1 с password_entries (конфигурация для конкретной записи)                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘


┌────────────────────────────────────��────────────────────────────────────────────────────────────────┐
│                                       security_logs                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PK  id                    INTEGER  (AUTOINCREMENT)                                          │  │
│  │      action_type           TEXT     NOT NULL                                                 │  │
│  │      timestamp             INTEGER  NOT NULL  (timestamp)                                    │  │
│  │      details               TEXT                                                              │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                       │
│  Индексы:                                                                                            │
│  - idx_security_logs_action_type (action_type) — для фильтрации по типу события                     │
│  - idx_security_logs_timestamp (timestamp) — для сортировки по времени                              │
│                                                                                                       │
│  Типы событий (EventTypes):                                                                          │
│  - AUTH_SUCCESS, AUTH_FAILURE, AUTH_LOCKOUT, AUTH_SETUP, AUTH_CHANGE, AUTH_REMOVE                   │
│  - PWD_CREATED, PWD_DELETED, PWD_UPDATED, PWD_EXPORTED, PWD_IMPORTED                                │
│  - CONFIG_CHANGED, CATEGORY_CREATED, CATEGORY_DELETED                                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                       app_settings                                                  │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PK  key                 TEXT                                                                │  │
│  │      value               TEXT     NOT NULL                                                   │  │
│  │      encrypted           INTEGER  DEFAULT 0  (0=plain, 1=encrypted)                          │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                       │
│  Примеры настроек:                                                                                   │
│  - theme (light/dark)                                                                                │
│  - language (ru/en)                                                                                  │
│  - auto_lock_timeout (минуты)                                                                        │
│  - last_backup_date (timestamp)                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Сводная таблица таблиц

| Таблица | Полей | Первичный ключ | Внешние ключи | Уникальные | Индексы |
|---------|-------|----------------|---------------|------------|---------|
| categories | 5 | id (AUTOINCREMENT) | - | - | - |
| password_entries | 8 | id (AUTOINCREMENT) | category_id → categories(id) | - | idx_category, idx_service |
| password_configs | 8 | id (AUTOINCREMENT) | entry_id → password_entries(id) | entry_id | - |
| security_logs | 4 | id (AUTOINCREMENT) | - | - | idx_action_type, idx_timestamp |
| app_settings | 3 | key | - | key | - |

### 6.3 Диаграмма связей

```
┌─────────────────┐
│   categories    │
│                 │
│  PK id          │
│  name           │
│  icon           │
│  is_system      │
│  created_at     │
└────────┬────────┘
         │ 1:N
         │
         ▼
┌─────────────────────────┐       1:1       ┌──────────────────┐
│   password_entries      │────────────────>│ password_configs │
│                         │                 │                  │
│  PK id                  │                 │  PK id           │
│  FK category_id         │                 │  UK entry_id     │
│  service                │                 │  strength        │
│  login                  │                 │  min_length      │
│  encrypted_password     │                 │  max_length      │
│  nonce                  │                 │  flags           │
│  created_at             │                 │  require_unique  │
│  updated_at             │                 │  encrypted_config│
└─────────────────────────┘                 └──────────────────┘


┌─────────────────┐     ┌─────────────────┐
│  security_logs  │     │  app_settings   │
│                 │     │                 │
│  PK id          │     │  PK key         │
│  action_type    │     │  value          │
│  timestamp      │     │  encrypted      │
│  details        │     │                 │
└─────────────────┘     └─────────────────┘
(независимая)           (независимая)
```

---

## 7. Диаграмма состояний (State Diagram)

### 7.1 Состояния аутентификации (AuthState)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Диаграмма состояний аутентификации                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

     ┌─────────┐
     │  START  │
     └────┬────┘
          │
          ▼
┌─────────────────────────┐
│  No PIN Setup           │
│  (isPinSetup = false)   │
│                         │
│  [setupPin()]           │
└───────────┬─────────────┘
            │
            │ PIN установлен
            ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  Authenticated          │────>│  Locked (timeout)       │
│  (isAuthenticated=true) │     │  (isLocked = true)      │
│                         │     │                         │
│  - Генерация паролей    │     │  [verifyPin()]          │
│  - Просмотр хранилища   │     │                         │
│  - Шифрование           │     │                         │
│  - Настройки            │     │                         │
└───────────┬─────────────┘     └───────────┬─────────────┘
            │                               │
            │ [5 мин неактивности]          │ PIN неверный (3 раза)
            │                               │
            │                               ▼
            │                     ┌─────────────────────────┐
            │                     │  Locked Out             │
            │                     │  (lockoutUntil)         │
            │                     │                         │
            │                     │  [ждать N минут]        │
            │                     └───────────┬─────────────┘
            │                                 │
            └─────────────────────────────────┘
                      │
                      │ [logout / lock]
                      ▼
            ┌─────────────────────────┐
            │  Require Auth           │
            │  (isAuthenticated=false)│
            │                         │
            │  [verifyPin()]          │
            └─────────────────────────┘
```

### 7.2 Состояния генератора паролей

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Диаграмма состояний генератора                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

     ┌─────────┐
     │  START  │
     └────┬────┘
          │
          ▼
┌─────────────────────────┐
│  Settings Configured    │
│  - strength: 0-4        │
│  - lengthRange: [min,max]│
│  - flags: bitmask       │
│  - require*: bool       │
│                         │
│  [generatePassword()]   │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  Generating...          │────>│  Error                  │
│  (isLoading = true)     │     │  (error != null)        │
│                         │     │                         │
│  - CSPRNG               │     │  [dismissError]         │
│  - ChaCha20             │     │                         │
│  - Strength evaluation  │     │                         │
└───────────┬─────────────┘     └─────────────────────────┘
            │
            │ Успех
            ▼
┌─────────────────────────┐
│  Password Generated     │
│  - password: String     │
│  - strength: 0.0-4.0    │
│  - config: String       │
│                         │
│  [savePassword()]       │
│  [generatePassword()]   │
└───────────┬─────────────┘
            │
            │ [savePassword()]
            ▼
┌─────────────────────────┐
│  Saving...              │
│  (isLoading = true)     │
│                         │
│  - Encrypt password     │
│  - Create entry         │
│  - Log event            │
└───────────┬─────────────┘
            │
            │ Успех / Ошибка
            ▼
┌─────────────────────────┐
│  Saved / Error          │
│  (notify user)          │
└─────────────────────────┘
```

### 7.3 Состояния хранилища паролей

```
┌─────────────────────────────────���───────────────────────────────────────────────────────────────────┐
│                                    Диаграмма состояний хранилища                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

     ┌─────────┐
     │  START  │
     └────┬────┘
          │
          ▼
┌─────────────────────────┐
│  Loading...             │
│  (isLoading = true)     │
│                         │
│  [loadPasswords()]      │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Passwords Loaded       │
│  - allPasswords: List   │
│  - currentIndex: int    │
│  - selectedCategory: int?│
│  - searchQuery: String  │
│                         │
│  [nextPassword()]       │
│  [prevPassword()]       │
│  [deletePassword()]     │
│  [exportPasswords()]    │
│  [importPasswords()]    │
└───────────┬─────────────┘
            │
            ├──────────────────────┬──────────────────────┐
            │                      │                      │
            ▼                      ▼                      ▼
┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐
│  Next Password    │   │  Delete Password  │   │  Export/Import    │
│  currentIndex++   │   │  remove entry     │   │  JSON / .passgen  │
│  wrap around      │   │  log event        │   │  encrypt/decrypt  │
└───────────────────┘   └───────────────────┘   └───────────────────┘
```

---

## 8. Диаграмма активности (Activity Diagram)

### 8.1 Генерация и сохранение пароля

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           Активность: Генерация и сохранение пароля                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────┐
    │  START  │
    └────┬────┘
         │
         ▼
┌─────────────────────────┐
│  Настроить параметры    │
│  - Выбрать сложность    │
│  - Задать длину         │
│  - Выбрать категорию    │
│  - Ввести сервис        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Нажать "Сгенерировать" │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Валидация настроек     │
│  (Domain layer)         │
└───────────┬─────────────┘
            │
       ┌────┴────┐
       │ Валидно?│
       └────┬────┘
            │
     ┌──────┴──────┐
     │             │
    ДА            НЕТ
     │             │
     ▼             ▼
┌─────────┐   ┌───────────┐
│Генерация│   │Показать   │
│пароля   │   │ошибку     │
│         │   └─────┬─────┘
│- CSPRNG │         │
│- ChaCha20◄────────┘
│- Strength eval
└────┬────┘
     │
     ▼
┌─────────────────┐
│Показать пароль  │
│и оценку надёжн. │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Нажать         │
│  "Сохранить"    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Шифрование       │
│пароля           │
│(ChaCha20-Poly1305)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Создание записи  │
│в БД             │
│INSERT INTO      │
│password_entries │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Логирование      │
│события          │
│PWD_CREATED      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Показать         │
│уведомление      │
└────────┬────────┘
         │
         ▼
    ┌─────────┐
    │   END   │
    └─────────┘
```

### 8.2 Аутентификация пользователя

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               Активность: Аутентификация пользователя                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────┐
    │  START  │
    └────┬────┘
         │
         ▼
┌─────────────────────────┐
│  Проверка наличия PIN   │
│  (isPinSetup?)          │
└──────────┬──────────────┘
           │
      ┌────┴────┐
      │         │
     ДА        НЕТ
      │         │
      ▼         ▼
┌──────────┐  ┌──────────────┐
│Экран     │  │Экран установки│
│ввода PIN │  │PIN           │
└────┬─────┘  └──────┬───────┘
     │               │
     │               ▼
     │        ┌──────────────┐
     │        │Ввести PIN    │
     │        │(4-8 цифр)    │
     │        └──────┬───────┘
     │               │
     │               ▼
     │        ┌──────────────┐
     │        │Подтвердить   │
     │        │PIN           │
     │        └──────┬───────┘
     │               │
     │               ▼
     │        ┌──────────────┐
     │        │Сохранить хеш │
     │        │(PBKDF2)      │
     │        └──────┬───────┘
     │               │
     ▼               ▼
┌────────────────────────┐
│Ввод PIN пользователем  │
│(до 8 цифр)             │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│Нажать "Войти"          │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│PBKDF2 deriveKey        │
│iterations: 10,000      │
│HMAC-SHA256             │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│Сравнение хешей         │
└───────────┬────────────┘
            │
       ┌────┴────┐
       │Совпали? │
       └────┬────┘
            │
     ┌──────┴──────┐
     │             │
    ДА            НЕТ
     │             │
     ▼             ▼
┌──────────┐  ┌──────────────┐
│Успешный  │  │Уменьшить     │
│вход      │  │счётчик       │
│          │  │попыток        │
│- Сброс   │  └──────┬───────┘
│  таймера │         │
│  (5 мин) │         ▼
│- Запуск  │  ┌──────────────┐
│  таймера │  │Попыток       │
│          │  │осталось?     │
│          │  └──────┬───────┘
│          │         │
│          │    ┌────┴────┐
│          │    │         │
│          │   ДА       НЕТ
│          │    │         │
│          │    ▼         ▼
│          │  ┌────┐  ┌──────────┐
│          │  │END │  │Блокировка│
│          │  └────┘  │(lockout) │
│          │          └────┬─────┘
│          │               │
│          │               ▼
│          │          ┌──────────┐
│          │          │Ждать N   │
│          │          │минут     │
│          │          └────┬─────┘
│          │               │
│          └───────────────┘
│
▼
┌──────────────────┐
│Главный экран     │
│(5 вкладок)       │
└────────┬─────────┘
         │
         ▼
    ┌─────────┐
    │   END   │
    └─────────┘
```

---

## 📎 Приложения

### A. Список событий для логирования (EventTypes)

| Событие | Код | Описание |
|---------|-----|----------|
| AUTH_SUCCESS | auth_success | Успешная аутентификация |
| AUTH_FAILURE | auth_failure | Неудачная попытка входа |
| AUTH_LOCKOUT | auth_lockout | Блокировка после 3 неудачных попыток |
| AUTH_SETUP | auth_setup | Установка PIN |
| AUTH_CHANGE | auth_change | Смена PIN |
| AUTH_REMOVE | auth_remove | Удаление PIN |
| PWD_CREATED | pwd_created | Создание пароля |
| PWD_DELETED | pwd_deleted | Удаление пароля |
| PWD_UPDATED | pwd_updated | Обновление пароля |
| PWD_EXPORTED | pwd_exported | Экспорт паролей (JSON/.passgen) |
| PWD_IMPORTED | pwd_imported | Импорт паролей (JSON/.passgen) |
| CONFIG_CHANGED | config_changed | Изменение настроек генерации |
| CATEGORY_CREATED | category_created | Создание категории |
| CATEGORY_DELETED | category_deleted | Удаление категории |

### B. Флаги сложности паролей (PasswordFlags)

| Уровень | Флаг | Длина | Требования |
|---------|------|-------|------------|
| 0 | 0 | [4, 6] | Базовый |
| 1 | 1 | [6, 8] | + цифры |
| 2 | 3 | [8, 12] | + цифры + строчные |
| 3 | 7 | [12, 16] | + заглавные + символы |
| 4 | 15 | [16, 32] | Все требования |

### C. Технологии и зависимости

| Компонент | Технология | Версия |
|-----------|------------|--------|
| Фреймворк | Flutter | 3.x |
| Язык | Dart | 3.x |
| Шифрование | cryptography | ChaCha20-Poly1305, PBKDF2 |
| БД | sqflite | SQLite3 |
| Хранилище | shared_preferences | Ключ-значение |
| Оценка паролей | zxcvbn, password_strength | - |
| State Management | provider | ChangeNotifier |
| UI | Material 3 | - |

---

**Конец документа**
