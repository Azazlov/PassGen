# 📋 Описание модулей проекта PassGen

## 🏗️ Общая архитектура (Clean Architecture)
Проект разделён на 3 основных слоя:

1.  **Presentation Layer** (UI)
2.  **Domain Layer** (бизнес-логика)
3.  **Data Layer** (данные)

---

## 1️⃣ APP MODULE (`lib/app/`)

### Функция
Точка входа приложения, конфигурация Dependency Injection (DI), маршрутизация между вкладками.

### Объекты
| Класс/Функция | Тип | Описание |
| :--- | :--- | :--- |
| `PasswordGeneratorApp` | `StatelessWidget` | Корневой виджет приложения |
| `TabScaffold` | `StatefulWidget` | Основной каркас с навигацией по вкладкам |
| `AppTab` | `enum` | Типобезопасное управление вкладками (4 значения) |
| `getTheme()` | Функция | Создание темы (светлая/тёмная) |

### Зависимости
*   `Provider` (DI)
*   `Google Fonts`
*   `Material 3`

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
| `PasswordFlags` | Флаги категорий символов (digits=1, lowercase=4, uppercase=16, symbols=64) |
| `AppConstants` | Глобальные константы приложения |

#### 2.2 Errors (`errors/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `Failure` | `abstract class` | Базовый класс ошибок |
| `EncryptionFailure` | Класс |Ошибка шифрования/дешифрования |
| `PasswordGenerationFailure` | Класс |Ошибка генерации пароля |
| `StorageFailure` | Класс |Ошибка хранилища |
| `ValidationFailure` | Класс |Ошибка валидации |
| `ConfigFailure` | Класс |Ошибка конфигурации |

#### 2.3 Utils (`utils/`)
| Класс | Методы | Описание |
| :--- | :--- | :--- |
| `CryptoUtils` | `encodeBase64()`, `decodeBase64()`, `encodeBytesBase64()`, `decodeBytesBase64()` | Кодирование Base64 |
| `PasswordUtils` | `evaluateStrength()` | Оценка надёжности пароля (zxcvbn + эвристика) |

### Для диаграмм
*   **Компонентов:** Базовый инфраструктурный компонент
*   **Развёртывания:** Используется всеми модулями

---

## 3️⃣ DOMAIN MODULE (`lib/domain/`)

### Функция
Бизнес-логика приложения. Не зависит от UI и источников данных.

### 3.1 Entities (`entities/`)
| Сущность | Поля | Методы | Описание |
| :--- | :--- | :--- | :--- |
| `PasswordConfig` | `version`, `service`, `lastUsageDate`, `uuid`, `category`, `expireDays`, `encryptedConfig` | `isExpired`, `dateFromUuid`, `copyWithUpdatedUsage()` | Конфигурация генерации пароля |
| `PasswordGenerationSettings` | `strength`, `lengthRange`, `flags`, `requireUppercase`, `requireLowercase`, `requireDigits`, `requireSymbols`, `allUnique` | `copyWith()` | Настройки генерации |
| `PasswordResult` | `password`, `strength`, `config`, `error` | `hasError` | Результат генерации |
| `PasswordEntry` | `service`, `password`, `config`, `createdAt`, `updatedAt` | `fromJson()`, `toJson()`, `copyWith()`, статические `encodeList()`, `decodeList()`, `findByService()` | Запись в хранилище |

### 3.2 Repository Interfaces (`repositories/`)
| Интерфейс | Методы | Описание |
| :--- | :--- | :--- |
| `PasswordGeneratorRepository` | `generatePassword()`, `restorePassword()`, `createPasswordConfig()`, `decryptPassword()`, `savePassword()` | Контракт для генерации паролей |
| `EncryptorRepository` | `encrypt()`, `decrypt()` | Контракт для шифрования |
| `StorageRepository` | `saveConfigs()`, `getConfigs()`, `removeConfigAt()`, `clearStorage()`, `savePasswords()`, `getPasswords()`, `removePasswordAt()`, `exportPasswords()`, `importPasswords()` | Контракт для хранилища |

