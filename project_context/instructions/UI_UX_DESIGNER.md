# 🎨 UI/UX Designer AI Agent — Инструкция по развёртыванию

**Версия:** 2.0
**Дата:** 8 марта 2026
**Статус:** ✅ Актуализировано (после IMPROVEMENT_PLAN_v0.6.0)
**Проект:** PassGen — Менеджер паролей

---

## 1. ОБЛАСТЬ ОТВЕТСТВЕННОСТИ

### 1.1 Роль
**UI/UX Дизайнер (ИИ-агент)** — отвечает за проектирование, дизайн и документирование пользовательского интерфейса и пользовательского опыта приложения PassGen.

### 1.2 Основные задачи
| Задача | Описание | Статус |
|---|---|---|
| **Дизайн-система** | Создание и поддержка дизайн-системы (цвета, типографика, компоненты) | ✅ v1.9.0 |
| **Прототипирование** | Создание макетов экранов (ASCII/spec/JSON) | ✅ 11 макетов |
| **Гайдлайны** | Документирование стандартов UI/UX для разработчиков | ✅ 11 разделов |
| **Анимации** | Проектирование микро-интеракций и переходов (Lottie) | ✅ 3 анимации |
| **Доступность** | Обеспечение соответствия WCAG AA | ✅ Раздел 10 |
| **Адаптивность** | Дизайн для mobile/tablet/desktop | ✅ 4 брейкпоинта |
| **Ассеты** | Создание иконок, графики, Lottie-анимаций | ✅ 7 иконок + 3 Lottie |

### 1.3 Границы ответственности
✅ **Входит в ответственность:**
- Дизайн экранов и компонентов
- Цветовые схемы и типографика (responsive)
- Анимации и переходы (Lottie JSON)
- Гайдлайны для разработчиков (JSON + MD)
- Проверка контрастности и доступности (WCAG AA)
- Empty states и error handling UI
- Two-pane layout specifications

❌ **Не входит в ответственность:**
- Написание кода (Frontend-разработчик)
- Бизнес-логика (Backend-разработчик)
- Тестирование (QA-инженер)
- Документация API (Технический писатель)

---

## 2. СТРУКТУРА ПАПОК

### 2.1 Основная директория
```
project_context/design/          # Корневая папка дизайнера
```

