# ⏱️ Временная шкала разработки PassGen

**Проект:** PassGen — кроссплатформенный менеджер паролей  
**Период разработки:** 5-10 марта 2026 г.  
**Общая продолжительность:** 6 дней  
**Финальная версия:** 0.5.0

---

## 1. ОБЩАЯ ДИАГРАММА ГАНТА

```mermaid
gantt
    title PassGen — Общая временная шкала разработки
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %d %b
    excludes    weekend
    
    section v0.1.0 — Инициализация
    Создание проекта           :done, v01init, 2026-03-05 09:00, 4h
    Настройка зависимостей     :done, v01deps, after v01init, 2h
    Clean Architecture         :done, v01arch, after v01deps, 4h
    Базовые компоненты         :done, v01comp, after v01arch, 4h
    
    section v0.2.0 — Аутентификация
    PBKDF2 реализация          :done, v02pbkdf2, 2026-03-06 09:00, 2h
    PIN валидация              :done, v02pin, after v02pbkdf2, 1h
    Блокировка от подбора      :done, v02lock, after v02pin, 1h
    Логирование событий        :done, v02log, after v02lock, 2h
    AuthScreen UI              :done, v02ui, after v02log, 3h
    Интеграция Provider        :done, v02di, after v02ui, 1h
    
    section v0.3.0 — SQLite + Категории + Логи
    DatabaseHelper             :done, v03dbh, 2026-03-07 09:00, 2h
    DatabaseSchema             :done, v03dbs, after v03dbh, 1h
    Миграция из SharedPreferences :done, v03migr, after v03dbs, 2h
    Entity Category            :done, v03cat, after v03migr, 1h
    Category Use Cases         :done, v03catuc, after v03cat, 2h
    CategoriesScreen           :done, v03catscr, after v03catuc, 2h
    LogsController             :done, v03logctrl, 2026-03-07 14:00, 1h
    LogsScreen                 :done, v03logscr, after v03logctrl, 2h
    SettingsScreen             :done, v03sets cr, 2026-03-07 16:00, 2h
    Provider интеграция        :done, v03di, after sets cr, 1h
    
    section v0.4.0 — .passgen + Автоблокировка
    PassgenFormat              :done, v04pf, 2026-03-07 18:00, 2h
    Export/Import Use Cases    :done, v04uc, after v04pf, 2h
    Логирование операций       :done, v04log, after v04uc, 1h
    Таймер автоблокировки      :done, v04timer, 2026-03-07 20:00, 1h
    Listener для касаний       :done, v04listen, after v04timer, 30m
    Интеграция                 :done, v04int, after v04listen, 1h
    
    section v0.5.0 — Финальная
    Логирование PWD_ACCESSED   :done, v05log1, 2026-03-08 09:00, 40m
    Логирование SETTINGS_CHG   :done, v05log2, after v05log1, 25m
    CharacterSetDisplay        :done, v05char, 2026-03-08 11:00, 2h
    KeyboardListener           :done, v05keyb, after v05char, 2h
    Widget тесты               :done, v05wt, 2026-03-08 14:00, 3h
    Unit тесты                 :done, v05ut, after v05wt, 3h
    Руководство пользователя   :done, v05doc1, 2026-03-08 16:00, 2h
    Техническая документация   :done, v05doc2, after v05doc1, 3h
    FAQ                        :done, v05doc3, after v05doc2, 2h
    Презентация                :done, v05doc4, after v05doc3, 2h
    Bash скрипты               :done, v05bash, 2026-03-10 09:00, 2h
    GitHub Actions             :done, v05ci, after v05bash, 2h
```

---

## 2. ДЕТАЛЬНАЯ ХРОНОЛОГИЯ ПО ДНЯМ

### 5 марта 2026 (День 1) — Инициализация

```mermaid
gantt
    title День 1: Инициализация проекта (v0.1.0)
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %H:%M
    
    section Утро
    Создание Flutter проекта   :done, init, 2026-03-05 09:00, 1h
    Настройка pubspec.yaml     :done, deps, after init, 1h
    
    section День
    Clean Architecture структура :done, arch, 2026-03-05 11:00, 3h
    Core слой (constants, errors) :done, core, after arch, 2h
    
    section Вечер
    Domain слой (entities, repositories) :done, domain, 2026-03-05 16:00, 3h
    Data слой (datasources, models) :done, data, after domain, 2h
    Presentation слой (widgets) :done, ui, after data, 2h
```

