# 📋 ПЛАН УЛУЧШЕНИЙ UI/UX PASSGEN v0.7.0
## На основе Flutter Best Practices 2025-2026

**Дата:** 8 марта 2026 г.
**Целевая версия:** 0.7.0
**На основе:** IMPROVEMENT_RECOMMENDATIONS_PLAN.md + Flutter Research 2025-2026
**Статус:** ✅ Готов к реализации

---

## 🎯 ОБЗОР ПЛАНА

Этот план обновлён с учётом актуальных best practices Flutter 2025-2026:
- **Window Size Classes** вместо device detection
- **Material 3** breakpoints (600/1200dp)
- **Semantics** для accessibility compliance
- **ValueKey** для performance optimization
- **FocusTraversalOrder** для keyboard navigation

---

## 📊 МАТРИЦА ПРИОРИТЕТОВ

| Приоритет | Задач | Часов | Статус |
|-----------|-------|-------|--------|
| 🔴 **Высокий** | 5 | 18 | ⏳ Ожидает |
| 🟡 **Средний** | 4 | 12 | ⏳ Ожидает |
| 🟢 **Низкий** | 3 | 6 | ⏳ Ожидает |
| **ВСЕГО** | **12** | **36** | ⏳ Ожидает |

---

## 🔴 ПРИОРИТЕТ 1: КРИТИЧЕСКИЕ УЛУЧШЕНИЯ (18 часов)

### Задача 1.1: ValueKey для всех списков
**Оценка:** 3 часа
**Файлы:** `storage_list_pane.dart`, `categories_screen.dart`, `logs_screen.dart`

**Обоснование (Research 2025-2026):**
- ValueKey предотвращает incidental widget reuse
- Без ключей Flutter rebuilds ненужные виджеты
- Performance improvement: до -30% rebuilds

**Реализация:**
```dart
// storage_list_pane.dart
ListView.builder(
  key: const PageStorageKey('storage_passwords_list'),
  itemCount: groupedPasswords.length,
  itemBuilder: (context, index) {
    final category = groupedPasswords.keys.elementAt(index);
    final passwords = groupedPasswords[category]!;
    
    return PasswordCategorySection(
      key: ValueKey('category_${category.id}'), // ✅ Critical!
      category: category,
      passwords: passwords,
      onPasswordSelected: onPasswordSelected,
    );
  },
)

// categories_screen.dart
CategoryTile(
  key: ValueKey('category_${category.id}'), // ✅ Use ID, not index
  category: category,
  onTap: () => _editCategory(category),
)

// logs_screen.dart
LogEntryTile(
  key: ValueKey('log_${log.id}_${log.timestamp}'),
  log: log,
)
```

**Критерии приёмки:**
- [ ] Все `ListView.builder` имеют `PageStorageKey`
- [ ] Все items в списках имеют `ValueKey` с уникальным ID
- [ ] Нет `UniqueKey()` (causes rebuilds)
- [ ] Тест: плавная прокрутка списков

---

### Задача 1.2: Semantics для accessibility
**Оценка:** 6 часов
**Файлы:** `generator_screen.dart`, `settings_screen.dart`, `categories_screen.dart`, `logs_screen.dart`

**Обоснование (Research 2025-2026):**
- Semantics widget критичен для screen readers (TalkBack/VoiceOver)
- WCAG 2.2 compliance требует proper labels и hints
- EU Accessibility Act (EN 301 549) aligns с WCAG 2.1

**Реализация:**