### 2.2 Полная структура (v1.9.0)
```
project_context/design/
├── README.md                    # 📖 Описание для разработчиков
├── changelog.md                 # 📝 История изменений дизайна (v1.0.0 - v1.9.0)
├── IMPROVEMENT_PLAN_COMPLETION_REPORT.md  # ✅ Отчёт о завершении v0.6.0
│
├── guidelines/
│   └── guidelines.md            # 📘 Полная дизайн-система (1700+ строк, 11 разделов)
│
├── for_development/             # 📦 Файлы для разработчиков (JSON)
│   ├── colors.json              # Цветовые токены (light/dark, blue scheme)
│   ├── typography.json          # Типографика (9 стилей, 3 брейкпоинта)
│   ├── components.json          # Спецификации компонентов (v1.1.0)
│   ├── breakpoints.json         # Брейкпоинты (4 значения)
│   ├── spacing.json             # Отступы (6 уровней)
│   ├── navigation.json          # Адаптивная навигация (4 типа)
│   └── storage_two_pane.json    # Двухпанельный макет
│
├── for_development/             # 🚀 Для передачи в разработку
│   └── [assets]                 # Готовые ассеты
│
├── assets/
│   └── icons/                   # 🎨 Иконки (SVG, 24x24px)
│       ├── social.svg           # Социальные сети (👥)
│       ├── finance.svg          # Финансы (🏦)
│       ├── shopping.svg         # Покупки (🛒)
│       ├── entertainment.svg    # Развлечения (🎬)
│       ├── work.svg             # Работа (💼)
│       ├── health.svg           # Здоровье (❤️)
│       └── other.svg            # Другое (📁)
│
├── animations/                  # 🎬 Анимации (Lottie JSON)
│   ├── pin_error.json           # Тряска при ошибке PIN (400ms, shake)
│   ├── copy_success.json        # Успешное копирование (200ms, scale+fade)
│   └── strength_pulse.json      # Индикатор стойкости (300ms, color transition)
│
├── prototypes/                  # 📐 Спецификации прототипов (MD)
│   ├── navigation_spec.md       # Спецификация навигации
│   ├── storage_two_pane_spec.md # Двухпанельный макет
│   ├── storage_layout_spec.md   # Макет хранилища
│   ├── animations_spec.md       # Спецификации анимаций
│   ├── error_states_spec.md     # Обработка ошибок
│   └── category_icons_spec.md   # Иконки категорий
│
├── final/                       # ✅ Финальные макеты (ASCII txt)
│   ├── navigation_mobile.txt    # Мобильная навигация
│   ├── navigation_tablet.txt    # Планшетная навигация
│   ├── navigation_desktop.txt   # Десктопная навигация
│   ├── navigation_wide.txt      # Широкоформатная навигация
│   ├── storage_mobile.txt       # Мобильное хранилище
│   ├── storage_tablet.txt       # Планшетное хранилище
│   ├── storage_desktop.txt      # Десктопное хранилище
│   ├── empty_state_storage.txt  # Нет паролей
│   ├── empty_state_search.txt   # Нет результатов поиска
│   ├── empty_state_logs.txt     # Нет событий
│   └── empty_state_categories.txt # Нет категорий
│
└── logs/                        # 📝 Логи задач
    └── [task_logs]
```

### 2.3 Связанные директории
```
project_context/
├── planning/
│   ├── passgen.tz.md            # 📋 Техническое задание (обязательно)
│   ├── WORK_PLAN.md             # 📅 План работ
│   ├── IMPROVEMENT_PLAN_v0.6.0.md # 📋 План улучшений
│   └── TASK_PLAN_N.md           # 📝 Планы задач
│
├── reviews/
│   └── UI_UX_CODE_REVIEW.md     # 🔍 Код-ревью UI/UX (71% → 98%)
│
├── current_progress/
│   └── CURRENT_PROGRESS.md      # 📊 Текущий статус проекта
│
└── instructions/
    ├── AI_AGENT_INSTRUCTIONS.md # 🤖 Общие инструкции
    ├── UI_UX_DESIGNER.md        # 🎨 Эта инструкция
    └── frontend_developer_instructions.md # 💻 Frontend
```

---

## 3. ПЕРЕД НАЧАЛОМ РАБОТЫ

### 3.1 Обязательное прочтение
```bash
# 1. Техническое задание (приоритет)
cat project_context/planning/passgen.tz.md

# 2. Текущий прогресс
cat project_context/current_progress/CURRENT_PROGRESS.md

# 3. План улучшений
cat project_context/planning/IMPROVEMENT_PLAN_v0.6.0.md

# 4. Код-ревью UI/UX
cat project_context/reviews/UI_UX_CODE_REVIEW.md

# 5. Отчёт о завершении
cat project_context/design/IMPROVEMENT_PLAN_COMPLETION_REPORT.md

# 6. Общие инструкции
cat project_context/instructions/AI_AGENT_INSTRUCTIONS.md
```

### 3.2 Чек-лист подготовки
- [ ] Прочитал `passgen.tz.md` (разделы 1-11)
- [ ] Прочитал `CURRENT_PROGRESS.md` (v0.6.0)
- [ ] Прочитал `UI_UX_CODE_REVIEW.md` (71% → 98%)
- [ ] Изучил структуру `project_context/design/` (v1.9.0)
- [ ] Понял границы ответственности
- [ ] Ознакомился с `IMPROVEMENT_PLAN_COMPLETION_REPORT.md`

---

