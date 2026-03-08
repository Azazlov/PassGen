# 📋 Сводный план работ PassGen

**Дата создания:** 2026-03-08
**Версия:** 1.0
**На основе:** WORK_PLAN.md, TASK_PLAN_8.md, TASK_PLAN_TESTING.md, TASK_PLAN_BUILD.md, passgen.tz.md

---

## 1. ТЕКУЩЕЕ СОСТОЯНИЕ ПРОЕКТА

### 1.1 Готовность
```
Общая готовность:     ████████████████████ 100% (базовый функционал)
Соответствие ТЗ:      ██████████████████░░ ~90% (по критериям ТЗ v2.0)
Тестирование:         ████████░░░░░░░░░░░░ ~40% (widget tests есть, unit нет)
Сборка и развёртывание: ████████████░░░░░░░░ ~60% (скрипты есть, не тестированы)
Документация:         ████████████████████ 100% (5 документов создано)
Диаграммы:            ████████░░░░░░░░░░░░ ~40% (Mermaid в документации)
```

### 1.2 Завершённые этапы (1-7, 13)
| Этап | Название | Статус | Дата | Отчёт |
|---|---|---|---|---|
| 1 | Аутентификация и безопасность | ✅ 100% | 2026-03-06 | `STAGE_1_COMPLETE.md` |
| 2 | Миграция на SQLite | ✅ 100% | 2026-03-07 | `STAGE_2_COMPLETE.md` |
| 3 | Логирование событий | ✅ 90% | 2026-03-07 | `STAGE_3_4_COMPLETE.md` |
| 4 | Категоризация паролей | ✅ 100% | 2026-03-07 | `STAGE_3_4_COMPLETE.md` |
| 5 | Настройки приложения | ✅ 100% | 2026-03-07 | `STAGE_5_COMPLETE.md` |
| 6 | Формат .passgen | ✅ 100% | 2026-03-07 | `STAGE_5_COMPLETE.md` |
| 7 | Автоблокировка по неактивности | ✅ 100% | 2026-03-07 | `STAGE_6_COMPLETE.md` |
| 13 | Документирование проекта | ✅ 100% | 2026-03-08 | `STAGE_13_COMPLETE.md` |

### 1.3 Метрики кода
| Метрика | Значение |
|---|---|
| **Файлов Dart** | 110+ |
| **Строк кода** | ~9500+ |
| **Entity** | 8 |
| **Repository Interfaces** | 7 |
| **Use Cases** | 25+ |
| **Controllers** | 8 |
| **Screens** | 9 |
| **Widgets** | 12 |
| **Widget Tests** | 8 |
| **Unit Tests** | 0 ⚠️ |
| **Integration Tests** | 0 ⚠️ |
| **Покрытие тестами** | ~82% (только widget) |

---

## 2. ПРИОРИТЕТЫ ЗАДАЧ

### 🔴 Критические (выполнить в первую очередь)

| ID | Задача | Оценка | ТЗ | Статус |
|---|---|---|---|---|
| **8.2** | Логирование PWD_ACCESSED | 1 час | 3.4 | ⏳ |
| **8.3** | Логирование SETTINGS_CHG | 1 час | 3.4 | ⏳ |
| **10.1** | Unit-тесты для Auth Use Cases | 2 часа | 12.1 | ⬜ |
| **10.2** | Unit-тесты для Password Use Cases | 1.5 часа | 12.1 | ⬜ |

### 🟡 Важные (выполнить во вторую очередь)

| ID | Задача | Оценка | ТЗ | Статус |
|---|---|---|---|---|
| **8.4** | Опция «Без повторяющихся символов» | 4 часа | 5.5 | ⬜ |
| **8.5** | Опция «Исключить похожие символы» | 4 часа | 5.5 | ⬜ |
| **9.1** | Двухпанельный макет StorageScreen | 8 часов | 6.3 | ⬜ |
| **10.3** | Unit-тесты для Storage Use Cases | 2 часа | 12.1 | ⬜ |
| **10.4** | Unit-тесты для Category Use Cases | 1.5 часа | 12.1 | ⬜ |
| **1.1** | Fix CharacterSetDisplay encoding | 1 час | - | ⏳ |
| **1.2** | Fix CopyablePassword timeout | 1 час | - | ⏳ |