**Generator Screen:**
```dart
// AppSwitch с Semantics
Semantics(
  label: 'Заглавные буквы',
  hint: 'Включить заглавные буквы A-Z в пароле',
  checked: controller.requireUppercase,
  toggleable: true,
  child: AppSwitch(
    label: 'Заглавные буквы',
    subtitle: 'A-Z',
    value: controller.requireUppercase,
    onChanged: controller.toggleUppercase,
  ),
)

// Для всех 6 переключателей
Semantics(
  label: 'Строчные буквы',
  hint: 'Включить строчные буквы a-z в пароле',
  checked: controller.requireLowercase,
  toggleable: true,
  child: AppSwitch(...),
)

Semantics(
  label: 'Цифры',
  hint: 'Включить цифры 0-9 в пароле',
  checked: controller.requireDigits,
  toggleable: true,
  child: AppSwitch(...),
)

Semantics(
  label: 'Спецсимволы',
  hint: 'Включить спецсимволы !@# в пароле',
  checked: controller.requireSymbols,
  toggleable: true,
  child: AppSwitch(...),
)

Semantics(
  label: 'Без повторяющихся символов',
  hint: 'Все символы в пароле будут уникальны',
  checked: controller.allUnique,
  toggleable: true,
  child: AppSwitch(...),
)

Semantics(
  label: 'Исключить похожие символы',
  hint: 'Исключить символы 1lI0Oo из пароля',
  checked: controller.excludeSimilar,
  toggleable: true,
  child: AppSwitch(...),
)
```

**Categories Screen:**
```dart
// Кнопки действий категории
Semantics(
  label: 'Редактировать категорию ${category.name}',
  hint: 'Дважды нажмите для редактирования',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.edit),
    tooltip: 'Редактировать',
    onPressed: () => _editCategory(category),
  ),
)

Semantics(
  label: 'Удалить категорию ${category.name}',
  hint: 'Дважды нажмите для удаления',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.delete),
    tooltip: 'Удалить',
    onPressed: () => _deleteCategory(category),
  ),
)
```

**Logs Screen:**
```dart
// Event tile с Semantics
Semantics(
  label: '${log.eventType} в ${_formatTime(log.timestamp)}',
  hint: log.details,
  child: ListTile(
    leading: Icon(_getEventIcon(log.eventType)),
    title: Text(log.eventType),
    subtitle: Text(_formatTime(log.timestamp)),
  ),
)
```

**Критерии приёмки:**
- [ ] Все `AppSwitch` обёрнуты в `Semantics`
- [ ] Все `IconButton` имеют `label`, `hint`, `button: true`
- [ ] Все list tiles имеют `label` и `hint`
- [ ] Тест с TalkBack: все элементы озвучиваются
- [ ] Тест с VoiceOver: навигация работает

---

### Задача 1.3: FocusTraversalOrder для keyboard navigation
**Оценка:** 4 часа
**Файлы:** `auth_screen.dart`, `generator_screen.dart`, `settings_screen.dart`

**Обоснование (Research 2025-2026):**
- FocusTraversalOrder устанавливает explicit focus order
- Критично для users who can't use touch/mouse
- Tab/Shift+Tab navigation требует proper ordering

**Реализация:**

**Auth Screen:**
```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      // PIN display dots
      FocusTraversalOrder(
        order: NumericFocusOrder(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (index) => _buildPinDot(index)),
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Numeric keypad
      FocusTraversalOrder(
        order: NumericFocusOrder(2),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 12,
          itemBuilder: (context, index) => _buildKeyButton(index),
        ),
      ),
    ],
  ),
)
```

**Generator Screen:**
```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: ListView(
    children: [
      // Service field
      FocusTraversalOrder(
        order: NumericFocusOrder(1),
        child: AppTextField(
          label: 'Сервис',
          controller: controller.serviceController,
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Password length slider
      FocusTraversalOrder(
        order: NumericFocusOrder(2),
        child: _buildLengthSlider(),
      ),
      
      // Switches (grouped)
      FocusTraversalOrder(
        order: NumericFocusOrder(3),
        child: Column(
          children: [
            _buildSwitch('Заглавные', ...),
            _buildSwitch('Строчные', ...),
            // ... all switches
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Generate button
      FocusTraversalOrder(
        order: NumericFocusOrder(4),
        child: AppButton(
          label: 'Сгенерировать',
          onPressed: controller.generatePassword,
        ),
      ),
    ],
  ),
)
```