## 4. РАБОЧИЙ ПРОЦЕСС

### 4.1 Создание нового дизайна

```mermaid
graph TD
    A[Анализ требований] --> B[Изучение ТЗ]
    B --> C[Создание спецификации MD]
    C --> D[Создание JSON для разработчиков]
    D --> E[Создание ASCII макетов]
    E --> F[Обновление гайдлайнов]
    F --> G[Обновление changelog]
    G --> H[Передача разработчикам]
```

### 4.2 Пошаговый процесс

#### Шаг 1: Анализ требований
```bash
# Изучи ТЗ
grep -A 20 "Раздел [0-9]" project_context/planning/passgen.tz.md

# Проверь текущий UI
ls lib/presentation/features/

# Проверь существующие спецификации
cat project_context/design/for_development/components.json
```

#### Шаг 2: Создание спецификации
```bash
# Создай файл спецификации
cat > project_context/design/prototypes/[name]_spec.md << EOF
# [Название] Specification
...
EOF
```

#### Шаг 3: Создание JSON для разработчиков
```bash
# Создай JSON со спецификациями
cat > project_context/design/for_development/[name].json << EOF
{
  "version": "1.0.0",
  "specifications": {...}
}
EOF
```

#### Шаг 4: Создание ASCII макетов
```bash
# Создай ASCII макет
cat > project_context/design/final/[name].txt << EOF
┌─────────────────────────────────┐
│     ASCII Mockup                │
└─────────────────────────────────┘
EOF
```

#### Шаг 5: Обновление гайдлайнов
```bash
# Обнови guidelines.md
# Добавь новый раздел
# Обнови спецификации
```

#### Шаг 6: Документирование
```bash
# Обнови changelog.md
# Запиши изменения
# Укажи версию (v1.X.0)
```

---

## 5. ИНСТРУКЦИИ ПО ЗАДАЧАМ

### 5.1 Создание дизайн-системы

**Команда:**
```
Создай дизайн-систему для PassGen
```

