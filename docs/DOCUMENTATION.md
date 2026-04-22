# 📚 Документация PassGen

**Версия:** 2.0  
**Дата:** 1 апреля 2026  
**Статус:** ✅ Структура обновлена под встроенных агентов

---

## 1. БЫСТРЫЙ ДОСТУП

### Для диплома
| Документ | Путь | Агент |
|----------|------|-------|
| **Техническое задание** | `project_context/product-manager-tracker/planning/passgen.tz.md` | task-planner |
| **Текущий прогресс** | `project_context/product-manager-tracker/progress/CURRENT_PROGRESS.md` | product-manager-tracker |
| **Финальный отчёт** | `project_context/product-manager-tracker/stages/FINAL_REPORT.md` | product-manager-tracker |
| **Код-ревью** | `project_context/product-manager-tracker/reviews/CODE_REVIEW_REPORT.md` | expert-code-reviewer |
| **Аудит безопасности** | `project_context/security-data-flow-analyzer/audit/security_audit_report.md` | security-data-flow-analyzer |
| **Тесты** | `test/` | — |
| **Презентация** | `project_context/tech-docs-writer/presentation/slides.md` | tech-docs-writer |
| **Хронология** | `docs/DEVELOPMENT_CHRONOLOGY.md` | — |

### Для разработчиков
| Документ | Путь | Назначение |
|----------|------|------------|
| **README** | `README.MD` | Основная документация |
| **DEVELOPER** | `docs/DEVELOPER.md` | Документация разработчика |
| **Архитектура БД** | `project_context/diagrams/DB.mermaid` | Схема базы данных |
| **Changelog** | `project_context/tech-docs-writer/CHANGELOG.md` | История версий |

### Для пользователей
| Документ | Путь | Назначение |
|----------|------|------------|
| **Руководство** | `project_context/tech-docs-writer/user_guide.md` | Как пользоваться |
| **FAQ** | `project_context/tech-docs-writer/faq.md` | Вопросы и ответы |

---

## 2. СТРУКТУРА ДОКУМЕНТАЦИИ

```
project_context/
├── diploma-thesis-specialist/     # 🎓 Дипломный агент
│   ├── README.md
│   └── workspace/
│       └── diploma_templates.md
│
├── product-manager-tracker/       # 📋 Менеджер проекта
│   ├── README.md
│   ├── planning/
│   │   └── passgen.tz.md         # ✅ Техническое задание
│   ├── progress/
│   │   └── CURRENT_PROGRESS.md   # ✅ Текущий прогресс
│   ├── stages/
│   │   └── FINAL_REPORT.md       # ✅ Финальный отчёт
│   └── reviews/
│       ├── CODE_REVIEW_REPORT.md # ✅ Код-ревью
│       └── DATA_SECURITY_AUDIT.md # Аудит безопасности
│
├── security-data-flow-analyzer/   # 🔐 Безопасность
│   ├── README.md
│   ├── audit/
│   │   ├── security_audit_report.md   # ✅ Аудит
│   │   └── security_fix_report_2026-03-10.md  # ✅ Исправления
│   ├── encryption/
│   │   ├── chacha20_specs.md
│   │   └── nonce_management.md
│   └── security/
│       ├── security_policy.md    # ✅ Политика
│       ├── threat_model.md       # ✅ Модель угроз
│       └── key_management.md     # Управление ключами
│
├── tech-docs-writer/              # 📚 Технический писатель
│   ├── README.md
│   ├── presentation/
│   │   └── slides.md             # ✅ Презентация
│   ├── user_guide.md             # ✅ Руководство
│   ├── faq.md                    # ✅ FAQ
│   └── CHANGELOG.md              # История версий
│
├── diagrams/                      # 📊 Диаграммы
│   ├── DB.mermaid                # ✅ Схема БД
│   └── password_generation_sequence.mermaid
│
├── general-purpose/               # 🔧 Общие задачи
│   └── (рабочая папка)
│
├── .archive/                      # 📦 Архив
│   ├── plans/                    # 15 файлов планов
│   ├── logs/                     # 6 файлов логов
│   ├── instructions/             # 11 файлов инструкций
│   └── reports/                  # 13 файлов отчётов
│
└── AGENTS.md                      # Описание агентов
```

---

