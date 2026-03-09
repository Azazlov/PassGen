# 🧪 QA Engineer — Рабочее пространство

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство QA инженера** для проекта PassGen. Содержит тест-кейсы, автотесты, баг-репорты и отчёты о тестировании.

---

## 2. СТРУКТУРА

```
qa_engineer/
├── test_cases/              # Тест-кейсы
│   ├── manual_test_cases.md # Ручные тест-кейсы
│   └── acceptance_criteria.md # Критерии приёмки
├── bug_reports/             # Баг-репорты
│   ├── BUG_001_*.md
│   ├── BUG_002_*.md
│   └── ...
├── auto_tests/              # Автотесты
│   ├── unit/                # Unit-тесты
│   │   ├── auth/
│   │   ├── password/
│   │   ├── storage/
│   │   └── settings/
│   ├── widget/              # Widget-тесты
│   │   ├── screens/
│   │   └── components/
│   └── integration/         # Integration-тесты
│       ├── auth_flow_test.dart
│       └── ...
├── reports/                 # Отчёты о тестировании
│   ├── test_report_*.md     # Отчёты о тестах
│   └── coverage_report.md   # Покрытие кода
└── checklists/              # Чек-листы
    ├── pre_release.md       # Предрелизный чек-лист
    └── regression.md        # Регрессионный чек-лист
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Unit-тесты (Use Cases, Repositories)
- Widget-тесты (Screens, Widgets)
- Integration-тесты (E2E сценарии)
- Ручное тестирование
- Баг-репорты
- Проверка соответствия ТЗ

### 3.2 Ключевые файлы
```
agents_context/planning/passgen.tz.md
agents_context/instructions/QA_ENGINEER_INSTRUCTIONS.md
agents_context/progress/CURRENT_PROGRESS.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Команды тестирования
```bash
# Все тесты
flutter test

# Unit-тесты
flutter test test/unit/

# Widget-тесты
flutter test test/widgets/

# Integration-тесты
flutter test integration_test/

# С покрытием
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 4.2 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция QA](../agents_context/instructions/QA_ENGINEER_INSTRUCTIONS.md)
- [Стратегия тестирования](TEST_STRATEGY.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность тестирования
```
Unit-тесты:     ████████░░░░░░░░░░░░ ~40%
Widget-тесты:   ████████████░░░░░░░░ ~60%
Integration:    ████░░░░░░░░░░░░░░░░ ~20%
Документация:   ████████████████████ 100%
```

### 5.2 Метрики
| Метрика | Значение | Цель |
|---|---|---|
| **Unit-тестов** | 25+ | 50+ |
| **Widget-тестов** | 29 | 50+ |
| **Integration-тестов** | 1 | 5+ |
| **Покрытие** | ~82% | ≥50% |
| **Баг-репортов** | 0 | — |

---

## 6. ШАБЛОНЫ

### 6.1 Шаблон баг-репорта
```markdown
# Баг #XXX: [Название]

**Дата:** YYYY-MM-DD
**Критичность:** 🔴/🟡/🟢
**Статус:** ⬜ Новый / 🔄 В работе / ✅ Исправлен

## Описание
[Описание проблемы]

## Воспроизведение
1. [Шаг 1]
2. [Шаг 2]

## Ожидаемый результат
[Что должно быть]

## Фактический результат
[Что есть]

## Вложения
[Скриншоты, логи]
```

---

**Последнее обновление:** 8 марта 2026  
**Ответственный:** AI QA Engineer
