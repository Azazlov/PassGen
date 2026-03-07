# ТЕХНИЧЕСКОЕ ЗАДАНИЕ (ТЗ)
## На разработку пользовательского интерфейса и пользовательского опыта (UI/UX)
### Для кроссплатформенного менеджера паролей «PassGen»

**Статус документа:** Утверждён  
**Версия:** 2.0 (полная)  
**Дата:** 2024  
**Тип проекта:** Дипломная работа / Прикладное ПО  
**Платформа:** Flutter (Mobile/Desktop/Web)

---

## 1. ОБЩИЕ ПОЛОЖЕНИЯ

### 1.1 Назначение документа
Настоящее техническое задание определяет требования к пользовательскому интерфейсу (UI) и пользовательскому опыту (UX) приложения PassGen. Документ предназначен для разработчиков, дизайнеров и руководителей проекта.

### 1.2 Область применения
ТЗ распространяется на все экраны приложения, компоненты интерфейса, адаптивные макеты, анимации и взаимодействия с пользователем.

### 1.3 Термины и определения

| Термин | Определение |
|---|---|
| **Брейкпоинт** | Контрольная ширина экрана для переключения макетов |
| **Clean Architecture** | Архитектурный паттерн разделения ответственности (Presentation/Domain/Data) |
| **ChangeNotifier** | Механизм управления состоянием во Flutter (Provider) |
| **KDF** | Key Derivation Function — функция деривации ключа |
| **Nonce** | Number used once — уникальное число для шифрования |

---

## 2. ДИЗАЙН-СИСТЕМА

### 2.1 Дизайн-система: Material 3

| Параметр | Значение |
|---|---|
| **Версия** | Material Design 3 (Material You) |
| **Основной цвет** | `ColorScheme.fromSeed(seedColor: Colors.blue)` |
| **Темы** | Светлая / Тёмная (авто или вручную) |
| **Шрифты** | Google Fonts (Roboto / Inter) с fallback на системные |
| **Иконки** | Material Symbols Outlined |

### 2.2 Цветовая схема

