# 📋 Описание модулей проекта PassGen v0.5.0

> ⚠️ **УСТАРЕЛО**: Этот документ устарел. Актуальная документация находится в [DEVELOPER.md](DEVELOPER.md).

## 🏗️ Общая архитектура (Clean Architecture)

Проект разделён на 5 основных слоёв:

1.  **App Layer** — точка входа, DI, навигация
2.  **Presentation Layer** — UI, контроллеры, виджеты
3.  **Domain Layer** — бизнес-логика (Entities, Use Cases, Repository Interfaces)
4.  **Data Layer** — реализация репозиториев, источники данных, SQLite
5.  **Core Layer** — утилиты, константы, ошибки

---

## 1️⃣ APP MODULE (`lib/app/`)

### Функция
Точка входа приложения, конфигурация Dependency Injection (Provider), маршрутизация, темы.

### Объекты
| Класс/Функция | Тип | Описание |
| :--- | :--- | :--- |
| `PasswordGeneratorApp` | `StatelessWidget` | Корневой виджет приложения |
| `TabScaffold` | `StatefulWidget` | Основной каркас с навигацией по вкладкам |
| `AuthWrapper` | `StatelessWidget` | Обёртка для проверки аутентификации |
| `AppTab` | `enum` | Типобезопасное управление вкладками (5 значений) |
| `getTheme()` | Функция | Создание темы (светлая/тёмная) |

### Зависимости (Providers)
- **Data Sources:** 4 (Encryptor, Storage, Auth, PasswordGenerator)
- **Repositories:** 10 (все реализации)
- **Use Cases:** 25 (все сценарии)
- **Controllers:** 7 (Generator, Encryptor, Storage, Auth, Settings, Categories, Logs)

### Для диаграмм
*   **Развёртывание:** Главный контейнер всех Providers
*   **Компонентов:** Связывает все слои архитектуры
*   **Последовательности:** Инициализация → Создание Providers → Рендер UI

---

## 2️⃣ CORE MODULE (`lib/core/`)

### Функция
Общесистемные утилиты, константы, ошибки. Не зависит от других модулей.

### Подмодули

#### 2.1 Constants (`constants/`)
| Класс | Описание |
| :--- | :--- |
| `AppConstants` | Глобальные константы приложения (strength, pin limits) |
| `EventTypes` | Типы событий для логирования (AUTH_SUCCESS, PWD_CREATED, etc.) |

#### 2.2 Errors (`errors/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `Failure` | `abstract class` | Базовый класс ошибок |
| `EncryptionFailure` | Класс | Ошибка шифрования/дешифрования |
| `PasswordGenerationFailure` | Класс | Ошибка генерации пароля |
| `StorageFailure` | Класс | Ошибка хранилища |
| `AuthFailure` | Класс | Ошибка аутентификации |

#### 2.3 Utils (`utils/`)
| Класс | Методы | Описание |
| :--- | :--- | :--- |
| `CryptoUtils` | `encodeBase64()`, `decodeBase64()`, `encodeBytesBase64()`, `decodeBytesBase64()` | Кодирование Base64 |
| `PasswordUtils` | `evaluateStrength()` | Оценка надёжности пароля (zxcvbn + эвристика) |

### Для диаграмм
*   **Компонентов:** Базовый инфраструкурный компонент
*   **Развёртывания:** Используется всеми модулями

---

## 3️⃣ DOMAIN MODULE (`lib/domain/`)

### Функция
Бизнес-логика приложения. Не зависит от UI и источников данных.

### 3.1 Entities (`entities/`) — 8 сущностей
| Сущность | Поля | Методы | Описание |
| :--- | :--- | :--- | :--- |
| `AuthState` | `isAuthenticated`, `isPinSetup`, `isLocked`, `remainingAttempts`, `lockoutUntil` | `copyWith()` | Состояние аутентификации |
| `AuthResult` | `success`, `message` | — | Результат проверки PIN |
| `Category` | `id`, `name`, `icon`, `isSystem`, `createdAt` | `copyWith()`, `systemCategories` | Категория паролей |
| `PasswordConfig` | `version`, `service`, `uuid`, `encryptedConfig`, `category`, `expireDays` | `isExpired`, `copyWith()` | Конфигурация генерации |
| `PasswordEntry` | `id`, `categoryId`, `service`, `login`, `password`, `config`, `createdAt`, `updatedAt` | `fromJson()`, `toJson()`, `copyWith()`, `encodeList()`, `decodeList()` | Запись в хранилище |
| `PasswordGenerationSettings` | `strength`, `lengthRange`, `flags`, `require*` | `copyWith()` | Настройки генерации |
| `PasswordResult` | `password`, `strength`, `config`, `error` | `hasError()` | Результат генерации |
| `SecurityLog` | `id`, `actionType`, `timestamp`, `details` | `fromJson()`, `toJson()`, `copyWith()` | Запись лога безопасности |

