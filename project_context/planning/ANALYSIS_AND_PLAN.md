# 📊 Анализ проекта PassGen и план разработки

**Дата анализа:** 6 марта 2026 г.  
**Версия документа:** 1.0  
**Статус:** Черновик

---

## 1. ОБЩАЯ ИНФОРМАЦИЯ О ПРОЕКТЕ

### 1.1 Текущее состояние
| Параметр | Значение |
|---|---|
| **Версия приложения** | 0.3.2+1 |
| **Язык разработки** | Dart 3.9+ (Flutter) |
| **Архитектура** | Clean Architecture (3 слоя) |
| **State Management** | Provider (ChangeNotifier) |
| **Хранилище** | SharedPreferences (локальное) |

### 1.2 Структура проекта (фактическая)
```
lib/
├── app/                          ✅ Точка входа, DI, навигация
│   └── app.dart
├── core/                         ✅ Базовые утилиты и константы
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── failures.dart
│   └── utils/
│       ├── crypto_utils.dart
│       └── password_utils.dart
├── domain/                       ✅ Бизнес-логика
│   ├── entities/
│   │   ├── password_config.dart
│   │   ├── password_entry.dart
│   │   ├── password_generation_settings.dart
│   │   └── password_result.dart
│   ├── repositories/
│   │   ├── encryptor_repository.dart
│   │   ├── password_generator_repository.dart
│   │   └── storage_repository.dart
│   └── usecases/
│       ├── encryptor/
│       │   ├── encrypt_message_usecase.dart
│       │   └── decrypt_message_usecase.dart
│       ├── password/
│       │   ├── generate_password_usecase.dart
│       │   └── save_password_usecase.dart
│       └── storage/
│           ├── get_configs_usecase.dart
│           ├── save_configs_usecase.dart
│           ├── get_passwords_usecase.dart
│           ├── delete_password_usecase.dart
│           ├── export_passwords_usecase.dart
│           └── import_passwords_usecase.dart
├── data/                         ✅ Реализация репозиториев
│   ├── datasources/
│   │   ├── encryptor_local_datasource.dart
│   │   ├── password_generator_local_datasource.dart
│   │   └── storage_local_datasource.dart
│   ├── models/                   ❌ ПУСТО
│   └── repositories/
│       ├── encryptor_repository_impl.dart
│       ├── password_generator_repository_impl.dart
│       └── storage_repository_impl.dart
├── presentation/                 ✅ UI слой
│   ├── features/
│   │   ├── about/
│   │   │   └── about_screen.dart
│   │   ├── encryptor/
│   │   │   ├── encryptor_controller.dart
│   │   │   └── encryptor_screen.dart
│   │   ├── generator/
│   │   │   ├── generator_controller.dart
│   │   │   └── generator_screen.dart
│   │   └── storage/
│   │       ├── storage_controller.dart
│   │       └── storage_screen.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_dialogs.dart
│       ├── app_switch.dart
│       ├── app_text_field.dart
│       └── copyable_password.dart
└── main.dart
```

---

## 2. СРАВНЕНИЕ ТЗ И ФАКТИЧЕСКОЙ РЕАЛИЗАЦИИ

### 2.1 Реализованные функции (✅ ГОТОВО)

| Требование ТЗ | Статус | Комментарий |
|---|---|---|
| **Генератор паролей** | ✅ | Полная реализация |
| - Длина 8-64 символа | ✅ | Настраиваемый диапазон |
| - Наборы символов | ✅ | 4 категории (a-z, A-Z, 0-9, спецсимволы) |
| - Пресеты сложности | ✅ | 5 уровней (0-4) |
| - Оценка стойкости | ✅ | zxcvbn + эвристика |
| **Хранилище данных** | ✅ | CRUD реализован |
| - Сохранение паролей | ✅ | С сервисом и конфигом |
| - Просмотр паролей | ✅ | Навигация по списку |
| - Удаление паролей | ✅ | По индексу |
| - Копирование в буфер | ✅ | С уведомлением |
| **Импорт/Экспорт** | ✅ | JSON формат |
| - JSON Miniified | ✅ | Экспорт/импорт работают |
| **Шифрование** | ✅ | ChaCha20-Poly1305 |
| - PBKDF2 деривация | ✅ | 10000 итераций, HMAC-SHA256 |
| - AES-GCM альтернатива | ✅ | ChaCha20 реализован |
| **Архитектура** | ✅ | Clean Architecture соблюдена |
| - Presentation layer | ✅ | Controllers + Screens |
| - Domain layer | ✅ | Entities + UseCases + Repositories |
| - Data layer | ✅ | DataSources + RepositoryImpls |
| **UI/UX** | ✅ | Material 3, адаптивность |
| - 4 вкладки | ✅ | Генератор, Шифратор, Хранилище, О программе |
| - Светлая/тёмная тема | ✅ | Автоматически от системы |