```dart
// lib/app/theme.dart
ThemeData getTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      tertiary: Colors.teal,
      error: Colors.red,
      success: Colors.green,
      warning: Colors.orange,
    ),
    // Кастомизация компонентов
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: Size(0, 48), // Мобильный стандарт
      ),
    ),
    cardTheme: CardTheme(
      elevation: brightness == Brightness.light ? 1 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

### 2.3 Типографика

| Стиль | Размер (моб.) | Размер (деск.) | Использование |
|---|---|---|---|
| `displayLarge` | 57 sp | 64 sp | Заголовки экранов (Auth) |
| `headlineLarge` | 32 sp | 40 sp | Заголовки разделов |
| `headlineMedium` | 28 sp | 32 sp | Подзаголовки |
| `titleLarge` | 22 sp | 24 sp | Названия карточек |
| `titleMedium` | 16 sp | 18 sp | Элементы списков |
| `bodyLarge` | 16 sp | 16 sp | Основной текст |
| `bodyMedium` | 14 sp | 14 sp | Вторичный текст, подсказки |
| `labelLarge` | 14 sp | 14 sp | Кнопки, чипы (жирный) |

### 2.4 Система отступов и сетка

```dart
// lib/core/constants/spacing.dart
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Базовая сетка: 8dp
// Все отступы кратны 4dp (предпочтительно 8dp)
```

---

## 3. АДАПТИВНОСТЬ И БРЕЙКПОИНТЫ

### 3.1 Брейкпоинты (фиксированные значения)

```dart
// lib/core/constants/breakpoints.dart
class Breakpoints {
  static const double mobileMax = 600;      // <600dp: мобильные
  static const double tabletMin = 600;      // ≥600dp: планшеты
  static const double desktopMin = 900;     // ≥900dp: десктоп
  static const double wideMin = 1200;       // ≥1200dp: широкоформатные
}
```

### 3.2 Типы макетов по устройствам

| Тип устройства | Ширина | Навигация | Макет | Особенности |
|---|---|---|---|---|
| **📱 Мобильный** | < 600 dp | BottomNavigationBar | Однопанельный | Вертикальный скролл, FAB |
| **📱 Планшет** | 600–900 dp | NavigationRail | Двухпанельный | Список + детали рядом |
| **💻 Десктоп** | 900–1200 dp | NavigationRail + Sidebar | Многопанельный | GridView, фиксированная ширина контента |
| **🖥️ Широкий** | > 1200 dp | Permanent Sidebar | Трёхпанельный | Навигация + список + детали одновременно |

### 3.3 Паттерн адаптивной вёрстки

```dart
// Пример: адаптивный экран хранилища
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < Breakpoints.mobileMax) {
        return _buildMobileLayout(); // BottomNav + ListView
      } else if (constraints.maxWidth < Breakpoints.desktopMin) {
        return _buildTabletLayout(); // NavRail + двухпанельный
      } else {
        return _buildDesktopLayout(); // Sidebar + GridView + детали
      }
    },
  );
}
```

### 3.4 Адаптивные компоненты

| Компонент | Мобильный | Планшет/Десктоп |
|---|---|---|
| **Навигация** | `BottomNavigationBar` (5 пунктов) | `NavigationRail` или `Drawer` |
| **Диалоги** | `AlertDialog` (на весь экран) | `Dialog` (фиксированная ширина 500dp) |
| **Кнопки** | Высота 48 dp, fullWidth | Высота 40 dp, фиксированная ширина |
| **Поля ввода** | Высота 56 dp, крупный шрифт | Высота 48 dp, стандартный шрифт |
| **Списки** | `ListView` с отступами 16 dp | `GridView` или `DataTable` с отступами 24 dp |
| **Карточки** | `Card` с elevation 1 | `Card` с elevation 0 + border |
| **FAB** | `FloatingActionButton` (справа снизу) | `ElevatedButton` в панели инструментов |

---

## 4. ЭКРАН АВТОРИЗАЦИИ (AuthScreen)

### 4.1 Назначение
Первичная аутентификация пользователя по PIN-коду. Защита сессии и мастер-ключа.

### 4.2 Макет

```
┌─────────────────────────────────┐
│                                 │
│         [🔐 Логотип]            │
│         PassGen                 │
│                                 │
│      Введите PIN-код            │
│    [●●●●] (4-8 цифр)           │
│                                 │
│  [1] [2] [3]                    │
│  [4] [5] [6]  ← Цифровая        │
│  [7] [8] [9]     клавиатура     │
│  [❌] [0] [⌫]                    │
│                                 │
│  [Войти] (кнопка)               │
│                                 │
│  ⚠️ Ошибка: "Неверный PIN"     │
│     [████░░░░] 30 сек блокировка│
│                                 │
└─────────────────────────────────┘
```

### 4.3 Виджеты и структура

| Виджет | Назначение | Адаптивность |
|---|---|---|
| `Center` + `Column` | Центрирование контента | `mainAxisAlignment: MainAxisAlignment.center` |
| `Text` (заголовок) | "Введите PIN-код" | `style: Theme.of(context).textTheme.headlineSmall` |
| `Row` + `AnimatedBuilder` | Отображение введённых символов (●) | Анимация появления точек |
| `GridView.builder` (3x4) | Цифровая клавиатура | На мобильном — на весь экран, на десктопе — компактная |
| `ElevatedButton` | Кнопка "Войти" | `minWidth: double.infinity` на мобильном, `200` на десктопе |
| `SnackBar` / `Banner` | Ошибки аутентификации | `SnackBar` на мобильном, `Banner` сверху на десктопе |
| `LinearProgressIndicator` | Блокировка после неудачных попыток | Показывается при `lockoutTime > 0` |

### 4.4 Поведение и логика

| Действие | Реакция UI |
|---|---|
| Ввод цифры | Добавление точки (●), вибрация (haptic feedback) |
| Ввод 4+ символов | Кнопка "Войти" становится активной |
| Нажатие "Войти" | Индикатор загрузки → проверка → навигация или ошибка |
| 5 неудачных попыток | Блокировка 30 сек, прогресс-бар обратного отсчёта |
| Успешный вход | Анимация перехода → главный экран |
| Таймаут неактивности 5 мин | Автоматический возврат на экран авторизации |

### 4.5 Требования безопасности UI

| Требование | Реализация |
|---|---|
| **Маскировка ввода** | Отображать `●` вместо цифр |
| **Защита от скриншотов** | На Android: `FLAG_SECURE` через `flutter_secure_window` |
| **Очистка поля** | Автоматическая очистка после входа/ошибки |
| **Отключение автозаполнения** | `autofillHints: null`, `enableSuggestions: false` |
| **Затирание ключа** | Мастер-ключ затирается нулями при выходе из сессии |

---

## 5. ЭКРАН ГЕНЕРАТОРА ПАРОЛЕЙ (GeneratorScreen)

### 5.1 Назначение
Генерация криптографически стойких паролей по настраиваемым параметрам.

### 5.2 Макет (мобильный)

```
┌─────────────────────────┐
│ 🔙 Назад  │ Генератор  │
├─────────────────────────┤
│                         │
│ [Сгенерированный пароль]│
│ ••••••••••••••••       │
│ [👁] [📋 Копировать]    │
│                         │
│ ───── Стойкость ─────   │
│ [████████░░] Надёжный  │
│                         │
│ ▼ Настройки генерации   │
│                         │
│ Длина: [8────●───64] 16│
│                         │
│ [✓] Строчные (a-z)     │
│ [✓] Заглавные (A-Z)    │
│ [✓] Цифры (0-9)        │
│ [✓] Спецсимволы (!@#)  │
│ [ ] Без повторов       │
│ [ ] Исключить похожие  │
│                         │
│ ▼ Пресеты              │
│ [Стандартный] [Надёжный]│
│ [Максимальный] [Свой+] │
│                         │
│ [🔄 Сгенерировать]      │
│ [💾 Сохранить в хранилище]│
└─────────────────────────┘
```

### 5.3 Макет (десктоп — двухколоночный)

```
┌─────────────────────────────────────┐
│ Генератор паролей                   │
├──────────────┬──────────────────────┤
│ НАСТРОЙКИ    │ РЕЗУЛЬТАТ            │
│              │                      │
│ Длина: ──●── │ [Сгенерированный    │
│ [8]    [64]  │  пароль здесь...]   │
│              │                      │
│ [✓] a-z      │ [👁] [📋] [🔄]      │
│ [✓] A-Z      │                      │
│ [✓] 0-9      │ ─── Стойкость ───   │
│ [✓] !@#      │ [████████░░] 85/100 │
│ [ ] Уникальные│                     │
│ [ ] Без l1I0 │ ▼ Пресеты:          │
│              │ [Стандартный] [Надёжный]│
│ ▼ Пресеты    │                      │
│ [Сохранить как...]│ [💾 Сохранить] │
└──────────────┴──────────────────────┘
```

### 5.4 Виджеты и структура

| Секция | Виджеты | Адаптивность |
|---|---|---|
| **Заголовок** | `AppBar` + `Text` | На десктопе — без кнопки "Назад" |
| **Результат** | `Card` + `SelectableText` + `IconButton` | На десктопе — крупный шрифт, фиксированная высота |
| **Индикатор стойкости** | `LinearProgressIndicator` + `Text` | Цвет: красный → жёлтый → зелёный |
| **Слайдер длины** | `Slider` с `TextField` для точного ввода | На десктопе — с полями `[min]` и `[max]` по бокам |
| **Чекбоксы настроек** | `CheckboxListTile` | Вертикальный список на мобильном, сетка 2x2 на десктопе |
| **Пресеты** | `Wrap` + `FilterChip` | Горизонтальный скролл на мобильном, сетка на десктопе |
| **Кнопки действий** | `ElevatedButton` + `OutlinedButton` | На мобильном — вертикальный стек, на десктопе — горизонтальная строка |

### 5.5 Параметры генерации (из ТЗ)

| Параметр | Диапазон / Значения | UI элемент |
|---|---|---|
| **Длина пароля** | 8–64 символа | `Slider` + `TextField` |
| **Строчные буквы** | Вкл/Выкл (a-z) | `CheckboxListTile` |
| **Заглавные буквы** | Вкл/Выкл (A-Z) | `CheckboxListTile` |
| **Цифры** | Вкл/Выкл (0-9) | `CheckboxListTile` |
| **Спецсимволы** | Вкл/Выкл (!@#$%^&*) | `CheckboxListTile` |
| **Уникальность** | Вкл/Выкл (без повторов) | `SwitchListTile` |
| **Исключить похожие** | Вкл/Выкл (l, 1, I, O, 0) | `SwitchListTile` |

### 5.6 Пресеты генерации

| Профиль | Конфигурация | Кнопка |
|---|---|---|
| **Стандартный** | 12 символов, буквы+цифры | `FilterChip(label: 'Стандартный')` |
| **Надёжный** | 16 символов, все категории | `FilterChip(label: 'Надёжный')` |
| **Максимальный** | 32 символа, все категории+уникальность | `FilterChip(label: 'Максимальный')` |
| **PIN-код** | 4-6 цифр | `FilterChip(label: 'PIN')` |
| **Пользовательский** | Сохраняется в БД | `FilterChip(label: 'Свой+', onSelected: savePreset)` |

### 5.7 Индикатор надёжности

```dart
// lib/presentation/widgets/strength_indicator.dart
Widget buildStrengthIndicator(double score) {
  Color color;
  String label;
  
  if (score < 30) {
    color = Colors.red;
    label = 'Слабый';
  } else if (score < 60) {
    color = Colors.orange;
    label = 'Средний';
  } else if (score < 80) {
    color = Colors.yellow;
    label = 'Надёжный';
  } else {
    color = Colors.green;
    label = 'Очень надёжный';
  }
  
  return Column(
    children: [
      LinearProgressIndicator(value: score / 100, color: color),
      SizedBox(height: 4),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ],
  );
}
```

---

## 6. ЭКРАН ХРАНИЛИЩА ПАРОЛЕЙ (StorageScreen)

### 6.1 Назначение
Просмотр, поиск, фильтрация и управление сохранёнными учётными данными (CRUD).

### 6.2 Макет (мобильный — список)

```
┌─────────────────────────┐
│ 🔍 Поиск...            │
│ [🗂️ Все] [👥 Соцсети]  │ ← Категории (horizontal scroll)
├─────────────────────────┤
│                         │
│ ▼ Банки (3)            │
│ ┌─────────────────┐    │
│ │ 🏦 Сбербанк     │    │
│ │ login: user123  │    │
│ │ [👁] [📋] [✏️]  │    │
│ └─────────────────┘    │
│                         │
│ ▼ Почта (2)            │
│ ┌─────────────────┐    │
│ │ 📧 Gmail        │    │
│ │ login: me@gmail │    │
│ │ [👁] [📋] [✏️]  │    │
│ └─────────────────┘    │
│                         │
│ [➕ Добавить запись]    │ ← FAB
└─────────────────────────┘
```

### 6.3 Макет (планшет/десктоп — двухпанельный)

```
┌─────────────────────────────────────┐
│ Хранилище паролей                   │
├──────────────┬──────────────────────┤
│ СПИСОК       │ ДЕТАЛИ               │
│              │                      │
│ 🔍 Поиск...  │ ┌─────────────────┐ │
│              │ │ 🏦 Сбербанк     │ │
│ [🗂️ Все]    │ │                 │ │
│ [👥 Соцсети] │ │ Логин:          │ │
│ [🏦 Банки]   │ │ [user123     ] │ │
│              │ │                 │ │
│ ▼ Банки (3)  │ │ Пароль:         │ │
│ • Сбербанк ● │ │ [••••••••] [👁]│ │
│ • Тинькофф   │ │ [📋 Копировать] │ │
│ • Альфа      │ │                 │ │
│              │ │ Категория: [Банки ▼]│
│ ▼ Почта (2)  │ │                 │ │
│ • Gmail      │ │ Создан: 01.01.24│ │
│ • Yahoo      │ │ Обновлено: сегодня│
│              │ │                 │ │
│ [➕ Добавить]│ │ [✏️ Редактировать]│
│              │ │ [🗑️ Удалить]    │ │
└──────────────┴──────────────────────┘
```

### 6.4 Виджеты и структура

| Секция | Виджеты | Адаптивность |
|---|---|---|
| **Поиск** | `TextField` с `InputDecoration(prefixIcon: Icon(Icons.search))` | На десктопе — фиксированная ширина |
| **Фильтр категорий** | `Wrap` с `FilterChip` | Горизонтальный скролл на мобильном, вертикальный список на десктопе |
| **Список записей** | `ExpansionTile` + `ListTile` для группировки | На десктопе — всегда развёрнутые группы |
| **Карточка пароля** | `Card` + `ListTile` + `Row` с иконками | На десктопе — более компактный `ListTile` |
| **Детали записи** | `Form` + `TextFormField` + `DropdownButton` | На мобильном — отдельный экран, на десктопе — панель справа |
| **Действия** | `IconButton` (показать, копировать, редактировать, удалить) | На мобильном — в `ListTile.trailing` |
| **FAB / Кнопка добавления** | `FloatingActionButton` / `ElevatedButton` | Справа снизу (моб.) / сверху панели (деск.) |

### 6.5 Карточка пароля (PasswordCard)

```dart
// lib/presentation/widgets/password_card.dart
class PasswordCard extends StatelessWidget {
  final PasswordEntryEntity password;
  
  const PasswordCard({Key? key, required this.password}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getCategoryIcon(password.category), size: 32),
        title: Text(password.service, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${password.login} • ${password.category.name}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.visibility), onPressed: () => _showPassword(password)),
            IconButton(icon: Icon(Icons.copy), onPressed: () => _copyPassword(password)),
            IconButton(icon: Icon(Icons.edit), onPressed: () => _editPassword(password)),
          ],
        ),
        onTap: () => _openDetails(password),
        onLongPress: () => _showDeleteConfirmation(password),
      ),
    );
  }
}
```

### 6.6 Очистка буфера обмена

| Требование | Реализация |
|---|---|
| **Таймаут** | 60 секунд после копирования |
| **Уведомление** | `SnackBar` с текстом "Пароль скопирован" |
| **Очистка** | `Clipboard.setData(ClipboardData(text: ''))` через `Future.delayed` |

---

## 7. ЭКРАН НАСТРОЕК (SettingsScreen)

### 7.1 Назначение
Управление приложением, данными, безопасностью и внешним видом.

### 7.2 Макет

```
┌─────────────────────────────────┐
│ Настройки                       │
├─────────────────────────────────┤
│                                 │
│ 🔐 Безопасность                 │
│ ┌─────────────────┐            │
│ │ Сменить PIN-код │            │
│ │ Автоблокировка: │            │
│ │ [5 мин ▼]       │            │
│ │ Очистить буфер: │            │
│ │ [✓] через 60 сек│            │
│ └─────────────────┘            │
│                                 │
│ 📦 Данные                       │
│ ┌─────────────────┐            │
│ │ [📤 Экспорт]    │            │
│ │ [📥 Импорт]     │            │
│ │ Формат: [JSON ▼]│            │
│ │ Очистить логи:  │            │
│ │ [🗑️ Удалить]   │            │
│ └─────────────────┘            │
│                                 │
│ 🎨 Интерфейс                    │
│ ┌─────────────────┐            │
│ │ Тема: [Системная ▼]│         │
│ │ [Светлая] [Тёмная]│          │
│ │ Язык: [Русский ▼]│           │
│ └─────────────────┘            │
│                                 │
│ ℹ️ О приложении                │
│ ┌─────────────────┐            │
│ │ Версия: 1.0.0   │            │
│ │ [Исходный код]  │            │
│ │ [Лицензия]      │            │
│ └─────────────────┘            │
│                                 │
└─────────────────────────────────┘
```

### 7.3 Виджеты

| Секция | Виджеты | Примечания |
|---|---|---|
| **Группы настроек** | `Card` + `Column` + `ListTile` | Каждая группа — отдельная карточка |
| **Переключатели** | `SwitchListTile` | Для опций типа "Очистить буфер" |
| **Выпадающие списки** | `DropdownButton` внутри `ListTile` | Для выбора времени блокировки, темы, формата |
| **Кнопки действий** | `ListTile` с `onTap` + `trailing: Icon(Icons.chevron_right)` | Для навигации к подэкранам |
| **Экспорт/Импорт** | `ElevatedButton.icon` + `FilePicker` | При нажатии — диалог выбора файла |
| **О приложении** | `AboutListTile` или кастомный `ListTile` | Ссылки на лицензию, репозиторий |

### 7.4 Форматы экспорта/импорта

| Формат | Расширение | Шифрование | Статус |
|---|---|---|---|
| **PassGen** | `.passgen` | ChaCha20-Poly1305 + Base64 | ✅ Обязательно |
| **JSON Mini** | `.json` | ChaCha20-Poly1305 + Base64 | ✅ Обязательно |
| **CSV** | `.csv` | Нет (только экспорт) | 🔲 Перспектива |

---

## 8. ЭКРАН О ПРИЛОЖЕНИИ (AboutScreen)

### 8.1 Назначение
Информация о приложении, авторе, технологиях и лицензии.

### 8.2 Макет

```
┌─────────────────────────────────┐
│         [🔐 Логотип]            │
│                                 │
│        PassGen                  │
│     Версия 1.0.0                │
│                                 │
│  Кроссплатформенный менеджер    │
│  паролей с локальным шифрованием│
│                                 │
│  ───── Технологии ─────         │
│  • Flutter / Dart               │
│  • SQLite                       │
│  • ChaCha20-Poly1305           │
│  • Clean Architecture           │
│                                 │
│  ───── Автор ─────              │
│  [Имя Фамилия]                  │
│  [Учебное заведение]            │
│                                 │
│  [🔗 Исходный код] [📄 Лицензия]│
│                                 │
│        [Закрыть]                │
└─────────────────────────────────┘
```

### 8.3 Виджеты

| Элемент | Виджет | Стиль |
|---|---|---|
| Логотип | `Image.asset` или `Icon` | Крупный, центрированный |
| Название | `Text` | `headlineMedium`, жирный |
| Описание | `Text` | `bodyLarge`, центрированный |
| Список технологий | `Column` + `ListTile` | Компактный список с иконками |
| Ссылки | `TextButton.icon` | С иконками `Icons.code`, `Icons.description` |
| Кнопка закрытия | `ElevatedButton` | Центрированная, `minWidth: 200` |

---

## 9. ИЕРАРХИЯ ВИДЖЕТОВ И ДЕКОМПОЗИЦИЯ

### 9.1 Принцип Composition over Inheritance

Каждый виджет должен иметь **одну и только одну ответственность**. Сложные экраны строятся из простых, самодостаточных компонентов.

### 9.2 Структура папок Presentation

```
📁 lib/presentation/
├── 📁 screens/
│   ├── auth_screen.dart          # Контейнер: только компоновка
│   ├── generator_screen.dart
│   ├── storage_screen.dart
│   ├── settings_screen.dart
│   └── about_screen.dart
├── 📁 widgets/
│   ├── 📁 reusable/
│   │   ├── password_card.dart    # Низкоуровневый: отображение 1 записи
│   │   ├── search_bar.dart       # Переиспользуемый поиск
│   │   ├── adaptive_dialog.dart  # Диалог с адаптивной шириной
│   │   ├── strength_indicator.dart # Индикатор надёжности
│   │   └── pin_keyboard.dart     # Цифровая клавиатура для PIN
│   └── 📁 forms/
│       ├── pin_input.dart        # Поле ввода PIN
│       └── password_form.dart    # Форма создания/редактирования
└── 📁 controllers/
    ├── auth_controller.dart
    ├── generator_controller.dart
    ├── storage_controller.dart
    └── settings_controller.dart
