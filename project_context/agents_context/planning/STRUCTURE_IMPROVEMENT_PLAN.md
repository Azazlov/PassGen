# 📋 План улучшения структуры проекта PassGen

**Дата создания:** 2026-03-08  
**Версия:** 1.0  
**Приоритет:** Высокий (для диплома и поддержки проекта)

---

## 🔍 АНАЛИЗ ТЕКУЩЕЙ СТРУКТУРЫ

### 1. ОБЩАЯ СТАТИСТИКА ПРОЕКТА

| Метрика | Значение | Оценка |
|---------|----------|--------|
| **Файлов Dart в lib/** | ~118 | ⚠️ Много |
| **Строк кода** | ~9500+ | ⚠️ Растёт |
| **Экранов** | 9 | ✅ Норма |
| **Контроллеров** | 7 | ✅ Норма |
| **Use Cases** | 25+ | ⚠️ Требует рефакторинга |
| **Widget тестов** | 29 файлов | ✅ Хорошо |
| **Unit тестов** | 25+ | ⚠️ Мало для такого кода |
| **Покрытие тестами** | ~82% | ✅ Хорошо |
| **Документов в project_context/** | 50+ | ⚠️ Избыточно |

---

## 🚨 ВЫЯВЛЕННЫЕ ПРОБЛЕМЫ

### 🔴 Критические проблемы

| # | Проблема | Файлы/Папки | Влияние | Приоритет |
|---|----------|-------------|---------|-----------|
| **1** | **Дублирование логики генерации паролей** | `lib/modules/psswd_gen_module.dart` vs `lib/data/datasources/password_generator_local_datasource.dart` | Конфликт логики, поддержка 2 реализаций | 🔴 |
| **2** | **Мёртвый код в lib/modules/** | `encryptobara.dart`, `gen_key.dart`, `rsa.dart` | Загрязнение кодовой базы, путаница | 🔴 |
| **3** | **Пустая папка diagrams/** | `project_context/diagrams/` | Отсутствие диаграмм для диплома | 🔴 |
| **4** | **Неструктурированные тесты** | `test/unit/` почти пуст, `test/usecases/` дублирует | Сложно найти тесты | 🔴 |
| **5** | **Нет интеграционных тестов** | `integration_test/` отсутствует | Нет E2E тестирования | 🔴 |

### 🟡 Средние проблемы

| # | Проблема | Файлы/Папки | Влияние | Приоритет |
|---|----------|-------------|---------|-----------|
| **6** | **Избыточная структура project_context/** | 15 папок, многие пустые или с 1 файлом | Сложная навигация | 🟡 |
| **7** | **Нет документации API** | Нет `API.md` или `CONTRACTS.md` | Сложно понимать интерфейсы | 🟡 |
| **8** | **Смешанные ответственности в Controllers** | Контроллеры содержат бизнес-логику | Нарушение Clean Architecture | 🟡 |
| **9** | **Нет разделения на фичи** | `presentation/features/` — плоская структура | Сложно масштабировать | 🟡 |
| **10** | **Отсутствует CHANGELOG.md** | Нет файла истории изменений | Сложно отслеживать версии | 🟡 |

### 🟢 Мелкие проблемы

| # | Проблема | Файлы/Папки | Влияние | Приоритет |
|---|----------|-------------|---------|-----------|
| **11** | **Нет .env.example** | Нет шаблона для переменных окружения | Сложно настроить CI/CD | 🟢 |
| **12** | **README.MD в верхнем регистре** | `README.MD` вместо `README.md` | Не соответствует конвенциям | 🟢 |
| **13** | **Нет CODE_OF_CONDUCT.md** | Отсутствует | Не критично для диплома | 🟢 |
| **14** | **Нет CONTRIBUTING.md** | Отсутствует | Не критично для диплома | 🟢 |
| **15** | **assets/icons/ без структуры** | Все иконки в одной папке | Проблема при росте | 🟢 |

---

## 📊 ДЕТАЛЬНЫЙ АНАЛИЗ ПО ПАПКАМ

### 1️⃣ `lib/` — Исходный код

#### Текущее состояние
```
lib/
├── app/              ✅ OK
├── core/             ✅ OK
├── data/             ✅ OK
├── domain/           ✅ OK
├── modules/          ❌ ПРОБЛЕМЫ (4 файла, дублирование)
├── presentation/     ⚠️ Требует рефакторинга
├── shared/           ⚠️ Можно улучшить
└── main.dart         ✅ OK
```

#### Проблемы

**`lib/modules/` — КРИТИЧЕСКИЕ ПРОБЛЕМЫ:**

| Файл | Проблема | Решение |
|------|----------|---------|
| `psswd_gen_module.dart` | Дублирует `PasswordGeneratorLocalDataSource`, использует слабый LCG вместо CSPRNG | ❌ **УДАЛИТЬ** |
| `encryptobara.dart` | Не используется, нет импортов | ❌ **УДАЛИТЬ** |
| `gen_key.dart` | Не используется, нет импортов | ❌ **УДАЛИТЬ** |
| `rsa.dart` | Не используется, RSA не применяется в проекте | ❌ **УДАЛИТЬ** |

**`lib/presentation/` — СТРУКТУРНЫЕ ПРОБЛЕМЫ:**

```
❌ ПЛОХО (текущее):
presentation/
├── features/
│   ├── auth/
│   ├── generator/
│   ├── storage/
│   ├── settings/
│   ├── categories/
│   ├── logs/
│   └── about/
└── widgets/

✅ ЛУЧШЕ:
presentation/
├── screens/           # Только экраны-контейнеры
├── widgets/           # Переиспользуемые виджеты
│   ├── common/        # Общие: AppButton, AppTextField
│   ├── password/      # PasswordCard, CopyablePassword
│   └── auth/          # PinInputWidget, PinKeyboard
├── controllers/       # Или features/ с контроллерами
└── router/            # Маршрутизация (если есть)
```

**`lib/shared/` — АРХИТЕКТУРНЫЕ ПРОБЛЕМЫ:**

| Проблема | Текущее состояние | Рекомендуемое |
|----------|-------------------|---------------|
| Функции вместо виджетов | `buildSwitch()`, `buildButton()` | Создать виджеты: `AppSwitch`, `AppButton` |
| Нет типизации | Возвращают `Widget` без спецификации | Создать специфичные виджеты |
| Сложно тестировать | Функции не изолированы | Виджеты легче тестировать |

---

### 2️⃣ `test/` — Тесты

#### Текущее состояние
```
test/
├── unit/
│   └── usecases/     ⚠️ Почти пуст
├── usecases/         ⚠️ Дублирует unit/
├── widgets/          ✅ 29 файлов
└── sqlite_test.dart  ✅ OK
```

#### Проблемы

| Проблема | Описание | Решение |
|----------|----------|---------|
| **Дублирование** | `test/unit/usecases/` и `test/usecases/` | Объединить в `test/unit/` |
| **Нет структуры** | Плоская структура в `test/unit/` | Группировать по фичам |
| **Нет integration/** | Отсутствуют E2E тесты | Создать `test/integration/` |
| **Нет mocks/** | Моки разбросаны | Создать `test/mocks/` |

#### Рекомендуемая структура
```
test/
├── unit/
│   ├── core/
│   │   ├── utils/
│   │   └── constants/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   │       ├── auth/
│   │       ├── password/
│   │       ├── storage/
│   │       └── ...
│   └── data/
│       ├── repositories/
│       └── datasources/
├── widget/
│   ├── screens/
│   └── widgets/
├── integration/
│   ├── auth_flow_test.dart
│   └── password_flow_test.dart
├── mocks/
│   ├── mock_repositories.dart
│   └── mock_usecases.dart
└── helpers/
    ├── test_fixtures.dart
    └── mocks_factory.dart
```

---

### 3️⃣ `project_context/` — Документация

#### Текущее состояние (15 папок)
```
project_context/
├── agents_context/           ⚠️ 1 файл
├── current_progress/         ✅ 1 файл (актуально)
├── data_security_specialist/ ⚠️ ?
├── design/                   ✅ Анимации
├── devops/                   ✅ Структурировано
├── devops_engineer/          ⚠️ ?
├── diagrams/                 ❌ ПУСТАЯ
├── documentation/            ✅ 3 файла
├── frontend_engineer/        ⚠️ ?
├── instructions/             ⚠️ ?
├── logs/                     ⚠️ Много файлов
├── planning/                 ✅ ТЗ, планы
├── qa_engineer/              ⚠️ ?
├── reviews/                  ⚠️ ?
└── stages/                   ✅ Отчёты
└── testing/                  ⚠️ ?
```

#### Проблемы

| Проблема | Описание | Решение |
|----------|----------|---------|
| **Избыточная структура** | 15 папок, многие с 1-2 файлами | Консолидировать в 5-7 папок |
| **Пустая diagrams/** | Нет диаграмм для диплома | Создать 5 диаграмм |
| **Нет оглавления** | Сложно ориентироваться | Создать `project_context/README.md` |
| **Дублирование** | `logs/`, `stages/`, `reviews/` могут пересекаться | Чётко разделить ответственность |

#### Рекомендуемая структура
```
project_context/
├── README.md                 # Оглавление и навигация
├── planning/                 # ПЛАНЫ (оставить)
│   ├── passgen.tz.md        # ТЗ
│   ├── COMPREHENSIVE_PLAN.md
│   └── task_plans/
├── documentation/            # ДОКУМЕНТАЦИЯ (объединить)
│   ├── architecture.md
│   ├── database.md
│   ├── api.md               # Создать
│   ├── user_guide.md
│   └── diploma/             # Для диплома
│       ├── chapter1.md
│       ├── chapter2.md
│       └── chapter3.md
├── diagrams/                 # ДИАГРАММЫ (создать)
│   ├── use_case.drawio
│   ├── sequence_*.drawio
│   ├── component.drawio
│   ├── er_diagram.drawio
│   └── deployment.drawio
├── devops/                   # DEVOPS (оставить)
│   ├── ci_cd/
│   ├── scripts/
│   └── docs/
├── testing/                  # ТЕСТИРОВАНИЕ (объединить)
│   ├── test_plans/
│   ├── test_cases/
│   └── reports/
└── logs/                     # ЛОГИ (объединить)
    ├── development/
    ├── stages/
    └── reviews/
```

---

### 4️⃣ `assets/` — Ресурсы

#### Текущее состояние
```
assets/
└── icons/
    ├── app_icon_1024.png
    ├── app_icon_fg_1024.png
    ├── passgen_icon.svg
    ├── passgen_icon_fg.svg
    └── generate_icons.sh
```

#### Проблемы

| Проблема | Решение |
|----------|---------|
| Все иконки в одной папке | Создать подпапки по типу/размеру |
| Нет favicon для web | Добавить `favicon.png` |
| Нет иконок для уведомлений | Добавить `notification_icon.png` |

#### Рекомендуемая структура
```
assets/
├── icons/
│   ├── app/
│   │   ├── app_icon_1024.png
│   │   └── app_icon_fg_1024.png
│   ├── svg/
│   │   ├── passgen_icon.svg
│   │   └── passgen_icon_fg.svg
│   └── web/
│       └── favicon.png
├── images/
│   └── screenshots/
├── animations/
│   ├── copy_success.json
│   ├── pin_error.json
│   └── strength_pulse.json
└── fonts/
    └── (кастомные шрифты)
```

---

### 5️⃣ Корневые файлы

#### Текущее состояние
```
/
├── .gitignore              ✅ OK
├── .metadata               ⚠️ Можно в .gitignore
├── analysis_options.yaml   ✅ OK
├── COMPREHENSIVE_TASK_PLAN.md ✅ OK
├── devtools_options.yaml   ⚠️ Можно в .gitignore
├── LICENSE                 ✅ OK
├── pass_gen.drawio         ⚠️ Переместить в diagrams/
├── pubspec.lock            ✅ OK
├── pubspec.yaml            ✅ OK
├── QWEN.md                 ⚠️ Специфично для ИИ
├── README.MD               ⚠️ Переименовать в README.md
└── structure.md            ⚠️ Переместить в docs/
```

#### Проблемы

| Файл | Проблема | Решение |
|------|----------|---------|
| `README.MD` | Верхний регистр | Переименовать в `README.md` |
| `.metadata` | Генерируется Flutter | Добавить в `.gitignore` |
| `devtools_options.yaml` | Локальная настройка | Добавить в `.gitignore` |
| `pass_gen.drawio` | Не в той папке | Переместить в `project_context/diagrams/` |
| `QWEN.md` | Специфично для ИИ | Переместить в `.qwen/` |
| `structure.md` | Устарел | Обновить или удалить |

---

## 📋 ПЛАН УЛУЧШЕНИЙ

### ЭТАП 1: Критические исправления (1-2 дня)

#### 1.1 Очистка `lib/modules/`
```bash
# Удалить мёртвый код
rm lib/modules/encryptobara.dart
rm lib/modules/gen_key.dart
rm lib/modules/rsa.dart
rm lib/modules/psswd_gen_module.dart

# Обновить .gitignore
echo "lib/modules/" >> .gitignore
# Или удалить папку полностью
rmdir lib/modules
```

**Файлы для проверки перед удалением:**
- [ ] Проверить импорты `psswd_gen_module.dart` в коде
- [ ] Убедиться что используется `PasswordGeneratorLocalDataSource`
- [ ] Запустить тесты после удаления

#### 1.2 Рефакторинг тестов
```bash
# Создать новую структуру
mkdir -p test/unit/domain/usecases/{auth,password,storage,category,settings,log}
mkdir -p test/unit/data/{repositories,datasources}
mkdir -p test/unit/core/{utils,constants}
mkdir -p test/mocks
mkdir -p test/helpers
mkdir -p test/integration

# Переместить файлы
mv test/usecases/* test/unit/domain/usecases/
rmdir test/usecases
```

#### 1.3 Создание диаграмм
```bash
# Создать 5 диаграмм для диплома
touch project_context/diagrams/use_case_diagram.drawio
touch project_context/diagrams/sequence_auth.drawio
touch project_context/diagrams/sequence_password_generation.drawio
touch project_context/diagrams/component_diagram.drawio
touch project_context/diagrams/er_diagram.drawio
touch project_context/diagrams/deployment_diagram.drawio
```

**Содержание диаграмм:**

| Диаграмма | Инструмент | Содержание |
|-----------|------------|------------|
| **Use Case** | Draw.io / PlantUML | 15+ сценариев использования |
| **Sequence (Auth)** | Draw.io | PIN ввод → проверка → доступ |
| **Sequence (Password)** | Draw.io | Генерация → оценка → сохранение |
| **Component** | Draw.io | 5 слоёв Clean Architecture |
| **ER** | Draw.io | 5 таблиц БД со связями |
| **Deployment** | Draw.io | Android/Desktop → SQLite |

---

### ЭТАП 2: Рефакторинг кода (3-5 дней)

#### 2.1 Рефакторинг `lib/presentation/`

**Шаг 1: Создать структуру**
```bash
cd lib/presentation

# Создать новую структуру
mkdir -p screens
mkdir -p widgets/common
mkdir -p widgets/password
mkdir -p widgets/auth
mkdir -p router

# Переместить features в screens
mv features/auth screens/
mv features/generator screens/
mv features/storage screens/
mv features/settings screens/
mv features/categories screens/
mv features/logs screens/
mv features/about screens/
mv features/encryptor screens/
```

**Шаг 2: Обновить импорты**
```dart
// Было:
import 'package:pass_gen/presentation/features/auth/auth_screen.dart';

// Стало:
import 'package:pass_gen/presentation/screens/auth/auth_screen.dart';
```

#### 2.2 Рефакторинг `lib/shared/`

**Задача:** Преобразовать функции в виджеты

```dart
// БЫЛО: lib/shared/dialog.dart
Widget buildSwitch(String label, bool value, bool isUsed, IconData icon) {
  return SwitchListTile(...);
}

// СТАЛО: lib/shared/widgets/app_switch.dart
class AppSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool isUsed;
  final IconData icon;
  
  const AppSwitch({
    required this.label,
    required this.value,
    required this.isUsed,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(...);
  }
}
```

---

### ЭТАП 3: Реорганизация документации (2-3 дня)

#### 3.1 Консолидация `project_context/`

```bash
cd project_context

# Создать README.md с оглавлением
touch README.md

# Объединить папки
mv agents_context instructions -t logs/development/ 2>/dev/null || true
mv data_security_specialist qa_engineer frontend_engineer devops_engineer -t reviews/ 2>/dev/null || true

# Создать структуру для диплома
mkdir -p documentation/diploma/chapters
mkdir -p documentation/diploma/figures
mkdir -p documentation/diploma/tables

# Переместить диаграмму
mv ../pass_gen.drawio diagrams/
```

#### 3.2 Создать `project_context/README.md`

```markdown
# 📚 Project Context — Навигация по документации

## 🎯 Быстрые ссылки

| Документ | Описание | Статус |
|----------|----------|--------|
| [ТЗ](planning/passgen.tz.md) | Техническое задание v2.0 | ✅ Утверждено |
| [План работ](../COMPREHENSIVE_TASK_PLAN.md) | Сводный план | ✅ Актуально |
| [Архитектура](documentation/technical/architecture.md) | Clean Architecture | ✅ |
| [База данных](documentation/technical/database.md) | Схема БД | ✅ |

## 📁 Структура папок

```
project_context/
├── planning/          # ТЗ, планы задач
├── documentation/     # Техническая документация
├── diagrams/          # Диаграммы UML, ER
├── devops/           # CI/CD, скрипты
├── testing/          # Тест-планы, кейсы
└── logs/             # Логи, отчёты
```

## 🎓 Для диплома

- [Глава 1: Анализ](documentation/diploma/chapter1.md)
- [Глава 2: Технологии](documentation/diploma/chapter2.md)
- [Глава 3: Разработка](documentation/diploma/chapter3.md)
- [Диаграммы](diagrams/)
```

---

### ЭТАП 4: Улучшение корневых файлов (1 день)

#### 4.1 Переименование и перемещение

```bash
# Переименовать README.MD
mv README.MD README.md

# Переместить pass_gen.drawio
mv pass_gen.drawio project_context/diagrams/

# Переместить QWEN.md
mv QWEN.md .qwen/

# Обновить .gitignore
echo ".metadata" >> .gitignore
echo "devtools_options.yaml" >> .gitignore
echo "structure.md" >> .gitignore
```

#### 4.2 Создать недостающие файлы

**`CHANGELOG.md`:**
```markdown
# Changelog

## [0.5.0] - 2026-03-08

### Added
- Категоризация паролей
- Логирование событий безопасности
- Автоблокировка по неактивности
- Экспорт/импорт в формате .passgen

### Changed
- Миграция на SQLite
- Обновлён UI хранилища

### Fixed
- Исправлены ошибки копирования в буфер
```

**`CONTRIBUTING.md`:**
```markdown
# Contributing to PassGen

## Как внести вклад

1. Fork репозиторий
2. Создай ветку (`git checkout -b feature/AmazingFeature`)
3. Закоммить изменения (`git commit -m 'Add AmazingFeature'`)
4. Push в ветку (`git push origin feature/AmazingFeature`)
5. Открой Pull Request
```

**`.env.example`:**
```bash
# Telegram Bot Token (для уведомлений CI/CD)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# Slack Webhook (опционально)
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
```

---

### ЭТАП 5: Финальная проверка (1 день)

#### 5.1 Чек-лист перед коммитом

- [ ] Все тесты проходят (`flutter test`)
- [ ] Анализ без ошибок (`flutter analyze`)
- [ ] Сборка работает (`flutter build linux`)
- [ ] Документация обновлена
- [ ] CHANGELOG.md заполнен
- [ ] Диаграммы созданы (5 шт)
- [ ] Мёртвый код удалён
- [ ] Импорты обновлены

#### 5.2 Коммит структуры

```bash
git add -A
git commit -m "refactor: масштабный рефакторинг структуры проекта

- Удалён мёртвый код из lib/modules/
- Реорганизованы тесты (test/unit/, test/integration/)
- Улучшена структура presentation/ (screens/, widgets/)
- Созданы диаграммы для диплома (5 шт)
- Обновлена документация project_context/
- Добавлены CHANGELOG.md, CONTRIBUTING.md
- Исправлены имена файлов (README.md)

BREAKING CHANGE: изменены пути импортов presentation/features/ → presentation/screens/"
```

---

## 📊 ОЖИДАЕМЫЕ РЕЗУЛЬТАТЫ

### До улучшений

| Метрика | Значение |
|---------|----------|
| **Папок в lib/** | 7 (с проблемами) |
| **Мёртвых файлов** | 4+ |
| **Структура тестов** | Запутанная |
| **Диаграмм** | 0 |
| **Документов для диплома** | Частично |

### После улучшений

| Метрика | Значение |
|---------|----------|
| **Папок в lib/** | 6 (оптимизировано) |
| **Мёртвых файлов** | 0 |
| **Структура тестов** | Чёткая (unit/widget/integration) |
| **Диаграмм** | 6 |
| **Документов для диплома** | Полностью готово |

---

## 🎯 ПРИОРИТЕТЫ ДЛЯ ДИПЛОМА

### Обязательно (для защиты)

1. ✅ **5 диаграмм** (Use Case, Sequence x2, Component, ER, Deployment)
2. ✅ **Главы диплома** в `documentation/diploma/`
3. ✅ **Тесты** (покрытие ≥50%)
4. ✅ **Рабочий прототип** (сборка без ошибок)

### Желательно (для высокой оценки)

1. ⚠️ **Чистая архитектура** (без мёртвого кода)
2. ⚠️ **Документация API**
3. ⚠️ **Integration тесты**
4. ⚠️ **CI/CD pipeline**

---

## 📅 ВРЕМЕННАЯ ШКАЛА

| Этап | Длительность | Даты | Статус |
|------|--------------|------|--------|
| **1. Критические исправления** | 1-2 дня | 2026-03-08 — 03-09 | ⏳ |
| **2. Рефакторинг кода** | 3-5 дней | 2026-03-09 — 03-12 | ⬜ |
| **3. Реорганизация документации** | 2-3 дня | 2026-03-12 — 03-14 | ⬜ |
| **4. Улучшение корневых файлов** | 1 день | 2026-03-14 | ⬜ |
| **5. Финальная проверка** | 1 день | 2026-03-15 | ⬜ |

**Общая длительность:** 8-12 дней

---

## 🛠️ ИНСТРУМЕНТЫ

### Для рефакторинга
```bash
# Найти все импорты modules/
grep -r "modules/" lib/ --include="*.dart"

# Найти все импорты features/
grep -r "features/" lib/ --include="*.dart"

# Проверить unused файлы
dart pub global activate dart_code_metrics
dart pub global run dart_code_metrics:metrics check-unused-files lib/
```

### Для диаграмм
- **Draw.io** — десктопное приложение
- **PlantUML** — текстовое описание
- **Mermaid** — в Markdown

### Для анализа кода
```bash
flutter analyze
dart analyze
dart pub global run dart_code_metrics:metrics .
```

---

## ✅ ЧЕК-ЛИСТ ЗАВЕРШЕНИЯ

### Код
- [ ] `lib/modules/` удалена
- [ ] `lib/presentation/` рефакторена
- [ ] `lib/shared/` преобразован в виджеты
- [ ] Все импорты обновлены
- [ ] Тесты проходят

### Тесты
- [ ] `test/unit/` структурированы
- [ ] `test/integration/` созданы
- [ ] `test/mocks/` созданы
- [ ] Покрытие ≥50%

### Документация
- [ ] `project_context/README.md` создан
- [ ] `diagrams/` заполнена (6 файлов)
- [ ] `documentation/diploma/` создана
- [ ] `CHANGELOG.md` создан
- [ ] `CONTRIBUTING.md` создан

### Корневые файлы
- [ ] `README.md` переименован
- [ ] `.gitignore` обновлён
- [ ] `.env.example` создан

### Для диплома
- [ ] 5 диаграмм готовы
- [ ] 3 главы написаны
- [ ] Тесты пройдены
- [ ] Сборка работает

---

**План создал:** AI Frontend Developer  
**Дата:** 2026-03-08  
**Версия:** 1.0  
**Статус:** ⏳ Ожидает утверждения