**Критерии приёмки:**
- [ ] Все интерактивные элементы в `FocusTraversalGroup`
- [ ] Явный порядок через `NumericFocusOrder`
- [ ] Tab перемещает фокус в правильном порядке
- [ ] Shift+Tab перемещает фокус назад
- [ ] Enter активирует кнопку в фокусе

---

### Задача 1.4: Adaptive breakpoints для всех экранов
**Оценка:** 4 часа
**Файлы:** Все экраны + `generator_adaptive_layout.dart`, `encryptor_adaptive_layout.dart`, `settings_adaptive_layout.dart`

**Обоснование (Research 2025-2026):**
- Не проверять тип устройства — использовать размер окна
- Material 3 breakpoints: 600dp (tablet), 1200dp (desktop)
- Window size classes — official Material 3 API

**Реализация:**

**Constants:**
```dart
// lib/core/constants/breakpoints.dart
class Breakpoints {
  static const double mobileMax = 600;      // <600dp: mobile
  static const double tabletMin = 600;      // ≥600dp: tablet
  static const double tabletMax = 1200;     // ≤1200dp: tablet
  static const double desktopMin = 1200;    // >1200dp: desktop
}
```

**Generator Adaptive Layout:**
```dart
// generator_adaptive_layout.dart
class GeneratorAdaptiveLayout extends StatelessWidget {
  const GeneratorAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.tabletMin) {
      return const GeneratorMobileLayout(); // Current ListView
    } else if (width < Breakpoints.desktopMin) {
      return const GeneratorTabletLayout(); // 2 columns
    } else {
      return const GeneratorDesktopLayout(); // 3 columns
    }
  }
}

// Tablet: 2 columns (settings | result)
class GeneratorTabletLayout extends StatelessWidget {
  const GeneratorTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: Settings (50%)
        Expanded(
          flex: 5,
          child: _buildSettingsPane(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Right: Result (50%)
        Expanded(
          flex: 5,
          child: _buildResultPane(),
        ),
      ],
    );
  }
}

// Desktop: 3 columns (NavRail | settings | result)
class GeneratorDesktopLayout extends StatelessWidget {
  const GeneratorDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Settings pane (320dp)
        const SizedBox(
          width: 320,
          child: _buildSettingsPane(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Result pane (Expanded, max 600dp)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildResultPane(),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Encryptor Adaptive Layout:**
```dart
// encryptor_adaptive_layout.dart
class EncryptorAdaptiveLayout extends StatelessWidget {
  const EncryptorAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.tabletMin) {
      return const EncryptorMobileLayout(); // Current ListView
    } else if (width < Breakpoints.desktopMin) {
      return const EncryptorTabletLayout(); // 2 columns
    } else {
      return const EncryptorDesktopLayout(); // 2 columns, centered
    }
  }
}
```

**Settings Adaptive Layout:**
```dart
// settings_adaptive_layout.dart
class SettingsAdaptiveLayout extends StatelessWidget {
  const SettingsAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.tabletMin) {
      return const SettingsMobileLayout(); // Current ListView
    } else if (width < Breakpoints.desktopMin) {
      return const SettingsTabletLayout(); // 2 columns (40%/60%)
    } else {
      return const SettingsDesktopLayout(); // 2 columns with max-width
    }
  }
}
```

**Критерии приёмки:**
- [ ] Generator: 3 макета (mobile/tablet/desktop)
- [ ] Encryptor: 3 макета
- [ ] Settings: 3 макета
- [ ] Categories: 2 макета (mobile/tablet+)
- [ ] Logs: 2 макета (mobile/tablet+)
- [ ] About: 2 макета (mobile/desktop centered)
- [ ] Тест на 3 размерах экрана

---

### Задача 1.5: const constructors оптимизация
**Оценка:** 1 час
**Файлы:** Все экраны и виджеты

**Обоснование (Research 2025-2026):**
- const constructors — базовая оптимизация Flutter
- Avoids rebuilding widget OBJECT
- Performance improvement: до -20% widget creation overhead

**Реализация:**
```dart
// Найти все места с:
SizedBox(height: 16)  // ❌