```

### 9.3 Требования к переиспользуемым виджетам

| Виджет | Ответственность | Зависимости |
|---|---|---|
| `PasswordCard` | Отображение карточки пароля | Только `PasswordEntryEntity` |
| `SearchBar` | Поле поиска с авто-фильтрацией | `ValueChanged<String>` callback |
| `AdaptiveDialog` | Диалог с адаптивной шириной | `Widget content`, `VoidCallback onConfirm` |
| `StrengthIndicator` | Визуализация надёжности пароля | `double strengthScore` (0–100) |
| `PinKeyboard` | Цифровая клавиатура для ввода PIN | `Function(String) onPinComplete` |

---

## 10. АНИМАЦИИ И МИКРО-ИНТЕРАКЦИИ

### 10.1 Переходы между экранами

```dart
// lib/app/routes.dart
PageRouteBuilder createFadeSlideRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  );
}
```

### 10.2 Микро-интеракции

| Действие | Анимация | Длительность |
|---|---|---|
| Нажатие кнопки | `InkWell` splash effect | 150 ms |
| Успешное копирование | `SnackBar` с иконкой ✓ | 2000 ms |
| Ошибка ввода | `ShakeAnimation` поля | 500 ms |
| Загрузка данных | `ShimmerEffect` для списков | Пока loading = true |
| Удаление записи | `Dismissible` с анимацией исчезновения | 300 ms |

### 10.3 Обратная связь (Feedback)

```dart
// lib/presentation/widgets/copy_feedback.dart
void showCopyFeedback(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('Пароль скопирован!'),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Открыть',
        textColor: Colors.white,
        onPressed: () => _openStorage(context),
      ),
    ),
  );
}
```

---

## 11. ДОСТУПНОСТЬ (ACCESSIBILITY)

### 11.1 Требования к доступности

| Требование | Реализация во Flutter |
|---|---|
| **Screen Reader** | Все `IconButton` имеют `tooltip`, все поля — `Semantics(label: ...)` |
| **Контрастность** | Мин. соотношение 4.5:1 для текста (проверка через `ColorUtils.computeLuminance`) |
| **Масштабирование текста** | Поддержка `MediaQuery.textScaleFactor` до 2.0 без поломки вёрстки |
| **Навигация с клавиатуры** | `FocusNode` для всех интерактивных элементов, `FocusTraversalPolicy` |
| **Цветовая слепота** | Дублировать статус иконками/текстом (не только цветом) |

### 11.2 Пример доступной карточки

```dart
// lib/presentation/widgets/password_card.dart
Semantics(
  label: 'Пароль для ${entry.service}, логин ${entry.login}',
  button: true,
  child: ListTile(
    title: Text(entry.service),
    subtitle: Text(entry.login),
    trailing: IconButton(
      icon: Icon(Icons.copy),
      tooltip: 'Копировать пароль', // Обязательно!
      onPressed: () => _copyPassword(entry.password),
    ),
  ),
)
```

### 11.3 Чеклист доступности

- [ ] Все интерактивные элементы имеют `tooltip`
- [ ] Все изображения имеют `alt` текст (`Semantics.label`)
- [ ] Контрастность текста ≥ 4.5:1
- [ ] Поддержка масштабирования текста до 200%
- [ ] Навигация с клавиатуры (Tab, Enter, Escape)
- [ ] Логический порядок фокуса (`FocusTraversalPolicy`)

---

## 12. ТЕСТИРОВАНИЕ UI

### 12.1 Типы тестов

| Тип | Инструмент | Что покрывает |
|---|---|---|
| **Unit-тесты** | `test` пакет | Use Cases, крипто-утилиты, валидация |
| **Widget-тесты** | `flutter_test` | Отрисовка виджетов, реакция на ввод |
| **Integration-тесты** | `integration_test` | Полный сценарий: вход → генерация → сохранение |
| **Золотые тесты** | `golden_toolkit` | Визуальная регрессия (скриншоты экранов) |

### 12.2 Минимальное покрытие

```yaml
# pubspec.yaml (требования к тестам)
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0  # Для моков репозиториев
  golden_toolkit: ^0.15.0  # Для золотых тестов
  