### 3.2 Repository Interfaces (`repositories/`) — 10 интерфейсов
| Интерфейс | Методы | Описание |
| :--- | :--- | :--- |
| `AppSettingsRepository` | `getValue()`, `setValue()`, `remove()`, `getAll()`, `clear()` | Контракт для настроек |
| `AuthRepository` | `setupPin()`, `verifyPin()`, `changePin()`, `removePin()`, `getAuthState()` | Контракт для аутентификации |
| `CategoryRepository` | `getAll()`, `getById()`, `create()`, `update()`, `delete()` | Контракт для категорий |
| `EncryptorRepository` | `encrypt()`, `decrypt()` | Контракт для шифрования |
| `PasswordEntryRepository` | `getAll()`, `getById()`, `getByCategory()`, `searchByService()`, `create()`, `update()`, `delete()` | Контракт для записей |
| `PasswordGeneratorRepository` | `generatePassword()`, `restorePassword()`, `createPasswordConfig()`, `decryptPassword()`, `savePassword()` | Контракт для генерации |
| `PasswordExportRepository` | `exportJson()` | Контракт для экспорта JSON |
| `PasswordImportRepository` | `importJson()` | Контракт для импорта JSON |
| `SecurityLogRepository` | `logEvent()`, `getLogs()`, `getLogsByType()`, `clearOldLogs()`, `count()` | Контракт для логов |
| `StorageRepository` | `getAll()`, `getByCategory()`, `searchByService()`, `create()`, `update()`, `delete()` | Контракт для хранилища |

### 3.3 Use Cases (`usecases/`) — 25+ сценариев

#### Аутентификация (`auth/`) — 5
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `SetupPinUseCase` | `pin` | `Either<AuthFailure, bool>` | Установка PIN |
| `VerifyPinUseCase` | `pin` | `Either<AuthFailure, AuthResult>` | Проверка PIN |
| `ChangePinUseCase` | `oldPin`, `newPin` | `Either<AuthFailure, bool>` | Смена PIN |
| `RemovePinUseCase` | `pin` | `Either<AuthFailure, bool>` | Удаление PIN |
| `GetAuthStateUseCase` | — | `Either<AuthFailure, AuthState>` | Получение состояния |

#### Категории (`category/`) — 4
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GetCategoriesUseCase` | — | `List<Category>` | Получение всех |
| `CreateCategoryUseCase` | `Category` | `Category` | Создание |
| `UpdateCategoryUseCase` | `Category` | `Category` | Обновление |
| `DeleteCategoryUseCase` | `id` | `void` | Удаление |

#### Шифратор (`encryptor/`) — 2
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `EncryptMessageUseCase` | `message`, `password` | `Either<Failure, String>` | Шифрование |
| `DecryptMessageUseCase` | `encryptedData`, `password` | `Either<Failure, String>` | Дешифрование |

#### Логи (`log/`) — 2
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `LogEventUseCase` | `actionType`, `details` | `void` | Логирование события |
| `GetLogsUseCase` | `limit` | `List<SecurityLog>` | Получение логов |

#### Генератор (`password/`) — 2
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GeneratePasswordUseCase` | `PasswordGenerationSettings` | `Either<Failure, PasswordResult>` | Генерация |
| `SavePasswordUseCase` | `service`, `password`, `config`, `categoryId`, `login` | `Either<Failure, Map>` | Сохранение |

#### Настройки (`settings/`) — 3
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GetSettingUseCase` | `key` | `String?` | Получение |
| `SetSettingUseCase` | `key`, `value`, `encrypted` | `void` | Сохранение |
| `RemoveSettingUseCase` | `key` | `void` | Удаление |

#### Хранилище (`storage/`) — 6
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GetConfigsUseCase` | `key` | `Either<Failure, List<String>>` | Получение конфигов |
| `SaveConfigsUseCase` | `key`, `configs` | `Either<Failure, bool>` | Сохранение конфигов |
| `GetPasswordsUseCase` | — | `Either<Failure, List<PasswordEntry>>` | Получение паролей |
| `DeletePasswordUseCase` | `index` | `Either<Failure, bool>` | Удаление пароля |
| `ExportPasswordsUseCase` | — | `Either<Failure, String>` | Экспорт JSON |
| `ImportPasswordsUseCase` | `jsonString` | `Either<Failure, bool>` | Импорт JSON |
| `ExportPassgenUseCase` | `masterPassword` | `Either<Failure, String>` | Экспорт .passgen |
| `ImportPassgenUseCase` | `data`, `masterPassword` | `Either<Failure, bool>` | Импорт .passgen |

