# 🤖 Агенты проекта PassGen

**Версия:** 2.0  
**Дата:** 1 апреля 2026  
**Статус:** ✅ Обновлена структура под встроенных агентов

---

## 1. ОБЗОР

Проект PassGen использует **встроенных ИИ-агентов Qwen Code** для координации разработки и документирования.

### Доступные агенты

| Агент | Назначение | Папка |
|-------|------------|-------|
| **diploma-thesis-specialist** | 🎓 Помощь с дипломом | `diploma-thesis-specialist/` |
| **expert-code-reviewer** | 🔍 Ревью кода | `product-manager-tracker/reviews/` |
| **product-manager-tracker** | 📋 Управление проектом | `product-manager-tracker/` |
| **security-data-flow-analyzer** | 🔐 Безопасность | `security-data-flow-analyzer/` |
| **task-planner** | 📅 Планирование | `product-manager-tracker/planning/` |
| **tech-docs-writer** | 📚 Документация | `tech-docs-writer/` |
| **general-purpose** | 🔧 Общие задачи | `general-purpose/` |
| **Explore** | 🔍 Поиск по коду | Встроенный |

---

## 2. СТРУКТУРА ПРОЕКТА

```
project_context/
├── diploma-thesis-specialist/     # 🎓 Дипломный агент
│   ├── README.md
│   └── workspace/
│       └── diploma_templates.md   # Шаблоны для диплома
│
├── product-manager-tracker/       # 📋 Менеджер проекта
│   ├── README.md
│   ├── planning/
│   │   └── passgen.tz.md         # Техническое задание
│   ├── progress/
│   │   └── CURRENT_PROGRESS.md   # Текущий прогресс
│   ├── stages/
│   │   └── FINAL_REPORT.md       # Финальный отчёт
│   └── reviews/
│       ├── CODE_REVIEW_REPORT.md # Код-ревью
│       └── DATA_SECURITY_AUDIT.md # Аудит безопасности
│
├── security-data-flow-analyzer/   # 🔐 Безопасность
│   ├── README.md
│   ├── audit/
│   │   ├── security_audit_report.md
│   │   └── security_fix_report_2026-03-10.md
│   ├── encryption/
│   │   ├── chacha20_specs.md
│   │   └── nonce_management.md
│   └── security/
│       ├── security_policy.md
│       ├── threat_model.md
│       └── key_management.md
│
├── tech-docs-writer/              # 📚 Технический писатель
│   ├── README.md
│   ├── user_guide.md             # Руководство пользователя
│   ├── faq.md                    # FAQ
│   ├── CHANGELOG.md              # История версий
│   ├── presentation/
│   │   └── slides.md             # Презентация
│   └── technical/
│       └── database.md           # Схема БД
│
├── diagrams/                      # 📊 Диаграммы
│   ├── DB.mermaid
│   └── password_generation_sequence.mermaid
│
├── general-purpose/               # 🔧 Общие задачи
│   └── (рабочая папка)
│
├── .archive/                      # 📦 Архив
│   ├── plans/
│   ├── logs/
│   ├── instructions/
│   └── reports/
│
└── AGENTS.md                      # Этот файл
```

---

## 3. КРИТИЧНЫЕ ДОКУМЕНТЫ ДЛЯ ДИПЛОМА

### Обязательно (12 файлов)

| № | Документ | Путь | Агент |
|---|----------|------|-------|
| 1 | **Техническое задание** | `product-manager-tracker/planning/passgen.tz.md` | task-planner |
| 2 | **Текущий прогресс** | `product-manager-tracker/progress/CURRENT_PROGRESS.md` | product-manager-tracker |
| 3 | **Финальный отчёт** | `product-manager-tracker/stages/FINAL_REPORT.md` | product-manager-tracker |
| 4 | **Код-ревью** | `product-manager-tracker/reviews/CODE_REVIEW_REPORT.md` | expert-code-reviewer |
| 5 | **Аудит безопасности** | `security-data-flow-analyzer/audit/security_audit_report.md` | security-data-flow-analyzer |
| 6 | **Отчёт об исправлениях** | `security-data-flow-analyzer/audit/security_fix_report_2026-03-10.md` | security-data-flow-analyzer |
| 7 | **Политика безопасности** | `security-data-flow-analyzer/security/security_policy.md` | security-data-flow-analyzer |
| 8 | **Модель угроз** | `security-data-flow-analyzer/security/threat_model.md` | security-data-flow-analyzer |
| 9 | **Презентация** | `tech-docs-writer/presentation/slides.md` | tech-docs-writer |
| 10 | **Руководство пользователя** | `tech-docs-writer/user_guide.md` | tech-docs-writer |
| 11 | **FAQ** | `tech-docs-writer/faq.md` | tech-docs-writer |
| 12 | **История версий** | `tech-docs-writer/CHANGELOG.md` | tech-docs-writer |

