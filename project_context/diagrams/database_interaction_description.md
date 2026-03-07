# 📊 Диаграмма взаимодействия объектов базы данных PassGen

**Версия:** 1.0  
**Дата:** 7 марта 2026 г.  
**Статус:** ✅ Утверждено

---

## 1. ОБЗОР ДИАГРАММЫ

Данная диаграмма описывает взаимодействие объектов базы данных в системе управления паролями PassGen. Диаграмма включает:

- **ER-схему** (5 таблиц с полями, типами данных и ограничениями)
- **5 сценариев** взаимодействия (Sequence Diagrams)
- **Индексы и ограничения** таблиц
- **Триггеры и автоматизация**

---

## 2. СХЕМА БАЗЫ ДАННЫХ

### 2.1 Таблицы и поля

#### 📁 categories (Категории)

| Поле | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Уникальный ID категории |
| `name` | TEXT | NOT NULL | Название категории |
| `icon` | TEXT | — | Иконка (emoji) |
| `is_system` | INTEGER | DEFAULT 0 | Флаг системной (0/1) |
| `created_at` | INTEGER | NOT NULL | Timestamp создания |

**Индексы:**
- `idx_categories_is_system` (is_system)

**Ограничения:**
- `is_system IN (0, 1)`

---

#### 🔐 password_entries (Записи паролей)

| Поле | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Уникальный ID записи |
| `category_id` | INTEGER | FOREIGN KEY → categories.id | Ссылка на категорию |
| `service` | TEXT | NOT NULL | Название сервиса |
| `login` | TEXT | — | Логин/Email |
| `encrypted_password` | BLOB | NOT NULL | Зашифрованный пароль |
| `nonce` | BLOB | NOT NULL | Nonce для шифрования |
| `created_at` | INTEGER | NOT NULL | Timestamp создания |
| `updated_at` | INTEGER | NOT NULL | Timestamp обновления |

**Индексы:**
- `idx_password_entries_category` (category_id)
- `idx_password_entries_service` (service)

**Ограничения:**
- `category_id REFERENCES categories(id)`
- `service NOT NULL`

**Связи:**
- Many-to-One → categories (category_id)
- One-to-One ← password_configs (entry_id)

---

#### ⚙️ password_configs (Конфигурации)

| Поле | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Уникальный ID конфигурации |
| `entry_id` | INTEGER | FOREIGN KEY → password_entries.id, UNIQUE | Ссылка на запись |
| `strength` | INTEGER | — | Уровень сложности (0-4) |
| `min_length` | INTEGER | — | Минимальная длина |
| `max_length` | INTEGER | — | Максимальная длина |
| `flags` | INTEGER | — | Битовая маска категорий |
| `require_unique` | INTEGER | DEFAULT 0 | Требовать уникальности |
| `encrypted_config` | BLOB | — | Зашифрованные доп. настройки |

**Индексы:**
- `idx_password_configs_entry` (entry_id) UNIQUE

**Ограничения:**
- `entry_id REFERENCES password_entries(id) UNIQUE`

**Связи:**
- One-to-One → password_entries (entry_id)

---

#### 📋 security_logs (Логи безопасности)

| Поле | Тип | Ограничения | Описание |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Уникальный ID лога |
| `action_type` | TEXT | NOT NULL | Тип события |
| `timestamp` | INTEGER | NOT NULL | Timestamp события |
| `details` | TEXT | — | JSON с деталями |

**Индексы:**
- `idx_security_logs_action` (action_type)
- `idx_security_logs_timestamp` (timestamp)

**Ограничения:**
- `action_type NOT NULL`
- `timestamp NOT NULL`

**Типы событий:**
- `AUTH_SUCCESS` — Успешный вход
- `AUTH_FAILURE` — Неудачная попытка
- `AUTH_LOCKOUT` — Блокировка
- `PWD_CREATED` — Создание пароля
- `PWD_UPDATED` — Обновление пароля
- `PWD_DELETED` — Удаление пароля
- `DATA_EXPORT` — Экспорт данных
- `DATA_IMPORT` — Импорт данных
- `SETTINGS_CHG` — Изменение настроек

---

#### ⚙️ app_settings (Настройки приложения)

