# 🐛 План исправления багов PassGen v0.5.1

**Дата создания:** 8 марта 2026 г.  
**Версия приложения:** 0.5.1  
**Статус:** ✅ Готов к реализации  
**Приоритет:** 🔴 Критичный (блокирует релиз)

---

## 📊 ОБЗОР БАГОВ

| # | Баг | Критичность | Влияние | Оценка |
|---|-----|-------------|---------|--------|
| **1** | Клик по паролю не открывает детали | 🔴 Высокая | UX сломан | 2 часа |
| **2** | При сортировке пропадает левая панель | 🔴 Высокая | Данные не видны | 3 часа |
| **3** | Дублирование информации в Настройках | 🟡 Средняя | Путаница у пользователей | 1 час |
| **ИТОГО** | **3 бага** | **2 критичных** | **6 часов** |

---

# 🐛 БАГ #1: Клик по паролю не открывает детали

## 📋 Описание проблемы

**Симптом:** При нажатии на пароль в списке (левая панель) правая панель с деталями не отображается.

**Воспроизведение:**
1. Открыть хранилище паролей
2. Нажать на любую запись в списке (например, "Gmail")
3. **Ожидаемый результат:** Правая панель показывает детали пароля
4. **Фактический результат:** Ничего не происходит

**Ожидаемое поведение:**
- При клике на запись в списке → правая панель отображает полную информацию
- При клике на иконку "глаз" → показать/скрыть пароль
- При клике на иконку "копировать" → скопировать пароль в буфер

---

## 🔍 Анализ кода

### Текущая реализация

**Файл:** `lib/presentation/features/storage/storage_list_pane.dart`

**Проблема 1: `onEntrySelected` не вызывает `selectEntry` в контроллере**

```dart
// storage_list_pane.dart (строка 127)
onTap: () => onEntrySelected?.call(entry),  // ❌ Вызывается callback, но не selectEntry
```

**Проблема 2: В контроллере нет обновления selectedEntry при клике**

```dart
// storage_controller.dart
void selectEntry(PasswordEntry? entry) {
  _selectedEntry = entry;
  notifyListeners();
}
// ✅ Метод есть, но не вызывается из UI
```

**Проблема 3: В StorageAdaptiveLayout не отслеживается selectedEntry**

```dart
// storage_adaptive_layout.dart
// Нет реакции на изменение selectedEntry
```

---

## ✅ Решение

### Шаг 1: Обновить StorageListPane

**Файл:** `lib/presentation/features/storage/storage_list_pane.dart`

**Изменения:**

```dart
// БЫЛО (строка 127)
onTap: () => onEntrySelected?.call(entry),

// СТАЛО
onTap: () {
  // Вызываем selectEntry в контроллере
  final controller = context.read<StorageController>();
  controller.selectEntry(entry);
  
  // Дополнительно вызываем callback (если нужен)
  onEntrySelected?.call(entry);
},
```

**Полная замена:**

```dart
// В StorageListPane (строки 120-130)
onTap: () {
  // Выбираем запись в контроллере
  final controller = context.read<StorageController>();
  controller.selectEntry(entry);
},
onLongPress: () {
  // Показываем меню удаления
  _showDeleteConfirmation(context, entry);
},
```

**Добавить метод для подтверждения удаления:**

```dart
void _showDeleteConfirmation(BuildContext context, PasswordEntry entry) {
  final controller = context.read<StorageController>();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить пароль?'),
      content: Text('Вы точно хотите удалить пароль для сервиса "${entry.service}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            controller.deleteCurrentPassword();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}
```

---

### Шаг 2: Обновить StorageAdaptiveLayout

**Файл:** `lib/presentation/features/storage/storage_adaptive_layout.dart`

**Проблема:** Планшетный и десктопный макеты не отображают выбранную запись.

**Решение:**

