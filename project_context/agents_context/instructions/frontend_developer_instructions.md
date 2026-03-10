# 🤖 Frontend Developer AI Agent — PassGen

**Версия:** 1.0  
**Дата:** 2026-03-08  
**Статус:** ✅ Актуально  

---

## 1. ОБЗОР

Эта инструкция предназначена для ИИ-агента Frontend Developer в проекте PassGen — кроссплатформенного менеджера паролей на Flutter.

### Проект
- **Название:** PassGen
- **Версия:** 0.5.0
- **Фреймворк:** Flutter ^3.9.0
- **Архитектура:** Clean Architecture
- **State Management:** Provider + ChangeNotifier

---

## 2. ОБЛАСТЬ ОТВЕТСТВЕННОСТИ

Frontend Developer отвечает за **4 критических компонента**:

### 2.1 Данные и безопасность (Data & Security) 🔐
- **Аутентификация:** PIN-код, PBKDF2, защита от подбора
- **Хранение данных:** SQLite (5 таблиц, CRUD, миграции)
- **Шифрование:** ChaCha20-Poly1305, CSPRNG
- **Экспорт/Импорт:** JSON, .passgen формат

**Файлы:**
```
lib/data/
├── database/
│   ├── database_helper.dart
│   ├── database_schema.dart
│   └── database_migrations.dart
├── datasources/
│   ├── auth_local_datasource.dart
│   ├── encryptor_local_datasource.dart
│   └── storage_local_datasource.dart
└── formats/
    └── passgen_format.dart
```

**Ключевые файлы для проверки:**
- `lib/core/constants/event_types.dart` — типы событий
- `lib/core/utils/crypto_utils.dart` — утилиты шифрования

---

### 2.2 Тестирование (QA & Testing) 🧪
- **Widget-тесты:** UI компоненты
- **Unit-тесты:** Use Cases, бизнес-логика
- **Integration-тесты:** Ключевые сценарии
- **Ручное тестирование:** Тест-кейсы

**Файлы:**
```
test/
├── usecases/
│   ├── auth/
│   ├── password/
│   ├── storage/
│   ├── category/
│   └── settings/
├── widgets/
│   └── screens/
└── integration/
```

**Целевые метрики:**
- Покрытие кода: ≥50%
- Pass rate: ≥95%
- Количество тестов: 50+

---

### 2.3 Сборка и развёртывание (Build & Deploy) 🏗️
- **Локальная сборка:** Linux, Windows, Android, Web
- **Скрипты:** Bash + PowerShell
- **Документация:** DEPLOYMENT_GUIDE.md
- **CI/CD:** GitHub Actions (опционально)

**Файлы:**
```
project_context/devops/
├── scripts/
│   ├── build_all.sh
│   ├── build_android.sh
│   ├── build_desktop.sh
│   └── *.ps1 (PowerShell)
├── docs/
│   ├── BUILD_AND_DEPLOY_STRATEGY.md
│   ├── TASK_PLAN_BUILD.md
│   └── DEPLOYMENT_GUIDE.md
└── logs/
```

**Команды сборки:**
```bash
# Все платформы
./project_context/devops/scripts/build_all.sh release

# Android
./project_context/devops/scripts/build_android.sh release

# Linux
./project_context/devops/scripts/build_desktop.sh linux release
```

---

### 2.4 Frontend Development (UI/UX) 🎨
- **Экраны:** 9 экранов (Auth, Generator, Storage, etc.)
- **Виджеты:** Переиспользуемые компоненты
- **Дизайн-система:** Material 3, темы, адаптивность
- **Анимации:** Page transitions, micro-interactions

**Файлы:**
```
lib/presentation/
├── features/
│   ├── auth/
│   ├── generator/
│   ├── storage/
│   ├── settings/
│   └── ...
└── widgets/
    ├── app_button.dart
    ├── app_dialogs.dart
    └── copyable_password.dart
```

