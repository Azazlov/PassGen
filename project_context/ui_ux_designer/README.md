# 🎨 UI/UX Designer — Рабочее пространство

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство UI/UX дизайнера** для проекта PassGen. Содержит дизайн-систему, прототипы, ассеты, анимации и гайдлайны.

---

## 2. СТРУКТУРА

```
ui_ux_designer/
└── design/
    ├── guidelines/              # Гайдлайны
    │   └── guidelines.md        # Полная дизайн-система (1700+ строк)
    ├── for_development/         # Файлы для разработчиков (JSON)
    │   ├── colors.json          # Цветовые токены
    │   ├── typography.json      # Типографика
    │   ├── components.json      # Компоненты
    │   ├── breakpoints.json     # Брейкпоинты
    │   ├── spacing.json         # Отступы
    │   ├── navigation.json      # Навигация
    │   └── storage_two_pane.json # Двухпанельный макет
    ├── assets/
    │   └── icons/               # Иконки (SVG)
    │       ├── social.svg
    │       ├── finance.svg
    │       └── ...
    ├── animations/              # Анимации (Lottie JSON)
    │   ├── pin_error.json
    │   ├── copy_success.json
    │   └── strength_pulse.json
    ├── prototypes/              # Спецификации прототипов
    │   ├── navigation_spec.md
    │   ├── storage_two_pane_spec.md
    │   └── ...
    └── final/                   # Финальные макеты (ASCII)
        ├── navigation_mobile.txt
        ├── storage_mobile.txt
        └── ...
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Дизайн-система (Material 3)
- Прототипирование экранов
- Анимации (Lottie)
- Гайдлайны доступности (WCAG AA)
- Ассеты (иконки, цвета)
- Адаптивный дизайн

### 3.2 Ключевые файлы
```
agents_context/planning/passgen.tz.md (Раздел 2-11)
agents_context/instructions/UI_UX_DESIGNER.md
design/guidelines/guidelines.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Поиск документов
```bash
# Найти все гайдлайны
find ui_ux_designer/design -name "*.md"

# Найти все JSON ассеты
find ui_ux_designer/design -name "*.json"

# Найти все SVG иконки
find ui_ux_designer/design -name "*.svg"

# Найти все ASCII макеты
find ui_ux_designer/design -name "*.txt"
```

### 4.2 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция Дизайнера](../agents_context/instructions/UI_UX_DESIGNER.md)
- [Гайдлайны](design/guidelines/guidelines.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность UI/UX
```
UI/UX готовность: ████████████████████ 100%
Соответствие ТЗ:  ██████████████████░░ ~98%
```

### 5.2 Метрики
| Метрика | Значение |
|---|---|
| **Гайдлайнов** | 1 (1700+ строк) |
| **JSON ассетов** | 7 |
| **SVG иконок** | 7 |
| **Lottie анимаций** | 3 |
| **ASCII макетов** | 11 |
| **Прототипов** | 6 |

### 5.3 Версии дизайн-системы
| Версия | Дата | Изменения |
|---|---|---|
| v1.0.0 | 2026-03-08 | Базовая дизайн-система |
| v1.9.0 | 2026-03-08 | Empty states |

---

## 6. ШАБЛОНЫ

### 6.1 Шаблон спецификации
```markdown
# 📐 [Название] Specification

**Version:** 1.0
**Date:** YYYY-MM-DD

## Overview
[Описание]

## Layout Types
### Mobile (< 600dp)
[Спецификация]

### Tablet (600-899dp)
[Спецификация]

### Desktop (900-1199dp)
[Спецификация]
```

---

**Последнее обновление:** 8 марта 2026  
**Ответственный:** AI UI/UX Designer