```dart
// БЫЛО (строки 65-80)
class StorageTabletLayout extends StatelessWidget {
  const StorageTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    return Row(
      children: [
        // Левая панель: Список (40%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: StorageListPane(
            onEntrySelected: (entry) => controller.selectEntry(entry),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        
        // Правая панель: Детали (60%)
        Expanded(
          child: controller.selectedEntry == null
              ? const StorageEmptyDetailState()
              : StorageDetailPane(entry: controller.selectedEntry!),
        ),
      ],
    );
  }
}

// СТАЛО (добавлена проверка на null и дефолтное значение)
class StorageTabletLayout extends StatelessWidget {
  const StorageTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    // Если есть выбранные записи, но selectedEntry == null, выбираем первую
    if (controller.passwords.isNotEmpty && controller.selectedEntry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectEntry(controller.passwords.first);
      });
    }

    return Row(
      children: [
        // Левая панель: Список (40%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: StorageListPane(
            onEntrySelected: (entry) {
              controller.selectEntry(entry);
            },
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        
        // Правая панель: Детали (60%)
        Expanded(
          child: controller.selectedEntry == null
              ? const StorageEmptyDetailState(
                  message: 'Выберите пароль из списка',
                )
              : StorageDetailPane(entry: controller.selectedEntry!),
        ),
      ],
    );
  }
}
```

**Аналогично для StorageDesktopLayout:**

```dart
class StorageDesktopLayout extends StatelessWidget {
  const StorageDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StorageController>();

    // Автовыбор первой записи при загрузке
    if (controller.passwords.isNotEmpty && controller.selectedEntry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.selectedEntry == null && controller.passwords.isNotEmpty) {
          controller.selectEntry(controller.passwords.first);
        }
      });
    }

    return Row(
      children: [
        // NavigationRail (80dp)
        SizedBox(
          width: 80,
          child: NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {},
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.archive),
                label: Text('Хранилище'),
              ),
            ],
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        
        // Список паролей (320px)
        SizedBox(
          width: 320,
          child: StorageListPane(
            onEntrySelected: (entry) {
              controller.selectEntry(entry);
            },
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        
        // Детали (оставшееся место)
        Expanded(
          child: controller.selectedEntry == null
              ? const StorageEmptyDetailState(
                  message: 'Выберите пароль из списка',
                )
              : StorageDetailPane(entry: controller.selectedEntry!),
        ),
      ],
    );
  }
}
```

---

### Шаг 3: Добавить StorageEmptyDetailState

**Файл:** `lib/presentation/features/storage/storage_detail_pane.dart`

**Добавить виджет в конец файла:**

```dart
/// Пустое состояние панели деталей
class StorageEmptyDetailState extends StatelessWidget {
  final String message;

  const StorageEmptyDetailState({
    super.key,
    this.message = 'Выберите пароль из списка',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите на запись в списке, чтобы увидеть детали',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

---

### Шаг 4: Обновить StorageController

**Файл:** `lib/presentation/features/storage/storage_controller.dart`

**Добавить метод для очистки выбора при фильтрации:**

```dart
// Добавить после метода clearSelection()

/// Применение фильтров с сохранением выбора
void applyFiltersWithSelection() {
  final previouslySelected = _selectedEntry;
  
  _passwords = _allPasswords.where((entry) {
    if (_selectedCategoryId != null) {
      final entryCategoryId = entry.categoryId;
      if (entryCategoryId != _selectedCategoryId) {
        return false;
      }
    }
    if (_searchQuery.isNotEmpty && 
        !entry.service.toLowerCase().contains(_searchQuery)) {
      return false;
    }
    return true;
  }).toList();
  
  _currentIndex = 0;
  
  // Пытаемся сохранить выбор, если запись ещё в списке
  if (previouslySelected != null) {
    final stillExists = _passwords.any((p) => 
      p.service == previouslySelected.service && 
      p.login == previouslySelected.login
    );
    
    if (!stillExists) {
      // Выбранная запись отфильтрована, очищаем выбор
      _selectedEntry = _passwords.isNotEmpty ? _passwords.first : null;
    }
  } else if (_passwords.isNotEmpty) {
    // Если ничего не было выбрано, выбираем первую запись
    _selectedEntry = _passwords.first;
  }
  
  notifyListeners();
}
```

**Обновить метод setCategoryFilter:**

```dart
// БЫЛО
void setCategoryFilter(int? categoryId) {
  _selectedCategoryId = categoryId;
  _applyFilters();
}

