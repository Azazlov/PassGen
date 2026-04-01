# 🔐 Data & Security Specialist — Рабочее пространство

**Версия:** 1.0  
**Дата:** 8 марта 2026  
**Статус:** ✅ Актуально  
**Проект:** PassGen — Менеджер паролей (v0.5.0)

---

## 1. ОБЗОР

Эта директория — **рабочее пространство Data & Security специалиста** для проекта PassGen. Содержит документы по безопасности, криптографии, аудиты и отчёты.

---

## 2. СТРУКТУРА

```
data_security_specialist/
├── security/                # Политики безопасности
│   ├── security_policy.md   # Политики и стандарты
│   ├── key_management.md    # Управление ключами
│   └── threat_model.md      # Модель угроз
├── encryption/              # Криптография
│   ├── chacha20_specs.md    # ChaCha20-Poly1305
│   ├── pbkdf2_specs.md      # PBKDF2
│   └── nonce_management.md  # Управление nonce
├── audit/                   # Аудит безопасности
│   ├── security_audit_*.md  # Отчёты об аудите
│   └── vulnerability_scan.md # Сканирование
└── reports/                 # Отчёты
    ├── security_report_*.md # Отчёты о безопасности
    └── compliance_report.md # Соответствие
```

---

## 3. ОТВЕТСТВЕННОСТЬ

### 3.1 Основные задачи
- Криптография (PBKDF2, ChaCha20-Poly1305)
- Безопасное хранение ключей
- Аудит безопасности
- Логирование событий
- Миграции БД
- Формат .passgen

### 3.2 Ключевые файлы
```
agents_context/planning/passgen.tz.md
agents_context/instructions/DATA_SECURITY_SPECIALIST_INSTRUCTIONS.md
agents_context/reviews/DATA_SECURITY_AUDIT.md
```

---

## 4. БЫСТРЫЙ ДОСТУП

### 4.1 Команды аудита
```bash
# Найти print в production
grep -r "print(" lib/ | grep -v test

# Найти TODO по безопасности
grep -r "TODO" lib/ | grep -i security

# Проверить PBKDF2
grep -A 5 "PBKDF2" lib/data/datasources/auth_local_datasource.dart

# Проверить ChaCha20
grep -A 5 "ChaCha20" lib/data/datasources/encryptor_local_datasource.dart
```

### 4.2 Полезные ссылки
- [Техническое задание](../agents_context/planning/passgen.tz.md)
- [Текущий прогресс](../agents_context/progress/CURRENT_PROGRESS.md)
- [Инструкция Security](../agents_context/instructions/DATA_SECURITY_SPECIALIST_INSTRUCTIONS.md)
- [Аудит безопасности](../agents_context/reviews/DATA_SECURITY_AUDIT.md)

---

## 5. ТЕКУЩИЙ СТАТУС

### 5.1 Готовность безопасности
```
Криптография:   ████████████████████ 100%
Хранение ключей: ████████████████████ 100%
Логирование:     ██████████████████░░ ~90%
Миграции БД:     ████████████████░░░░ ~80%
```

### 5.2 Метрики
| Метрика | Значение | Требование |
|---|---|---|
| **PBKDF2 итерации** | 10,000 | ≥10,000 ✅ |
| **Длина ключа** | 256 бит | 256 бит ✅ |
| **Nonce** | 96 бит | 96 бит ✅ |
| **MAC** | 128 бит | 128 бит ✅ |
| **Таблицы БД** | 5 | 5 ✅ |

---

## 6. ШАБЛОНЫ

### 6.1 Шаблон аудита безопасности
```markdown
# Аудит безопасности [Компонент]

**Дата:** YYYY-MM-DD
**Аудитор:** Data & Security AI

## Найденные проблемы
| ID | Описание | Критичность | Статус |
|---|---|---|---|
| 1 | [Проблема] | 🔴/🟡/🟢 | ⬜ |

## Рекомендации
[Список]

## Заключение
[Вывод]
```

---

**Последнее обновление:** 8 марта 2026  
**Ответственный:** AI Data & Security Specialist