### 3.3 Use Cases (`usecases/`)

#### Генератор паролей (`password/`)
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GeneratePasswordUseCase` | `PasswordGenerationSettings` | `Either<Failure, PasswordResult>` | Генерация пароля |
| `SavePasswordUseCase` | `service`, `password`, `config` | `Either<Failure, Map>` | Сохранение в хранилище |

#### Шифратор (`encryptor/`)
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `EncryptMessageUseCase` | `message`, `password` | `Either<Failure, String>` | Шифрование AES-GCM |
| `DecryptMessageUseCase` | `encryptedData`, `password` | `Either<Failure, String>` | Дешифрование |

#### Хранилище (`storage/`)
| Use Case | Вход | Выход | Описание |
| :--- | :--- | :--- | :--- |
| `GetConfigsUseCase` | `key` | `Either<Failure, List<String>>` | Получение конфигов |
| `SaveConfigsUseCase` | `key`, `configs` | `Either<Failure, bool>` | Сохранение конфигов |
| `GetPasswordsUseCase` | — | `Either<Failure, List<PasswordEntry>>` | Получение паролей |
| `DeletePasswordUseCase` | `index` | `Either<Failure, bool>` | Удаление пароля |
| `ExportPasswordsUseCase` | — | `Either<Failure, String>` | Экспорт в JSON |
| `ImportPasswordsUseCase` | `jsonString` | `Either<Failure, bool>` | Импорт из JSON |

### Для диаграмм
*   **Вариантов использования:** Каждый Use Case — отдельный сценарий
*   **Последовательности:** `Controller` → `Use Case` → `Repository` → `DataSource`
*   **Компонентов:** Ядро бизнес-логики

---

## 4️⃣ DATA MODULE (`lib/data/`)

### Функция
Реализация репозиториев и источники данных (`SharedPreferences`, криптография).

### 4.1 Data Sources (`datasources/`)
| Класс | Зависимости | Методы | Описание |
| :--- | :--- | :--- | :--- |
| `EncryptorLocalDataSource` | `cryptography` (Chacha20) | `generateRandomBytes()`, `generateRandomInt()`, `encrypt()`, `decrypt()`, `encryptToMini()`, `decryptFromMini()` | Шифрование AES-GCM (Chacha20-Poly1305) |
| `StorageLocalDataSource` | `shared_preferences` | `saveConfig()`, `getConfigs()`, `removeConfigs()`, `savePasswords()`, `getPasswords()`, `exportPasswords()`, `importPasswords()` | Локальное хранилище |
| `PasswordGeneratorLocalDataSource` | `EncryptorLocalDataSource`, `StorageLocalDataSource` | `generate()`, `restoreFromConfig()`, `createEncryptedConfig()`, `decryptConfig()`, `savePassword()` | Генерация паролей |

### 4.2 Repositories (`repositories/`)
| Класс | Реализует | Методы |
| :--- | :--- | :--- |
| `PasswordGeneratorRepositoryImpl` | `PasswordGeneratorRepository` | Делегирует вызовы в `PasswordGeneratorLocalDataSource` |
| `EncryptorRepositoryImpl` | `EncryptorRepository` | Делегирует вызовы в `EncryptorLocalDataSource` |
| `StorageRepositoryImpl` | `StorageRepository` | Делегирует вызовы в `StorageLocalDataSource` |

### Для диаграмм
*   **Последовательности:** `DataSource` → Внешние сервисы (`SharedPreferences`, `Cryptography`)
*   **Развёртывания:** Локальное хранилище на устройстве
*   **Компонентов:** Слой доступа к данным

---

## 5️⃣ PRESENTATION MODULE (`lib/presentation/`)

### Функция
UI приложение, контроллеры состояния, экраны.

### 5.1 Features (`features/`)

#### Генератор (`generator/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `GeneratorController` | `ChangeNotifier` | Управление состоянием генератора |
| `GeneratorScreen` | `StatelessWidget` | Экран генератора |