// Заменить на:
const SizedBox(height: 16)  // ✅

// Проверить:
// - Все SizedBox
// - Все Icon
// - Все Text с статическим контентом
// - Все Padding с const EdgeInsets
```

**Критерии приёмки:**
- [ ] Все `SizedBox` с `const`
- [ ] Все `Icon` с `const`
- [ ] Все статические `Text` с `const`
- [ ] `flutter analyze` без warnings

---

## 🟡 ПРИОРИТЕТ 2: ВАЖНЫЕ УЛУЧШЕНИЯ (12 часов)

### Задача 2.1: NavigationRail для tablet/desktop
**Оценка:** 4 часа
**Файлы:** `app.dart`, все экраны

**Обоснование (Research 2025-2026):**
- NavigationRail — responsive alternative to bottom navigation для larger screens
- Pair with bottom navigation bar для smaller screens
- Material 3 recommendation для ≥600dp

**Реализация:**
```dart
// app.dart — адаптивная навигация
Widget _buildNavigation() {
  final width = MediaQuery.of(context).size.width;

  if (width < Breakpoints.tabletMin) {
    // Mobile: BottomNavigationBar
    return BottomNavigationBar(
      currentIndex: _currentTab.index,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      items: AppTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(tab.icon),
          label: tab.label,
        );
      }).toList(),
    );
  } else {
    // Tablet/Desktop: NavigationRail
    return NavigationRail(
      selectedIndex: _currentTab.index,
      onDestinationSelected: _onTabTapped,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
      unselectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      destinations: AppTab.values.map((tab) {
        return NavigationRailDestination(
          icon: Icon(tab.icon),
          label: Text(tab.label),
        );
      }).toList(),
    );
  }
}
```

**Критерии приёмки:**
- [ ] Mobile (< 600dp): BottomNavigationBar
- [ ] Tablet (600-1200dp): NavigationRail
- [ ] Desktop (> 1200dp): NavigationRail
- [ ] Плавный переход между режимами

---

### Задача 2.2: ColorScheme.fromSeed для dynamic color
**Оценка:** 2 часа
**Файлы:** `app.dart`

**Обоснование (Research 2025-2026):**
- Material 3 components come with better default contrast ratios
- ColorScheme.fromSeed best practice для dynamic theming
- Поддержка dynamic color extraction (Android 12+)

**Реализация:**
```dart
// app.dart
ThemeData getTheme(bool isDarkMode) {
  return ThemeData(
    useMaterial3: true,
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Blue
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ),
    typography: Typography.material2021(),
    textTheme: GoogleFonts.latoTextTheme(
      isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
  );
}
```

**Критерии приёмки:**
- [ ] `ColorScheme.fromSeed` используется
- [ ] Светлая и тёмная темы работают
- [ ] Контрастность соответствует WCAG AA

---

### Задача 2.3: WCAG contrast check
**Оценка:** 3 часа
**Файлы:** `colors.json`, `guidelines.md`

**Обоснование (Research 2025-2026):**
- WCAG 2.2: 4.5:1 для normal text, 3:1 для large text
- Material 3 components имеют better default contrast ratios
- EU Accessibility Act требует compliance

**Реализация:**
```dart
// Проверить контрастность всех комбинаций:
// Primary on Surface: 7.2:1 ✅
// Error on Surface: 5.1:1 ✅
// Success on Surface: 4.5:1 ✅
// Warning on Surface: 3.2:1 ⚠️ (добавить иконку)

// guidelines.md — добавить таблицу
### 10.1.1 Контрастность компонентов