### Для диаграмм
*   **Вариантов использования:** Каждый Use Case — отдельный сценарий
*   **Последовательности:** `Controller` → `Use Case` → `Repository` → `DataSource`
*   **Компонентов:** Ядро бизнес-логики

---

## 4️⃣ DATA MODULE (`lib/data/`)

### Функция
Реализация репозиториев, источники данных, SQLite, миграции.

### 4.1 Database (`database/`)
| Класс | Описание |
| :--- | :--- |
| `DatabaseHelper` | Синглтон для управления SQLite (CRUD, транзакции) |
| `DatabaseSchema` | Схема БД (5 таблиц, индексы, системные категории) |
| `DatabaseMigrations` | Миграции между версиями БД |
| `MigrationFromSharedPreferences` | Миграция данных из SharedPreferences в SQLite |

### 4.2 Models (`models/`) — 5 моделей
| Модель | Описание |
| :--- | :--- |
| `AppSettingsModel` | Модель настройки приложения |
| `CategoryModel` | Модель категории |
| `PasswordConfigModel` | Модель конфигурации пароля |
| `PasswordEntryModel` | Модель записи пароля |
| `SecurityLogModel` | Модель лога безопасности |

### 4.3 Data Sources (`datasources/`) — 4 источника
| Класс | Зависимости | Методы | Описание |
| :--- | :--- | :--- | :--- |
| `AuthLocalDataSource` | `shared_preferences`, `cryptography` (PBKDF2) | `isValidPinFormat()`, `isPinSetup()`, `_hashPin()`, `_verifyPin()`, `setupPin()`, `verifyPin()` | Аутентификация |
| `EncryptorLocalDataSource` | `cryptography` (Chacha20) | `generateRandomBytes()`, `generateRandomInt()`, `encrypt()`, `decrypt()`, `encryptToMini()`, `decryptFromMini()` | Шифрование |
| `StorageLocalDataSource` | `shared_preferences` | `saveConfig()`, `getConfigs()`, `savePasswords()`, `getPasswords()`, `exportPasswords()`, `importPasswords()` | Хранилище |
| `PasswordGeneratorLocalDataSource` | `EncryptorLocalDataSource`, `StorageLocalDataSource` | `generate()`, `restoreFromConfig()`, `savePassword()` | Генерация паролей |

### 4.4 Formats (`formats/`)
| Класс | Описание |
| :--- | :--- |
| `PassgenFormat` | Фирменный формат .passgen (экспорт/импорт, ChaCha20-Poly1305) |

### 4.5 Repositories (`repositories/`) — 9 реализаций
| Класс | Реализует | Методы |
| :--- | :--- | :--- |
| `AppSettingsRepositoryImpl` | `AppSettingsRepository` | CRUD для настроек в SQLite |
| `AuthRepositoryImpl` | `AuthRepository` | Работа с AuthLocalDataSource |
| `CategoryRepositoryImpl` | `CategoryRepository` | CRUD для категорий в SQLite |
| `EncryptorRepositoryImpl` | `EncryptorRepository` | Делегирует в EncryptorLocalDataSource |
| `PasswordGeneratorRepositoryImpl` | `PasswordGeneratorRepository` | Делегирует в PasswordGeneratorLocalDataSource |
| `PasswordExportRepositoryImpl` | `PasswordExportRepository` | Экспорт JSON |
| `PasswordImportRepositoryImpl` | `PasswordImportRepository` | Импорт JSON |
| `SecurityLogRepositoryImpl` | `SecurityLogRepository` | Логирование в SQLite, автоочистка |
| `StorageRepositoryImpl` | `StorageRepository` | CRUD для паролей, экспорт/импорт JSON и .passgen |

### Для диаграмм
*   **Последовательности:** `DataSource` → Внешние сервисы (`SharedPreferences`, `SQLite`, `Cryptography`)
*   **Развёртывания:** Локальное хранилище на устройстве
*   **Компонентов:** Слой доступа к данным

---

## 5️⃣ PRESENTATION MODULE (`lib/presentation/`)

### Функция
UI приложение, контроллеры состояния, экраны, виджеты.