---

### 2.2 НЕ реализованные функции (❌ ТРЕБУЕТСЯ РАЗРАБОТКА)

| Требование ТЗ | Статус | Приоритет | Трудоёмкость |
|---|---|---|---|
| **Аутентификация и безопасность** | ❌ | 🔴 КРИТИЧНО | Высокая |
| - Вход по PIN-коду (4-8 цифр) | ❌ | 🔴 | 8-12 часов |
| - Деривация ключа (PBKDF2/Argon2) | ⚠️ Частично | 🔴 | 4-6 часов |
| - Хранение ключей в RAM | ❌ | 🔴 | 4-6 часов |
| - Блокировка при неактивности (5 мин) | ❌ | 🟡 | 4-6 часов |
| - Защита от подбора (30 сек после 5 попыток) | ❌ | 🔴 | 4-6 часов |
| **База данных SQLite** | ❌ | 🔴 КРИТИЧНО | Высокая |
| - Таблица `categories` | ❌ | 🟡 | 4-6 часов |
| - Таблица `password_entries` | ❌ | 🔴 | 6-8 часов |
| - Таблица `password_configs` | ❌ | 🟡 | 4-6 часов |
| - Таблица `security_logs` | ❌ | 🟡 | 4-6 часов |
| - Таблица `app_settings` | ❌ | 🟢 | 2-4 часа |
| - Миграции БД | ❌ | 🟡 | 4-6 часов |
| **Логирование событий** | ❌ | 🟡 СРЕДНИЙ | Средняя |
| - AUTH_SUCCESS/FAILURE | ❌ | 🟡 | 2-4 часа |
| - PWD_CREATED/ACCESSED/DELETED | ❌ | 🟡 | 2-4 часа |
| - DATA_EXPORT/IMPORT | ❌ | 🟡 | 2-4 часа |
| - SETTINGS_CHG | ❌ | 🟢 | 2-4 часа |
| - Автоудаление старых логов (1000 записей) | ❌ | 🟢 | 2-4 часа |
| **Расширенные функции генератора** | ⚠️ | 🟢 НИЗКИЙ | Низкая |
| - Опция «Без повторяющихся символов» | ❌ | 🟢 | 2-4 часа |
| - Опция «Исключить похожие символы» | ❌ | 🟢 | 2-4 часа |
| **Категоризация паролей** | ⚠️ Частично | 🟡 | Средняя |
| - Системные категории | ❌ | 🟡 | 4-6 часов |
| - Пользовательские категории | ❌ | 🟢 | 4-6 часов |
| - Поиск/фильтрация | ❌ | 🟡 | 4-6 часов |
| **Настройки приложения** | ❌ | 🟡 СРЕДНИЙ | Средняя |
| - Экран настроек | ❌ | 🟡 | 4-6 часов |
| - Сохранение настроек | ⚠️ Частично | 🟡 | 2-4 часа |
| **Формат .passgen** | ❌ | 🟢 НИЗКИЙ | Низкая |
| - Фирменный формат файла | ❌ | 🟢 | 4-6 часов |
| **Экспорт CSV** | ❌ | 🟢 НИЗКИЙ | Низкая |
| - Текстовый формат без шифрования | ❌ | 🟢 | 2-4 часа |

---

## 3. ПРОБЛЕМЫ И ТЕХНИЧЕСКИЙ ДОЛГ

### 3.1 Критические проблемы