**Дизайн-система:**
- Цветовая схема: Blue (#2196F3)
- Типографика: Google Fonts Lato
- Spacing: 8dp grid (4, 8, 16, 24, 32, 48dp)
- Breakpoints: 600/900/1200dp

---

## 3. СТРУКТУРА PROJECT_CONTEXT

```
project_context/
├── current_progress/     # CURRENT_PROGRESS.md — состояние проекта
├── design/               # Дизайн-макеты, гайдлайны
│   ├── for_development/  # Для frontend разработчика
│   └── animations/       # Lottie файлы
├── development/
│   └── flutter/          # Frontend разработка
│       ├── lib/
│       ├── test/
│       ├── reports/
│       └── docs/
├── devops/               # Сборка и развёртывание
│   ├── scripts/
│   ├── docs/
│   └── logs/
├── diagrams/             # Диаграммы для диплома
├── documentation/        # Документация проекта
├── instructions/         # Инструкции для ИИ-агентов
├── logs/                 # Логи операций
├── planning/             # Планы и ТЗ
│   ├── WORK_PLAN.md      # Основной план
│   ├── TASK_PLAN_8.md    # Критические исправления
│   └── passgen.tz.md     # Техническое задание
├── reviews/              # Код-ревью, аудиты
├── stages/               # Отчёты по этапам
└── testing/              # Тестирование
    ├── TEST_STRATEGY.md
    ├── TASK_PLAN_TESTING.md
    └── MANUAL_TEST_CASES.md
```

---

## 4. ИНСТРУКЦИИ ПО ВЫПОЛНЕНИЮ ЗАДАЧ

### 4.1 Перед началом работы

```bash
# 1. Проверь текущий прогресс
cat project_context/current_progress/CURRENT_PROGRESS.md

# 2. Ознакомься с планом
cat project_context/planning/WORK_PLAN.md

# 3. Проверь ТЗ
cat project_context/planning/passgen.tz.md
```

---

### 4.2 При выполнении задачи

#### Шаг 1: Создай план задачи
```bash
# Создай файл плана
touch project_context/planning/TASK_PLAN_$(date +%Y-%m-%d).md
```

**Структура плана:**
```markdown
# 📋 План задач: [Название]

**Дата:** YYYY-MM-DD
**Приоритет:** 🔴/🟡/🟢

## Задачи
- [ ] Задача 1
- [ ] Задача 2

## Критерии успеха
- [ ] Все задачи выполнены
```

#### Шаг 2: Выполни задачу
```dart
// [Выполнение задачи в коде]
```

#### Шаг 3: За логируй результат
```bash
# Создай лог
cat > project_context/logs/LOG_$(date +%Y-%m-%d)_TASK.md << EOF
# 📝 Лог: [Тема]

**Дата:** $(date +%Y-%m-%d)

## Хронология

### $(date +%H:%M)
- Действие
- Результат

## Итоги
[Итог]
EOF
```

---

### 4.3 После завершения задачи

#### Шаг 1: Обнови прогресс
```bash
# Обнови CURRENT_PROGRESS.md
# Добавь информацию о завершённой задаче
```

#### Шаг 2: Создай отчёт об этапе
```bash
# Создай отчёт
cat > project_context/stages/STAGE_N_COMPLETE.md << EOF
# 📋 Отчёт о завершении Этапа N: [Название]

**Дата завершения:** $(date +%Y-%m-%d)
**Статус:** ✅ ЗАВЕРШЕНО

## 1. Реализовано
[Список]

## 2. Файлы
[Список файлов]

## 3. Проверка
[Результаты]

## 4. Выводы
[Готовность %]
EOF
```

#### Шаг 3: Проведи ревью
```bash
# Создай ревью
cat > project_context/reviews/CODE_REVIEW_$(date +%Y-%m-%d).md << EOF
# 🔍 Код-ревью [Компонент]

**Дата:** $(date +%Y-%m-%d)

## 1. Файлы
[Таблица]

## 2. Проблемы
[Список]

## 3. Оценка
[Процент]
EOF
```

---

## 5. СПИСОК ЗАДАЧ ПО ОБЛАСТЯМ

### 5.1 Data & Security (Приоритет 🔴)

| Задача | Файлы | Статус |
|---|---|---|
| Логирование PWD_ACCESSED | `event_types.dart`, `storage_controller.dart` | ⏳ |
| Логирование SETTINGS_CHG | `event_types.dart`, `settings_controller.dart` | ⏳ |
| Миграция auth на SQLite | `auth_local_datasource.dart` | ⬜ |
| Реализация миграций БД | `database_migrations.dart` | ⬜ |
| Unit-тесты для Use Cases | `test/usecases/` | ⬜ |

---

### 5.2 Testing (Приоритет 🔴)

| Задача | Файлы | Статус |
|---|---|---|
| Fix CharacterSetDisplay | `test/widgets/character_set_display_test.dart` | ⏳ |
| Fix CopyablePassword timeout | `test/widgets/copyable_password_test.dart` | ⏳ |
| Auth Use Cases тесты | `test/usecases/auth/` (5 файлов) | ⬜ |
| Widget-тесты экранов | `test/widgets/screens/` (3 файла) | ⬜ |
| Integration-тесты | `integration_test/` (2 файла) | ⬜ |

---

### 5.3 Build & Deploy (Приоритет 🟡)

| Задача | Файлы | Статус |
|---|---|---|
| Тест build_android.sh | `devops/scripts/build_android.sh` | ⏳ |
| Тест build_desktop.sh | `devops/scripts/build_desktop.sh` | ⏳ |
| build_android.ps1 | `devops/scripts/build_android.ps1` | ⬜ |
| build_desktop.ps1 | `devops/scripts/build_desktop.ps1` | ⬜ |
| DEPLOYMENT_GUIDE.md | `devops/docs/DEPLOYMENT_GUIDE.md` | ⬜ |

---

### 5.4 Frontend Development (Приоритет 🟡)

| Задача | Файлы | Статус |
|---|---|---|
| Двухпанельный макет | `storage_screen.dart` | ⬜ |
| Уникальность символов | `password_generator_local_datasource.dart` | ⬜ |
| Исключить похожие | `password_generator_local_datasource.dart` | ⬜ |
| Shimmer при загрузке | `storage_screen.dart` | ⬜ |

---

## 6. КОМАНДЫ ДЛЯ РАЗРАБОТКИ

### 6.1 Сборка и запуск
```bash
# Запуск приложения
flutter run -d linux  # или windows, android

# Сборка
flutter build linux
flutter build windows
flutter build apk

# Анализ
flutter analyze

# Форматирование
dart format lib/
```

### 6.2 Тестирование
```bash
# Запуск всех тестов
flutter test

# Запуск unit-тестов
flutter test test/usecases/

# Запуск widget-тестов
flutter test test/widgets/

# Запуск integration-тестов
flutter test integration_test/

# С покрытием
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 6.3 Генерация моков
```bash
# Для unit-тестов
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 6.4 ОБЯЗАТЕЛЬНАЯ ПРОЦЕДУРА ПРОВЕРКИ

**⚠️ ВАЖНО:** После ЛЮБЫХ исправлений в коде выполняй следующую процедуру:

### Шаг 1: Статический анализ
```bash
# Проверка на критические ошибки
flutter analyze 2>&1 | grep -E "^  error"

# Если есть ошибки — ИСПРАВЬ перед продолжением
```

**Критерий успеха:** ❌ Никаких ошибок (`error`) в выводе

### Шаг 2: Сборка приложения
```bash
# Сборка для текущей платформы
flutter build macos    # macOS
flutter build linux    # Linux
flutter build windows  # Windows
flutter build apk      # Android

# ИЛИ запуск приложения
flutter run -d macos
```

**Критерий успеха:** ✅ Сборка завершена без ошибок

### Шаг 3: Проверка ProviderNotFoundException
**Частая проблема:** Несоответствие типов в Provider

**Проверка:**
1. Все интерфейсы репозиториев должны быть импортированы
2. Регистрация провайдеров должна использовать тип интерфейса

**Пример правильной регистрации:**
```dart
// ✅ ПРАВИЛЬНО:
Provider<PasswordGeneratorRepository>(
  create: (_) => PasswordGeneratorRepositoryImpl(...),
),

// ❌ НЕПРАВИЛЬНО:
Provider(
  create: (_) => PasswordGeneratorRepositoryImpl(...),
),
```

### Шаг 4: Документирование
```bash
# Создай отчёт об исправлении
cat > project_context/frontend_engineer/reports/FIX_$(date +%Y-%m-%d).md << EOF
# 🔧 Отчёт об исправлении

**Дата:** $(date +%Y-%m-%d)
**Проблема:** [Описание]
**Решение:** [Описание]
**Файлы:** [Список]
**Проверка:**
- [x] flutter analyze — ошибок нет
- [x] flutter build — сборка успешна
EOF
```

### Чек-лист проверки
```markdown
## После любых изменений
- [ ] `flutter analyze` — 0 ошибок
- [ ] `flutter build` — сборка успешна
- [ ] Приложение запускается без исключений
- [ ] ProviderNotFoundException отсутствует
- [ ] Отчёт об исправлении создан
```

---

## 7. ШАБЛОНЫ ДОКУМЕНТОВ

### 7.1 План задачи
```markdown
# 📋 План задач: [Название]

**Дата:** YYYY-MM-DD
**Версия:** 1.0
**Приоритет:** 🔴/🟡/🟢

## Задачи
- [ ] Задача 1
- [ ] Задача 2

## Критерии успеха
- [ ] Все задачи выполнены
```

### 7.2 Отчёт об этапе
```markdown
# 📋 Отчёт о завершении Этапа N

**Дата:** YYYY-MM-DD
**Статус:** ✅ ЗАВЕРШЕНО

## Реализовано
[Список]

## Файлы
[Список]

## Проверка
[Результаты]
```

### 7.3 Лог операций
```markdown
# 📝 Лог: [Тема]

**Дата:** YYYY-MM-DD

## Хронология

### HH:MM
- Действие
- Результат

## Итоги
[Итог]
```

---

## 8. ПРОВЕРКА ПЕРЕД КОММИТОМ

### Чек-лист
```markdown
## Перед коммитом
- [ ] Код отформатирован (dart format)
- [ ] Анализ пройден (flutter analyze)
- [ ] Тесты проходят (flutter test)
- [ ] Документация обновлена
- [ ] Лог создан

## После коммита
- [ ] Push выполнен
- [ ] CURRENT_PROGRESS.md обновлён
```

---

## 9. БЫСТРЫЙ ДОСТУП К ФАЙЛАМ

### Планы
```bash
cat project_context/planning/WORK_PLAN.md
cat project_context/planning/TASK_PLAN_8.md
```

### Тестирование
```bash
cat project_context/testing/TEST_STRATEGY.md
cat project_context/testing/TASK_PLAN_TESTING.md
```

### Сборка
```bash
cat project_context/devops/docs/BUILD_AND_DEPLOY_STRATEGY.md
cat project_context/devops/docs/TASK_PLAN_BUILD.md
```

### Аудиты
```bash
cat project_context/reviews/DATA_SECURITY_AUDIT.md
cat project_context/testing/TESTING_ACCEPTANCE_REPORT.md
cat project_context/devops/docs/BUILD_ACCEPTANCE_REPORT.md
```

---

## 10. ТЕКУЩИЙ СТАТУС ПРОЕКТА

### Готовность
```
Общая готовность: ████████████████████ 100%
Соответствие ТЗ:  ██████████████████░░ ~90%
```

### Завершённые этапы
1. ✅ Аутентификация и безопасность
2. ✅ Миграция на SQLite
3. ✅ Логирование событий
4. ✅ Категоризация паролей
5. ✅ Настройки приложения
6. ✅ Формат .passgen
7. ✅ Автоблокировка по неактивности

### Следующий этап
**Этап 8:** Критические исправления ТЗ
- [ ] Логирование PWD_ACCESSED
- [ ] Логирование SETTINGS_CHG
- [ ] Уникальность символов
- [ ] Исключить похожие символы

---

## 11. КОНТАКТЫ И РЕСУРСЫ

### Документация
- [README.MD](../../README.MD) — Основная документация
- [structure.md](../../structure.md) — Описание модулей
- [passgen.tz.md](../planning/passgen.tz.md) — Техническое задание

### Репозиторий
- GitHub: https://github.com/azazlov/passgen

### Фреймворки
- Flutter: https://flutter.dev
- Provider: https://pub.dev/packages/provider
- Cryptography: https://pub.dev/packages/cryptography

---

**Документ создал:** AI Frontend Developer  
**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ✅ Актуально

**Ответственный:** AI Frontend Developer  
**Область ответственности:** Data & Security, Testing, Build & Deploy, Frontend Development
