# PassGen — Генератор паролей и система шифрования

[![Version](https://img.shields.io/badge/version-0.3.2-blue.svg)](https://github.com/azazlov/passgen/releases)
[![Flutter](https://img.shields.io/badge/flutter-^3.9.0-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20android%20%7C%20web-lightgrey.svg)](https://github.com/azazlov/passgen)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Кроссплатформенное приложение на Flutter для генерации паролей и шифрования сообщений с использованием современных криптографических методов (а также простого локального хранилища).

---

## 📸 Скриншоты

<p align="center">
  <img width="1266" height="713" alt="Страница генератора паролей" src="https://github.com/user-attachments/assets/250c4701-9b52-422e-aa9b-01ea13a7b651"/>
  <br><b>Генератор паролей</b>
</p>

<p align="center">
  <img width="1266" height="713" alt="Страница шифрования сообщений" src="https://github.com/user-attachments/assets/a14d553a-49e3-4c73-93a1-4544e29fe703"/>
  <br><b>Шифратор сообщений</b>
</p>

<p align="center">
  <img width="1266" height="713" alt="Страница хранилища конфигураций" src="https://github.com/user-attachments/assets/247888c0-3910-4f81-888e-e09cb59d2ef0"/>
  <br><b>Хранилище</b>
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
flutter run -d <устройство>  # например: linux, windows, android, chrome
```

---

## 🎯 Возможности

### Генератор паролей
- Настройка длины пароля (диапазон значений)
- Выбор категорий символов: цифры, строчные, заглавные, спецсимволы
- Обязательное включение выбранных категорий
- Оценка надёжности пароля (алгоритм zxcvbn)
- Генерация «конфига» для восстановления пароля

### Шифратор сообщений
- Шифрование/дешифрование текстовых сообщений
- Алгоритм **ChaCha20-Poly1305 (AEAD)** (пакет `cryptography`)
- Вывод: компактный **mini-format** (Base64) для копирования/обмена
- Проверка целостности: встроенная аутентификация (Poly1305 tag)

### Хранилище
- Локальное хранение записей (SharedPreferences)
- Экспорт/импорт данных (JSON)
- Удаление записей

### Дополнительно
- 4 вкладки навигации: Генератор, Шифратор, Хранилище, О программе
- Тёмная/светлая тема (системная)
- Кроссплатформенность: Windows, Linux, Android, Web

---

## 🏗️ Архитектура

Проект реализует паттерн **Clean Architecture** с разделением на три слоя:

```
lib/
├── app/                    # Точка входа, маршрутизация, DI (Provider)
├── core/                   # Утилиты, константы, ошибки
├── data/                   # Data Layer
│   ├── datasources/        # Источники данных (SharedPreferences)
│   ├── models/             # Модели данных
│   └── repositories/       # Реализации репозиториев
├── domain/                 # Domain Layer (бизнес-логика)
│   ├── entities/           # Сущности (PasswordConfig, PasswordEntry, etc.)
│   ├── repositories/       # Абстракции репозиториев
│   └── usecases/           # Сценарии использования (10+)
└── presentation/           # Presentation Layer (UI)
    ├── features/           # Экраны: generator, encryptor, storage, about
    ├── widgets/            # Переиспользуемые виджеты
    └── controllers/        # Контроллеры (ChangeNotifier)
```

### State Management
- **Provider** для управления состоянием
- **ChangeNotifier** для реактивных обновлений UI

---

## 🛠️ Технологии

| Категория | Технологии |
|-----------|------------|
| **Фреймворк** | Flutter, Dart ^3.9.0 |
| **State Management** | Provider, ChangeNotifier |
| **Локальное хранилище** | SharedPreferences |
| **Криптография** | `cryptography` (ChaCha20-Poly1305, PBKDF2, CSPRNG), `crypto` |
| **Оценка паролей** | `zxcvbn`, `password_strength` |
| **UI** | Material 3, Google Fonts |
| **Функциональное программирование** | `dartz` (Either) |
| **Работа с файлами** | `file_picker`, `share_plus`, `path_provider` |
| **Утилиты** | `uuid`, `url_launcher` |

---

## 🔐 Безопасность

### Криптографические алгоритмы
- **Шифрование**: ChaCha20-Poly1305 (AEAD)
- **Деривация ключа**: PBKDF2-HMAC-SHA256, 10 000 итераций, 256-bit ключ
- **Генерация случайных чисел**: `Random.secure()` (CSPRNG)
- **Аутентификация/целостность**: Poly1305 tag (16 bytes)

### Важно про хранение
На текущий момент сохранённые записи в «Хранилище» сохраняются **локально в SharedPreferences** в виде JSON и **не шифруются автоматически**. Шифрование используется в модуле «Шифратор» (и может применяться для шифрования конфигов генератора).

### Структура зашифрованных данных
```
Mini Format (Base64): saltNonce(32) + secretBoxNonce(12) + cipherText + mac(16)
JSON Format: { nonce, nonceBox, cipherText, mac } (Base64) — доступно на уровне data source
```

---

## 🧪 Тестирование

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test tests/generate_password_test.dart
flutter test tests/encrypted_test.dart
flutter test tests/password_strength_test.dart
flutter test tests/sqlite_test.dart
```

### Покрытие тестами
- ✅ Генерация паролей (категории, обязательность)
- ✅ Шифрование/дешифрование (ChaCha20-Poly1305, mini-format)
- ✅ Оценка надёжности паролей
- ✅ Прототип хранения в SQLite (демо/тест в `tests/sqlite_test.dart`)

---

## 📦 Сборка

```bash
# Windows
flutter build windows

# Linux
flutter build linux

# Android (APK)
flutter build apk

# Web
flutter build web
```

---

## 📥 Установка

### Windows
1. Распакуйте архив в удобное место
2. Создайте ярлык на исполняемый файл

### Linux
- **Вариант 1:** Распакуйте архив с бинарными файлами
- **Вариант 2:** Установите пакет `.rpm` (`.deb` планируется)

### Android
1. Установите `.apk` файл
2. Разрешите установку из неизвестных источников

---

## 🗺️ Roadmap

- [ ] Шифрование файлов и бинарных данных
- [ ] Кастомизация алгоритмов генерации паролей
- [ ] Корпоративные конфигурации
- [ ] Сервер для синхронизации между устройствами
- [ ] Биометрическая аутентификация
- [ ] Расширение поддержки платформ (macOS, iOS)

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

## 👥 Авторы

- **Разработчик**: [azazlov](https://github.com/azazlov)

---

## 📄 Лицензия

MIT License — см. файл [LICENSE](LICENSE)

---

## 📞 Контакты

- GitHub: [@azazlov](https://github.com/azazlov)
- Issues: [Сообщить о проблеме](https://github.com/azazlov/passgen/issues)