| Поле | Тип | Ограничения | Описание |
|---|---|---|---|
| `key` | TEXT | PRIMARY KEY | Ключ настройки |
| `value` | TEXT | NOT NULL | Значение настройки |
| `encrypted` | INTEGER | DEFAULT 0 | Флаг шифрования (0/1) |

**Индексы:**
- PRIMARY KEY (key)

**Ограничения:**
- `key PRIMARY KEY`
- `value NOT NULL`

**Примеры настроек:**
- `theme` — Тема оформления
- `language` — Язык интерфейса
- `inactivity_timeout` — Время автоблокировки
- `security_report_settings` — Настройки отчётов

---

## 3. СЦЕНАРИИ ВЗАИМОДЕЙСТВИЯ

### 📝 Сценарий 1: Добавление новой записи пароля

**Участники:**
- 👤 Пользователь
- 🔧 PasswordRepository
- 📊 password_entries
- ⚙️ password_configs
- 📋 security_logs

**Последовательность:**

```
1. Пользователь → PasswordRepository: createPasswordEntry(service, login, password, categoryId, config)

2. PasswordRepository → password_entries: BEGIN TRANSACTION
   ← Transaction Started

3. PasswordRepository → password_entries: 
   INSERT INTO password_entries(
     category_id, service, login,
     encrypted_password, nonce,
     created_at, updated_at
   ) VALUES (?, ?, ?, ?, ?, ?, ?)
   
   Параметры:
   - category_id: Int?
   - service: String (NOT NULL)
   - login: String?
   - encrypted_password: BLOB (ChaCha20-Poly1305)
   - nonce: BLOB (32 bytes)
   - created_at: Timestamp (ms)
   - updated_at: Timestamp (ms)
   
   ← lastInsertRowId: Int (ID новой записи)

4. PasswordRepository → password_configs:
   INSERT INTO password_configs(
     entry_id, strength, min_length,
     max_length, flags, require_unique,
     encrypted_config
   ) VALUES (?, ?, ?, ?, ?, ?, ?)
   
   Параметры:
   - entry_id: Int (FK из шага 3)
   - strength: Int (0-4)
   - min_length: Int
   - max_length: Int
   - flags: Int (битовая маска)
   - require_unique: Int (0/1)
   - encrypted_config: BLOB?
   
   ← lastInsertRowId: Int

5. PasswordRepository → security_logs:
   INSERT INTO security_logs(
     action_type, timestamp, details
   ) VALUES ('PWD_CREATED', ?, ?)
   
   Параметры:
   - action_type: 'PWD_CREATED'
   - timestamp: Timestamp (ms)
   - details: JSON {service, category_id}
   
   ← lastInsertRowId: Int

6. PasswordRepository → password_entries: COMMIT TRANSACTION
   ← Success

7. PasswordRepository → Пользователь: 
   PasswordEntry {
     id: Int,
     service: String,
     categoryId: Int?,
     createdAt: DateTime
   }
```

**Возвращаемые значения:**
- ✅ `PasswordEntry` — созданная запись с ID
- ❌ `Error` — ошибка транзакции

**Ошибки:**
- `DatabaseException` — ошибка БД
- `ConstraintViolationException` — нарушение ограничений

---

### ✏️ Сценарий 2: Обновление существующей записи пароля

**Участники:**
- 👤 Пользователь
- 🔧 PasswordRepository
- 📊 password_entries
- ⚙️ password_configs
- 📋 security_logs

**Последовательность:**