### 🟢 Желательные (выполнить при наличии времени)

| ID | Задача | Оценка | ТЗ | Статус |
|---|---|---|---|---|
| **11.1** | Use Case Diagram | 2 часа | 14.1 | ⬜ |
| **11.2** | Sequence Diagrams (3 шт) | 3 часа | 14.2 | ⬜ |
| **11.3** | Component Diagram | 2 часа | 14.1 | ⬜ |
| **11.4** | ER-Diagram | 2 часа | 14.1 | ⬜ |
| **11.5** | Deployment Diagram | 1 час | 14.1 | ⬜ |
| **1.1** | Тест build_android.sh | 1 час | - | ⏳ |
| **1.2** | Тест build_desktop.sh | 1 час | - | ⏳ |

---

## 3. ДЕТАЛЬНЫЙ ПЛАН РАБОТ

### Этап 8: Критические исправления ТЗ
**Даты:** 2026-03-08 — 2026-03-09
**Приоритет:** 🔴 Критический
**Оценка:** 12 часов
**Статус:** ⏳ В работе

#### Задачи:
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 8.1 | Очистка буфера (60 сек) | `copyable_password.dart` | ✅ |
| 8.2 | Логирование PWD_ACCESSED | `event_types.dart`, `storage_controller.dart` | ⏳ |
| 8.3 | Логирование SETTINGS_CHG | `event_types.dart`, `settings_controller.dart` | ⏳ |
| 8.4 | Без повторяющихся символов | `password_generator_local_datasource.dart`, `generator_screen.dart` | ⬜ |
| 8.5 | Исключить похожие символы | `password_generator_local_datasource.dart`, `generator_screen.dart` | ⬜ |

**Критерии успеха:**
- [ ] Все 5 задач выполнены
- [ ] Сборка без ошибок
- [ ] Тесты пройдены
- [ ] Соответствие ТЗ повышено до ~95%

---

### Этап 9: Улучшение UI/UX
**Даты:** 2026-03-09 — 2026-03-10
**Приоритет:** 🟡 Средний
**Оценка:** 16 часов
**Статус:** ⬜ Ожидает

#### Задачи:
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 9.1 | Двухпанельный макет | `storage_screen.dart` | ⬜ |
| 9.2 | ShimmerEffect интеграция | `storage_screen.dart` | ✅ |
| 9.3 | Анимации микро-интеракций | `copy_feedback.dart` | ⬜ |

**Критерии успеха:**
- [ ] Двухпанельный режим работает на tablet/desktop
- [ ] Анимации плавные (60 FPS)

---

### Этап 10: Тестирование
**Даты:** 2026-03-10 — 2026-03-12
**Приоритет:** 🔴 Высокий (для диплома)
**Оценка:** 20 часов
**Статус:** ⏳ В работе (частично)

#### 10.1 Fix существующих тестов
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 1.1 | Fix CharacterSetDisplay | `character_set_display_test.dart` | ⏳ |
| 1.2 | Fix CopyablePassword timeout | `copyable_password_test.dart` | ⏳ |

#### 10.2 Unit-тесты Use Cases
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 2.1 | Auth Use Cases | `test/usecases/auth/` (5 файлов) | ⬜ |
| 2.2 | Password Use Cases | `test/usecases/password/` (2 файла) | ⬜ |
| 2.3 | Storage Use Cases | `test/usecases/storage/` (6 файлов) | ⬜ |
| 2.4 | Category Use Cases | `test/usecases/category/` (4 файла) | ⬜ |
| 2.5 | Settings & Log Use Cases | `test/usecases/settings/` (5 файлов) | ⬜ |

