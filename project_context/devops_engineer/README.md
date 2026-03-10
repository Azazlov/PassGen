# ⚙️ DevOps Engineer — Рабочее пространство

**Версия:** 2.0
**Дата:** 10 марта 2026
**Статус:** ✅ Актуально
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство DevOps инженера** для проекта PassGen. Содержит скрипты сборки, документацию по развёртыванию, CI/CD конфигурации и логи.

---

## 2. СТРУКТУРА

```
devops_engineer/
├── scripts/                 # Скрипты сборки (Bash)
│   ├── build_all.sh         # Все платформы
│   ├── build_android.sh     # Android APK
│   ├── build_desktop.sh     # Desktop (Linux/Windows/macOS)
│   ├── build_ios.sh         # iOS
│   ├── build_web.sh         # Web
│   ├── deploy_test.sh       # Развёртывание в test
│   ├── deploy_prod.sh       # Развёртывание в prod
│   ├── notify_slack.py      # Slack уведомления
│   └── notify_telegram.py   # Telegram уведомления
├── docs/                    # Документация
│   ├── BUILD_AND_DEPLOY_STRATEGY.md  # Стратегия сборки
│   ├── cicd_setup.md                 # Настройка CI/CD
│   ├── developer_guide.md            # Руководство разработчика
│   └── TASK_PLAN_BUILD.md            # План задач сборки
├── logs/                    # Логи и мониторинг
│   ├── build_*.log          # Логи сборок
│   ├── deploy_*.log         # Логи развёртывания
│   ├── sentry.yaml          # Sentry конфигурация
│   ├── firebase_crashlytics.yaml
│   └── fastlane_config.rb
└── ci_cd/                   # CI/CD конфигурации
    └── workflows/
        ├── github-actions-flutter.yml  # Основной workflow
        ├── github-actions-pr.yml       # PR валидация
        └── gitlab-ci.yml               # GitLab CI
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Скрипты сборки (Bash)
- CI/CD (GitHub Actions, GitLab CI)
- Публикация релизов
- Логирование сборок
- Интеграция с Firebase/Sentry

### 3.2 Ключевые файлы
```
project_context/agents_context/planning/passgen.tz.md
project_context/agents_context/instructions/DEVOPS_ENGINEER_INSTRUCTIONS.md
project_context/agents_context/progress/CURRENT_PROGRESS.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Команды сборки
```bash
# Все платформы
./project_context/devops_engineer/scripts/build_all.sh release

# Android
./project_context/devops_engineer/scripts/build_android.sh release

# Linux
./project_context/devops_engineer/scripts/build_desktop.sh linux release

# Web
./project_context/devops_engineer/scripts/build_web.sh release
```

### 4.2 Мониторинг
```bash
# Последние логи
tail -f project_context/devops_engineer/logs/build_*.log

# Статус сборок
ls -lh project_context/devops_engineer/logs/
```

### 4.3 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция DevOps](../agents_context/instructions/DEVOPS_ENGINEER_INSTRUCTIONS.md)
- [Руководство по развёртыванию](docs/developer_guide.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность DevOps
```
Bash скрипты:    ████████████████████ 100%
CI/CD:           ████████████░░░░░░░░ ~60%
Документация:    ██████████████░░░░░░ ~70%
Мониторинг:      ████████████░░░░░░░░ ~60%
```

### 5.2 Метрики
| Метрика | Значение |
|---|---|
| **Bash скриптов** | 8 |
| **Workflow файлов** | 3 |
| **Документов** | 4 |
| **Конфигураций мониторинга** | 4 |

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

## 7. CI/CD СТАТУС

### GitHub Actions
| Workflow | Назначение | Статус |
|---|---|---|
| `github-actions-flutter.yml` | Основная сборка и релиз | ⚠️ Требуется настройка секретов |
| `github-actions-pr.yml` | Валидация PR | ⚠️ Требуется настройка секретов |

### GitLab CI
| Файл | Назначение | Статус |
|---|---|---|
| `gitlab-ci.yml` | Альтернативный CI/CD | ⚠️ Требуется настройка переменных |

### Требуемые секреты
```
FIREBASE_TOKEN          # Firebase CLI token
FIREBASE_APP_ID         # Firebase App ID
SLACK_WEBHOOK_URL       # Slack webhook
TELEGRAM_BOT_TOKEN      # Telegram bot (опционально)
TELEGRAM_CHAT_ID        # Telegram chat (опционально)
```

---

**Последнее обновление:** 10 марта 2026
**Ответственный:** AI DevOps Engineer
