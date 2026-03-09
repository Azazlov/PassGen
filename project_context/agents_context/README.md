# 📚 Agents Context — Контекст для ИИ-агентов PassGen

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория содержит **централизованный контекст** для всех ИИ-агентов, участвующих в разработке PassGen. Структура организована по принципу **общего контекста** + **персональные рабочие пространства**.

---

## 2. СТРУКТУРА ДИРЕКТОРИИ

```
project_context/
├── agents_context/              # 📚 ОБЩИЙ КОНТЕКСТ (для всех агентов)
│   ├── common/                  # Общие документы проекта
│   ├── planning/                # Планы и ТЗ
│   ├── progress/                # Текущий прогресс
│   ├── stages/                  # Отчёты по этапам
│   ├── reviews/                 # Код-ревью и аудиты
│   ├── logs/                    # Логи операций
│   ├── diagrams/                # Диаграммы и схемы
│   └── instructions/            # Общие инструкции для агентов
│
├── frontend_engineer/           # 👨‍💻 FRONTEND РАЗРАБОТЧИК
│   ├── lib/                     # Исходный код
│   ├── test/                    # Тесты
│   ├── reports/                 # Отчёты
│   └── docs/                    # Документация
│
├── qa_engineer/                 # 🧪 QA ИНЖЕНЕР
│   ├── test_cases/              # Тест-кейсы
│   ├── bug_reports/             # Баг-репорты
│   ├── auto_tests/              # Автотесты
│   │   ├── unit/
│   │   ├── widget/
│   │   └── integration/
│   ├── reports/                 # Отчёты о тестировании
│   └── checklists/              # Чек-листы
│
├── data_security_specialist/    # 🔐 DATA & SECURITY
│   ├── security/                # Политики безопасности
│   ├── encryption/              # Криптография
│   ├── audit/                   # Аудит безопасности
│   └── reports/                 # Отчёты
│
├── ui_ux_designer/              # 🎨 UI/UX ДИЗАЙНЕР
│   ├── design/                  # Дизайн-система
│   │   ├── guidelines/
│   │   ├── for_development/
│   │   ├── assets/
│   │   ├── animations/
│   │   ├── prototypes/
│   │   └── final/
│   └── README.md
│
├── technical_writer/            # 📝 ТЕХНИЧЕСКИЙ ПИСАТЕЛЬ
│   ├── documentation/           # Документация проекта
│   │   ├── technical/
│   │   ├── presentation/
│   │   └── ...
│   └── README.md
│
└── devops_engineer/             # ⚙️ DEVOPS ИНЖЕНЕР
    ├── scripts/                 # Скрипты сборки
    ├── docs/                    # Документация
    ├── logs/                    # Логи сборок
    └── ci_cd/                   # CI/CD конфигурации
```

---

## 3. АГЕНТЫ И ИХ ОТВЕТСТВЕННОСТЬ

### 3.1 Frontend Engineer 👨‍💻

**Область ответственности:**
- Разработка UI компонентов и экранов
- Интеграция с бизнес-логикой (Use Cases)
- Widget-тесты
- Адаптивная вёрстка

**Ключевые файлы:**
```
project_context/agents_context/planning/passgen.tz.md
project_context/agents_context/instructions/frontend_developer_instructions.md
project_context/ui_ux_designer/design/guidelines/guidelines.md
```

**Рабочая директория:**
```
project_context/frontend_engineer/
```

---

### 3.2 QA Engineer 🧪

**Область ответственности:**
- Unit-тесты (Use Cases, Repositories)
- Widget-тесты (Screens, Widgets)
- Integration-тесты (E2E сценарии)
- Ручное тестирование
- Баг-репорты

**Ключевые файлы:**
```
project_context/agents_context/planning/passgen.tz.md
project_context/agents_context/instructions/QA_ENGINEER_INSTRUCTIONS.md
project_context/qa_engineer/TEST_STRATEGY.md
```

**Рабочая директория:**
```
project_context/qa_engineer/
```

---

### 3.3 Data & Security Specialist 🔐

**Область ответственности:**
- Криптография (PBKDF2, ChaCha20-Poly1305)
- Безопасное хранение данных
- Аудит безопасности
- Логирование событий
- Миграции БД

**Ключевые файлы:**
```
project_context/agents_context/planning/passgen.tz.md
project_context/agents_context/reviews/DATA_SECURITY_AUDIT.md
lib/core/utils/crypto_utils.dart
lib/data/database/
```

**Рабочая директория:**
```
project_context/data_security_specialist/
```

---

### 3.4 UI/UX Designer 🎨

**Область ответственности:**
- Дизайн-система (Material 3)
- Прототипирование экранов
- Анимации (Lottie)
- Гайдлайны доступности (WCAG AA)
- Ассеты (иконки, цвета)

**Ключевые файлы:**
```
project_context/agents_context/planning/passgen.tz.md (Раздел 2-11)
project_context/ui_ux_designer/design/guidelines/guidelines.md
project_context/ui_ux_designer/design/for_development/*.json
```