| Проблема | Описание | Влияние | Решение |
|---|---|---|---|
| **Отсутствие аутентификации** | Нет PIN-кода, любой доступ ко всем данным | 🔴 КРИТИЧНО | Реализовать экран входа, хранение хеша PIN |
| **Нет SQLite** | Данные в SharedPreferences (небезопасно, нет структуры) | 🔴 КРИТИЧНО | Миграция на sqflite с правильной схемой |
| **Ключи не очищаются** | Мастер-ключи могут оставаться в памяти | 🔴 КРИТИЧНО | Реализовать очистку при блокировке/выходе |
| **Нет логирования** | Невозможно отследить события безопасности | 🟡 СРЕДНЕЕ | Таблица security_logs + триггеры |

### 3.2 Архитектурные проблемы

| Проблема | Описание | Влияние | Решение |
|---|---|---|---|
| **Пустая папка models** | `lib/data/models/` не используется | 🟢 НИЗКОЕ | Либо удалить, либо создать модели для БД |
| **GetConfigsUseCase не используется** | Есть в DI, но нет в контроллерах | 🟢 НИЗКОЕ | Удалить или интегрировать |
| **PasswordConfig не шифруется** | Поле encryptedConfig есть, но не используется | 🟡 СРЕДНЕЕ | Реализовать шифрование конфигов |

### 3.3 Проблемы UX

| Проблема | Описание | Влияние | Решение |
|---|---|---|---|
| **Нет валидации PIN** | Нет требований к длине/формату | 🔴 КРИТИЧНО | Валидация 4-8 цифр |
| **Нет автоблокировки** | Приложение не блокируется | 🔴 КРИТИЧНО | Таймер неактивности |
| **Нет защиты от перебора** | Нет задержек при неудачных попытках | 🔴 КРИТИЧНО | Блокировка на 30 сек после 5 попыток |

---

## 4. ПОДРОБНЫЙ ПЛАН РАЗРАБОТКИ

### Этап 1: Безопасность и аутентификация (Приоритет: 🔴 КРИТИЧНО)
**Срок:** 3-4 дня (24-32 часа)

#### 1.1 Экран аутентификации
- [ ] **Создать `lib/presentation/features/auth/`**
  - [ ] `auth_screen.dart` — экран ввода PIN-кода
  - [ ] `auth_controller.dart` — логика ввода, валидация, блокировки
  - [ ] `pin_input_widget.dart` — кастомный виджет ввода PIN (4-8 цифр)
  
- [ ] **Требования к UI:**
  - [ ] 4-8 цифровых ячеек
  - [ ] Визуальная обратная связь при вводе
  - [ ] Индикатор попыток
  - [ ] Сообщение о блокировке при 5 неудачных попытках

#### 1.2 Хранение и проверка PIN
- [ ] **Создать `lib/domain/usecases/auth/`**
  - [ ] `setup_pin_usecase.dart` — первичная установка PIN
  - [ ] `verify_pin_usecase.dart` — проверка введённого PIN
  - [ ] `change_pin_usecase.dart` — смена PIN
  - [ ] `remove_pin_usecase.dart` — удаление PIN

- [ ] **Создать `lib/data/datasources/auth_local_datasource.dart`**
  - [ ] Хранение хеша PIN (не самого PIN!)
  - [ ] PBKDF2 деривация для хеширования
  - [ ] Счётчик неудачных попыток
  - [ ] Timestamp блокировки

#### 1.3 Защита от подбора
- [ ] **Реализовать логику блокировки:**
  - [ ] Счётчик неудачных попыток (максимум 5)
  - [ ] Блокировка на 30 секунд после 5 попыток
  - [ ] Сохранение timestamp разблокировки
  - [ ] Сброс счётчика при успешном входе

#### 1.4 Интеграция аутентификации
- [ ] **Модифицировать `lib/app/app.dart`:**
  - [ ] Проверка состояния аутентификации при старте
  - [ ] Показ AuthScreen если не аутентифицирован
  - [ ] Показ основного приложения если аутентифицирован

---

### Этап 2: Миграция на SQLite (Приоритет: 🔴 КРИТИЧНО)
**Срок:** 4-5 дней (32-40 часов)

#### 2.1 Настройка SQLite
- [ ] **Проверить зависимости в `pubspec.yaml`:**
  - [ ] `sqflite: ^2.4.2` ✅ Уже есть
  - [ ] `sqflite_common_ffi: ^2.4.0+2` ✅ Уже есть для desktop
  - [ ] `path_provider: ^2.1.5` ✅ Уже есть
  - [ ] `path: ^1.9.0` ✅ Уже есть

