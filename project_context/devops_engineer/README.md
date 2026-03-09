# ⚙️ DevOps Engineer — Рабочее пространство

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство DevOps инженера** для проекта PassGen. Содержит скрипты сборки, документацию по развёртыванию, CI/CD конфигурации и логи.

---

## 2. СТРУКТУРА

```
devops_engineer/
├── scripts/                 # Скрипты сборки
│   ├── build_all.sh         # Все платформы (Bash)
│   ├── build_android.sh     # Android APK
│   ├── build_desktop.sh     # Desktop (Linux/Windows)
│   ├── build_all.ps1        # Все платформы (PowerShell)
│   ├── build_android.ps1    # Android (PowerShell)
│   └── build_desktop.ps1    # Desktop (PowerShell)
├── docs/                    # Документация
│   ├── DEPLOYMENT_GUIDE.md  # Руководство по развёртыванию
│   ├── BUILD_STRATEGY.md    # Стратегия сборки
│   └── CI_CD_SETUP.md       # Настройка CI/CD
├── logs/                    # Логи сборок
│   ├── build_*.log          # Логи сборок
│   └── deploy_*.log         # Логи развёртывания
└── ci_cd/                   # CI/CD конфигурации
    └── workflows/
        └── build.yml        # GitHub Actions
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Скрипты сборки (Bash, PowerShell)
- CI/CD (GitHub Actions)
- Публикация релизов
- Логирование сборок
- Управление зависимостями

### 3.2 Ключевые файлы
```
agents_context/planning/passgen.tz.md
agents_context/instructions/DEVOPS_ENGINEER_INSTRUCTIONS.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Команды сборки
```bash
# Все платформы (Bash)
./devops_engineer/scripts/build_all.sh release

# Android
./devops_engineer/scripts/build_android.sh release

# Linux
./devops_engineer/scripts/build_desktop.sh linux release

# Windows (PowerShell)
.\devops_engineer\scripts\build_all.ps1 release
```

### 4.2 Мониторинг
```bash
# Последние логи
tail -f devops_engineer/logs/build_*.log

# Статус сборок
ls -lh devops_engineer/logs/
```

### 4.3 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция DevOps](../agents_context/instructions/DEVOPS_ENGINEER_INSTRUCTIONS.md)
- [Руководство по развёртыванию](docs/DEPLOYMENT_GUIDE.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность DevOps
```
Bash скрипты:    ████████████████████ 100%
PowerShell:      ████████░░░░░░░░░░░░ ~40%
CI/CD:           ████░░░░░░░░░░░░░░░░ ~20%
Документация:    ████████████░░░░░░░░ ~60%
```

### 5.2 Метрики
| Метрика | Значение |
|---|---|
| **Bash скриптов** | 3 |
| **PowerShell скриптов** | 0 |
| **Workflow** | 0 |
| **Документов** | 1 |

---

## 6. ШАБЛОНЫ

### 6.1 Шаблон отчёта о сборке
```markdown
# Отчёт о сборке

**Дата:** YYYY-MM-DD
**Платформа:** [Название]
**Версия:** X.X.X

## Результат
- **Статус:** ✅ Успешно / ❌ Ошибка
- **Время:** X мин
- **Размер:** X MB

## Логи
[Ссылка]

## Проблемы
[Список]
```

---

**Последнее обновление:** 8 марта 2026  
**Ответственный:** AI DevOps Engineer
