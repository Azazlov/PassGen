# 👨‍💻 Frontend Engineer — Рабочее пространство

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство Frontend разработчика** для проекта PassGen. Содержит код, тесты, отчёты и документацию.

---

## 2. СТРУКТУРА

```
frontend_engineer/
├── lib/                     # Исходный код приложения
│   ├── app/                 # DI, навигация, темы
│   ├── core/                # Утилиты, константы, ошибки
│   ├── domain/              # Бизнес-логика (Use Cases, Entities)
│   ├── data/                # Репозитории, БД, datasource
│   └── presentation/        # UI (Screens, Widgets)
├── test/                    # Тесты
│   ├── unit/                # Unit-тесты (Use Cases)
│   ├── widget/              # Widget-тесты (Screens, Widgets)
│   └── integration/         # Integration-тесты
├── reports/                 # Отчёты
│   ├── code_review_*.md     # Код-ревью
│   └── feature_*.md         # Отчёты о функциях
└── docs/                    # Документация
    ├── api_reference.md     # API Reference
    └── architecture.md      # Архитектура
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Разработка UI компонентов и экранов
- Интеграция с бизнес-логикой (Use Cases)
- Widget-тесты
- Адаптивная вёрстка
- Material 3 дизайн

### 3.2 Ключевые файлы
```
agents_context/planning/passgen.tz.md
agents_context/instructions/frontend_developer_instructions.md
agents_context/progress/CURRENT_PROGRESS.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Команды разработки
```bash
# Запуск
flutter run -d linux

# Сборка
flutter build linux
flutter build windows
flutter build apk

# Анализ
flutter analyze

# Форматирование
dart format lib/

# Тесты
flutter test
flutter test --coverage
```

### 4.2 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция Frontend](../agents_context/instructions/frontend_developer_instructions.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность
```
UI компоненты:   ████████████████████ 100%
Widget-тесты:    ████████████░░░░░░░░ ~60%
Unit-тесты:      ████████░░░░░░░░░░░░ ~40%
```

### 5.2 Метрики
| Метрика | Значение |
|---|---|
| **Файлов Dart** | 118 |
| **Строк кода** | ~9500+ |
| **Экранов** | 8 |
| **Виджетов** | 11 |
| **Widget-тестов** | 29 |
| **Unit-тестов** | 25+ |

---

**Последнее обновление:** 8 марта 2026  
**Ответственный:** AI Frontend Developer