#### 2.2 Создание схемы БД
- [ ] **Создать `lib/data/database/`:**
  - [ ] `database_helper.dart` — синглтон для управления БД
  - [ ] `database_schema.dart` — SQL CREATE TABLE statements
  - [ ] `database_migrations.dart` — миграции между версиями

- [ ] **Таблица `categories`:**
  ```sql
  CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    icon TEXT,
    is_system INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
  )
  ```

- [ ] **Таблица `password_entries`:**
  ```sql
  CREATE TABLE password_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER REFERENCES categories(id),
    service TEXT NOT NULL,
    login TEXT,
    encrypted_password BLOB NOT NULL,
    nonce BLOB NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
  ```

- [ ] **Таблица `password_configs`:**
  ```sql
  CREATE TABLE password_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entry_id INTEGER UNIQUE REFERENCES password_entries(id),
    strength INTEGER,
    min_length INTEGER,
    max_length INTEGER,
    flags INTEGER,
    require_unique INTEGER DEFAULT 0,
    encrypted_config BLOB
  )
  ```

- [ ] **Таблица `security_logs`:**
  ```sql
  CREATE TABLE security_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action_type TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    details TEXT
  )
  ```

- [ ] **Таблица `app_settings`:**
  ```sql
  CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    encrypted INTEGER DEFAULT 0
  )
  ```

#### 2.3 Репозитории для SQLite
- [ ] **Создать `lib/data/repositories/sqlite/`:**
  - [ ] `category_repository_impl.dart` — CRUD для категорий
  - [ ] `password_entry_repository_impl.dart` — CRUD для записей
  - [ ] `password_config_repository_impl.dart` — CRUD для конфигов
  - [ ] `security_log_repository_impl.dart` — логирование
  - [ ] `app_settings_repository_impl.dart` — настройки

#### 2.4 Миграция данных из SharedPreferences
- [ ] **Создать `lib/data/database/migration_from_shared_prefs.dart`:**
  - [ ] Чтение данных из SharedPreferences
  - [ ] Преобразование в формат SQLite
  - [ ] Вставка в новые таблицы
  - [ ] Очистка SharedPreferences после успешной миграции
  - [ ] Флаг выполненной миграции в app_settings

#### 2.5 Обновление Use Cases
- [ ] **Модифицировать существующие use cases:**
  - [ ] `get_passwords_usecase.dart` → работа с SQLite
  - [ ] `save_password_usecase.dart` → работа с SQLite
  - [ ] `delete_password_usecase.dart` → работа с SQLite
  - [ ] `export_passwords_usecase.dart` → работа с SQLite
  - [ ] `import_passwords_usecase.dart` → работа с SQLite

---

### Этап 3: Логирование событий (Приоритет: 🟡 СРЕДНИЙ)
**Срок:** 2-3 дня (16-24 часа)

#### 3.1 Система логирования
- [ ] **Создать `lib/domain/entities/security_log.dart`:**
  - [ ] Поля: id, actionType, timestamp, details
  - [ ] Методы: toJson, fromJson

- [ ] **Создать `lib/domain/repositories/security_log_repository.dart`:**
  - [ ] `logEvent(String actionType, Map<String, dynamic> details)`
  - [ ] `getLogs({int limit = 1000})`
  - [ ] `clearOldLogs({int keepLast = 1000})`

#### 3.2 Типы событий
- [ ] **Создать `lib/core/constants/event_types.dart`:**
  ```dart
  class EventTypes {
    static const String authSuccess = 'AUTH_SUCCESS';
    static const String authFailure = 'AUTH_FAILURE';
    static const String pwdCreated = 'PWD_CREATED';
    static const String pwdAccessed = 'PWD_ACCESSED';
    static const String pwdDeleted = 'PWD_DELETED';
    static const String dataExport = 'DATA_EXPORT';
    static const String dataImport = 'DATA_IMPORT';
    static const String settingsChanged = 'SETTINGS_CHG';
  }
  ```