// СТАЛО
void setCategoryFilter(int? categoryId) {
  _selectedCategoryId = categoryId;
  applyFiltersWithSelection();
}
```

**Обновить метод setSearchQuery:**

```dart
// БЫЛО
void setSearchQuery(String query) {
  _searchQuery = query.toLowerCase();
  _applyFilters();
}

// СТАЛО
void setSearchQuery(String query) {
  _searchQuery = query.toLowerCase();
  applyFiltersWithSelection();
}
```

---

## ✅ Критерии приёмки (Баг #1)

- [ ] При клике на запись в списке → правая панель отображает детали
- [ ] При клике на иконку "глаз" → пароль показывается/скрывается
- [ ] При клике на иконку "копировать" → пароль копируется в буфер
- [ ] При long press → показывается меню удаления
- [ ] При загрузке хранилища → первая запись выбирается автоматически
- [ ] При фильтрации → выбор сохраняется или сбрасывается корректно

---

# 🐛 БАГ #2: При сортировке пропадает левая панель

## 📋 Описание проблемы

**Симптом:** При применении фильтра (поиск по сервису или выбор категории) левая панель со списком паролей пропадает, отображается сообщение "Нет сохранённых паролей" на весь экран.

**Воспроизведение:**
1. Открыть хранилище паролей
2. Ввести текст в поле поиска (например, "gmail")
3. **Ожидаемый результат:** Список фильтруется, показываются matching записи
4. **Фактический результат:** Левая панель пропадает, отображается "Нет сохранённых паролей"

**Ожидаемое поведение:**
- При вводе поискового запроса → список фильтруется
- При выборе категории → список показывает записи этой категории
- Если записей нет → показывается "Нет записей по запросу" в левой панели

---

## 🔍 Анализ кода

### Текущая реализация

**Файл:** `lib/presentation/features/storage/storage_screen.dart`

**Проблема: Неправильная проверка isEmpty**

```dart
// storage_screen.dart (строки 90-100)
body: SafeArea(
  child: controller.isLoading
      ? ShimmerList(itemCount: 5, itemHeight: 120)
      : controller.isEmpty  // ❌ Проверяет isEmpty, который не учитывает фильтры
          ? const StorageEmptyState(...)
          : const StorageAdaptiveLayout(),
),
```

**Проблема в контроллере:**

```dart
// storage_controller.dart
bool get isEmpty => _passwords.isEmpty;  // ❌ Проверяет отфильтрованный список
```

**Когда применяется фильтр:**
1. `_passwords` становится пустым (если нет совпадений)
2. `isEmpty` возвращает `true`
3. Отображается `StorageEmptyState` на весь экран
4. `StorageAdaptiveLayout` не рендерится

---

## ✅ Решение

### Шаг 1: Разделить isEmpty и isFilterEmpty

**Файл:** `lib/presentation/features/storage/storage_controller.dart`

**Добавить новый геттер:**

```dart
// Добавить после геттера isEmpty

/// Есть ли вообще пароли в хранилище
bool get hasNoPasswords => _allPasswords.isEmpty;

/// Пуст ли результат фильтрации
bool get isFilterEmpty => _passwords.isEmpty;

/// Есть ли активный фильтр
bool get hasActiveFilter => _selectedCategoryId != null || _searchQuery.isNotEmpty;
```

---

### Шаг 2: Обновить StorageScreen

**Файл:** `lib/presentation/features/storage/storage_screen.dart`

**Изменения:**

```dart
// БЫЛО (строки 90-100)
body: SafeArea(
  child: controller.isLoading
      ? ShimmerList(itemCount: 5, itemHeight: 120)
      : controller.isEmpty
          ? const StorageEmptyState(
              icon: Icons.archive,
              title: 'Нет сохранённых паролей',
              subtitle: 'Создайте первый пароль прямо сейчас',
            )
          : const StorageAdaptiveLayout(),
),

// СТАЛО
body: SafeArea(
  child: controller.isLoading
      ? ShimmerList(itemCount: 5, itemHeight: 120)
      : controller.hasNoPasswords  // ✅ Проверяем, есть ли вообще пароли
          ? const StorageEmptyState(
              icon: Icons.archive,
              title: 'Нет сохранённых паролей',
              subtitle: 'Создайте первый пароль прямо сейчас',
            )
          : const StorageAdaptiveLayout(),
),
```

---

### Шаг 3: Обновить StorageListPane

**Файл:** `lib/presentation/features/storage/storage_list_pane.dart`

**Изменения:**

```dart
// БЫЛО (строки 65-70)
Expanded(
  child: controller.isEmpty
      ? const StorageEmptyListState()
      : ListView.builder(...),
),