### 5.1 Features (`features/`) — 8 экранов

#### Аутентификация (`auth/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `AuthController` | `ChangeNotifier` | Управление аутентификацией, таймер неактивности |
| `AuthScreen` | `StatelessWidget` | Экран ввода PIN |
| `PinInputWidget` | `StatelessWidget` | Виджет ввода PIN (8 ячеек) |

**Состояние контроллера:**
*   `AuthState _authState`
*   `bool _isLoading`, `String? _error`
*   `Timer? _inactivityTimer` (5 минут)

**Методы:**
*   `addDigit()`, `removeDigit()`, `clearPin()`
*   `setupPin()`, `verifyPin()`, `changePin()`, `removePin()`
*   `startInactivityTimer()`, `resetInactivityTimer()`, `_lockApp()`

#### Генератор (`generator/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `GeneratorController` | `ChangeNotifier` | Управление генератором |
| `GeneratorScreen` | `StatelessWidget` | Экран генератора |

**Состояние:**
*   `PasswordGenerationSettings _settings`
*   `PasswordResult? _lastResult`
*   `int _strength` (0-4)
*   `TextEditingController` (service, minLength, maxLength)
*   `int? _selectedCategoryId`

**Методы:**
*   `updateStrength()`, `toggleRequire*()`, `updateLengthRange()`
*   `generatePassword()`, `savePassword()` (с логированием PWD_CREATED)
*   `updateSelectedCategoryId()`

#### Шифратор (`encryptor/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `EncryptorController` | `ChangeNotifier` | Управление шифрованием |
| `EncryptorScreen` | `StatelessWidget` | Экран шифратора |

**Состояние:**
*   `String _result`
*   `bool _isLoading`
*   `bool _isEncryptMode`
*   `TextEditingController` (message, password)

#### Хранилище (`storage/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `StorageController` | `ChangeNotifier` | Управление хранилищем |
| `StorageScreen` | `StatelessWidget` | Экран хранилища |

**Состояние:**
*   `List<PasswordEntry> _allPasswords`, `List<PasswordEntry> _passwords`
*   `int _currentIndex`
*   `int? _selectedCategoryId`, `String _searchQuery`
*   `bool _isLoading`, `String? _error`

**Методы:**
*   `loadPasswords()`, `nextPassword()`, `prevPassword()`
*   `deleteCurrentPassword()` (с логированием PWD_DELETED)
*   `setCategoryFilter()`, `setSearchQuery()`, `clearFilters()`
*   `exportPasswords()`, `importPasswords()` (с логированием)
*   `exportPassgen()`, `importPassgen()`

#### Настройки (`settings/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `SettingsController` | `ChangeNotifier` | Управление настройками |
| `SettingsScreen` | `StatelessWidget` | Экран настроек |

**Методы:**
*   `getSetting()`, `setSetting()`
*   `changePin()`, `removePin()`
*   `getLogsCount()`

#### Категории (`categories/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `CategoriesController` | `ChangeNotifier` | Управление категориями |
| `CategoriesScreen` | `StatelessWidget` | Экран управления категориями |

**Методы:**
*   `loadCategories()`, `createCategory()`, `updateCategory()`, `deleteCategory()`
*   `getSystemCategories()`, `getUserCategories()`

#### Логи (`logs/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `LogsController` | `ChangeNotifier` | Просмотр логов |
| `LogsScreen` | `StatelessWidget` | Экран журнала событий |

**Методы:**
*   `loadLogs()`, `getLogsByDate()`
*   `getEventIcon()`, `getEventColor()`, `formatTime()`

#### О программе (`about/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `AboutScreen` | `StatelessWidget` | Информационный экран |

### 5.2 Widgets (`widgets/`) — 6 виджетов
| Виджет | Описание |
| :--- | :--- |
| `AppButton` | Кнопка с индикатором загрузки |
| `AppDialogs` | Диалоги (подтверждение, информация, ошибка) |
| `AppSwitch` | Переключатель с иконкой |
| `AppTextField` | Поле ввода с валидацией |
| `CopyablePassword` | Отображение пароля с копированием |
| `widgets.dart` | Экспорты |

### Для диаграмм
*   **Вариантов использования:** 9 экранов (акторов)
*   **Последовательности:** `UI` → `Controller` → `Use Case`
*   **Компонентов:** UI компоненты
*   **Развёртывания:** Мобильное/десктопное приложение

---

## 6️⃣ SHARED MODULE (`lib/shared/`)

### Функция
Общие переиспользуемые функции для построения UI.