#### 3.3 Интеграция логирования
- [ ] **Добавить логирование в:**
  - [ ] AuthController → AUTH_SUCCESS, AUTH_FAILURE
  - [ ] GeneratorController → PWD_CREATED
  - [ ] StorageController → PWD_ACCESSED, PWD_DELETED
  - [ ] Export/Import → DATA_EXPORT, DATA_IMPORT

#### 3.4 Автоочистка логов
- [ ] **Создать `lib/domain/usecases/logs/clear_old_logs_usecase.dart`:**
  - [ ] Удаление логов старше N записей
  - [ ] Запуск при каждом N-м запуске приложения

---

### Этап 4: Категоризация паролей (Приоритет: 🟡 СРЕДНИЙ)
**Срок:** 2-3 дня (16-24 часа)

#### 4.1 Управление категориями
- [ ] **Создать `lib/domain/entities/category.dart`:**
  - [ ] Поля: id, name, icon, isSystem, createdAt
  - [ ] Предустановленные категории: "Соцсети", "Почта", "Банки", "Другое"

- [ ] **Создать `lib/domain/usecases/category/`:**
  - [ ] `get_categories_usecase.dart`
  - [ ] `create_category_usecase.dart`
  - [ ] `update_category_usecase.dart`
  - [ ] `delete_category_usecase.dart`

#### 4.2 UI для категорий
- [ ] **Создать `lib/presentation/features/categories/`:**
  - [ ] `categories_screen.dart` — список категорий
  - [ ] `category_form_dialog.dart` — создание/редактирование
  - [ ] `categories_controller.dart`

#### 4.3 Привязка к паролям
- [ ] **Модифицировать `lib/presentation/features/generator/`:**
  - [ ] Добавить выбор категории при сохранении пароля
  - [ ] Dropdown или диалог с категориями

#### 4.4 Поиск и фильтрация
- [ ] **Модифицировать `lib/presentation/features/storage/`:**
  - [ ] Поиск по названию сервиса
  - [ ] Фильтр по категории
  - [ ] Сортировка (по имени, по дате)

---

### Этап 5: Настройки приложения (Приоритет: 🟡 СРЕДНИЙ)
**Срок:** 2-3 дня (16-24 часа)

#### 5.1 Экран настроек
- [ ] **Создать `lib/presentation/features/settings/`:**
  - [ ] `settings_screen.dart` — список настроек
  - [ ] `settings_controller.dart`

#### 5.2 Типы настроек
- [ ] **Настройки для реализации:**
  - [ ] Тема оформления (системная/светлая/тёмная)
  - [ ] Язык интерфейса
  - [ ] Время автоблокировки (1, 5, 10, 30 минут)
  - [ ] Очистка буфера обмена (30, 60, 120 секунд)
  - [ ] Смена PIN-кода
  - [ ] Экспорт данных
  - [ ] Импорт данных
  - [ ] О приложении

#### 5.3 Хранение настроек
- [ ] **Интеграция с таблицей `app_settings`:**
  - [ ] Шифрование чувствительных настроек
  - [ ] Кеширование часто используемых настроек

---

### Этап 6: Улучшения генератора (Приоритет: 🟢 НИЗКИЙ)
**Срок:** 1-2 дня (8-16 часов)

#### 6.1 Уникальность символов
- [ ] **Модифицировать `lib/data/datasources/password_generator_local_datasource.dart`:**
  - [ ] Опция `require_unique` — без повторяющихся символов
  - [ ] Проверка доступной длины для уникальных символов

#### 6.2 Исключение похожих символов
- [ ] **Добавить опцию `exclude_similar`:**
  - [ ] Исключить: l, 1, I, O, 0
  - [ ] Настройка набора символов

---

### Этап 7: Формат .passgen и CSV (Приоритет: 🟢 НИЗКИЙ)
**Срок:** 1-2 дня (8-16 часов)

#### 7.1 Фирменный формат .passgen
- [ ] **Создать `lib/data/formats/passgen_format.dart`:**
  - [ ] Структура файла: заголовок + зашифрованные данные
  - [ ] Экспорт в .passgen
  - [ ] Импорт из .passgen

#### 7.2 Экспорт CSV
- [ ] **Создать `lib/data/formats/csv_exporter.dart`:**
  - [ ] Экспорт в CSV (без шифрования!)
  - [ ] Предупреждение о безопасности

---