**Рабочая директория:**
```
project_context/ui_ux_designer/
```

---

### 3.5 Technical Writer 📝

**Область ответственности:**
- Руководство пользователя
- Техническая документация
- FAQ
- Презентационные материалы (для защиты)
- Диаграммы (Mermaid)

**Ключевые файлы:**
```
project_context/agents_context/planning/passgen.tz.md
project_context/technical_writer/documentation/README.md
```

**Рабочая директория:**
```
project_context/technical_writer/
```

---

### 3.6 DevOps Engineer ⚙️

**Область ответственности:**
- Скрипты сборки (Bash, PowerShell)
- CI/CD (GitHub Actions)
- Развёртывание
- Мониторинг сборок

**Ключевые файлы:**
```
project_context/agents_context/devops_engineer/docs/DEPLOYMENT_GUIDE.md
project_context/devops_engineer/scripts/*.sh
project_context/devops_engineer/ci_cd/*.yml
```

**Рабочая директория:**
```
project_context/devops_engineer/
```

---

## 4. ОБЩИЕ ДОКУМЕНТЫ (agents_context/)

### 4.1 common/
Общие документы проекта:
- `README.md` — основная документация
- `faq.md` — FAQ
- `user_guide.md` — руководство пользователя

### 4.2 planning/
Планы и техническое задание:
- `passgen.tz.md` — **Техническое задание (обязательно для всех)**
- `COMPREHENSIVE_TASK_PLAN.md` — сводный план работ
- `WORK_PLAN.md` — рабочий план
- `TASK_PLAN_*.md` — планы задач

### 4.3 progress/
Текущий прогресс:
- `CURRENT_PROGRESS.md` — **актуальное состояние проекта**

### 4.4 stages/
Отчёты о завершении этапов:
- `STAGE_1_COMPLETE.md` — Аутентификация и безопасность
- `STAGE_2_COMPLETE.md` — Миграция на SQLite
- `STAGE_13_COMPLETE.md` — Документирование
- ...

### 4.5 reviews/
Код-ревью и аудиты:
- `CODE_REVIEW_*.md` — отчёты о ревью
- `DATA_SECURITY_AUDIT.md` — аудит безопасности
- `UI_UX_CODE_REVIEW.md` — ревью UI/UX

### 4.6 logs/
Логи операций:
- `LOG_YYYY-MM-DD_TOPIC.md` — логи важных операций

### 4.7 diagrams/
Диаграммы и схемы:
- `*.puml` — PlantUML диаграммы
- `*.drawio` — draw.io диаграммы
- `*_description.md` — описание диаграмм

### 4.8 instructions/
Инструкции для агентов:
- `AI_AGENT_INSTRUCTIONS.md` — **общие инструкции для всех**
- `frontend_developer_instructions.md`
- `QA_ENGINEER_INSTRUCTIONS.md`
- `TECHNICAL_WRITER_INSTRUCTIONS.md`
- `UI_UX_DESIGNER.md`
- `CODE_REVIEW_INSTRUCTIONS.md`
- `LOGGING_INSTRUCTIONS.md`
- `PLANNING_INSTRUCTIONS.md`

---

## 5. РАБОЧИЙ ПРОЦЕСС

### 5.1 Перед началом работы

1. **Прочитай общие документы:**
   ```bash
   cat agents_context/planning/passgen.tz.md
   cat agents_context/progress/CURRENT_PROGRESS.md
   cat agents_context/instructions/AI_AGENT_INSTRUCTIONS.md
   ```

2. **Ознакомься с инструкцией своего агента:**
   ```bash
   cat agents_context/instructions/[YOUR_ROLE]_INSTRUCTIONS.md
   ```

3. **Проверь планы:**
   ```bash
   cat agents_context/planning/COMPREHENSIVE_TASK_PLAN.md
   ```

---

### 5.2 При выполнении задачи

1. **Создай план задачи:**
   ```bash
   touch agents_context/planning/TASK_PLAN_$(date +%Y-%m-%d).md
   ```

2. **Выполни задачу в своей директории:**
   ```
   [Выполнение задачи]
   ```

3. **За логируй результат:**
   ```bash
   touch agents_context/logs/LOG_$(date +%Y-%m-%d)_TASK.md
   ```

---

### 5.3 После завершения задачи

1. **Обнови прогресс:**
   ```bash
   # Обнови agents_context/progress/CURRENT_PROGRESS.md
   ```

2. **Создай отчёт об этапе:**
   ```bash
   touch agents_context/stages/STAGE_N_COMPLETE.md
   ```

3. **Проведи ревью:**
   ```bash
   touch agents_context/reviews/CODE_REVIEW_$(date +%Y-%m-%d).md
   ```

---

## 6. СОГЛАШЕНИЯ ОБ ИМЕНОВАНИИ

### 6.1 Файлы планов
- `PROJECT_PLAN.md` — основной план проекта
- `TASK_PLAN_YYYY-MM-DD.md` — план задачи на дату
- `SPRINT_PLAN_N.md` — план спринта N