## 3. СТАТИСТИКА ПОСЛЕ ОЧИСТКИ

| Метрика | До очистки | После | Удалено/Архивировано |
|---------|------------|-------|---------------------|
| **.md файлов (всего)** | 159 | 144 | -15 |
| **Документов в project_context/** | 115 | ~75 | ~40 в архиве |
| **Документов для диплома** | — | 18 критичных | — |
| **Пустых директорий** | 5 | 0 | 5 удалено |
| **Дубликатов** | 12 | 0 | 12 удалено |
| **Устаревших отчётов** | 8 | 0 | 8 удалено |

### Распределение по категориям

| Категория | Файлов | Строк |
|-----------|--------|-------|
| **Критичные для диплома** | 18 | ~5,000 |
| **Дополнительные** | ~25 | ~8,000 |
| **Архив** | ~40 | ~12,000 |
| **Всего** | 144 | ~25,000 |

---

## 4. ЧТО УДАЛЕНО

### Пустые директории (5)
- `project_context/data_analyst/reports/`
- `project_context/diploma_assistant/reports/`
- `project_context/scripts/`
- `project_context/temp/`

### Дубликаты (5)
- `project_context/tech-docs-writer/technical/architecture.md` → дубль `docs/DEVELOPER.md`
 - `docs/DEVELOPER.md` / `README.MD` → единая “истина” по архитектуре/запуску/сборке

### Устаревшие отчёты об этапах (5)
- `STAGE_1_COMPLETE.md` → заменён `FINAL_REPORT.md`
- `STAGE_2_COMPLETE.md` → заменён `FINAL_REPORT.md`
- `STAGE_3_4_COMPLETE.md` → заменён `FINAL_REPORT.md`
- `STAGE_5_COMPLETE.md` → заменён `FINAL_REPORT.md`
- `STAGE_6_COMPLETE.md` → заменён `FINAL_REPORT.md`

### Консолидирована хронология (5)
- `docs/chronology/v0.1.0.md` → оставлен `DEVELOPMENT_CHRONOLOGY.md`
- `docs/chronology/v0.2.0.md` → оставлен `SUMMARY.md`
- `docs/chronology/v0.3.0.md` → оставлен `TIMELINE.md`
- `docs/chronology/v0.4.0.md`
- `docs/chronology/v0.5.0.md`

---

## 5. ЧТО АРХИВИРОВАНО

### Планы (15 файлов)
Рабочие планы, неактуальные для диплома:
- `BUG_FIX_PLAN_v0.5.1.md`
- `FIX_PLAN_P0_P1_P2.md`
- `FLUTTER_2025-2026_IMPROVEMENTS.md`
- `FRONTEND_IMPLEMENTATION_PLAN.md`
- `IMPROVEMENT_PLAN_v0.6.0.md`
- `STRUCTURE_IMPROVEMENT_PLAN.md`
- `TASK_PLAN_*.md` (4 файла)
- `WORK_PLAN.md`
- `DESIGN_TASK_PLAN.md`
- `FINAL_IMPROVEMENT_PLAN_v0.7.0.md`
- `IMPROVEMENT_PLAN_COMPLETION_REPORT.md`
- `IMPROVEMENT_RECOMMENDATIONS_PLAN.md`
- `SEARCH_QUERY_FLUTTER_UI_UX_2025_2026.md`

**Путь:** `project_context/.archive/plans/`

### Логи (6 файлов)
Рабочие логи операций:
- `LOG_2026-03-08_FIX_CA_VIOLATIONS.md`
- `LOG_2026-03-08_OPTIMIZATION*.md` (2 файла)
- `LOG_2026-03-08_REFACTOR_*.md` (3 файла)

**Путь:** `project_context/.archive/logs/`

### Инструкции агентов (11 файлов)
Внутренние инструкции ИИ-агентов:
- `AI_AGENT_INSTRUCTIONS.md`
- `PROJECT_MANAGER_INSTRUCTIONS.md`
- `CODE_REVIEW_INSTRUCTIONS.md`
- `DATA_SECURITY_SPECIALIST_INSTRUCTIONS.md`
- `DEVOPS_ENGINEER_INSTRUCTIONS.md`
- `frontend_developer_instructions.md`
- `LOGGING_INSTRUCTIONS.md`
- `PLANNING_INSTRUCTIONS.md`
- `QA_ENGINEER_INSTRUCTIONS.md`
- `TECHNICAL_WRITER_INSTRUCTIONS.md`
- `UI_UX_DESIGNER.md`

**Путь:** `project_context/.archive/instructions/`

### Отчёты агентов (13 файлов)
Внутренние отчёты:
- отчёты и рабочие материалы перенесены в `project_context/.archive/`

**П путь:** `project_context/.archive/reports/`

---

## 6. КРИТИЧНЫЕ ДОКУМЕНТЫ ДЛЯ ДИПЛОМА

### Обязательно (12 файлов)

#### Техническое задание
1. `project_context/product-manager-tracker/planning/passgen.tz.md` — Требования к проекту

#### Прогресс и отчёты
2. `project_context/product-manager-tracker/progress/CURRENT_PROGRESS.md` — Текущий статус
3. `project_context/product-manager-tracker/stages/FINAL_REPORT.md` — Финальный отчёт
4. `project_context/product-manager-tracker/reviews/CODE_REVIEW_REPORT.md` — Код-ревью

#### Безопасность
5. `project_context/security-data-flow-analyzer/audit/security_audit_report.md` — Аудит
6. `project_context/security-data-flow-analyzer/audit/security_fix_report_2026-03-10.md` — Исправления
7. `project_context/security-data-flow-analyzer/security/security_policy.md` — Политика
8. `project_context/security-data-flow-analyzer/security/threat_model.md` — Модель угроз
9. `project_context/security-data-flow-analyzer/security/key_management.md` — Ключи

#### Документация
10. `project_context/tech-docs-writer/presentation/slides.md` — Презентация
11. `project_context/tech-docs-writer/user_guide.md` — Руководство
12. `project_context/tech-docs-writer/faq.md` — FAQ
13. `project_context/tech-docs-writer/CHANGELOG.md` — История версий

#### Диаграммы
14. `project_context/diagrams/DB.mermaid` — Схема БД
15. `project_context/diagrams/password_generation_sequence.mermaid` — Последовательность

#### Хронология
16. `docs/DEVELOPMENT_CHRONOLOGY.md` — История разработки
17. `docs/chronology/SUMMARY.md` — Краткая сводка
18. `docs/chronology/TIMELINE.md` — Временная шкала

#### Основная документация
19. `README.MD` — Основная документация
20. `docs/DEVELOPER.md` — Документация разработчика

---

## 7. НАВИГАЦИЯ

### По назначению

```bash
# Для диплома
code project_context/product-manager-tracker/planning/passgen.tz.md
code project_context/product-manager-tracker/progress/CURRENT_PROGRESS.md
code project_context/product-manager-tracker/stages/FINAL_REPORT.md

# Для безопасности
code project_context/security-data-flow-analyzer/audit/

# Для презентации
code project_context/tech-docs-writer/presentation/slides.md

# Для хронологии
code docs/DEVELOPMENT_CHRONOLOGY.md
code docs/chronology/TIMELINE.md
```

### Поиск документов

```bash
# Найти все критичные документы
find . -name "passgen.tz.md" -o -name "FINAL_REPORT.md" -o -name "security_audit_report.md"

# Найти все диаграммы
find . -name "*.mermaid"

# Найти документы для диплома
find project_context -name "*.md" | grep -E "(tz|FINAL_REPORT|security_audit|slides|user_guide|faq)"
```

---

## 8. АРХИВ

### Доступ к архивным документам

Все рабочие документы перемещены в архив:

```
project_context/.archive/
├── plans/         # 15 файлов планов
├── logs/          # 6 файлов логов
├── instructions/  # 11 файлов инструкций
└── reports/       # 13 файлов отчётов
```

**Для просмотра архива:**
```bash
code project_context/.archive/plans/
code project_context/.archive/logs/
code project_context/.archive/instructions/
code project_context/.archive/reports/
```

---

## 9. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Изменения |
|--------|------|-----------|
| 2.0 | 1 апр 2026 | Переименование под встроенных агентов Qwen Code |
| 1.0 | 31 мар 2026 | Очистка документации: удалено 15 файлов, архивировано ~40 |

---

**Последнее обновление:** 1 апреля 2026  
**Ответственный:** AI Product Manager  
**Статус:** ✅ Актуально