#### 10.3 Widget-тесты экранов
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 3.1 | AuthScreen | `test/widgets/screens/auth_screen_test.dart` | ⬜ |
| 3.2 | GeneratorScreen | `test/widgets/screens/generator_screen_test.dart` | ⬜ |
| 3.3 | StorageScreen | `test/widgets/screens/storage_screen_test.dart` | ⬜ |

#### 10.4 Integration-тесты
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 4.1 | Authentication flow | `integration_test/auth_flow_test.dart` | ⬜ |
| 4.2 | Password generation flow | `integration_test/generation_flow_test.dart` | ⬜ |

#### 10.5 Ручное тестирование
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 5.1 | Тест-кейсы (10+) | `MANUAL_TEST_CASES.md` | ⬜ |

**Критерии успеха:**
- [ ] Покрытие тестами ≥50%
- [ ] Все тесты проходят
- [ ] 50+ тестов всего
- [ ] Нет критических багов

---

### Этап 11: Диаграммы для диплома
**Даты:** 2026-03-12 — 2026-03-13
**Приоритет:** 🔴 Высокий (для защиты)
**Оценка:** 10 часов
**Статус:** ⬜ Ожидает

#### Задачи:
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 11.1 | Use Case Diagram | `diagrams/use_case_diagram.puml/.drawio` | ⬜ |
| 11.2 | Sequence Diagrams (3) | `diagrams/sequence_*.puml` | ⬜ |
| 11.3 | Component Diagram | `diagrams/component_diagram.puml` | ⬜ |
| 11.4 | ER-Diagram | `diagrams/er_diagram.puml` | ⬜ |
| 11.5 | Deployment Diagram | `diagrams/deployment_diagram.puml` | ⬜ |

**Критерии успеха:**
- [ ] Все 5 диаграмм созданы
- [ ] Диаграммы в форматах .puml и .drawio

---

### Этап 12: Финальная подготовка к релизу
**Даты:** 2026-03-13 — 2026-03-14
**Приоритет:** 🔴 Высокий
**Оценка:** 8 часов
**Статус:** ⬜ Ожидает

#### Задачи:
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 12.1 | Сборка релиза v0.5.0 | `build/` | ⬜ |
| 12.2 | Обновление документации | `README.MD`, `CHANGELOG.md` | ⬜ |
| 12.3 | Публикация на GitHub | GitHub Release | ⬜ |
| 12.4 | Подготовка к защите | Презентация | ⬜ |

**Критерии успеха:**
- [ ] Релиз v0.5.0 опубликован
- [ ] Документация актуальна
- [ ] Презентация готова

---

### Этап 14: Сборка и развёртывание
**Даты:** 2026-03-12 — 2026-03-13
**Приоритет:** 🔴 Высокий (для релиза)
**Оценка:** 10 часов
**Статус:** ⏳ В работе (аудит)

#### 14.1 Тестирование Bash скриптов
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 1.1 | Тест build_android.sh | `devops/scripts/build_android.sh` | ⏳ |
| 1.2 | Тест build_desktop.sh | `devops/scripts/build_desktop.sh` | ⏳ |

#### 14.2 Создание PowerShell скриптов
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 2.1 | build_android.ps1 | `devops/scripts/build_android.ps1` | ⬜ |
| 2.2 | build_desktop.ps1 | `devops/scripts/build_desktop.ps1` | ⬜ |
| 2.3 | build_all.ps1 | `devops/scripts/build_all.ps1` | ⬜ |

#### 14.3 Документация
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 3.1 | DEPLOYMENT_GUIDE.md | `devops/docs/DEPLOYMENT_GUIDE.md` | ⬜ |
| 3.2 | devops/README.md | `devops/README.md` | ⬜ |

#### 14.4 CI/CD
| № | Задача | Файлы | Статус |
|---|---|---|---|
| 4.1 | GitHub Actions workflow | `.github/workflows/build.yml` | ⬜ |