### 6.2 Файлы отчётов
- `STAGE_N_COMPLETE.md` — отчёт о завершении этапа N
- `WEEKLY_REPORT_YYYY-WW.md` — недельный отчёт

### 6.3 Файлы ревью
- `CODE_REVIEW_YYYY-MM-DD.md` — ревью кода на дату
- `TOPIC_REVIEW.md` — тематическое ревью

### 6.4 Файлы логов
- `LOG_YYYY-MM-DD_TOPIC.md` — лог операции на дату

### 6.5 Файлы диаграмм
- `[component]_diagram.puml` — PlantUML
- `[component]_diagram.drawio` — draw.io

---

## 7. ВЕРСИОНИРОВАНИЕ ДОКУМЕНТОВ

### 7.1 Формат версии
```
MAJOR.MINOR.PATCH
```

- **MAJOR** — крупные изменения архитектуры
- **MINOR** — добавление функциональности
- **PATCH** — исправления и уточнения

### 7.2 Статусы документов
- `Черновик` — начальная версия
- `На рассмотрении` — ожидает утверждения
- `Актуально` — утверждённая версия
- `Завершено` — работа завершена
- `Устарело` — заменено новой версией

---

## 8. БЫСТРЫЙ ДОСТУП

### 8.1 Поиск документов
```bash
# Найти все планы
find project_context -name "*PLAN*.md"

# Найти все отчёты
find project_context -name "*REPORT*.md"

# Найти все инструкции
find project_context -name "*INSTRUCTIONS*.md"

# Найти по дате
find project_context -name "*2026-03*.md"
```

### 8.2 Поиск по содержимому
```bash
# Поиск по ключевым словам
grep -r "критический" project_context/

# Поиск по типу документа
grep -r "Техническое задание" project_context/planning/
```

---

## 9. ТЕКУЩИЙ СТАТУС ПРОЕКТА

### 9.1 Готовность
```
Общая готовность:     ████████████████████ 100% (базовый функционал)
Соответствие ТЗ:      ██████████████████░░ ~90% (по ТЗ v2.0)
Тестирование:         ████████░░░░░░░░░░░░ ~40%
Документация:         ████████████████████ 100%
```

### 9.2 Завершённые этапы
| Этап | Название | Статус |
|---|---|---|
| 1 | Аутентификация и безопасность | ✅ |
| 2 | Миграция на SQLite | ✅ |
| 3 | Логирование событий | ✅ |
| 4 | Категоризация паролей | ✅ |
| 5 | Настройки приложения | ✅ |
| 6 | Формат .passgen | ✅ |
| 7 | Автоблокировка | ✅ |
| 13 | Документирование | ✅ |

### 9.3 Следующие этапы
| Этап | Название | Приоритет |
|---|---|---|
| 8 | Критические исправления ТЗ | 🔴 |
| 9 | Улучшение UI/UX | 🟡 |
| 10 | Тестирование | 🔴 |
| 11 | Диаграммы для диплома | 🔴 |
| 12 | Финальная подготовка | 🔴 |

---

## 10. КОНТАКТЫ И РЕСУРСЫ

### 10.1 Репозиторий
- **GitHub:** https://github.com/azazlov/passgen

### 10.2 Документация
- [README.MD](../../README.MD) — основная документация
- [structure.md](../../structure.md) — описание модулей
- [QWEN.md](../../QWEN.md) — справка по проекту

### 10.3 Фреймворки
- [Flutter](https://flutter.dev)
- [Provider](https://pub.dev/packages/provider)
- [Cryptography](https://pub.dev/packages/cryptography)

---

## 11. ПРИЛОЖЕНИЯ

### A. Чек-лист для ИИ-агента

```markdown
## Перед началом работы
- [ ] Прочитал passgen.tz.md
- [ ] Прочитал CURRENT_PROGRESS.md
- [ ] Прочитал AI_AGENT_INSTRUCTIONS.md
- [ ] Ознакомился с инструкцией своего агента

## Во время работы
- [ ] Создал план задачи
- [ ] Выполняю задачу
- [ ] Логирую промежуточные результаты

## После завершения
- [ ] Обновил CURRENT_PROGRESS.md
- [ ] Создал отчёт об этапе
- [ ] Провёл ревью
- [ ] Закоммитил изменения
```

### B. Список всех агентов

| Агент | Директория | Инструкция |
|---|---|---|
| Frontend Engineer | `frontend_engineer/` | `frontend_developer_instructions.md` |
| QA Engineer | `qa_engineer/` | `QA_ENGINEER_INSTRUCTIONS.md` |
| Data & Security | `data_security_specialist/` | — |
| UI/UX Designer | `ui_ux_designer/` | `UI_UX_DESIGNER.md` |
| Technical Writer | `technical_writer/` | `TECHNICAL_WRITER_INSTRUCTIONS.md` |
| DevOps Engineer | `devops_engineer/` | — |

---

**Документ утверждён:** 8 марта 2026  
**Версия:** 1.0  
**Статус:** ✅ Актуально
