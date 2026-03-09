# 📋 Frontend Implementation Plan — UI/UX Designer Improvements

**Дата:** 2026-03-08
**На основе:** IMPROVEMENT_PLAN_COMPLETION_REPORT.md (UI/UX Designer)
**Статус:** ⏳ В работе

---

## 1. ОБЗОР

План внедрения улучшений от UI/UX дизайнера во фронтенд.

**Источник:** `project_context/design/IMPROVEMENT_PLAN_COMPLETION_REPORT.md`

---

## 2. ЗАДАЧИ ДЛЯ FRONTEND

### 🔴 Приоритет 1: Критические улучшения

#### Задача F-1.1: Двухпанельный макет Storage
**Спецификация:** `for_development/storage_two_pane.json`
**Оценка:** 8 часов
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Обновить `storage_screen.dart` с LayoutBuilder
2. Реализовать mobile layout (< 600dp) — текущий
3. Реализовать tablet layout (600-899dp) — two-pane
4. Реализовать desktop layout (≥ 900dp) — three-pane

**Файлы:**
- `lib/presentation/features/storage/storage_screen.dart`
- `lib/presentation/features/storage/storage_controller.dart`

**Пример:**
```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < Breakpoints.tabletMin) {
    return _buildMobileLayout();
  } else if (width < Breakpoints.desktopMin) {
    return _buildTabletLayout(); // Two-pane
  } else {
    return _buildDesktopLayout(); // Three-pane
  }
}
```

---

#### Задача F-1.2: Адаптивные кнопки (48dp/40dp)
**Спецификация:** `for_development/components.json` (v1.1.0)
**Оценка:** 2 часа
**Статус:** ✅ Выполнено (AppButton)

**Что сделано:**
- `AppButton` использует адаптивную высоту
- Mobile: 48dp
- Desktop: 40dp

---

#### Задача F-1.3: Empty States
**Спецификация:** `final/empty_state_*.txt`
**Оценка:** 3 часа
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Создать виджет `EmptyState`
2. Реализовать 4 состояния:
   - Empty storage (нет паролей)
   - Empty search (ничего не найдено)
   - Empty logs (нет событий)
   - Empty categories (нет пользовательских)

**Файлы:**
- `lib/presentation/widgets/empty_state.dart`
- `lib/presentation/features/storage/storage_screen.dart`
- `lib/presentation/features/logs/logs_screen.dart`
- `lib/presentation/features/categories/categories_screen.dart`

---

### 🟡 Приоритет 2: Анимации и доступность

#### Задача F-2.1: Lottie анимации
**Спецификация:** `animations_spec.md`, `animations/*.json`
**Оценка:** 4 часа
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Добавить пакет `lottie` в `pubspec.yaml`
2. Интегрировать 3 анимации:
   - `copy_success.json` — успешное копирование
   - `pin_error.json` — ошибка PIN (тряска)
   - `strength_pulse.json` — индикатор стойкости

**Файлы:**
- `pubspec.yaml` (добавить `lottie: ^3.0.0`)
- `lib/presentation/widgets/copy_feedback.dart`
- `lib/presentation/features/auth/auth_screen.dart`
- `lib/presentation/features/generator/generator_screen.dart`

---

#### Задача F-2.2: Semantics для доступности
**Спецификация:** `guidelines/guidelines.md` (Раздел 10)
**Оценка:** 4 часа
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Добавить `Semantics` виджеты для всех интерактивных элементов
2. Добавить `tooltip` для всех `IconButton`
3. Добавить `label` для всех `TextField`
4. Проверить навигацию с клавиатуры

**Файлы:**
- `lib/presentation/widgets/*.dart`
- `lib/presentation/features/*/*.dart`

**Пример:**
```dart
Semantics(
  label: 'Копировать пароль для ${entry.service}',
  hint: 'Дважды нажмите для копирования',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.copy),
    tooltip: 'Копировать пароль',
    onPressed: () => _copyPassword(entry.password),
  ),
)
```

---

#### Задача F-2.3: Error handling UI
**Спецификация:** `error_states_spec.md`
**Оценка:** 3 часа
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Интегрировать `GlobalErrorBanner` в контроллеры
2. Добавить обработку ошибок валидации
3. Добавить empty/loading states

**Файлы:**
- `lib/presentation/widgets/global_error_banner.dart` ✅ (создан)
- `lib/presentation/features/*/*_controller.dart`

---

### 🟢 Приоритет 3: Полировка

#### Задача F-3.1: Адаптивная навигация
**Спецификация:** `navigation.json`
**Оценка:** ✅ Выполнено (app.dart)

**Что сделано:**
- BottomNavigationBar для мобильных
- NavigationRail для планшетов/десктопов

---

#### Задача F-3.2: Анимации переходов
**Спецификация:** `animations_spec.md`
**Оценка:** 2 часа
**Статус:** ⏳ Ожидает

**Что сделать:**
1. Добавить `AnimatedSwitcher` для переключения макетов
2. Добавить `AnimatedContainer` для выделения элементов
3. Добавить page transitions

**Файлы:**
- `lib/presentation/features/storage/storage_screen.dart`
- `lib/app/app.dart`

---

## 3. МАТРИЦА ОТВЕТСТВЕННОСТИ

| Задача | UI/UX | Frontend | Статус |
|---|---|---|---|
| Двухпанельный макет | ✅ Spec готов | ⏳ В работу | ⏳ |
| Empty states | ✅ Mockups готовы | ⏳ В работу | ⏳ |
| Lottie анимации | ✅ JSON готовы | ⏳ В работу | ⏳ |
| Semantics | ✅ Guidelines готовы | ⏳ В работу | ⏳ |
| Error handling | ✅ Spec готов | ✅ Частично | ⏳ |
| Адаптивные кнопки | ✅ Spec готов | ✅ Выполнено | ✅ |
| Адаптивная навигация | ✅ Spec готов | ✅ Выполнено | ✅ |

---

## 4. ПЛАН РАБОТ

### Этап 1: Критические задачи (1-2 дня)
1. [ ] Двухпанельный макет Storage (8 часов)
2. [ ] Empty states (3 часа)

### Этап 2: Анимации и доступность (2-3 дня)
1. [ ] Lottie анимации (4 часа)
2. [ ] Semantics для доступности (4 часа)
3. [ ] Error handling integration (3 часа)

### Этап 3: Полировка (1 день)
1. [ ] Анимации переходов (2 часа)

**Итого:** 24 часа (3-4 дня)

---

## 5. ТЕКУЩИЙ ПРОГРЕСС

| Задача | Статус | Прогресс |
|---|---|---|
| F-1.1 Двухпанельный макет | ⏳ | 0% |
| F-1.2 Адаптивные кнопки | ✅ | 100% |
| F-1.3 Empty states | ⏳ | 0% |
| F-2.1 Lottie анимации | ⏳ | 0% |
| F-2.2 Semantics | ⏳ | 0% |
| F-2.3 Error handling | ⏳ | 50% |
| F-3.1 Адаптивная навигация | ✅ | 100% |
| F-3.2 Анимации переходов | ⏳ | 0% |

**Общий прогресс:** 2/8 задач (25%)

---

## 6. СЛЕДУЮЩИЕ ШАГИ

### Немедленно:
1. [ ] Начать задачу F-1.1 (Двухпанельный макет)

### На этой неделе:
1. [ ] Завершить Этап 1 (Двухпанельный макет + Empty states)
2. [ ] Начать Этап 2 (Lottie + Semantics)

---

**План создал:** AI Frontend Developer
**Дата:** 2026-03-08
**Версия:** 1.0
**Статус:** ⏳ В работе