**Итого за день:** ~16 часов  
**Создано файлов:** ~25  
**Строк кода:** ~1,500

---

### 6 марта 2026 (День 2) — Аутентификация

```mermaid
gantt
    title День 2: Аутентификация и безопасность (v0.2.0)
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %H:%M
    
    section Утро
    PBKDF2 деривация           :done, pbkdf2, 2026-03-06 09:00, 2h
    PIN валидация и хранение   :done, pin, after pbkdf2, 2h
    Блокировка от подбора      :done, lock, after pin, 1h
    
    section День
    Логирование событий        :done, log, 2026-03-06 12:00, 2h
    AuthScreen UI              :done, authui, after log, 3h
    Цифровая клавиатура        :done, keypad, after authui, 2h
    
    section Вечер
    AuthController             :done, ctrl, 2026-03-06 17:00, 2h
    Provider интеграция        :done, di, after ctrl, 1h
    Тестирование               :done, test, after di, 1h
```

**Итого за день:** ~16 часов  
**Создано файлов:** ~20  
**Строк кода:** ~1,700

---

### 7 марта 2026 (День 3) — SQLite, Категории, Логи, .passgen, Автоблокировка

```mermaid
gantt
    title День 3: Масштабное обновление (v0.3.0 + v0.4.0)
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %H:%M
    
    section Утро (v0.3.0)
    DatabaseHelper             :done, dbh, 2026-03-07 09:00, 2h
    DatabaseSchema             :done, dbs, after dbh, 1h
    Миграция из SharedPreferences :done, migr, after dbs, 2h
    Entity Category            :done, cat, after migr, 1h
    Category Use Cases         :done, catuc, after cat, 2h
    
    section День (v0.3.0)
    CategoriesScreen           :done, catscr, 2026-03-07 13:00, 2h
    LogsController             :done, logctrl, after catscr, 1h
    LogsScreen                 :done, logscr, after logctrl, 2h
    SettingsScreen             :done, sets cr, after logscr, 2h
    
    section Вечер (v0.4.0)
    PassgenFormat              :done, pf, 2026-03-07 18:00, 2h
    Export/Import Use Cases    :done, expuc, after pf, 2h
    Логирование операций       :done, oplog, after expuc, 1h
    
    section Ночь (v0.4.0)
    Таймер автоблокировки      :done, timer, 2026-03-07 21:00, 1h
    Listener для касаний       :done, listen, after timer, 30m
    Интеграция                 :done, int, after listen, 1h
```

**Итого за день:** ~18 часов  
**Создано файлов:** ~50  
**Строк кода:** ~4,000

---

### 8 марта 2026 (День 4) — Критические исправления, UI/UX, Тесты, Документация

```mermaid
gantt
    title День 4: Финализация (v0.5.0 — часть 1)
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %H:%M
    
    section Утро
    Логирование PWD_ACCESSED   :done, logacc, 2026-03-08 09:00, 40m
    Логирование SETTINGS_CHG   :done, logset, after logacc, 25m
    Анализ опций генератора    :done, analysis, after logset, 35m
    
    section День
    CharacterSetDisplay        :done, charset, 2026-03-08 11:00, 2h
    KeyboardListener           :done, keyb, after charset, 2h
    Адаптивность               :done, adaptive, after keyb, 1h
    Widget тесты               :done, wt, after adaptive, 3h
    
    section Вечер
    Unit тесты                 :done, ut, 2026-03-08 16:00, 3h
    Руководство пользователя   :done, userdoc, after ut, 2h
    Техническая документация   :done, techdoc, after userdoc, 2h
    
    section Ночь
    FAQ                        :done, faq, 2026-03-08 21:00, 2h
    Презентация                :done, slides, after faq, 2h
```

**Итого за день:** ~18 часов  
**Создано файлов:** ~40  
**Строк кода:** ~2,300 + ~2,600 документация

---

### 9 марта 2026 (День 5) — Резерв / Документация

**План:** Резервное время для завершения документации и тестирования

**Фактически:**
- Завершение технической документации
- Обновление README.MD
- Обновление structure.md
- Слияние веток test → main

---

### 10 марта 2026 (День 6) — DevOps, Архивирование