**Состояние контроллера:**
*   `PasswordGenerationSettings _settings`
*   `PasswordResult? _lastResult`
*   `bool _isLoading`
*   `String? _error`
*   `TextEditingController` (service, minLength, maxLength)

**Методы:**
*   `updateStrength()`, `toggleRequire*()`, `updateLengthRange()`
*   `generatePassword()`, `savePassword()`

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
*   `List<PasswordEntry> _passwords`
*   `int _currentIndex`
*   `bool _isLoading`

**Методы:**
*   `loadPasswords()`, `nextPassword()`, `prevPassword()`
*   `deleteCurrentPassword()`, `exportPasswords()`, `importPasswords()`

#### О программе (`about/`)
| Класс | Тип | Описание |
| :--- | :--- | :--- |
| `AboutScreen` | `StatelessWidget` | Информационный экран |

### 5.2 Widgets (`widgets/`)
| Виджет | Описание |
| :--- | :--- |
| `AppButton` | Кнопка с индикатором загрузки |
| `AppDialogs` | Диалоги (подтверждение, информация) |
| `AppSwitch` | Переключатель с иконкой |
| `AppTextField` | Поле ввода с валидацией |
| `CopyablePassword` | Отображение пароля с копированием |

### Для диаграмм
*   **Вариантов использования:** 4 основных актора (Генератор, Шифратор, Хранилище, Пользователь)
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
| `GeneratorController` | Use Cases | Состояние UI |
| `EncryptorController` | Use Cases | Состояние UI |
| `StorageController` | Use Cases | Состояние UI |
| `Use Cases` | Repositories | Бизнес-логика |
| `Repositories` | Data Sources | Абстракция данных |
| `Data Sources` | Внешние пакеты | Данные |

### Таблица 2: Потоки данных
```text
Пользователь → UI (Screen) → Controller → Use Case → Repository → DataSource → Внешний сервис
                                                                                    ↓
                                                                           SharedPreferences / Crypto
```

### Таблица 3: Сущности базы данных (7 таблиц)
| Таблица | Поля | Назначение |
| :--- | :--- | :--- |
| `categories` | — | Категории паролей |
| `passwords` | `service`, `password`, `config`, `createdAt`, `updatedAt` | Записи паролей |
| `encrypted_data` | `cipher_text`, `nonce` | Зашифрованные данные |
| `generator_configs` | — | Конфигурации генератора |
| `security_events` | — | Логи безопасности |
| `app_settings` | — | Настройки приложения |
| `password_history` | — | История изменений |

---

## 🎯 Рекомендации для диаграмм

### ✅ Диаграмма вариантов использования (Use Case)
*   **Акторы:** Пользователь
*   **Сценарии:**
    *   Генерация пароля
    *   Настройка сложности пароля
    *   Сохранение пароля в хранилище
    *   Шифрование сообщения
    *   Дешифрование сообщения
    *   Просмотр паролей
    *   Удаление пароля
    *   Экспорт/импорт паролей

### ✅ Диаграмма последовательности (Sequence)
*   **Пример:** Генерация пароля
    ```text
    User → GeneratorScreen → GeneratorController → GeneratePasswordUseCase 
    → PasswordGeneratorRepository → PasswordGeneratorLocalDataSource 
    → EncryptorLocalDataSource (CSPRNG) → PasswordUtils (оценка) → PasswordResult
    ```

### ✅ Диаграмма компонентов (Component)
*   3 слоя: `Presentation` → `Domain` → `Data` + `Core` (общий)

### ✅ Диаграмма развёртывания (Deployment)
*   **Узлы:**
    *   Мобильное устройство (Android)
    *   Десктоп (Windows/Linux)
    *   Локальное хранилище (`SharedPreferences`)