| Функция | Параметры | Описание |
| :--- | :--- | :--- |
| `buildSwitch()` | `label`, `value`, `isUsed`, `icon` | Создание переключателя |
| `buildInput()` | `label`, `placeholder`, `controller`, `hidden`, `symbols` | Поле ввода |
| `buildButton()` | `label`, `function` | Кнопка |
| `buildBigText()` | `text` | Крупный текст |
| `buildCopyOnTap()` | `label`, `text1`, `function` | Текст с копированием |

---

## 📊 Сводная таблица для диаграмм

### Таблица 1: Компоненты и связи
| Компонент | Зависит от | Предоставляет |
| :--- | :--- | :--- |
| `App` | Все контроллеры | DI контейнер |
| `AuthController` | Auth Use Cases | Состояние аутентификации, таймер |
| `GeneratorController` | Password Use Cases, LogEvent | Состояние генератора |
| `EncryptorController` | Encryptor Use Cases | Состояние шифратора |
| `StorageController` | Storage Use Cases, LogEvent | Состояние хранилища, фильтрация |
| `SettingsController` | Settings, Auth, Logs Use Cases | Настройки |
| `CategoriesController` | Category Use Cases | Категории |
| `LogsController` | Logs Use Case | Логи |
| `Use Cases` | Repositories | Бизнес-логика |
| `Repositories` | Data Sources | Абстракция данных |
| `Data Sources` | SQLite, SharedPreferences, Cryptography | Данные |

### Таблица 2: Потоки данных
```text
Пользователь → UI (Screen) → Controller → Use Case → Repository → DataSource → SQLite / SharedPreferences / Crypto
                                                                                ↓
                                                                        Локальное хранилище
```

### Таблица 3: Сущности базы данных (5 таблиц)
| Таблица | Поля | Назначение |
| :--- | :--- | :--- |
| `categories` | `id`, `name`, `icon`, `is_system`, `created_at` | Категории паролей |
| `password_entries` | `id`, `category_id`, `service`, `login`, `encrypted_password`, `nonce`, `created_at`, `updated_at` | Записи паролей |
| `password_configs` | `id`, `entry_id`, `strength`, `min_length`, `max_length`, `flags`, `require_unique`, `encrypted_config` | Конфигурации генерации |
| `security_logs` | `id`, `action_type`, `timestamp`, `details` | Логи безопасности |
| `app_settings` | `key`, `value`, `encrypted` | Настройки приложения |

---

## 🎯 Рекомендации для диаграмм

### ✅ Диаграмма вариантов использования (Use Case)
*   **Акторы:** Пользователь
*   **Сценарии:**
    *   Аутентификация по PIN
    *   Генерация пароля
    *   Настройка сложности пароля
    *   Выбор категории
    *   Сохранение пароля в хранилище
    *   Шифрование сообщения
    *   Дешифрование сообщения
    *   Просмотр паролей
    *   Поиск и фильтрация
    *   Удаление пароля
    *   Экспорт/импорт (JSON, .passgen)
    *   Управление категориями
    *   Просмотр логов
    *   Смена PIN

### ✅ Диаграмма последовательности (Sequence)
*   **Пример:** Генерация и сохранение пароля
    ```text
    User → GeneratorScreen → GeneratorController → GeneratePasswordUseCase
    → PasswordGeneratorRepository → PasswordGeneratorLocalDataSource
    → EncryptorLocalDataSource (CSPRNG) → PasswordUtils (оценка) → PasswordResult
    → GeneratorController → savePasswordUseCase → LogEventUseCase (PWD_CREATED)
    ```

*   **Пример:** Аутентификация с таймером
    ```text
    User → AuthScreen → AuthController → VerifyPinUseCase → AuthRepository
    → AuthLocalDataSource (PBKDF2) → AuthResult
    → AuthController → resetInactivityTimer() → Timer (5 min) → _lockApp()
    ```

### ✅ Диаграмма компонентов (Component)
*   5 слоёв: `App` → `Presentation` → `Domain` → `Data` → `Core` (общий)

### ✅ Диаграмма развёртывания (Deployment)
*   **Узлы:**
    *   Мобильное устройство (Android)
    *   Десктоп (Windows/Linux)
    *   Локальное хранилище (`SQLite`, `SharedPreferences`)

### ✅ ER-диаграмма (Entity-Relationship)
*   5 таблиц со связями:
    *   `categories` ← `password_entries` (Many-to-One)
    *   `password_entries` ← `password_configs` (One-to-One)
    *   `security_logs` (независимая)
    *   `app_settings` (независимая)