### Дополнительно

| Документ | Путь |
|----------|------|
| **Хронология** | `docs/DEVELOPMENT_CHRONOLOGY.md` |
| **Временная шкала** | `docs/chronology/TIMELINE.md` |
| **Сводка** | `docs/chronology/SUMMARY.md` |
| **Схема БД** | `project_context/diagrams/DB.mermaid` |
| **Шаблоны диплома** | `diploma-thesis-specialist/workspace/diploma_templates.md` |

---

## 4. НАЗНАЧЕНИЕ АГЕНТОВ

### 🎓 diploma-thesis-specialist

**Назначение:** Помощь в написании и оформлении дипломной работы

**Возможности:**
- Структура диплома по ГОСТ 7.32-2017
- Шаблоны документов (титульник, введение, заключение)
- Презентация для защиты (10-15 слайдов)
- Речь для доклада (5-7 минут)
- Ответы на вопросы комиссии

**Файлы:**
- `diploma-thesis-specialist/README.md`
- `diploma-thesis-specialist/workspace/diploma_templates.md`

---

### 🔍 expert-code-reviewer

**Назначение:** Анализ и ревью кода

**Возможности:**
- Поиск уязвимостей и ошибок
- Проверка соответствия лучшим практикам
- Анализ производительности
- Проверка архитектуры (Clean Architecture, SOLID)

**Отчёты:**
- `product-manager-tracker/reviews/CODE_REVIEW_REPORT.md`

---

### 📋 product-manager-tracker

**Назначение:** Управление проектом и отслеживание прогресса

**Возможности:**
- Планирование этапов
- Мониторинг прогресса
- Координация задач
- Отчётность по этапам
- Контроль соответствия ТЗ

**Файлы:**
- `product-manager-tracker/README.md`
- `product-manager-tracker/planning/passgen.tz.md`
- `product-manager-tracker/progress/CURRENT_PROGRESS.md`
- `product-manager-tracker/stages/FINAL_REPORT.md`

---

### 🔐 security-data-flow-analyzer

**Назначение:** Аудит безопасности и анализ потоков данных

**Возможности:**
- Аудит криптографических алгоритмов
- Модель угроз
- Анализ уязвимостей
- Политика безопасности
- Управление ключами

**Файлы:**
- `security-data-flow-analyzer/README.md`
- `security-data-flow-analyzer/audit/`
- `security-data-flow-analyzer/security/`
- `security-data-flow-analyzer/encryption/`

---

### 📅 task-planner

**Назначение:** Планирование задач и этапов

**Возможности:**
- Декомпозиция задач
- Приоритизация
- Оценка сроков
- Отслеживание зависимостей

**Файлы:**
- `product-manager-tracker/planning/passgen.tz.md`

---

### 📚 tech-docs-writer

**Назначение:** Создание технической документации

**Возможности:**
- Руководства пользователя
- FAQ
- Презентации
- Changelog
- Техническая документация

**Файлы:**
- `tech-docs-writer/README.md`
- `tech-docs-writer/user_guide.md`
- `tech-docs-writer/faq.md`
- `tech-docs-writer/presentation/slides.md`

---

### 🔧 general-purpose

**Назначение:** Универсальный агент для общих задач

**Возможности:**
- Исследование кодовой базы
- Поиск информации
- Выполнение многошаговых задач
- Анализ документации

---

### 🔍 Explore

**Назначение:** Быстрый поиск по кодовой базе

**Возможности:**
- Поиск файлов по паттернам
- Поиск кода по ключевым словам
- Анализ структуры проекта

---

## 5. БЫСТРЫЙ ДОСТУП

### Для диплома

```bash
# Техническое задание
code project_context/product-manager-tracker/planning/passgen.tz.md

# Прогресс
code project_context/product-manager-tracker/progress/CURRENT_PROGRESS.md

# Финальный отчёт
code project_context/product-manager-tracker/stages/FINAL_REPORT.md

# Аудит безопасности
code project_context/security-data-flow-analyzer/audit/security_audit_report.md

# Презентация
code project_context/tech-docs-writer/presentation/slides.md
```

### Для разработки

```bash
# Схема БД
code project_context/diagrams/DB.mermaid

# История версий
code project_context/tech-docs-writer/CHANGELOG.md

# Хронология разработки
code docs/DEVELOPMENT_CHRONOLOGY.md
```

---

## 6. СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Папок агентов** | 7 |
| **Документов для диплома** | 12 критичных |
| **Всего .md файлов** | ~70 |
| **Архивных файлов** | ~40 |

---

## 7. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Изменения |
|--------|------|-----------|
| 2.0 | 1 апр 2026 | Переименование под встроенных агентов |
| 1.0 | 31 мар 2026 | Первая версия |

---

**Последнее обновление:** 1 апреля 2026  
**Ответственный:** AI Product Manager  
**Статус:** ✅ Актуально
