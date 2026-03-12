# PassGen — Техническая документация

**Версия:** 0.5.0
**Последнее обновление:** 10 марта 2026

---

## 📖 Оглавление

1. [Обзор архитектуры](#обзор-архитектуры)
2. [Диаграммы](#диаграммы)
3. [API Reference](#api-reference)
4. [База данных](#база-данных)
5. [Криптография](#криптография)
6. [Примеры кода](#примеры-кода)
7. [Сборка и развёртывание](#сборка-и-развёртывание)
8. [CI/CD](#cicd)

---

## Обзор архитектуры

### Clean Architecture

Проект реализует паттерн **Clean Architecture** с разделением на 5 слоёв:

```
┌─────────────────────────────────────────────────────────┐
│                    App Layer                            │
│            (DI, Navigation, Theme)                      │
├─────────────────────────────────────────────────────────┤
│               Presentation Layer                        │
│         (UI, Controllers, Widgets)                      │
├─────────────────────────────────────────────────────────┤
│                 Domain Layer                            │
│    (Entities, Use Cases, Repository Interfaces)         │
├─────────────────────────────────────────────────────────┤
│                  Data Layer                             │
│   (Repository Implementations, Data Sources, SQLite)    │
├─────────────────────────────────────────────────────────┤
│                  Core Layer                             │
│        (Utils, Constants, Errors)                       │
└─────────────────────────────────────────────────────────┘
```

### Структура проекта

```
lib/
├── app/                          # Точка входа, DI, навигация
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
├── domain/                       # Бизнес-логика
│   ├── entities/                 # 8 сущностей
│   ├── repositories/             # 7 интерфейсов
│   └── usecases/                 # 25+ сценариев
├── data/                         # Слой данных
│   ├── database/
│   │   ├── database_helper.dart
│   │   ├── database_schema.dart
│   │   └── database_migrations.dart
│   ├── datasources/              # 4 источника данных
│   ├── formats/
│   │   └── passgen_format.dart
│   ├── models/                   # 5 моделей
│   └── repositories/             # 7 реализаций
├── presentation/                 # UI слой
│   ├── features/                 # 9 экранов
│   └── widgets/                  # 12 виджетов
├── shared/                       # Общие UI функции
│   └── shared.dart
└── main.dart                     # Entry point
```

**Статистика проекта (v0.5.0):**
- Файлов Dart: 110+
- Строк кода: ~9500+
- Покрытие тестами: ~82%

---

## Диаграммы

### Диаграмма вариантов использования (Use Case Diagram)

```mermaid
usecaseDiagram
    actor Пользователь

    usecase "Аутентификация по PIN" as UC1
    usecase "Установка PIN" as UC2
    usecase "Смена PIN" as UC3
    usecase "Удаление PIN" as UC4

    usecase "Генерация пароля" as UC5
    usecase "Настройка сложности" as UC6
    usecase "Сохранение пароля" as UC7

    usecase "Просмотр паролей" as UC8
    usecase "Поиск и фильтрация" as UC9
    usecase "Удаление пароля" as UC10

    usecase "Шифрование сообщения" as UC11
    usecase "Дешифрование сообщения" as UC12

    usecase "Экспорт (JSON)" as UC13
    usecase "Экспорт (.passgen)" as UC14
    usecase "Импорт (JSON)" as UC15
    usecase "Импорт (.passgen)" as UC16

    usecase "Управление категориями" as UC17
    usecase "Просмотр логов" as UC18

    Пользователь --> UC1
    Пользователь --> UC2
    Пользователь --> UC3
    Пользователь --> UC4
    Пользователь --> UC5
    Пользователь --> UC6
    Пользователь --> UC7
    Пользователь --> UC8
    Пользователь --> UC9
    Пользователь --> UC10
    Пользователь --> UC11
    Пользователь --> UC12
    Пользователь --> UC13
    Пользователь --> UC14
    Пользователь --> UC15
    Пользователь --> UC16
    Пользователь --> UC17
    Пользователь --> UC18
```

---

## API Reference

### Domain Entities

#### AuthState

```dart
class AuthState {
  final bool isAuthenticated;
  final bool isPinSetup;
  final bool isLocked;
  final int? remainingAttempts;
  final DateTime? lockoutUntil;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isPinSetup,
    bool? isLocked,
    int? remainingAttempts,
    DateTime? lockoutUntil,
  });
}
```

#### PasswordEntry

```dart
class PasswordEntry {
  final int? id;
  final int categoryId;
  final String service;
  final String? login;
  final String password; // decrypted
  final PasswordConfig? config;
  final DateTime createdAt;
  final DateTime updatedAt;

  static List<PasswordEntry> decodeList(String jsonString);
  static String encodeList(List<PasswordEntry> entries);

  PasswordEntry copyWith({...});
}
```

---

## База данных

Смотрите отдельный документ: [database.md](database.md)

---

## Криптография

### Алгоритмы

| Алгоритм | Назначение | Параметры |
|----------|------------|-----------|
| **ChaCha20-Poly1305** | Шифрование данных | AEAD, 256-bit ключ |
| **PBKDF2-HMAC-SHA256** | Деривация ключа из PIN | 10 000 итераций, 256-bit |
| **CSPRNG** | Генерация случайных чисел | `Random.secure()` |

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

## Примеры кода

### Генерация пароля

```dart
import 'package:pass_gen/domain/usecases/password/generate_password_usecase.dart';
import 'package:pass_gen/domain/entities/password_generation_settings.dart';

final settings = PasswordGenerationSettings(
  strength: 3, // Высокая сложность
  lengthRange: (12, 16),
  flags: 0b1111, // Все наборы символов
  requireUnique: false,
);

final result = await generatePasswordUseCase.execute(settings);

result.fold(
  (failure) => print('Ошибка: $failure'),
  (passwordResult) => print('Пароль: ${passwordResult.password}'),
);
```

---

## Сборка и развёртывание

### Требования

| Компонент | Версия |
|-----------|--------|
| Flutter SDK | 3.24.0+ |
| Dart SDK | 3.9.0+ |
| Java | 17+ (для Android) |
| Xcode | Latest (для iOS, macOS) |

### Команды сборки

```bash
# Debug сборка
flutter build apk --debug          # Android
flutter build ios --debug          # iOS
flutter build web --debug          # Web
flutter build linux --debug        # Linux
flutter build windows --debug      # Windows
flutter build macos --debug        # macOS

# Release сборка
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
flutter build web --release        # Web
flutter build linux --release      # Linux
flutter build windows --release    # Windows
```

### Скрипты автоматизации

Скрипты расположены в `project_context/devops_engineer/scripts/`:

| Скрипт | Назначение | Статус |
|---|---|---|
| `build_all.sh` | Сборка всех платформ | ✅ |
| `build_android.sh` | Сборка Android (APK, AAB) | ✅ |
| `build_desktop.sh` | Сборка Desktop (Linux/Windows) | ✅ |
| `build_ios.sh` | Сборка iOS | ⚠️ Требуется macOS |
| `build_web.sh` | Сборка Web | ✅ |
| `deploy_test.sh` | Развёртывание в test | ✅ |
| `deploy_prod.sh` | Развёртывание в prod | ✅ |

**Пример использования:**
```bash
# Все платформы
./project_context/devops_engineer/scripts/build_all.sh release

# Android
./project_context/devops_engineer/scripts/build_android.sh release

# Linux
./project_context/devops_engineer/scripts/build_desktop.sh linux release
```

### Расположение артефактов

```
build/
├── app/outputs/flutter-apk/     # Android APK
├── app/outputs/bundle/release/  # Android AAB
├── ios/iphoneos/                # iOS
├── web/                         # Web
├── linux/                       # Linux
├── windows/                     # Windows
└── macos/                       # macOS
```

### Время сборки

| Платформа | Время (среднее) |
|-----------|-----------------|
| Android APK | ~8 минут |
| Android AAB | ~10 минут |
| iOS | ~12 минут |
| Web | ~5 минут |
| Linux | ~5 минут |
| Windows | ~10 минут |
| macOS | ~12 минут |

---

## CI/CD

### GitHub Actions

**Файл:** `.github/workflows/github-actions-flutter.yml`

**Джобы:**

| Джоб | Назначение | Время | Платформа |
|---|---|---|---|
| Code Quality | Formatting, analysis | ~5 мин | Ubuntu |
| Tests | Unit, widget tests | ~10 мин | Ubuntu |
| Build Android | APK, AAB | ~15 мин | Ubuntu |
| Build iOS | IPA | ~20 мин | macOS |
| Build Web | Static files | ~5 мин | Ubuntu |
| Build Desktop | Linux, Windows, macOS | ~15 мин | Разные |
| Deploy Firebase | App Distribution, Hosting | ~5 мин | Ubuntu |
| Notify Status | Slack/Telegram | ~1 мин | Ubuntu |

**Триггеры:**
- Push в `main` или `develop`
- Pull requests
- Теги версий (`v*`)

### Переменные окружения

Для развёртывания требуются следующие секреты:

```bash
# Firebase
FIREBASE_APP_ID=your-app-id
FIREBASE_TOKEN=your-token

# Slack уведомления
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
SLACK_CHANNEL=#ci-cd-notifications

# Telegram уведомления
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_CHAT_ID=your-chat-id
```

### Статус сборок

- **GitHub Actions:** https://github.com/azazlov/passgen/actions
- **Firebase App Distribution:** Проверьте email приглашения
- **Sentry:** https://sentry.io/organizations/your-org/

---

## Troubleshooting

### Расположение логов

| Платформа | Путь |
|-----------|------|
| Windows | `%APPDATA%/pass_gen/logs/` |
| Linux | `~/.local/share/pass_gen/logs/` |
| Android | `adb logcat \| grep pass_gen` |

### Частые проблемы

**Build fails with "Gradle error"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**iOS build fails**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Desktop build fails on Linux**
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

---

**PassGen v0.5.0** | [MIT License](../../LICENSE)