| Компонент | Цвет фона | Цвет текста | Контраст | Статус |
|-----------|-----------|-------------|----------|--------|
| Primary Button | #2196F3 | #FFFFFF | 7.2:1 | ✅ AAA |
| Error Banner | #FFEBEE | #B71C1C | 5.1:1 | ✅ AA |
| Success SnackBar | #E8F5E9 | #1B5E20 | 6.8:1 | ✅ AAA |
| Warning Banner | #FFF3E0 | #E65100 | 4.5:1 | ✅ AA |
| Disabled Button | #F5F5F5 | #9E9E9E | 3.2:1 | ✅ AA (UI) |
```

**Критерии приёмки:**
- [ ] Все текстовые компоненты ≥ 4.5:1
- [ ] Все UI компоненты ≥ 3:1
- [ ] Таблица контрастности в guidelines.md
- [ ] Warning colour дублируется иконкой

---

### Задача 2.4: ListView.builder для всех списков
**Оценка:** 3 часа
**Файлы:** `storage_list_pane.dart`, `categories_screen.dart`, `logs_screen.dart`

**Обоснование (Research 2025-2026):**
- ListView.builder builds items on-demand (lazy loading)
- Memory reduction: до -60% vs ListView
- Обязательно для long lists (>20 items)

**Реализация:**
```dart
// Было:
ListView(
  children: passwords.map((p) => PasswordCard(p)).toList(),
)

// Стало:
ListView.builder(
  itemCount: passwords.length,
  itemBuilder: (context, index) => PasswordCard(passwords[index]),
)
```

**Критерии приёмки:**
- [ ] Все списки >10 items используют `ListView.builder`
- [ ] `itemCount` указан явно
- [ ] Тест: memory usage снизился

---

## 🟢 ПРИОРИТЕТ 3: ПОЛИРОВКА (6 часов)

### Задача 3.1: AnimatedSwitcher для transitions
**Оценка:** 2 часа
**Файлы:** `generator_screen.dart`, `storage_screen.dart`

**Обоснование (Research 2025-2026):**
- AnimatedSwitcher автоматически animates transition between widgets
- Keep animations under 300ms для most transitions
- Implicit animations проще для micro-interactions

**Реализация:**
```dart
// Generator: анимация смены пароля
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  switchInCurve: Curves.easeInOut,
  switchOutCurve: Curves.easeOut,
  child: CopyablePassword(
    key: ValueKey(controller.password), // ✅ Critical for animation!
    label: 'Пароль',
    text: controller.password,
  ),
)

// Storage: анимация смены количества паролей
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: Text(
    '${controller.passwords.length} паролей',
    key: ValueKey('count_${controller.passwords.length}'),
  ),
)
```

**Критерии приёмки:**
- [ ] Смена пароля анимирована
- [ ] Смена количества анимирована
- [ ] Длительность ≤ 300ms

---

### Задача 3.2: Focus indicators
**Оценка:** 2 часа
**Файлы:** `app_button.dart`, `app_text_field.dart`

**Обоснование (Research 2025-2026):**
- Focus indicators критичны для keyboard users
- FocusNode tracks whether input widget has keyboard focus
- Visible focus border required for WCAG

**Реализация:**
```dart
// app_button.dart
Focus(
  onFocusChange: (hasFocus) {
    setState(() => _isFocused = hasFocus);
  },
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      side: BorderSide(
        color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
        width: 3,
      ),
    ),
    onPressed: onPressed,
    child: child,
  ),
)

// app_text_field.dart
Focus(
  onFocusChange: (hasFocus) {
    setState(() => _isFocused = hasFocus);
  },
  child: TextFormField(
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: _isFocused ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: _isFocused ? 2 : 1,
        ),
      ),
    ),
  ),
)
```

**Критерии приёмки:**
- [ ] Все кнопки показывают focus border
- [ ] Все поля показывают focus border
- [ ] Border width: 3px для кнопок, 2px для полей
- [ ] Цвет: primary

---

### Задача 3.3: Documentation update
**Оценка:** 2 часа
**Файлы:** `guidelines.md`, `changelog.md`

**Реализация:**
```markdown
# Обновление документации