```
1. Пользователь → PasswordRepository: 
   updatePasswordEntry(id, service?, login?, password?, categoryId?)

2. PasswordRepository → password_entries: BEGIN TRANSACTION
   ← Transaction Started

3. PasswordRepository → password_entries: 
   SELECT * FROM password_entries WHERE id = ?
   
   Параметры:
   - id: Int
   
   ← PasswordEntry? или NULL

4. ALT: Запись не найдена
   → PasswordRepository → Пользователь: Error: NotFound
   
5. ELSE: Запись найдена
   PasswordRepository → password_entries:
   UPDATE password_entries SET
     service = ?, login = ?,
     category_id = ?,
     encrypted_password = ?,
     nonce = ?,
     updated_at = ?
   WHERE id = ?
   
   Параметры:
   - service: String
   - login: String?
   - category_id: Int?
   - encrypted_password: BLOB
   - nonce: BLOB
   - updated_at: Timestamp (ms)
   - id: Int (WHERE)
   
   ← rowsAffected: Int
   
   PasswordRepository → password_configs:
   UPDATE OR INSERT password_configs
   SET entry_id = ?, strength = ?, ...
   WHERE entry_id = ?
   
   ← rowsAffected: Int
   
   PasswordRepository → security_logs:
   INSERT INTO security_logs(
     action_type, timestamp, details
   ) VALUES ('PWD_UPDATED', ?, ?)
   
   ← lastInsertRowId: Int
   
   PasswordRepository → password_entries: COMMIT TRANSACTION
   ← Success
   
   PasswordRepository → Пользователь: 
   PasswordEntry {
     id: Int,
     updatedAt: DateTime
   }
```

**Возвращаемые значения:**
- ✅ `PasswordEntry` — обновлённая запись
- ❌ `Error: NotFound` — запись не найдена

**Ошибки:**
- `NotFoundException` — запись с ID не найдена
- `DatabaseException` — ошибка БД

---

### 🗑️ Сценарий 3: Удаление записи пароля

**Участники:**
- 👤 Пользователь
- 🔧 PasswordRepository
- 📊 password_entries
- ⚙️ password_configs
- 📋 security_logs

**Последовательность:**

```
1. Пользователь → PasswordRepository: deletePasswordEntry(id)

2. PasswordRepository → password_entries: BEGIN TRANSACTION
   ← Transaction Started

3. PasswordRepository → password_entries: 
   SELECT * FROM password_entries WHERE id = ?
   
   Параметры:
   - id: Int
   
   ← PasswordEntry? или NULL

4. ALT: Запись не найдена
   → PasswordRepository → Пользователь: Error: NotFound
   
5. ELSE: Запись найдена
   PasswordRepository → password_configs:
   DELETE FROM password_configs WHERE entry_id = ?
   
   Параметры:
   - entry_id: Int (FK)
   
   ← rowsAffected: Int
   
   PasswordRepository → password_entries:
   DELETE FROM password_entries WHERE id = ?
   
   Параметры:
   - id: Int
   
   ← rowsAffected: Int
   
   PasswordRepository → security_logs:
   INSERT INTO security_logs(
     action_type, timestamp, details
   ) VALUES ('PWD_DELETED', ?, ?)
   
   ← lastInsertRowId: Int
   
   PasswordRepository → password_entries: COMMIT TRANSACTION
   ← Success
   
   PasswordRepository → Пользователь: Success: Boolean
```

**Возвращаемые значения:**
- ✅ `Boolean: true` — успешно удалено
- ❌ `Error: NotFound` — запись не найдена

**Ошибки:**
- `NotFoundException` — запись с ID не найдена
- `DatabaseException` — ошибка БД

**Каскадное удаление:**
- password_configs удаляется автоматически (entry_id FK)

---

### 🔍 Сценарий 4: Поиск записей по категории

**Участники:**
- 👤 Пользователь
- 🔧 PasswordRepository
- 📊 password_entries
- 📋 categories

**Последовательность:**

```
1. Пользователь → PasswordRepository: 
   getPasswordsByCategory(categoryId, searchQuery?)

2. PasswordRepository → categories: 
   SELECT * FROM categories WHERE id = ?
   
   Параметры:
   - id: Int
   
   ← Category? или NULL

3. ALT: Категория не найдена
   → PasswordRepository → Пользователь: Error: CategoryNotFound
   
4. ELSE: Категория найдена
   ALT: Есть поисковый запрос
     PasswordRepository → password_entries:
     SELECT * FROM password_entries
     WHERE category_id = ?
     AND service LIKE ?
     ORDER BY service ASC
     
     Параметры:
     - category_id: Int
     - searchQuery: '%text%'
     - ORDER BY: service ASC
   
   ELSE: Нет поискового запроса
     PasswordRepository → password_entries:
     SELECT * FROM password_entries
     WHERE category_id = ?
     ORDER BY service ASC
     
     Параметры:
     - category_id: Int
     - ORDER BY: service ASC
   
   ← List<PasswordEntry>
   
   PasswordRepository → Пользователь: 
   List<PasswordEntry> {
     id: Int,
     service: String,
     login: String?,
     categoryId: Int,
     createdAt: DateTime
   }
```