```mermaid
gantt
    title День 6: DevOps и архивирование (v0.5.0 — часть 2)
    dateFormat  YYYY-MM-DD HH:mm
    axisFormat  %H:%M
    
    section Утро
    Bash скрипты сборки        :done, bash, 2026-03-10 09:00, 2h
    GitHub Actions CI          :done, ci, after bash, 2h
    GitHub Actions Build       :done, build, after ci, 1h
    
    section День
    GitHub Actions Deploy      :done, deploy, 2026-03-10 13:00, 1h
    Архивирование документации :done, archive, after deploy, 2h
    Финальная проверка         :done, check, after archive, 1h
```

**Итого за день:** ~9 часов  
**Создано файлов:** ~12 (скрипты + workflow)

---

## 3. СТАТИСТИКА ПО ДНЯМ

| День | Дата | Версии | Часов работы | Файлов | Строк кода |
|------|------|--------|--------------|--------|------------|
| 1 | 5 марта | v0.1.0 | ~16 | ~25 | ~1,500 |
| 2 | 6 марта | v0.2.0 | ~16 | ~20 | ~1,700 |
| 3 | 7 марта | v0.3.0, v0.4.0 | ~18 | ~50 | ~4,000 |
| 4 | 8 марта | v0.5.0 (часть 1) | ~18 | ~40 | ~2,300 |
| 5 | 9 марта | — | ~8 | ~5 | ~500 |
| 6 | 10 марта | v0.5.0 (часть 2) | ~9 | ~12 | ~200 |
| **ИТОГО** | **5-10 марта** | **v0.1.0 - v0.5.0** | **~85** | **~152** | **~10,200** |

---

## 4. КЛЮЧЕВЫЕ ВЕХИ

| Дата | Время | Событие | Версия |
|------|-------|---------|--------|
| 5 марта | 09:00 | Начало проекта | v0.1.0 |
| 5 марта | 17:00 | Завершение инициализации | v0.1.0 ✅ |
| 6 марта | 17:00 | Аутентификация готова | v0.2.0 ✅ |
| 7 марта | 17:00 | SQLite + Категории + Логи | v0.3.0 ✅ |
| 7 марта | 23:00 | .passgen + Автоблокировка | v0.4.0 ✅ |
| 8 марта | 23:00 | Критические исправления + UI/UX | v0.5.0 ✅ |
| 8 марта | 23:00 | Документация завершена | v0.5.0 ✅ |
| 10 марта | 15:00 | DevOps завершён | v0.5.0 ✅ |
| 10 марта | 17:00 | Проект готов к релизу | v0.5.0 🎉 |

---

## 5. ВРЕМЕННАЯ ШКАЛА ЭТАПОВ

```mermaid
timeline
    title Хронология этапов разработки PassGen
    section День 1 (5 марта)
      v0.1.0 : Инициализация
               : Clean Architecture
    section День 2 (6 марта)
      v0.2.0 : Аутентификация
               : PBKDF2, блокировка
    section День 3 (7 марта)
      v0.3.0 : SQLite миграция
               : Категории, Логи
      v0.4.0 : Формат .passgen
               : Автоблокировка
    section День 4 (8 марта)
      v0.5.0 : Критические исправления
               : UI/UX улучшения
               : Тесты, Документация
    section День 5-6 (9-10 марта)
      v0.5.0 : DevOps
               : Архивирование
               : Финальная проверка
```

---

## 6. РАСПРЕДЕЛЕНИЕ ВРЕМЕНИ ПО КАТЕГОРИЯМ

```mermaid
pie
    title Распределение времени по категориям работ
    "Код (разработка)" : 45
    "Тестирование" : 10
    "Документация" : 20
    "DevOps" : 10
    "Планирование" : 10
    "Интеграция" : 5
```

---

## 7. ССЫЛКИ

- [README.md](README.md) — Оглавление всех версий
- [SUMMARY.md](SUMMARY.md) — Сводные метрики проекта
- [v0.1.0.md](v0.1.0.md) — Версия 0.1.0
- [v0.2.0.md](v0.2.0.md) — Версия 0.2.0
- [v0.3.0.md](v0.3.0.md) — Версия 0.3.0
- [v0.4.0.md](v0.4.0.md) — Версия 0.4.0
- [v0.5.0.md](v0.5.0.md) — Версия 0.5.0

---

**PassGen** | [MIT License](../../LICENSE) | [GitHub](https://github.com/azazlov/passgen)