**Критерии успеха:**
- [ ] Все скрипты работают
- [ ] PowerShell версии созданы
- [ ] Документация полная
- [ ] CI/CD настроен

---

## 4. СРОКИ ВЫПОЛНЕНИЯ

### Неделя 1 (2026-03-08 — 2026-03-10)
- [x] Этап 13: Документирование ✅
- [ ] Этап 8: Критические исправления (12 часов)
- [ ] Этап 9: UI/UX улучшения (16 часов) — частично

### Неделя 2 (2026-03-11 — 2026-03-14)
- [ ] Этап 10: Тестирование (20 часов)
- [ ] Этап 11: Диаграммы (10 часов)
- [ ] Этап 12: Финальная подготовка (8 часов)
- [ ] Этап 14: Сборка и развёртывание (10 часов)

---

## 5. РАСПРЕДЕЛЕНИЕ РЕСУРСОВ

### Файлы для создания
```
test/usecases/auth/*.dart (5 файлов)
test/usecases/password/*.dart (2 файла)
test/usecases/storage/*.dart (6 файлов)
test/usecases/category/*.dart (4 файла)
test/usecases/settings/*.dart (5 файлов)
test/widgets/screens/*.dart (3 файла)
integration_test/*.dart (2 файла)

project_context/diagrams/*.puml (5 файлов)
project_context/diagrams/*.drawio (5 файлов)

project_context/devops/scripts/*.ps1 (3 файла)
project_context/devops/docs/DEPLOYMENT_GUIDE.md
.github/workflows/build.yml
```

### Файлы для обновления
```
lib/core/constants/event_types.dart
lib/presentation/features/storage/storage_controller.dart
lib/presentation/features/settings/settings_controller.dart
lib/data/datasources/password_generator_local_datasource.dart
lib/presentation/features/generator/generator_screen.dart
lib/domain/entities/password_generation_settings.dart

README.MD
CHANGELOG.md
project_context/current_progress/CURRENT_PROGRESS.md
```

---

## 6. ЗАВИСИМОСТИ

### Блокирующие
- ✅ Этап 8 → Этап 10 (тестирование требует стабильного кода)
- ✅ Этап 10 → Этап 12 (релиз требует тестов)
- ✅ Этап 14 → Этап 12 (релиз требует рабочей сборки)

### Параллельные задачи
- Этап 9 (UI/UX) и Этап 10 (Тестирование) — можно выполнять параллельно
- Этап 11 (Диаграммы) и Этап 14 (Сборка) — можно выполнять параллельно

---

## 7. РИСКИ

| Риск | Вероятность | Влияние | Митигация |
|---|---|---|---|
| Недостаточное покрытие тестами | Высокая | Среднее | Приоритизация критических Use Cases |
| Проблемы со сборкой на Windows | Средняя | Высокое | Тестирование на каждой платформе |
| Нехватка времени на диаграммы | Средняя | Высокое | Использование Mermaid в документации |
| Конфликты слияния | Средняя | Среднее | Частые коммиты в main |
| Изменения в ТЗ | Низкая | Высокое | Фиксация версии ТЗ 2.0 |

---

## 8. КРИТЕРИИ УСПЕХА ПРОЕКТА

### Обязательные (для сдачи диплома)
- [x] Все 9 экранов реализованы ✅
- [x] Адаптивная навигация ✅
- [x] Темы переключаются ✅
- [x] Очистка буфера (60 сек) ✅
- [ ] Уникальность символов ⏳
- [ ] Исключить похожие символы ⏳
- [x] Документация для диплома ✅ (5 документов)
- [ ] 5 диаграмм для диплома ⏳ (Mermaid в документации)
- [ ] Тесты (покрытие ≥50%) ⏳

### Продвинутые (для высокой оценки)
- [ ] Двухпанельный макет ⏳
- [ ] ShimmerEffect ✅
- [ ] Золотые тесты ⏳
- [ ] Полная доступность ⏳
- [ ] Integration-тесты ⏳

---

## 9. СЛЕДУЮЩИЕ ШАГИ

