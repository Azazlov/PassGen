# PassGen — Менеджер паролей с локальным шифрованием

[![Version](https://img.shields.io/badge/version-0.5.0-blue.svg)](https://github.com/azazlov/passgen/releases)
[![Flutter](https://img.shields.io/badge/flutter-^3.9.0-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20android-lightgrey.svg)](https://github.com/azazlov/passgen)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Security](https://img.shields.io/badge/security-98/100-brightgreen.svg)](project_context/data_security_specialist/audit/security_fix_report_2026-03-10.md)

Кроссплатформенное приложение на Flutter для генерации, хранения и управления паролями с использованием современных криптографических методов и локальной базы данных SQLite.

---

## 📊 Текущий статус

| Метрика | Значение | Статус |
|---------|----------|--------|
| **Версия** | 0.5.0 | ✅ Стабильная |
| **Готовность** | 100% | ✅ Готов к релизу |
| **Соответствие ТЗ** | ~98% | ✅ |
| **Безопасность** | 98/100 | ✅ (+13 с марта 2026) |
| **Тесты** | 33/33 unit, 82% widget | ✅ |
| **Сборка** | Linux ✅ Windows ✅ Android ✅ | ✅ |
| **Последнее обновление** | 10 марта 2026 | ✅ |

### 🔐 Безопасность (исправлено 15 уязвимостей)
- ✅ Хранение PIN только в SQLite (удалено из SharedPreferences)
- ✅ Затирание ключей после использования
- ✅ Автоочистка буфера обмена через 60 сек
- ✅ FLAG_SECURE для Android
- ✅ Удалена debug-отладка из production

### 📈 Прогресс по этапам
```
Общая готовность:     ████████████████████ 100%

├─ Аутентификация:    ████████████████████ 100% ✅
├─ Генератор:         ████████████████████ 100% ✅
├─ Хранилище:         ████████████████████ 100% ✅
├─ Импорт/Экспорт:    ████████████████████ 100% ✅
├─ Логирование:       ████████████████████ 100% ✅
├─ База данных:       ████████████████████ 100% ✅
├─ Архитектура:       ████████████████████ 100% ✅
├─ UI/UX:             ████████████████████ 100% ✅
└─ Безопасность:      ████████████████████ 100% ✅
```

---

## 📸 Скриншоты

<p align="center">
  <img width="1266" height="713" alt="Генератор паролей" src="https://github.com/user-attachments/assets/250c4701-9b52-422e-aa9b-01ea13a7b651"/>
  <br><b>Генератор паролей с выбором категории</b>
</p>

<p align="center">
  <img width="1266" height="713" alt="Хранилище паролей" src="https://github.com/user-attachments/assets/247888c0-3910-4f81-888e-e09cb59d2ef0"/>
  <br><b>Хранилище с поиском и фильтрацией</b>
</p>

<p align="center">
  <img width="1266" height="713" alt="Настройки приложения" src="https://github.com/user-attachments/assets/settings"/>
  <br><b>Настройки и управление PIN-кодом</b>
</p>

---

## ⚡ Быстрый старт

```bash
# Клонируйте репозиторий
git clone https://github.com/azazlov/passgen.git
cd passgen

# Установите зависимости
flutter pub get

# Запустите приложение
flutter run -d <устройство>  # linux, windows, android
```

---

## 🎯 Возможности

### 🔐 Аутентификация и безопасность
- ✅ **PIN-код** (4-8 цифр) при запуске
- ✅ **PBKDF2** деривация ключа (10000 итераций, HMAC-SHA256)
- ✅ **Защита от подбора** (30 сек блокировка после 5 попыток)
- ✅ **Автоблокировка** при неактивности (5 минут)
- ✅ **Логирование событий** безопасности

### 🎲 Генератор паролей
- ✅ Длина пароля: 8–64 символа
- ✅ 4 категории символов: a-z, A-Z, 0-9, спецсимволы
- ✅ 5 пресетов сложности (Стандартный → Максимальный)
- ✅ Оценка надёжности (zxcvbn + эвристика)
- ✅ **Выбор категории** для сохранения

### 🗄️ Хранилище данных
- ✅ **SQLite** база данных (5 таблиц)
- ✅ **CRUD операции** с паролями
- ✅ **Категоризация** (7 системных + пользовательские)
- ✅ **Поиск** по названию сервиса
- ✅ **Фильтрация** по категориям
- ✅ Копирование в буфер обмена

### 📦 Импорт и Экспорт
- ✅ **JSON** (Miniified) — стандартный формат
- ✅ **.passgen** — фирменный формат с шифрованием
- ✅ Шифрование ChaCha20-Poly1305

### 🔧 Шифратор сообщений
- ✅ Шифрование/дешифрование текстовых сообщений
- ✅ Алгоритм **ChaCha20-Poly1305 (AEAD)**
- ✅ Проверка целостности (Poly1305 tag)

### ⚙️ Настройки
- ✅ Смена/удаление PIN-кода
- ✅ Просмотр журнала событий
- ✅ Управление категориями

---

## 🏗️ Архитектура

Проект реализует паттерн **Clean Architecture** с разделением на 5 слоёв:

```
lib/
├── app/                          # Точка входа, DI, навигация, темы
│   └── app.dart
├── core/                         # Утилиты, константы, ошибки
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── event_types.dart
│   ├── errors/
│   │   └── failures.dart
│   └── utils/
│       ├── crypto_utils.dart
│       └── password_utils.dart
├── domain/                       # Domain Layer (бизнес-логика)
│   ├── entities/                 # 8 сущностей
│   │   ├── auth_state.dart
│   │   ├── auth_result.dart
│   │   ├── category.dart
│   │   ├── password_config.dart
│   │   ├── password_entry.dart
│   │   ├── password_generation_settings.dart
│   │   ├── password_result.dart
│   │   └── security_log.dart
│   ├── repositories/             # 10 интерфейсов
│   │   ├── app_settings_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── category_repository.dart
│   │   ├── encryptor_repository.dart
│   │   ├── password_entry_repository.dart
│   │   ├── password_generator_repository.dart
│   │   ├── password_export_repository.dart
│   │   ├── password_import_repository.dart
│   │   ├── security_log_repository.dart
│   │   └── storage_repository.dart
│   └── usecases/                 # 25 сценариев
│       ├── auth/ (5)
│       ├── category/ (4)
│       ├── encryptor/ (2)
│       ├── log/ (2)
│       ├── password/ (2)
│       ├── settings/ (3)
│       └── storage/ (6)
├── data/                         # Data Layer (данные)
│   ├── database/
│   │   ├── database_helper.dart
│   │   ├── database_schema.dart
│   │   ├── database_migrations.dart
│   │   └── migration_from_shared_prefs.dart
│   ├── datasources/              # 4 источника данных
│   │   ├── auth_local_datasource.dart
│   │   ├── encryptor_local_datasource.dart
│   │   ├── password_generator_local_datasource.dart
│   │   └── storage_local_datasource.dart
│   ├── formats/
│   │   └── passgen_format.dart
│   ├── models/                   # 5 моделей БД
│   │   ├── app_settings_model.dart
│   │   ├── category_model.dart
│   │   ├── password_config_model.dart
│   │   ├── password_entry_model.dart
│   │   └── security_log_model.dart
│   └── repositories/             # 9 реализаций
│       ├── app_settings_repository_impl.dart
│       ├── auth_repository_impl.dart
│       ├── category_repository_impl.dart
│       ├── encryptor_repository_impl.dart
│       ├── password_generator_repository_impl.dart
│       ├── password_export_repository_impl.dart
│       ├── password_import_repository_impl.dart
│       ├── security_log_repository_impl.dart
│       └── storage_repository_impl.dart
└── presentation/                 # Presentation Layer (UI)
    ├── features/                 # 8 экранов
    │   ├── about/
    │   ├── auth/
    │   ├── categories/
    │   ├── encryptor/
    │   ├── generator/
    │   ├── logs/
    │   ├── settings/
    │   └── storage/
    └── widgets/                  # 6 виджетов
        ├── app_button.dart
        ├── app_dialogs.dart
        ├── app_switch.dart
        ├── app_text_field.dart
        ├── copyable_password.dart
        └── widgets.dart
```

### State Management
- **Provider** для Dependency Injection
- **ChangeNotifier** для реактивных обновлений UI

---

## 🛠️ Технологии

| Категория | Технологии |
|-----------|------------|
| **Фреймворк** | Flutter, Dart ^3.9.0 |
| **State Management** | Provider, ChangeNotifier |
| **База данных** | SQLite (`sqflite` ^2.4.2) |
| **Криптография** | `cryptography` (ChaCha20-Poly1305, PBKDF2, CSPRNG) |
| **Оценка паролей** | `zxcvbn`, `password_strength` |
| **UI** | Material 3, Google Fonts |
| **Функциональное программирование** | `dartz` (Either) |
| **Работа с файлами** | `file_picker`, `share_plus`, `path_provider` |
| **Утилиты** | `uuid`, `url_launcher`, `shared_preferences` |

---

## 🔐 Безопасность

### Криптографические алгоритмы
- **Шифрование**: ChaCha20-Poly1305 (AEAD)
- **Деривация ключа**: PBKDF2-HMAC-SHA256, 10 000 итераций, 256-bit ключ
- **Генерация случайных чисел**: `Random.secure()` (CSPRNG)
- **Аутентификация/целостность**: Poly1305 tag (16 bytes)

### Схема базы данных (5 таблиц)
```sql
-- Категории
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT,
  is_system INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
)

-- Записи паролей
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

-- Конфигурации паролей
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

-- Логи безопасности
CREATE TABLE security_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_type TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  details TEXT
)

-- Настройки приложения
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  encrypted INTEGER DEFAULT 0
)
```

### Формат .passgen
```
┌─────────────────────────────────────┐
│ HEADER: "PASSGEN_V1" (10 байт)      │
├─────────────────────────────────────┤
│ VERSION: 1 (1 байт)                 │
├─────────────────────────────────────┤
│ FLAGS: 0 (1 байт)                   │
├─────────────────────────────────────┤
│ NONCE: случайные 32 байта           │
├─────────────────────────────────────┤
│ DATA_LENGTH: длина (4 байта)        │
├─────────────────────────────────────┤
│ DATA: зашифрованный JSON            │
├─────────────────────────────────────┤
│ MAC: authentication tag (16 байт)   │
└─────────────────────────────────────┘
```

---

## 🧪 Тестирование

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test tests/sqlite_test.dart
```

---

## 📦 Сборка

```bash
# Windows
flutter build windows

# Linux
flutter build linux

# Android (APK)
flutter build apk
```

---

## 📥 Установка

### Windows
1. Распакуйте архив в удобное место
2. Запустите `pass_gen.exe`

### Linux
1. Распакуйте архив
2. Запустите `pass_gen`

### Android
1. Установите `.apk` файл
2. Разрешите установку из неизвестных источников

---

## 🗺️ Roadmap

- [ ] Опции генератора: «Без повторяющихся символов», «Исключить похожие»
- [ ] Автоочистка буфера обмена (60 сек)
- [ ] CSV экспорт
- [ ] Биометрическая аутентификация
- [ ] Синхронизация между устройствами
- [ ] Поддержка macOS и iOS

---

## 📋 Требования

| Компонент | Версия |
|-----------|--------|
| Flutter SDK | ^3.9.0 |
| Dart SDK | ^3.9.0 |
| Android Studio | Для сборки APK |
| Xcode | Для сборки под iOS/macOS |

[Официальная документация по установке Flutter](https://docs.flutter.dev/get-started)

---

## 📚 Документация

### Основная документация
- **[DEVELOPER.md](DEVELOPER.md)** — Полная документация разработчика (архитектура, API, БД, криптография, тестирование, сборка)

### Проектная документация (актуальная)
- **[passgen.tz.md](project_context/agents_context/planning/passgen.tz.md)** — Техническое задание
- **[CURRENT_PROGRESS.md](project_context/agents_context/progress/CURRENT_PROGRESS.md)** — Текущий прогресс (100%)
- **[FINAL_REPORT.md](project_context/agents_context/stages/FINAL_REPORT.md)** — Финальный отчёт
- **[CODE_REVIEW_REPORT.md](project_context/agents_context/reviews/CODE_REVIEW_REPORT.md)** — Код-ревью по ТЗ

### Безопасность
- **[security_fix_report_2026-03-10.md](project_context/data_security_specialist/audit/security_fix_report_2026-03-10.md)** — Устранение 15 уязвимостей
- **[security_audit_report.md](project_context/data_security_specialist/audit/security_audit_report.md)** — Полный аудит безопасности
- **[security_policy.md](project_context/data_security_specialist/security/security_policy.md)** — Политика безопасности

### Тестирование
- **[UNIT_TESTS_COMPLETE.md](project_context/qa_engineer/UNIT_TESTS_COMPLETE.md)** — Unit-тесты (33/33 пройдено)
- **[UNIT_TESTS_REPORT.md](project_context/qa_engineer/UNIT_TESTS_REPORT.md)** — Отчёт о тестировании

### Сборка и развёртывание
- **[BUILD_AND_DEPLOY_STRATEGY.md](project_context/devops_engineer/docs/BUILD_AND_DEPLOY_STRATEGY.md)** — Стратегия сборки

### Устаревшая документация (в архиве)
- [ARCHITECTURE.md](.archive/ARCHITECTURE.md) — Устарело, см. [DEVELOPER.md](DEVELOPER.md)
- [structure.md](.archive/structure.md) — Устарело, см. [DEVELOPER.md](DEVELOPER.md)

---

## 👥 Авторы

- **Разработчик**: [azazlov](https://github.com/azazlov)

---

## 📄 Лицензия

MIT License — см. файл [LICENSE](LICENSE)

---

## 📞 Контакты

- GitHub: [@azazlov](https://github.com/azazlov)
- Issues: [Сообщить о проблеме](https://github.com/azazlov/passgen/issues)