**Возвращаемые значения:**
- ✅ `List<PasswordEntry>` — список записей
- ❌ `Error: CategoryNotFound` — категория не найдена

**Ошибки:**
- `CategoryNotFoundException` — категория с ID не найдена
- `DatabaseException` — ошибка БД

**Оптимизация:**
- Индекс `idx_password_entries_category` ускоряет поиск
- Индекс `idx_password_entries_service` ускоряет поиск по service

---

### 📊 Сценарий 5: Генерация отчёта о безопасности

**Участники:**
- 👤 Пользователь
- 🔧 SecurityLogRepository
- 📋 security_logs
- 📊 password_entries
- ⚙️ app_settings

**Последовательность:**

```
1. Пользователь → SecurityLogRepository: 
   generateSecurityReport(startDate, endDate, limit)

2. SecurityLogRepository → app_settings: 
   SELECT value FROM app_settings
   WHERE key = 'security_report_settings'
   
   ← SettingsJSON? или NULL

3. SecurityLogRepository → security_logs: 
   SELECT action_type, COUNT(*) as count,
          MIN(timestamp) as first,
          MAX(timestamp) as last
   FROM security_logs
   WHERE timestamp BETWEEN ? AND ?
   GROUP BY action_type
   ORDER BY count DESC
   LIMIT ?
   
   Параметры:
   - start_timestamp: Int (ms)
   - end_timestamp: Int (ms)
   - limit: Int
   
   ← List<LogSummary> {
     action_type: String,
     count: Int,
     first: Timestamp,
     last: Timestamp
   }

4. SecurityLogRepository → security_logs: 
   SELECT * FROM security_logs
   WHERE action_type IN ('AUTH_FAILURE', 'AUTH_LOCKOUT')
   AND timestamp BETWEEN ? AND ?
   ORDER BY timestamp DESC
   LIMIT 100
   
   ← List<SecurityLog> {
     id: Int,
     action_type: String,
     timestamp: Timestamp,
     details: JSON
   }

5. SecurityLogRepository → password_entries: 
   SELECT COUNT(*) as total,
          COUNT(DISTINCT category_id) as categories,
          MIN(created_at) as oldest,
          MAX(updated_at) as newest
   FROM password_entries
   
   ← PasswordStats {
     total: Int,
     categories: Int,
     oldest: Timestamp,
     newest: Timestamp
   }

6. SecurityLogRepository → Пользователь: 
   SecurityReport {
     logSummary: List<LogSummary>,
     securityEvents: List<SecurityLog>,
     passwordStats: PasswordStats,
     generatedAt: DateTime
   }
```

**Возвращаемые значения:**
- ✅ `SecurityReport` — полный отчёт
- ❌ `Error` — ошибка генерации

**Ошибки:**
- `DatabaseException` — ошибка БД
- `InvalidDateRangeException` — некорректный диапазон дат

---

## 4. ТРИГГЕРЫ И АВТОМАТИЗАЦИЯ

### 🔄 Триггер: cleanup_old_logs

**Назначение:** Автоматическая очистка старых логов

```sql
CREATE TRIGGER IF NOT EXISTS cleanup_old_logs
AFTER INSERT ON security_logs
WHEN (SELECT COUNT(*) FROM security_logs) > 2000
BEGIN
  DELETE FROM security_logs
  WHERE id NOT IN (
    SELECT id FROM security_logs
    ORDER BY timestamp DESC
    LIMIT 1000
  );
END;
```

**Срабатывание:**
- AFTER INSERT на security_logs
- Условие: COUNT > 2000
- Действие: Удалить все кроме последних 1000

---

### 🔄 Триггер: update_timestamp

**Назначение:** Автоматическое обновление updated_at

```sql
CREATE TRIGGER IF NOT EXISTS update_timestamp
AFTER UPDATE ON password_entries
BEGIN
  UPDATE password_entries
  SET updated_at = (strftime('%s', 'now') * 1000)
  WHERE id = NEW.id;
END;
```