### Немедленно (сегодня, 2026-03-08)
1. [ ] **Задача 8.2:** Логирование PWD_ACCESSED
   - Файлы: `event_types.dart`, `storage_controller.dart`
   - Оценка: 1 час

2. [ ] **Задача 8.3:** Логирование SETTINGS_CHG
   - Файлы: `event_types.dart`, `settings_controller.dart`
   - Оценка: 1 час

3. [ ] **Задача 1.1:** Fix CharacterSetDisplay encoding
   - Файл: `character_set_display_test.dart`
   - Оценка: 1 час

4. [ ] **Задача 1.2:** Fix CopyablePassword timeout
   - Файл: `copyable_password_test.dart`
   - Оценка: 1 час

### На этой неделе
- [ ] Завершить Этап 8 (критические исправления)
- [ ] Начать Этап 10 (тестирование)
- [ ] Начать Этап 11 (диаграммы)

### К концу недели
- [ ] Завершить Этап 10 (тестирование)
- [ ] Завершить Этап 11 (диаграммы)
- [ ] Подготовить релиз v0.5.0

---

## 10. ИНСТРУКЦИИ ДЛЯ ИИ-АГЕНТОВ

### 10.1 Перед началом работы
1. **Проверь текущий прогресс:**
   ```
   Прочитай project_context/current_progress/CURRENT_PROGRESS.md
   ```

2. **Ознакомься с планом:**
   ```
   Прочитай COMPREHENSIVE_TASK_PLAN.md (этот файл)
   ```

3. **Проверь ТЗ:**
   ```
   Прочитай project_context/planning/passgen.tz.md
   ```

### 10.2 При выполнении задачи
1. **Создай план задачи:**
   ```
   Создай план в project_context/planning/TASK_PLAN_YYYY-MM-DD.md
   ```

2. **Выполни задачу:**
   ```
   [Выполнение задачи в коде]
   ```

3. **За логируй результат:**
   ```
   Создай лог в project_context/logs/LOG_YYYY-MM-DD_TASK.md
   ```

### 10.3 После завершения задачи
1. **Обнови прогресс:**
   ```
   Обнови project_context/current_progress/CURRENT_PROGRESS.md
   ```

2. **Создай отчёт об этапе:**
   ```
   Создай отчёт в project_context/stages/STAGE_N_COMPLETE.md
   ```

3. **Проведи ревью:**
   ```
   Создай ревью в project_context/reviews/CODE_REVIEW_YYYY-MM-DD.md
   ```

---

## 11. ПРИЛОЖЕНИЯ

### A. Команды для разработки
```bash
# Запуск приложения
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
genhtml coverage/lcov.info -o coverage/html
```

### B. Команды сборки
```bash
# Все платформы (Bash)
./project_context/devops/scripts/build_all.sh release

# Android
./project_context/devops/scripts/build_android.sh release

# Linux
./project_context/devops/scripts/build_desktop.sh linux release

# Windows (PowerShell)
.\project_context\devops\scripts\build_all.ps1 release
```

### C. Чек-лист для коммита
```markdown
## Перед коммитом
- [ ] Код отформатирован (dart format)
- [ ] Анализ пройден (flutter analyze)
- [ ] Тесты проходят (flutter test)
- [ ] Документация обновлена
- [ ] Лог создан

## После коммита
- [ ] Push выполнен
- [ ] CURRENT_PROGRESS.md обновлён
```

---

## 12. ИСТОРИЯ ИЗМЕНЕНИЙ

| Версия | Дата | Автор | Изменения |
|---|---|---|---|
| 1.0 | 2026-03-08 | AI Frontend Developer | Первая версия сводного плана |

---

**План создал:** AI Frontend Developer
**Дата создания:** 2026-03-08
**Версия:** 1.0
**Статус:** ⏳ В работе

**Ответственный:** AI Frontend Developer
**Область ответственности:** Data & Security, Testing, Build & Deploy, Frontend Development