// СТАЛО
Expanded(
  child: controller.isFilterEmpty  // ✅ Проверяем результат фильтрации
      ? StorageFilterEmptyState(
          hasActiveFilter: controller.hasActiveFilter,
          searchQuery: controller.searchQuery,
        )
      : ListView.builder(...),
),
```

---

### Шаг 4: Создать StorageFilterEmptyState

**Файл:** `lib/presentation/features/storage/storage_list_pane.dart`

**Добавить виджет в конец файла:**

```dart
/// Пустое состояние при фильтрации
class StorageFilterEmptyState extends StatelessWidget {
  final bool hasActiveFilter;
  final String searchQuery;

  const StorageFilterEmptyState({
    super.key,
    required this.hasActiveFilter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilter ? Icons.filter_alt_off : Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? 'Нет записей по фильтру'
                  : 'Ничего не найдено',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (hasActiveFilter) ...[
              Text(
                'Измените параметры фильтра или сбросьте его',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final controller = context.read<StorageController>();
                  controller.clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Сбросить фильтры'),
              ),
            ] else ...[
              Text(
                'Попробуйте другой поисковый запрос',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### Шаг 5: Обновить метод clearFilters

**Файл:** `lib/presentation/features/storage/storage_controller.dart`

**Изменения:**

```dart
// БЫЛО
void clearFilters() {
  _selectedCategoryId = null;
  _searchQuery = '';
  _passwords = List.from(_allPasswords);
  _currentIndex = 0;

  debugPrint('Filters cleared');
  notifyListeners();
}

// СТАЛО
void clearFilters() {
  _selectedCategoryId = null;
  _searchQuery = '';
  _passwords = List.from(_allPasswords);
  _currentIndex = 0;
  
  // Восстанавливаем выбор первой записи
  _selectedEntry = _passwords.isNotEmpty ? _passwords.first : null;

  debugPrint('Filters cleared');
  notifyListeners();
}
```

---

## ✅ Критерии приёмки (Баг #2)

- [ ] При вводе поискового запроса → список фильтруется, панель не пропадает
- [ ] При выборе категории → список показывает записи категории
- [ ] Если записей нет → показывается "Ничего не найдено" в левой панели
- [ ] Если записей вообще нет → показывается "Нет сохранённых паролей" на весь экран
- [ ] Кнопка "Сбросить фильтры" работает корректно
- [ ] Правая панель не пропадает при фильтрации

---

# 🐛 БАГ #3: Дублирование информации в Настройках

## 📋 Описание проблемы

**Симптом:** Страница настроек содержит раздел "О приложении" с информацией, которая дублирует страницу "О программе".

**Воспроизведение:**
1. Открыть Настройки
2. Прокрутить вниз до раздела "О приложении"
3. Нажать на "Версия" или "Лицензия"
4. **Ожидаемый результат:** Уникальная информация
5. **Фактический результат:** Та же информация, что на странице "О программе"

**Ожидаемое поведение:**
- Настройки содержат только настройки приложения
- Информация "О приложении" находится только на отдельной странице "О программе"

---

## 🔍 Анализ кода

### Текущая реализация

**Файл:** `lib/presentation/features/settings/settings_screen.dart`

**Проблема: Лишний раздел в настройках**

```dart
// settings_screen.dart (строки 125-145)
// Секция: О приложении
_buildSectionHeader('О приложении', theme),
_buildListTile(
  icon: Icons.info,
  title: 'Версия',
  subtitle: '0.4.0',
  onTap: () => _showInfoDialog(...),  // ❌ Дублирует AboutScreen
),
_buildListTile(
  icon: Icons.description,
  title: 'Лицензия',
  subtitle: 'MIT License',
  onTap: () => _showInfoDialog(...),  // ❌ Дублирует AboutScreen
),
```

---

## ✅ Решение

### Шаг 1: Удалить раздел "О приложении" из настроек

**Файл:** `lib/presentation/features/settings/settings_screen.dart`

**Изменения:**

```dart
// БЫЛО (строки 120-145)
const SizedBox(height: 16),

// Секция: О приложении
_buildSectionHeader('О приложении', theme),
_buildListTile(
  icon: Icons.info,
  title: 'Версия',
  subtitle: '0.4.0',
  onTap: () => _showInfoDialog(
    context,
    'PassGen',
    'Менеджер паролей с локальным шифрованием\n\nВерсия: 0.4.0\nFlutter + SQLite\nChaCha20-Poly1305',
  ),
),
_buildListTile(
  icon: Icons.description,
  title: 'Лицензия',
  subtitle: 'MIT License',
  onTap: () => _showInfoDialog(
    context,
    'Лицензия',
    'MIT License\n\nCopyright (c) 2024',
  ),
),

// СТАЛО
// Просто удалить весь раздел "О приложении"
// Навигация на AboutScreen остаётся в нижней навигационной панели
```

**Полный код после удаления:**

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final controller = context.watch<SettingsController>();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Настройки'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Секция: Безопасность
        _buildSectionHeader('Безопасность', theme),
        _buildListTile(
          icon: Icons.pin,
          title: 'Сменить PIN-код',
          onTap: () => _showChangePinDialog(context, controller),
        ),
        _buildListTile(
          icon: Icons.lock_outline,
          title: 'Удалить PIN-код',
          onTap: () => _showRemovePinDialog(context, controller),
          textColor: Colors.red,
        ),

        const SizedBox(height: 16),

        // Секция: Данные
        _buildSectionHeader('Данные', theme),
        _buildListTile(
          icon: Icons.folder,
          title: 'Категории',
          subtitle: 'Управление категориями паролей',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            );
          },
        ),

        const SizedBox(height: 16),

        // Секция: Логи
        _buildSectionHeader('Журнал событий', theme),
        _buildListTile(
          icon: Icons.history,
          title: 'Просмотр логов',
          subtitle: 'Записей: $_logsCount',
          onTap: () => _showLogsDialog(context, controller),
        ),
        _buildListTile(
          icon: Icons.delete_sweep,
          title: 'Очистить логи',
          onTap: () => _confirmClearLogs(context, controller),
          textColor: Colors.orange,
        ),

        // ❌ Удалить раздел "О приложении"
        // const SizedBox(height: 16),
        // _buildSectionHeader('О приложении', theme),
        // ...
      ],
    ),
  );
}
```

---

### Шаг 2: Удалить неиспользуемые методы

**Файл:** `lib/presentation/features/settings/settings_screen.dart`

**Удалить методы (больше не используются):**

```dart
// Удалить метод _showInfoDialog
void _showInfoDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}
```

---

### Шаг 3: Обновить навигацию (опционально)

**Файл:** `lib/app/app.dart`

**Проверить, что навигация на AboutScreen работает:**

```dart
enum AppTab {
  generator(Icons.create, 'Генератор'),
  encryptor(Icons.lock, 'Шифратор'),
  storage(Icons.archive, 'Хранилище'),
  settings(Icons.settings, 'Настройки'),
  about(Icons.info, 'О программе'),  // ✅ Убедиться, что есть
}
```

---

## ✅ Критерии приёмки (Баг #3)

- [ ] Раздел "О приложении" удалён из настроек
- [ ] Метод `_showInfoDialog` удалён
- [ ] Навигация на AboutScreen работает через нижнюю панель
- [ ] Информация "О приложении" отображается только на странице "О программе"

---

# 📅 ПОШАГОВЫЙ ПЛАН РЕАЛИЗАЦИИ

## День 1: Баг #1 (Клик по паролю)

| Время | Задача | Файл | Статус |
|---|---|---|---|
| 0:00-0:30 | Анализ кода | `storage_list_pane.dart` | ⬜ |
| 0:30-1:00 | Обновить onTap в StorageListPane | `storage_list_pane.dart` | ⬜ |
| 1:00-1:30 | Обновить StorageTabletLayout | `storage_adaptive_layout.dart` | ⬜ |
| 1:30-2:00 | Обновить StorageDesktopLayout | `storage_adaptive_layout.dart` | ⬜ |
| 2:00-2:30 | Добавить StorageEmptyDetailState | `storage_detail_pane.dart` | ⬜ |
| 2:30-3:00 | Обновить StorageController | `storage_controller.dart` | ⬜ |
| 3:00-3:30 | **Тестирование** | Ручное тестирование | ⬜ |

**Итого День 1:** 3.5 часа

---

## День 2: Баг #2 (Фильтрация)

| Время | Задача | Файл | Статус |
|---|---|---|---|
| 0:00-0:30 | Добавить геттеры hasNoPasswords, isFilterEmpty | `storage_controller.dart` | ⬜ |
| 0:30-1:00 | Обновить StorageScreen | `storage_screen.dart` | ⬜ |
| 1:00-1:30 | Обновить StorageListPane | `storage_list_pane.dart` | ⬜ |
| 1:30-2:00 | Создать StorageFilterEmptyState | `storage_list_pane.dart` | ⬜ |
| 2:00-2:30 | Обновить clearFilters | `storage_controller.dart` | ⬜ |
| 2:30-3:00 | **Тестирование** | Ручное тестирование | ⬜ |

**Итого День 2:** 3 часа

---

## День 3: Баг #3 (Дублирование) + Финальное тестирование

| Время | Задача | Файл | Статус |
|---|---|---|---|
| 0:00-0:30 | Удалить раздел "О приложении" | `settings_screen.dart` | ⬜ |
| 0:30-1:00 | Удалить _showInfoDialog | `settings_screen.dart` | ⬜ |
| 1:00-1:30 | Проверить навигацию | `app.dart` | ⬜ |
| 1:30-2:30 | **Финальное тестирование** | Все 3 бага | ⬜ |
| 2:30-3:00 | **Сборка и проверка** | `flutter build` | ⬜ |

**Итого День 3:** 3 часа

---

## 📊 ОБЩАЯ СВОДКА

| Этап | Задач | Время | Статус |
|---|---|---|---|
| **День 1** | 6 | 3.5 часа | Баг #1 |
| **День 2** | 5 | 3 часа | Баг #2 |
| **День 3** | 3 | 3 часа | Баг #3 + тесты |
| **ВСЕГО** | **14** | **9.5 часов** | **3 дня** |

---

## ✅ ЧЕК-ЛИСТ ПЕРЕД КОММИТОМ

### Перед каждым коммитом
```bash
# 1. Запустить анализ
flutter analyze