**Что делать:**
1. Прочитать раздел 2 ТЗ (`passgen.tz.md`)
2. Создать `guidelines/guidelines.md` (11 разделов)
3. Создать `for_development/colors.json` (blue scheme #2196F3)
4. Создать `for_development/typography.json` (responsive, 3 breakpoints)
5. Создать `for_development/components.json` (adaptive)

**Результат:**
```
✅ guidelines/guidelines.md (1700+ строк)
✅ for_development/colors.json
✅ for_development/typography.json
✅ for_development/components.json
```

---

### 5.2 Прототипирование адаптивного макета

**Команда:**
```
Создай прототип адаптивного макета для [экран]
```

**Что делать:**
1. Изучить раздел 3 ТЗ (адаптивность)
2. Создать спецификацию в `prototypes/[name]_spec.md`
3. Создать JSON в `for_development/[name].json`
4. Создать 4 ASCII макета (mobile/tablet/desktop/wide)

**Результат:**
```
✅ prototypes/[name]_spec.md
✅ for_development/[name].json
✅ final/[name]_mobile.txt
✅ final/[name]_tablet.txt
✅ final/[name]_desktop.txt
✅ final/[name]_wide.txt
```

---

### 5.3 Создание Lottie анимации

**Команда:**
```
Создай анимацию для [событие]
```

**Что делать:**
1. Описать сценарий анимации (duration, easing, stages)
2. Создать Lottie JSON (After Effects или вручную)
3. Сохранить в `animations/[event].json`
4. Добавить спецификацию в `guidelines.md` (Раздел 8)

**Результат:**
```
✅ animations/[event].json
✅ guidelines.md (Раздел 8 обновлён)
```

---

### 5.4 Обновление гайдлайнов доступности

**Команда:**
```
Обнови гайдлайны доступности
```

**Что делать:**
1. Проверить Раздел 10 в `guidelines.md`
2. Добавить Semantics требования
3. Добавить Keyboard Navigation specs
4. Добавить Touch Target requirements
5. Обновить `components.json` (accessibility section)

**Результат:**
```
✅ guidelines.md (Раздел 10: 350+ строк)
✅ components.json (accessibility section)
```

---

### 5.5 Создание Empty States

**Команда:**
```
Создай пустые состояния для [экран]
```

**Что делать:**
1. Определить тип empty state (no data, no search results, no events)
2. Создать ASCII макет с иконкой (64px), заголовком, кнопками
3. Добавить Flutter implementation example
4. Добавить в `guidelines.md` (Раздел 11.6)

**Результат:**
```
✅ final/empty_state_[name].txt
✅ guidelines.md (Раздел 11.6)
```

---

## 6. ШАБЛОНЫ ДОКУМЕНТОВ

### 6.1 Шаблон спецификации прототипа
```markdown
# 📐 [Название] Specification

**Version:** 1.0
**Date:** YYYY-MM-DD
**Task:** [Ссылка на план]
**ТЗ Section:** [Раздел]

## 1. Overview
[Описание]

## 2. Layout Types
### 2.1 Mobile (< 600dp)
[Спецификация + ASCII]

### 2.2 Tablet (600-899dp)
[Спецификация + ASCII]

### 2.3 Desktop (900-1199dp)
[Спецификация + ASCII]

## 3. Component Specifications
[Таблица компонентов]

## 4. Flutter Implementation
[Примеры кода]
```

### 6.2 Шаблон JSON для разработчиков
```json
{
  "version": "1.0.0",
  "lastUpdated": "YYYY-MM-DD",
  "description": "Описание",
  "layouts": {
    "mobile": {...},
    "tablet": {...},
    "desktop": {...}
  },
  "flutterImplementation": {
    "code": "..."
  }
}
```

### 6.3 Шаблон ASCII макета
```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [Иконка 64px]                      │
│                                                 │
│         Заголовок                               │
│                                                 │
│    Подзаголовок                                 │
│                                                 │
│          [Кнопка]                               │
│                                                 │
└─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════

ХАРАКТЕРИСТИКИ:
───────────────────────────────────────────────────
• Иконка: Icons.xxx (64px, grey[400])
• Заголовок: headlineSmall (24px)
• Подзаголовок: bodyMedium (14px)
• Кнопка: ElevatedButton.icon

═══════════════════════════════════════════════════

FLUTTER IMPLEMENTATION:
───────────────────────────────────────────────────

[Код на Dart]
```

### 6.4 Шаблон changelog
```markdown
## [1.X.0] - YYYY-MM-DD

### Added
#### [Название раздела] (ТЗ раздел X)
- [Список изменений]

**Files Added:**
- `[file_path]` — описание

**Files Modified:**
- `[file_path]` — изменения
```

---

## 7. КРИТЕРИИ КАЧЕСТВА

### 7.1 Чек-лист качества дизайна

| Критерий | Требование | Проверка |
|---|---|---|
| **Контрастность** | ≥ 4.5:1 для текста | Color contrast checker ✅ |
| **Touch targets** | ≥ 48x48px | Измерение в макете ✅ |
| **Консистентность** | Единый стиль | Сравнение с гайдлайнами ✅ |
| **Доступность** | WCAG AA, Semantics, keyboard nav | Проверка по чек-листу ✅ |
| **Адаптивность** | 4 брейкпоинта | Mobile/Tablet/Desktop/Wide ✅ |
| **Документация** | Полные гайдлайны (11 разделов) | Проверка guidelines.md ✅ |

### 7.2 Чек-лист перед передачей

- [ ] Все экраны спроектированы (ASCII макеты)
- [ ] Все компоненты документированы (JSON specs)
- [ ] Цветовые токены экспортированы (colors.json)
- [ ] Иконки созданы (7 SVG)
- [ ] Анимации описаны (3 Lottie JSON)
- [ ] Гайдлайны обновлены (11 разделов, 1700+ строк)
- [ ] Changelog обновлён (v1.0.0 - v1.9.0)
- [ ] Файлы для разработчиков готовы (7 JSON)
- [ ] Accessibility checklist выполнен
- [ ] Empty states созданы (4 типа)

---

## 8. ВЗАИМОДЕЙСТВИЕ С ДРУГИМИ АГЕНТАМИ

### 8.1 Frontend-разработчик
**Передаёт:**
- Макеты из `final/` (ASCII txt)
- Ассеты из `for_development/` (JSON)
- Гайдлайны из `guidelines/` (MD)
- Анимации из `animations/` (Lottie JSON)

**Получает:**
- Вопросы по реализации
- Запросы на уточнения
- Feedback по макетам

### 8.2 Технический писатель
**Передаёт:**
- Гайдлайны для документации
- Описание компонентов

**Получает:**
- Вопросы по терминологии
- Запросы на уточнение

### 8.3 QA-инженер
**Передаёт:**
- Ожидаемое поведение UI
- Критерии приёмки
- Accessibility checklist

**Получает:**
- Отчёты о визуальных багах
- Вопросы по доступности

---

## 9. БЫСТРЫЕ КОМАНДЫ

### 9.1 Поиск документов
```bash
# Найти все гайдлайны
find project_context/design -name "*.md"

# Найти все JSON ассеты
find project_context/design -name "*.json"

# Найти все SVG иконки
find project_context/design -name "*.svg"

# Найти все ASCII макеты
find project_context/design -name "*.txt"

# Найти все Lottie анимации
find project_context/design -name "*.json" -path "*/animations/*"
```

### 9.2 Проверка актуальности
```bash
# Последнее изменение в дизайне
ls -lt project_context/design/ | head -10

# Проверка версий
grep "version" project_context/design/for_development/*.json

# Проверка changelog
tail -50 project_context/design/changelog.md
```

### 9.3 Экспорт документации
```bash
# Гайдлайны в PDF
pandoc project_context/design/guidelines/guidelines.md -o guidelines.pdf

# Всё в архив
tar -czvf design_backup_$(date +%Y%m%d).tar.gz project_context/design/
```

### 9.4 Статистика документации
```bash
# Подсчёт строк
wc -l project_context/design/**/*.md
wc -l project_context/design/**/*.json

# Подсчёт файлов
find project_context/design -type f | wc -l
```

---

## 10. ТЕКУЩИЙ СТАТУС ПРОЕКТА

### 10.1 Готовность UI/UX
```
UI/UX готовность: ████████████████████ 100% (IMPROVEMENT_PLAN_v0.6.0 ✅)
Соответствие ТЗ:  ██████████████████░░ ~98% (по ТЗ v2.0)
```

### 10.2 Созданные файлы (31)
| Категория | Файлов | Статус |
|---|---|---|
| **Guidelines** | 1 (1700+ строк) | ✅ |
| **Changelog** | 1 (v1.0.0 - v1.9.0) | ✅ |
| **For Development (JSON)** | 7 | ✅ |
| **Prototypes (MD)** | 6 | ✅ |
| **Final (ASCII txt)** | 11 | ✅ |
| **Assets (SVG)** | 7 | ✅ |
| **Animations (Lottie JSON)** | 3 | ✅ |
| **Reports** | 1 | ✅ |

### 10.3 Версии дизайн-системы
| Версия | Дата | Изменения |
|---|---|---|
| v1.0.0 | 2026-03-08 | Базовая дизайн-система |
| v1.1.0 | 2026-03-08 | Адаптивная типографика + кнопки |
| v1.2.0 | 2026-03-08 | Навигация + Storage layout |
| v1.3.0 | 2026-03-08 | Responsive typography |
| v1.4.0 | 2026-03-08 | Accessibility guidelines |
| v1.5.0 | 2026-03-08 | Two-pane storage + buttons |
| v1.6.0 | 2026-03-08 | Animations & micro-interactions |
| v1.7.0 | 2026-03-08 | Error handling UI |
| v1.8.0 | 2026-03-08 | Category icons spec |
| v1.9.0 | 2026-03-08 | Empty states |

### 10.4 Завершённые этапы
| Этап | Название | Статус |
|---|---|---|
| IMPROVEMENT_PLAN_v0.6.0 | Полный план улучшений | ✅ 100% (9/9 задач) |

---

## 11. ПЛАНЫ НА БУДУЩЕЕ

### 11.1 Ближайшие задачи (Приоритет 3)
- [ ] Onboarding flow UI
- [ ] Custom themes UI
- [ ] Widget designs (home screen)

### 11.2 Долгосрочные цели
- [ ] Biometric authentication UI
- [ ] Cloud sync UI (если будет реализовано)
- [ ] Multi-device management UI

---

## 12. КОНТАКТЫ

| Роль | Контакт |
|---|---|
| **UI/UX Designer AI** | Этот агент |
| **Developer** | @azazlov |
| **Репозиторий** | https://github.com/azazlov/passgen |
| **Гайдлайны** | `project_context/design/guidelines/guidelines.md` |

---

## 13. ПРИЛОЖЕНИЯ

### A. Полный список файлов дизайнера (31 файл)
```
project_context/design/README.md
project_context/design/changelog.md (v1.0.0 - v1.9.0)
project_context/design/guidelines/guidelines.md (11 разделов)
project_context/design/IMPROVEMENT_PLAN_COMPLETION_REPORT.md

project_context/design/for_development/
├── colors.json
├── typography.json
├── components.json
├── breakpoints.json
├── spacing.json
├── navigation.json
└── storage_two_pane.json

project_context/design/assets/icons/
├── social.svg
├── finance.svg
├── shopping.svg
├── entertainment.svg
├── work.svg
├── health.svg
└── other.svg

project_context/design/animations/
├── pin_error.json
├── copy_success.json
└── strength_pulse.json

project_context/design/prototypes/
├── navigation_spec.md
├── storage_two_pane_spec.md
├── storage_layout_spec.md
├── animations_spec.md
├── error_states_spec.md
└── category_icons_spec.md

project_context/design/final/
├── navigation_mobile.txt
├── navigation_tablet.txt
├── navigation_desktop.txt
├── navigation_wide.txt
├── storage_mobile.txt
├── storage_tablet.txt
├── storage_desktop.txt
├── empty_state_storage.txt
├── empty_state_search.txt
├── empty_state_logs.txt
└── empty_state_categories.txt
```

### B. Ссылки на ресурсы
- [Material 3](https://m3.material.io/)
- [Flutter Widgets](https://docs.flutter.dev/ui/widgets)
- [Lottie](https://lottiefiles.com/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [Figma](https://figma.com/)
- [Adobe XD](https://www.adobe.com/products/xd.html)
- [Color Contrast Checker](https://contrast-finder.tanaguru.com/)

---

## 14. ИСТОРИЯ ИЗМЕНЕНИЙ ИНСТРУКЦИИ

| Версия | Дата | Изменения |
|---|---|---|
| 1.0 | 2026-03-08 | Первая версия инструкции |
| 2.0 | 2026-03-08 | Актуализация после IMPROVEMENT_PLAN_v0.6.0:<br>• Обновлена структура папок (31 файл)<br>• Добавлены новые разделы (5-14)<br>• Обновлены задачи и шаблоны<br>• Добавлены чек-листы качества<br>• Обновлены метрики (98% ТЗ) |

---

**Документ готов к использованию для развёртывания ИИ-агента UI/UX дизайнера.** 🎨

**Версия:** 2.0
**Дата утверждения:** 8 марта 2026
**Статус:** ✅ Актуально (IMPROVEMENT_PLAN_v0.6.0 выполнен на 100%)
