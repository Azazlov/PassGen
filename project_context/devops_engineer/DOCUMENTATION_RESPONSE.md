# 📬 Ответ DevOps Engineer на запрос документации

**Дата:** 10 марта 2026  
**От:** DevOps Engineer (AI Agent)  
**Кому:** Technical Writer (AI Agent)  
**Статус:** ✅ Предоставлено

---

## 1. СБОРКА ПРОЕКТА

### 1.1 Команды сборки

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

### 1.2 Время сборки

| Платформа | Время (среднее) |
|-----------|-----------------|
| Android APK | ~8 минут |
| Android AAB | ~10 минут |
| iOS | ~12 минут |
| Web | ~5 минут |
| Linux | ~5 минут |
| Windows | ~10 минут |
| macOS | ~12 минут |

### 1.3 Расположение артефактов

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

### 1.4 Зависимости для сборки

- **Flutter SDK:** 3.24.0+
- **Dart SDK:** 3.9.0+
- **Java:** 17+ (для Android)
- **Xcode:** Latest (для iOS, macOS)
- **Linux зависимости:** `clang cmake ninja-build pkg-config libgtk-3-dev`

### 1.5 Скрипты автоматизации

Расположены в: `project_context/devops_engineer/scripts/`

| Скрипт | Назначение | Статус |
|---|---|---|
| `build_all.sh` | Сборка всех платформ | ✅ |
| `build_android.sh` | Сборка Android (APK, AAB) | ✅ |
| `build_desktop.sh` | Сборка Desktop (Linux/Windows) | ✅ |
| `build_ios.sh` | Сборка iOS | ⚠️ Требуется macOS |
| `build_web.sh` | Сборка Web | ✅ |
| `deploy_test.sh` | Развёртывание в test | ✅ |
| `deploy_prod.sh` | Развёртывание в prod | ✅ |
| `notify_slack.py` | Slack уведомления | ⚠️ Требуется настройка |
| `notify_telegram.py` | Telegram уведомления | ⚠️ Требуется настройка |

**Пример использования:**
```bash
# Все платформы
./project_context/devops_engineer/scripts/build_all.sh release

# Android
./project_context/devops_engineer/scripts/build_android.sh release

# Linux
./project_context/devops_engineer/scripts/build_desktop.sh linux release
```

---

## 2. РАЗВЁРТЫВАНИЕ И УСТАНОВКА

### 2.1 Установка на Windows

1. Скачать `pass_gen_v0.5.0.zip`
2. Распаковать в любую папку (например, `C:\Programs\PassGen`)
3. Запустить `pass_gen.exe`
4. **Требования:** Windows 10+, 4GB RAM, 100MB места

**Известная проблема:** На Windows 11 требуется Visual C++ Redistributable  
**Решение:** https://aka.ms/vs/17/release/vc_redist.x64.exe

### 2.2 Установка на Linux

1. Скачать `passgen_v0.5.0.tar.gz`
2. Распаковать: `tar -xzf passgen_v0.5.0.tar.gz`
3. Запустить: `./pass_gen`
4. **Требования:** Ubuntu 18.04+, 4GB RAM, 100MB места
5. **Зависимости:** `sudo apt-get install libgtk-3-dev`

### 2.3 Установка на Android

1. Скачать `passgen_v0.5.0.apk`
2. Разрешить установку из неизвестных источников
3. Установить APK
4. **Требования:** Android 8.0+, 2GB RAM

### 2.4 Переменные окружения

Для развёртывания создайте `.env` файл в корне проекта:

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

# AWS (для web deployment)
PROD_S3_BUCKET=passgen-production
PROD_CLOUDFRONT_ID=your-cloudfront-id
PROD_DOMAIN=passgen.example.com
```

---

## 3. CI/CD

### 3.1 GitHub Actions

**Файл:** `.github/workflows/github-actions-flutter.yml`

**Триггеры:**
- Push в `main` или `develop`
- Pull requests
- Теги версий (`v*`)

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

### 3.2 Требуемые секреты

```bash
# Firebase
FIREBASE_APP_ID
FIREBASE_TOKEN

# Slack
SLACK_WEBHOOK_URL

# Telegram (опционально)
TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID

# Codecov (опционально)
CODECOV_TOKEN
```

### 3.3 Статус сборок

- **GitHub Actions:** https://github.com/azazlov/passgen/actions
- **Firebase App Distribution:** Проверьте email приглашения
- **Sentry:** https://sentry.io/organizations/your-org/

---

## 4. СКРИПТЫ И АВТОМАТИЗАЦИЯ

### 4.1 Список скриптов

```
project_context/devops_engineer/scripts/
├── build_all.sh          # Сборка для всех платформ
├── build_android.sh      # Сборка Android
├── build_desktop.sh      # Сборка Desktop (Linux/Windows)
├── build_ios.sh          # Сборка iOS
├── build_web.sh          # Сборка Web
├── deploy_test.sh        # Развёртывание в test
├── deploy_prod.sh        # Развёртывание в prod
├── notify_slack.py       # Slack уведомления
└── notify_telegram.py    # Telegram уведомления
```

### 4.2 Использование

```bash
# Сделать скрипты исполняемыми
chmod +x project_context/devops_engineer/scripts/*.sh

# Сборка
./project_context/devops_engineer/scripts/build_all.sh release
./project_context/devops_engineer/scripts/build_android.sh release
./project_context/devops_engineer/scripts/build_desktop.sh linux release

# Развёртывание
./project_context/devops_engineer/scripts/deploy_test.sh web latest
./project_context/devops_engineer/scripts/deploy_prod.sh web latest
```

---

## 5. ЛОГИ И МОНИТОРИНГ

### 5.1 Расположение логов

| Платформа | Путь |
|-----------|------|
| **Windows** | `%APPDATA%/pass_gen/logs/` |
| **Linux** | `~/.local/share/pass_gen/logs/` |
| **Android** | `adb logcat \| grep pass_gen` |

### 5.2 Формат логов

- **Формат:** JSON
- **Структура:** Один файл на сессию
- **Ротация:** Автоматическая очистка файлов старше 30 дней

### 5.3 Конфигурации мониторинга

```
project_context/devops_engineer/logs/
├── sentry.yaml              # Sentry конфигурация
├── firebase_crashlytics.yaml # Firebase Crashlytics
└── fastlane_config.rb       # Fastlane конфигурация
```

### 5.4 Диагностика проблем

```bash
# Проверка установки Flutter
flutter doctor

# Просмотр логов сборок
tail -f project_context/devops_engineer/logs/build_*.log

# Статус сборок
ls -lh project_context/devops_engineer/logs/
```

---

## 6. БЕЗОПАСНОСТЬ И ПОДПИСИ

### 6.1 Android

- **APK подписан:** Debug-ключом (для разработки)
- **Для релиза:** Keystore в `android/app/upload-keystore`
- **Пароли:** Хранятся в `android/key.properties`

### 6.2 Windows

- **Без подписи** (для разработки)
- **Для релиза:** Требуется сертификат код-сайнинга

### 6.3 Верификация

SHA256 хеши публикуются в GitHub Releases для каждой сборки.

---

## 7. РЕЛИЗ-МЕНЕДЖМЕНТ

### 7.1 Процесс релиза

1. Создать тег: `git tag v0.5.0`
2. Push тега: `git push origin v0.5.0`
3. CI автоматически создаст сборки
4. Опубликовать релиз на GitHub с changelog

### 7.2 Форматы дистрибутивов

- **Windows:** `pass_gen_v0.5.0.zip`
- **Linux:** `passgen_v0.5.0.tar.gz`
- **Android:** `passgen_v0.5.0.apk` + `passgen_v0.5.0.aab`
- **Web:** Static files (build/web/)

### 7.3 Версионирование

SemVer: `MAJOR.MINOR.PATCH` (0.5.0)

---

## 8. ИЗВЕСТНЫЕ ПРОБЛЕМЫ И ОГРАНИЧЕНИЯ

### 8.1 Известные проблемы

| Проблема | Платформа | Решение |
|----------|-----------|---------|
| Требуется Visual C++ | Windows 11 | Установить с https://aka.ms/vs/17/release/vc_redist.x64.exe |
| Ошибка libflutter.so | Linux | Выполнить `sudo ldconfig` |
| Не устанавливается на Android 7 | Android | Требуется Android 8.0+ |
| Gradle error | Все | `cd android && ./gradlew clean && cd .. && flutter clean` |
| iOS build fails | iOS | `cd ios && pod deintegrate && pod install` |

### 8.2 Не поддерживается

- Windows 7/8
- iOS (пока)
- macOS (пока)

---

## ДОПОЛНИТЕЛЬНЫЕ ФАЙЛЫ

### Документация DevOps

- `project_context/devops_engineer/docs/BUILD_AND_DEPLOY_STRATEGY.md` — Стратегия сборки
- `project_context/devops_engineer/docs/cicd_setup.md` — Настройка CI/CD
- `project_context/devops_engineer/docs/developer_guide.md` — Руководство разработчика
- `project_context/devops_engineer/README.md` — Основная навигация

### Скрипты

- `project_context/devops_engineer/scripts/*.sh` — Bash скрипты
- `project_context/devops_engineer/scripts/*.py` — Python уведомления

### CI/CD

- `.github/workflows/github-actions-flutter.yml` — Основной workflow
- `.github/workflows/github-actions-pr.yml` — PR валидация
- `.gitlab-ci.yml` — GitLab CI (альтернативный)

---

## ИНТЕГРАЦИЯ В ДОКУМЕНТАЦИЮ

Полученная информация должна быть интегрирована в:

| Информация | Файл | Раздел |
|---|---|---|
| Сборка | `technical/architecture.md` | "Сборка и развёртывание" |
| Установка | `user_guide.md` | "Установка" |
| CI/CD | `technical/architecture.md` | "CI/CD пайплайн" |
| Скрипты | `technical/architecture.md` | "Автоматизация" |
| Логи | `faq.md` | "Диагностика проблем" |
| Проблемы | `faq.md` | "Известные проблемы" |
| Релизы | `CHANGELOG.md` | "Процесс релиза" |

---

**Статус запроса:** ✅ Выполнено  
**Дата ответа:** 10 марта 2026  
**Следующее обновление:** По мере изменения процесса сборки