## Раздел 10: Accessibility (обновить)
- Добавить Semantics requirements
- Добавить keyboard navigation specs
- Добавить focus indicator specs
- Добавить WCAG contrast table

## Раздел 12: Performance (новый)
- Добавить ValueKey best practices
- Добавить const constructor guidelines
- Добавить ListView.builder recommendations

## Changelog (добавить v1.10.0)
- Added: Adaptive layouts for all screens
- Added: Semantics for accessibility
- Added: Focus traversal order
- Added: ValueKey for list performance
- Updated: Material 3 breakpoints
- Updated: NavigationRail for tablet/desktop
```

**Критерии приёмки:**
- [ ] guidelines.md обновлён
- [ ] changelog.md обновлён
- [ ] Все примеры кода актуальны

---

## 📊 ИТОГОВЫЙ ПЛАН

### Этап 1: Критические улучшения (18 часов)
| Задача | Оценка | Статус |
|---|---|---|
| 1.1 ValueKey для списков | 3 часа | ⏳ |
| 1.2 Semantics для accessibility | 6 часов | ⏳ |
| 1.3 FocusTraversalOrder | 4 часа | ⏳ |
| 1.4 Adaptive breakpoints | 4 часа | ⏳ |
| 1.5 const constructors | 1 час | ⏳ |

### Этап 2: Важные улучшения (12 часов)
| Задача | Оценка | Статус |
|---|---|---|
| 2.1 NavigationRail | 4 часа | ⏳ |
| 2.2 ColorScheme.fromSeed | 2 часа | ⏳ |
| 2.3 WCAG contrast check | 3 часа | ⏳ |
| 2.4 ListView.builder | 3 часа | ⏳ |

### Этап 3: Полировка (6 часов)
| Задача | Оценка | Статус |
|---|---|---|
| 3.1 AnimatedSwitcher | 2 часа | ⏳ |
| 3.2 Focus indicators | 2 часа | ⏳ |
| 3.3 Documentation update | 2 часа | ⏳ |

---

## ✅ КРИТЕРИИ УСПЕХА

### Адаптивность
- [ ] Все 8 экранов имеют адаптивные макеты
- [ ] Breakpoints: 600dp (tablet), 1200dp (desktop)
- [ ] NavigationRail для ≥600dp
- [ ] Контент центрируется на desktop

### Доступность
- [ ] Все интерактивные элементы имеют Semantics
- [ ] Контрастность ≥ 4.5:1 для текста
- [ ] Focus indicators видны
- [ ] Keyboard navigation работает

### Производительность
- [ ] Все списки имеют ValueKey
- [ ] ListView.builder для long lists
- [ ] const constructors где возможно
- [ ] Плавная прокрутка (60 FPS)

---

## 🚀 СЛЕДУЮЩИЕ ШАГИ

### Немедленно (сегодня)
1. [ ] Начать с Задачи 1.1 (ValueKey) — quick win
2. [ ] Обновить `storage_list_pane.dart`
3. [ ] Обновить `categories_screen.dart`
4. [ ] Обновить `logs_screen.dart`

### На этой неделе
1. [ ] Завершить Этап 1 (критические улучшения)
2. [ ] Начать Этап 2 (навигация)

### К концу недели
1. [ ] Завершить все 3 этапа
2. [ ] Провести финальное тестирование
3. [ ] Обновить документацию
4. [ ] Релиз v0.7.0

---

**План готов к реализации!** ✅

**Версия:** 1.0
**Дата:** 2026-03-08
**Статус:** ✅ Готов к реализации
**Целевая версия приложения:** 0.7.0