**Срабатывание:**
- AFTER UPDATE на password_entries
- Действие: SET updated_at = CURRENT_TIMESTAMP

---

### 🔄 Триггер: cascade_delete_config

**Назначение:** Каскадное удаление конфигурации

```sql
CREATE TRIGGER IF NOT EXISTS cascade_delete_config
AFTER DELETE ON password_entries
BEGIN
  DELETE FROM password_configs
  WHERE entry_id = OLD.id;
END;
```

**Срабатывание:**
- AFTER DELETE на password_entries
- Действие: DELETE FROM password_configs WHERE entry_id = OLD.id

---

## 5. ТИПЫ ДАННЫХ

### INTEGER
- **id:** AUTOINCREMENT (1, 2, 3...)
- **timestamps:** milliseconds since Unix epoch
- **flags:** bit mask (0-255)
- **is_system/is_encrypted:** 0 или 1

### TEXT
- **service:** VARCHAR(255)
- **login:** VARCHAR(255)
- **action_type:** ENUM string
- **key/value:** VARCHAR(500)

### BLOB
- **encrypted_password:** ChaCha20-Poly1305 encrypted data
- **nonce:** 32 bytes random
- **encrypted_config:** JSON encrypted with PBKDF2 key

---

## 6. КОНСТАНТЫ

| Константа | Значение | Описание |
|---|---|---|
| `PBKDF2_ITERATIONS` | 10000 | Итераций для деривации ключа |
| `LOCKOUT_DURATION` | 30 | Секунд блокировки после 5 попыток |
| `MAX_FAILED_ATTEMPTS` | 5 | Максимум попыток ввода PIN |
| `INACTIVITY_TIMEOUT` | 300 | Секунд до автоблокировки (5 мин) |
| `MAX_LOGS` | 2000 | Максимум записей логов |
| `KEEP_LOGS` | 1000 | Сколько хранить после очистки |
| `MIN_PIN_LENGTH` | 4 | Минимум цифр в PIN |
| `MAX_PIN_LENGTH` | 8 | Максимум цифр в PIN |

---

## 7. ВИЗУАЛИЗАЦИЯ

### PlantUML

Для визуализации диаграммы используйте:

```bash
# Онлайн
https://www.plantuml.com/plantuml/

# Локально
java -jar plantuml.jar database_interaction_diagram.puml
```

### draw.io

1. Откройте draw.io
2. Импорт → PlantUML
3. Вставьте содержимое `.puml` файла

---

## 8. ПРИЛОЖЕНИЯ

### A. SQL CREATE TABLE statements

```sql
-- Таблица categories
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT,
  is_system INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- Таблица password_entries
CREATE TABLE password_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER REFERENCES categories(id),
  service TEXT NOT NULL,
  login TEXT,
  encrypted_password BLOB NOT NULL,
  nonce BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Таблица password_configs
CREATE TABLE password_configs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER UNIQUE REFERENCES password_entries(id),
  strength INTEGER,
  min_length INTEGER,
  max_length INTEGER,
  flags INTEGER,
  require_unique INTEGER DEFAULT 0,
  encrypted_config BLOB
);

-- Таблица security_logs
CREATE TABLE security_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_type TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  details TEXT
);

-- Таблица app_settings
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  encrypted INTEGER DEFAULT 0
);
```

### B. SQL CREATE INDEX statements

```sql
CREATE INDEX IF NOT EXISTS idx_categories_is_system 
  ON categories(is_system);

CREATE INDEX IF NOT EXISTS idx_password_entries_category 
  ON password_entries(category_id);

CREATE INDEX IF NOT EXISTS idx_password_entries_service 
  ON password_entries(service);

CREATE INDEX IF NOT EXISTS idx_password_configs_entry 
  ON password_configs(entry_id);

CREATE INDEX IF NOT EXISTS idx_security_logs_action 
  ON security_logs(action_type);

CREATE INDEX IF NOT EXISTS idx_security_logs_timestamp 
  ON security_logs(timestamp);
```

---

**Документ утверждён:** 7 марта 2026 г.  
**Версия:** 1.0  
**Статус:** ✅ Актуально