### Этап 8: Тестирование и документация (Приоритет: 🔴 КРИТИЧНО)
**Срок:** 3-4 дня (24-32 часа)

#### 8.1 Unit-тесты
- [ ] **Создать `test/`:**
  - [ ] `domain/usecases/` — тесты use cases
  - [ ] `data/repositories/` — тесты репозиториев
  - [ ] `data/datasources/` — тесты источников данных

#### 8.2 Интеграционные тесты
- [ ] **Создать `integration_test/`:**
  - [ ] `auth_flow_test.dart` — поток аутентификации
  - [ ] `password_generation_test.dart` — генерация паролей
  - [ ] `storage_crud_test.dart` — CRUD операции

#### 8.3 Документация
- [ ] **Обновить README.md:**
  - [ ] Инструкция по запуску
  - [ ] Скриншоты
  - [ ] Описание функций

- [ ] **DartDoc комментарии:**
  - [ ] Документировать ключевые классы
  - [ ] Добавить примеры использования

---

## 5. ДОПОЛНИТЕЛЬНЫЕ ТРЕБОВАНИЯ К ДИПЛОМУ

### 5.1 Диаграммы (обязательно по ТЗ)

| Диаграмма | Статус | Приоритет |
|---|---|---|
| Use Case Diagram | ❌ | 🔴 |
| Sequence Diagram | ❌ | 🔴 |
| Component Diagram | ❌ | 🔴 |
| ER-Diagram | ❌ | 🔴 |
| Deployment Diagram | ❌ | 🔴 |

### 5.2 Пояснительная записка
- [ ] Введение (актуальность, цели)
- [ ] Анализ предметной области
- [ ] Теоретическая часть (криптография, БД, архитектура)
- [ ] Практическая часть (реализация, код, скриншоты)
- [ ] Заключение и перспективы
- [ ] Список литературы
- [ ] Приложения

---

## 6. СВОДНАЯ ТАБЛИЦА ЗАДАЧ

| Этап | Задача | Приоритет | Трудоёмкость (часы) |
|---|---|---|---|
| 1 | Аутентификация и безопасность | 🔴 | 24-32 |
| 2 | Миграция на SQLite | 🔴 | 32-40 |
| 3 | Логирование событий | 🟡 | 16-24 |
| 4 | Категоризация паролей | 🟡 | 16-24 |
| 5 | Настройки приложения | 🟡 | 16-24 |
| 6 | Улучшения генератора | 🟢 | 8-16 |
| 7 | Формат .passgen и CSV | 🟢 | 8-16 |
| 8 | Тестирование и документация | 🔴 | 24-32 |
| **ИТОГО** | | | **144-208 часов** |

---

## 7. РЕКОМЕНДАЦИИ ПО ПРИОРИТЕТАМ

### Неделя 1-2: Критический функционал
1. ✅ Аутентификация (PIN-код, блокировки)
2. ✅ SQLite (базовая схема, миграция)

### Неделя 3-4: Безопасность и логирование
1. ✅ Логирование событий
2. ✅ Интеграция аутентификации с логами
3. ✅ Очистка ключей из памяти

### Неделя 5-6: Категоризация и настройки
1. ✅ Управление категориями
2. ✅ Поиск и фильтрация
3. ✅ Экран настроек

### Неделя 7-8: Полировка и документация
1. ✅ Улучшения генератора
2. ✅ Форматы экспорта
3. ✅ Тесты и документация
4. ✅ Диаграммы для диплома

---

## 8. ВЫВОДЫ

### Текущее состояние проекта: ~45% готовности

**Сильные стороны:**
- ✅ Правильная архитектура (Clean Architecture)
- ✅ Рабочий генератор паролей
- ✅ Рабочее хранилище (хотя и на SharedPreferences)
- ✅ Шифрование ChaCha20-Poly1305
- ✅ Импорт/Экспорт JSON

**Критические пробелы:**
- ❌ Нет аутентификации (PIN-код)
- ❌ Нет SQLite (данные в SharedPreferences)
- ❌ Нет логирования событий
- ❌ Нет автоблокировки
- ❌ Нет защиты от подбора PIN

**Рекомендация:** Сфокусироваться на Этапах 1 и 2 (аутентификация + SQLite) как на наиболее критичных для безопасности и соответствия ТЗ.