# Требования:
# - Покрытие Use Cases: ≥90%
# - Покрытие контроллеров: ≥70%
# - Минимум 1 integration-тест на ключевой сценарий
# - Минимум 1 golden-тест на каждый экран
```

### 12.3 Пример widget-теста

```dart
// test/widgets/password_card_test.dart
testWidgets('PasswordCard displays service and login', (tester) async {
  final entry = PasswordEntryEntity(
    service: 'Gmail',
    login: 'test@gmail.com',
    password: 'encrypted',
    category: CategoryEntity(name: 'Почта'),
  );
  
  await tester.pumpWidget(
    MaterialApp(home: PasswordCard(password: entry)),
  );
  
  expect(find.text('Gmail'), findsOneWidget);
  expect(find.text('test@gmail.com'), findsOneWidget);
});
```

---

## 13. КРИТЕРИИ ПРИЁМКИ UI/UX

### 13.1 Обязательные критерии

| Критерий | Статус |
|---|---|
| Все 5 экранов реализованы | ✅ |
| Адаптивная навигация (BottomNav / NavRail) | ✅ |
| Темная/светлая тема переключается | ✅ |
| Кнопки и поля имеют минимальные размеры для тач (48dp) | ✅ |
| Ошибки отображаются через `SnackBar` / `Banner` | ✅ |
| Индикатор надёжности пароля работает | ✅ |
| Очистка буфера обмена через 60 сек | ✅ |
| Блокировка после 5 неудачных попыток ввода PIN | ✅ |

### 13.2 Продвинутые критерии (для высокой оценки)

| Критерий | Статус |
|---|---|
| Двухпанельный макет для планшета/десктопа | ✅ |
| Анимации переходов и микро-интеракции | ✅ |
| Поддержка масштабирования текста | ✅ |
| Полная доступность (Semantics, keyboard navigation) | ✅ |
| Плавные анимации загрузки (`ShimmerEffect`) | ✅ |
| Золотые тесты для всех экранов | ✅ |

### 13.3 Тестирование адаптивности

```bash
# Эмуляция разных размеров экрана
flutter run -d chrome --web-renderer canvaskit \
  --web-launch-url="http://localhost:8080/?size=mobile"
  
