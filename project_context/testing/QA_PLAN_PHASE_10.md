# 🧪 ПЛАН РАБОТ QA-ИНЖЕНЕРА — Этап 10: Тестирование

**Проект:** PassGen — Менеджер паролей  
**Дата:** 8 марта 2026 г.  
**Версия:** 0.5.0  
**Статус:** ✅ Готов к выполнению

---

## 📊 ТЕКУЩЕЕ СОСТОЯНИЕ ПРОЕКТА

### ✅已完成 (Completed)
| Категория | Файлов | Тестов | Статус |
|---|---|---|---|
| **Auth Use Cases** | 5 | 25 | ✅ 100% |
| **Password Use Cases** | 2 | 8 | ✅ 100% |
| **Widget тесты** | 3 | ~20 | ✅ 100% |
| **Итого** | 10 | ~53 | ✅ ~82% покрытие |

### ⬜ Требуется реализовать
| Категория | Use Cases | Файлов | Приоритет |
|---|---|---|---|
| **Storage** | Get, Delete, Export, Import, ExportPassgen, ImportPassgen | 6 | 🔴 Высокий |
| **Category** | Get, Create, Update, Delete | 4 | 🔴 Высокий |
| **Settings** | Get, Set, Remove | 3 | 🟡 Средний |
| **Log** | LogEvent, GetLogs | 2 | 🟡 Средний |
| **Encryptor** | Encrypt, Decrypt | 2 | 🟢 Низкий |
| **Widget тесты** | 9 экранов | 9 | 🔴 Высокий |
| **Integration тесты** | 5 сценариев | 5 | 🔴 Высокий |

---

## 🎯 ЦЕЛИ ЭТАПА 10: ТЕСТИРОВАНИЕ

### Критические задачи (🔴)
- [ ] Достичь покрытия кода ≥50% (текущее ~40%)
- [ ] Написать Unit-тесты для всех 26 Use Cases
- [ ] Написать Widget-тесты для 9 экранов
- [ ] Написать Integration-тесты для 5 ключевых сценариев
- [ ] Создать MANUAL_TEST_CASES.md

### Средние задачи (🟡)
- [ ] Провести статический анализ кода
- [ ] Создать отчёты о тестировании
- [ ] Создать BUG_REPORTS для найденных проблем

### Низкие задачи (🟢)
- [ ] Провести проверку доступности (a11y)
- [ ] Создать CHECKLISTS (PRE_RELEASE, REGRESSION)

---

## 📋 ДЕТАЛЬНЫЙ ПЛАН РАБОТ

### Этап 10.1: Unit-тестирование Use Cases (8-10 часов)

#### 10.1.1 Storage Use Cases (6 файлов) — 3 часа
```
test/unit/usecases/storage/
├── get_passwords_usecase_test.dart
├── delete_password_usecase_test.dart
├── export_passwords_usecase_test.dart
├── import_passwords_usecase_test.dart
├── export_passgen_usecase_test.dart
└── import_passgen_usecase_test.dart
```

**Что тестировать:**
- ✅ Успешное получение/сохранение/удаление паролей
- ✅ Обработка ошибок (пустой список, дубликаты)
- ✅ Экспорт/импорт в форматах JSON и .passgen
- ✅ Валидация данных перед операциями

#### 10.1.2 Category Use Cases (4 файла) — 2 часа
```
test/unit/usecases/category/
├── get_categories_usecase_test.dart
├── create_category_usecase_test.dart
├── update_category_usecase_test.dart
└── delete_category_usecase_test.dart
```

**Что тестировать:**
- ✅ CRUD операции с категориями
- ✅ Валидация названий категорий
- ✅ Системные vs пользовательские категории
- ✅ Удаление с проверкой связей

#### 10.1.3 Settings Use Cases (3 файла) — 1.5 часа
```
test/unit/usecases/settings/
├── get_settings_usecase_test.dart
├── set_settings_usecase_test.dart
└── remove_settings_usecase_test.dart
```