# 2. Проверить сборку
flutter build linux --release

# 3. Ручное тестирование
# - Клик по паролю открывает детали ✅
# - Фильтрация не ломает UI ✅
# - В настройках нет дублирования ✅
```

### Чек-лист задач
```markdown
## Баг #1: Клик по паролю
- [ ] onTap вызывает selectEntry в контроллере
- [ ] StorageTabletLayout отображает selectedEntry
- [ ] StorageDesktopLayout отображает selectedEntry
- [ ] StorageEmptyDetailState создан
- [ ] Автовыбор первой записи работает

## Баг #2: Фильтрация
- [ ] hasNoPasswords проверяет _allPasswords
- [ ] isFilterEmpty проверяет _passwords
- [ ] StorageFilterEmptyState создан
- [ ] Кнопка "Сбросить фильтры" работает
- [ ] Правая панель не пропадает

## Баг #3: Дублирование
- [ ] Раздел "О приложении" удалён
- [ ] Метод _showInfoDialog удалён
- [ ] Навигация на AboutScreen работает
```

---

## 🎯 ОЖИДАЕМЫЕ РЕЗУЛЬТАТЫ

### До исправлений
```
❌ Баг #1: Клик по паролю не работает
❌ Баг #2: При фильтрации пропадает панель
❌ Баг #3: Дублирование информации
```

### После исправлений
```
✅ Баг #1: Клик открывает детали
✅ Баг #2: Фильтрация работает корректно
✅ Баг #3: Информация не дублируется
```

---

**План составил:** Технический Писатель (ИИ-агент)  
**Дата:** 8 марта 2026 г.  
**Версия:** 1.0  
**Статус:** ✅ Готов к реализации

---

**PassGen v0.5.1** | [MIT License](../../LICENSE)