# Тест на планшете
flutter run -d chrome --web-launch-url="http://localhost:8080/?size=tablet"

# Тест на десктопе
flutter run -d windows
```

---

## 14. ДИАГРАММЫ ДЛЯ ДИПЛОМА

### 14.1 Обязательные диаграммы

| Диаграмма | Назначение | Инструмент |
|---|---|---|
| **Use Case** | Варианты использования | draw.io / Lucidchart |
| **Sequence** | Поток данных для 3 сценариев | draw.io / PlantUML |
| **Component** | Архитектура Clean Architecture | draw.io |
| **ER-Diagram** | Схема базы данных | draw.io / dbdiagram.io |
| **Deployment** | Развёртывание на устройствах | draw.io |

### 14.2 Сценарии для Sequence Diagram

1.  **Аутентификация:** User → AuthScreen → AuthController → LoginUseCase → AuthRepository → SQLite
2.  **Генерация пароля:** User → GeneratorScreen → GeneratorController → GeneratePasswordUseCase → PasswordGeneratorRepository → CryptoService
3.  **Экспорт данных:** User → SettingsScreen → SettingsController → ExportDataUseCase → PasswordRepository → CryptoService → File

---

## 15. ПРИЛОЖЕНИЯ

### 15.1 Глоссарий UI/UX

| Термин | Определение |
|---|---|
| **Брейкпоинт** | Контрольная ширина экрана для переключения макетов |
| **FAB** | Floating Action Button — плавающая кнопка действия |
| **Shimmer** | Эффект скелетона при загрузке данных |
| **Semantics** | Система доступности Flutter для скринридеров |
| **ChangeNotifier** | Механизм уведомления об изменении состояния |

### 15.2 Список сокращений

| Сокращение | Расшифровка |
|---|---|
| **UI** | User Interface |
| **UX** | User Experience |
| **FAB** | Floating Action Button |
| **DI** | Dependency Injection |
| **KDF** | Key Derivation Function |
| **PIN** | Personal Identification Number |

---

**Разработчик:** _________________ / _________________  
**Руководитель:** _________________ / _________________  
**Дата утверждения:** _________________

---

## 📋 СВОДНАЯ ТАБЛИЦА ИЗМЕНЕНИЙ (Версия 2.0)

| Раздел | Что добавлено | Приоритет |
|---|---|---|
| **2. Дизайн-система** | Полная спецификация Material 3, цвета, типографика | 🔴 Высокий |
| **3. Адаптивность** | Фиксированные брейкпоинты (600/900/1200), паттерны `LayoutBuilder` | 🔴 Высокий |
| **4-8. Экраны** | Детальные макеты для всех 5 экранов с виджетами | 🔴 Высокий |
| **9. Иерархия виджетов** | Структура папок, требования к декомпозиции | 🟡 Средний |
| **10. Анимации** | Спецификация переходов и микро-интеракций | 🟡 Средний |
| **11. Доступность** | Конкретные требования к Semantics, контрасту, навигации | 🟢 Низкий (но желательно) |
| **12. Тестирование** | Типы тестов, минимальное покрытие, примеры кода | 🟡 Средний |
| **14. Диаграммы** | Список обязательных диаграмм для диплома | 🔴 Высокий |

---

**Документ готов к использованию в дипломной работе.** 🎓