**Что тестировать:**
- ✅ Чтение/запись/удаление настроек
- ✅ Валидация ключей и значений
- ✅ Настройки PIN-кода

#### 10.1.4 Log Use Cases (2 файла) — 1.5 часа
```
test/unit/usecases/log/
├── log_event_usecase_test.dart
└── get_logs_usecase_test.dart
```

**Что тестировать:**
- ✅ Логирование 8 типов событий
- ✅ Получение логов с фильтрацией
- ✅ Группировка по дате

#### 10.1.5 Encryptor Use Cases (2 файла) — 1 час
```
test/unit/usecases/encryptor/
├── encrypt_message_usecase_test.dart
└── decrypt_message_usecase_test.dart
```

**Что тестировать:**
- ✅ Шифрование/дешифрование ChaCha20-Poly1305
- ✅ Обработка некорректных данных
- ✅ Проверка целостности (MAC tag)

---

### Этап 10.2: Widget-тестирование экранов (6-8 часов)

#### 10.2.1 Widget-тесты для 9 экранов
```
test/widget/screens/
├── auth_screen_test.dart          ⬜
├── generator_screen_test.dart     ⬜
├── storage_screen_test.dart       ⬜
├── settings_screen_test.dart      ⬜
├── categories_screen_test.dart    ⬜
├── encryptor_screen_test.dart     ⬜
├── logs_screen_test.dart          ⬜
├── about_screen_test.dart         ⬜
└── splash_screen_test.dart        ⬜
```

**Что тестировать на каждом экране:**
- ✅ Отображение ключевых элементов UI
- ✅ Взаимодействие (нажатия, ввод текста)
- ✅ Навигация и переходы
- ✅ Обработка состояний (loading, error, empty)
- ✅ Адаптивность (мобильный/десктоп)

#### 10.2.2 Widget-тесты для компонентов
```
test/widget/components/
├── app_button_test.dart           ⬜
├── app_text_field_test.dart       ⬜
├── app_switch_test.dart           ⬜
├── copyable_password_test.dart    ✅ (существует)
├── character_set_display_test.dart ✅ (существует)
├── shimmer_effect_test.dart       ✅ (существует)
├── password_card_test.dart        ⬜
└── strength_indicator_test.dart   ⬜
```

---

### Этап 10.3: Integration-тестирование (4-6 часов)

#### 10.3.1 Integration-тесты для 5 сценариев
```
integration_test/
├── auth_flow_test.dart                  ⬜
├── password_generation_flow_test.dart   ⬜
├── storage_crud_flow_test.dart          ⬜
├── import_export_flow_test.dart         ⬜
└── settings_change_flow_test.dart       ⬜
```

**Сценарии для тестирования:**

1. **Auth Flow** — полный цикл аутентификации:
   - Запуск приложения → ввод PIN → вход → автоблокировка → повторный вход

2. **Password Generation Flow** — генерация и сохранение:
   - Настройка параметров → генерация → копирование → сохранение в хранилище

3. **Storage CRUD Flow** — управление паролями:
   - Создание → чтение → обновление → удаление записи

4. **Import/Export Flow** — работа с данными:
   - Экспорт в JSON → импорт из JSON → проверка целостности

5. **Settings Change Flow** — изменение настроек:
   - Смена PIN-кода → проверка нового PIN → выход

---

### Этап 10.4: Ручное тестирование (3-4 часа)

#### 10.4.1 Создание MANUAL_TEST_CASES.md
```markdown
## TC-001: Аутентификация с верным PIN
## TC-002: Аутентификация с неверным PIN
## TC-003: Блокировка после 5 неудачных попыток
## TC-004: Генерация пароля стандартной сложности
## TC-005: Генерация пароля максимальной сложности
## TC-006: Сохранение пароля в хранилище
## TC-007: Поиск пароля по названию
## TC-008: Фильтрация по категории
## TC-009: Экспорт в JSON
## TC-010: Импорт из JSON
## TC-011: Смена PIN-кода
## TC-012: Удаление PIN-кода
## TC-013: Просмотр логов безопасности
## TC-014: Шифрование сообщения
## TC-015: Дешифрование сообщения
```

#### 10.4.2 Проведение ручного тестирования
- ✅ Выполнить каждый тест-кейс
- ✅ Зафиксировать результаты
- ✅ Создать скриншоты для багов

---

### Этап 10.5: Статический анализ и качество (1-2 часа)

#### 10.5.1 Статический анализ
```bash
flutter analyze
flutter analyze --fatal-infos
```

#### 10.5.2 Проверка покрытия
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

#### 10.5.3 Создание отчётов
```
project_context/testing/REPORTS/
├── TEST_REPORT_2026-03-08.md
├── COVERAGE_REPORT.md
├── STATIC_ANALYSIS_REPORT.md
└── ACCESSIBILITY_REPORT.md
```

---

### Этап 10.6: Проверка доступности (a11y) (2 часа)

#### Чек-лист доступности:
- [ ] Все IconButton имеют tooltip
- [ ] Все изображения имеют Semantics.label
- [ ] Контрастность текста ≥ 4.5:1
- [ ] Поддержка масштабирования текста до 200%
- [ ] Навигация с клавиатуры (Tab, Enter, Escape)
- [ ] Фокус виден на всех элементах

---

## 📅 ВРЕМЕННАЯ ШКАЛА

| Этап | Задачи | Время | Приоритет |
|---|---|---|---|
| **10.1** | Unit-тесты Use Cases (17 файлов) | 8-10 часов | 🔴 |
| **10.2** | Widget-тесты (9 экранов + 6 компонентов) | 6-8 часов | 🔴 |
| **10.3** | Integration-тесты (5 сценариев) | 4-6 часов | 🔴 |
| **10.4** | Ручное тестирование + тест-кейсы | 3-4 часа | 🟡 |
| **10.5** | Статический анализ + отчёты | 1-2 часа | 🟡 |
| **10.6** | Проверка доступности (a11y) | 2 часа | 🟢 |
| **Итого** | **Все этапы** | **24-32 часа** | — |

---

## 🎯 КРИТЕРИИ ПРИЁМКИ

### Unit-тесты:
- [ ] 26+ файлов с тестами
- [ ] 100+ тестов
- [ ] ≥90% покрытие Use Cases
- [ ] Все тесты проходят

### Widget-тесты:
- [ ] 9+ файлов с тестами экранов
- [ ] 6+ файлов с тестами компонентов
- [ ] ≥70% покрытие UI
- [ ] Все тесты проходят

### Integration-тесты:
- [ ] 5+ сценариев
- [ ] Все сценарии проходят на эмуляторе

### Документация:
- [ ] MANUAL_TEST_CASES.md создан
- [ ] TEST_REPORT.md создан
- [ ] BUG_REPORTS созданы (если найдены баги)
- [ ] Покрытие ≥50%

---

## 📦 НЕОБХОДИМЫЕ РЕСУРСЫ

### Зависимости (уже есть в pubspec.yaml):
```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.9
  flutter_test:
    sdk: flutter
```

### Команды для работы:
```bash
# Генерация моков
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск тестов
flutter test
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/

# Покрытие
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📊 ОЖИДАЕМЫЕ РЕЗУЛЬТАТЫ

### Метрики после завершения:
| Метрика | Было | Стало |
|---|---|---|
| **Файлов тестов** | 10 | 40+ |
| **Unit-тестов** | 33 | 100+ |
| **Widget-тестов** | 20 | 50+ |
| **Integration-тестов** | 0 | 5+ |
| **Покрытие** | ~40% | ≥50% |
| **Баг-репортов** | 0 | 3+ |

---

**План составил:** AI QA Engineer  
**Дата:** 8 марта 2026 г.  
**Статус:** ✅ Готов к выполнению
