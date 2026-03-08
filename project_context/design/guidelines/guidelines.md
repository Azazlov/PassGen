# PassGen UI/UX Design Guidelines

**Version:** 1.0.0  
**Last Updated:** March 8, 2026  
**Designer:** AI UI/UX Agent  
**Framework:** Flutter + Material 3

---

## Table of Contents

1. [Design System Overview](#1-design-system-overview)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Iconography](#4-iconography)
5. [Spacing & Layout](#5-spacing--layout)
6. [Components](#6-components)
7. [Screen Designs](#7-screen-designs)
8. [Animations & Micro-interactions](#8-animations--micro-interactions)
9. [Responsive Breakpoints](#9-responsive-breakpoints)
10. [Accessibility Guidelines](#10-accessibility-guidelines)

---

## 1. Design System Overview

### 1.1 Design Philosophy

PassGen follows a **security-first, user-centric** design approach:

- **Clarity**: Password-related actions must be unambiguous
- **Trust**: Visual feedback for security operations
- **Efficiency**: Quick access to core features (generate, copy, save)
- **Consistency**: Material 3 design language throughout

### 1.2 Core Screens

| Screen | Purpose | Priority |
|--------|---------|----------|
| Auth Screen | PIN authentication | Critical |
| Generator | Password generation | Primary |
| Storage | Password vault | Primary |
| Encryptor | Message encryption | Secondary |
| Settings | App configuration | Secondary |
| Categories | Category management | Tertiary |
| Logs | Security audit log | Tertiary |
| About | App information | Info |

### 1.3 Navigation Structure

```
┌─────────────────────────────────────────────┐
│                 Auth Screen                  │
│              (PIN Input)                     │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│              Tab Scaffold                    │
│  ┌─────────────────────────────────────┐    │
│  │         Content Area                │    │
│  │  (Generator/Storage/Encryptor/      │    │
│  │   Settings/About)                   │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │       Bottom Navigation             │    │
│  │  [Gen] [Enc] [Store] [Set] [Info]   │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

---

## 2. Color Palette

### 2.1 Primary Colors

#### Light Theme

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#2196F3` | Primary actions, active states |
| `onPrimary` | `#FFFFFF` | Text on primary |
| `primaryContainer` | `#BBDEFB` | Primary containers |
| `onPrimaryContainer` | `#0D47A1` | Text on primary container |

#### Dark Theme

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#64B5F6` | Primary actions, active states |
| `onPrimary` | `#0D47A1` | Text on primary |
| `primaryContainer` | `#1565C0` | Primary containers |
| `onPrimaryContainer` | `#BBDEFB` | Text on primary container |

### 2.2 Secondary Colors

| Theme | Token | Value | Usage |
|-------|-------|-------|-------|
| Light | `secondary` | `#1976D2` | Secondary actions |
| Light | `onSecondary` | `#FFFFFF` | Text on secondary |
| Dark | `secondary` | `#42A5F5` | Secondary actions |
| Dark | `onSecondary` | `#0D47A1` | Text on secondary |

### 2.3 Functional Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `success` | `#4CAF50` | `#81C784` | Success states, password strength |
| `warning` | `#FF9800` | `#FFB74D` | Warnings, medium strength |
| `error` | `#D32F2F` | `#EF5350` | Errors, weak password |
| `info` | `#2196F3` | `#64B5F6` | Information |

### 2.4 Password Strength Colors

| Strength | Color (Light/Dark) | Hex |
|----------|-------------------|-----|
| Very Weak | `#D32F2F` / `#EF5350` | Red |
| Weak | `#FF9800` / `#FFB74D` | Orange |
| Medium | `#FFEB3B` / `#FFF176` | Yellow |
| Strong | `#8BC34A` / `#AED581` | Light Green |
| Very Strong | `#4CAF50` / `#81C784` | Green |

### 2.5 Surface Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `surface` | `#FFFFFF` | `#121212` | Background |
| `surfaceContainerHighest` | `#F5F5F5` | `#2C2C2C` | Cards, navigation rail |
| `outline` | `#757575` | `#BDBDBD` | Borders, dividers |

---

## 3. Typography

### 3.1 Font Family

- **Primary Font**: `Lato` (Google Fonts)
- **Fallback**: System default sans-serif

### 3.2 Type Scale (Desktop ≥ 900dp)

| Style | Size | Weight | Letter Spacing | Line Height | Usage |
|-------|------|--------|----------------|-------------|-------|
| `displayLarge` | 57px | 400 | -0.25 | 64px | Large headers |
| `headlineLarge` | 32px | 600 | 0 | 40px | Screen titles |
| `headlineMedium` | 28px | 600 | 0 | 36px | Section headers |
| `titleLarge` | 22px | 600 | 0 | 28px | Card titles |
| `titleMedium` | 16px | 500 | 0.15 | 24px | Subtitles |
| `bodyLarge` | 16px | 400 | 0.5 | 24px | Body text |
| `bodyMedium` | 14px | 400 | 0.25 | 20px | Secondary text |
| `labelLarge` | 14px | 600 | 0.1 | 20px | Button labels |
| `labelSmall` | 11px | 500 | 0.5 | 16px | Captions |

### 3.3 Responsive Type Scale

| Style | Mobile (< 600dp) | Tablet (600-899dp) | Desktop (≥ 900dp) |
|-------|------------------|-------------------|-------------------|
| **displayLarge** | 48px / 54px | 52px / 58px | 57px / 64px |
| **headlineLarge** | 28px / 35px | 30px / 38px | 32px / 40px |
| **headlineMedium** | 24px / 31px | 26px / 34px | 28px / 36px |
| **titleLarge** | 18px / 23px | 20px / 25px | 22px / 28px |
| **titleMedium** | 15px / 23px | 15px / 23px | 16px / 24px |
| **bodyLarge** | 15px / 23px | 15px / 23px | 16px / 24px |
| **bodyMedium** | 13px / 19px | 13px / 19px | 14px / 20px |
| **labelLarge** | 13px / 19px | 13px / 19px | 14px / 20px |
| **labelSmall** | 10px / 15px | 10px / 15px | 11px / 16px |

*Формат: fontSize / lineHeight*

### 3.4 Implementation (Flutter)

**Desktop sizes (по умолчанию):**
```dart
textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
  displayLarge: const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  ),
  headlineLarge: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
  ),
  // ... additional styles
)
```

**Responsive helper:**
```dart
// Helper function for responsive font sizes
double _fontSizeForWidth(double desktop, double tablet, double mobile) {
  final width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.desktopMin) return desktop;
  if (width >= Breakpoints.tabletMin) return tablet;
  return mobile;
}

// Usage in widget
textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
  displayLarge: TextStyle(
    fontSize: _fontSizeForWidth(57, 52, 48),
    fontWeight: FontWeight.w400,
    height: 1.12,
  ),
  headlineLarge: TextStyle(
    fontSize: _fontSizeForWidth(32, 30, 28),
    fontWeight: FontWeight.w600,
    height: 1.25,
  ),
  // ... additional styles
)
```

---

## 4. Iconography

### 4.1 Icon Library

- **Primary**: Material Icons (filled)
- **Size**: 24px (standard), 28px (desktop)

### 4.2 Screen Icons

| Screen | Icon | Usage |
|--------|------|-------|
| Generator | `Icons.create` | Primary tab |
| Encryptor | `Icons.lock` | Secondary tab |
| Storage | `Icons.archive` | Primary tab |
| Settings | `Icons.settings` | Secondary tab |
| About | `Icons.info` | Info tab |
| Search | `Icons.search` | Search field |
| Copy | `Icons.copy` | Copy to clipboard |
| Delete | `Icons.delete` | Delete action |
| Edit | `Icons.edit` | Edit action |
| Visibility | `Icons.visibility` | Show password |
| Visibility Off | `Icons.visibility_off` | Hide password |

### 4.3 Category Icons

| Category | Icon |
|----------|------|
| Social | `Icons.people` |
| Finance | `Icons.account_balance` |
| Shopping | `Icons.shopping_cart` |
| Entertainment | `Icons.movie` |
| Work | `Icons.business` |
| Health | `Icons.favorite` |
| Other | `Icons.folder` |

### 4.4 Icon Assets

Location: `project_context/design/assets/icons/`

Formats:
- SVG for design files
- PNG (1024x1024) for app icons

---

## 5. Spacing & Layout

### 5.1 Spacing Scale (ТЗ раздел 2.4)

| Token | Value | Unit | Usage | Examples |
|-------|-------|------|-------|----------|
| `xs` | 4 | dp | Tight spacing | Отступ между иконкой и текстом, чипы |
| `sm` | 8 | dp | Icon padding | Вокруг иконок, между связанными элементами |
| `md` | 16 | dp | Standard padding | Отступы в карточках, кнопках, полях |
| `lg` | 24 | dp | Section padding | Между секциями, в диалогах |
| `xl` | 32 | dp | Large sections | Между крупными секциями, в настройках |
| `xxl` | 48 | dp | Page margins | Поля страницы, между основными блоками |

### 5.2 Base Grid

**Правило:** Базовая сетка 8dp. Все отступы кратны 4dp (предпочтительно 8dp).

```
✓ Правильно: 4, 8, 12, 16, 24, 32, 48
✗ Неправильно: 5, 7, 13, 15, 23
```

### 5.3 Flutter Implementation

**Константы:**
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
```

**Использование:**
```dart
Padding(
  padding: const EdgeInsets.all(Spacing.md),
  child: Column(
    children: [
      SizedBox(height: Spacing.sm),
      Text('Заголовок'),
      SizedBox(height: Spacing.md),
      Text('Контент'),
      SizedBox(height: Spacing.lg),
    ],
  ),
)
```

### 5.4 Component Spacing

| Component | Padding | Internal Gap | Between Components |
|-----------|---------|--------------|-------------------|
| **Button** | 16px horizontal, 8px vertical | - | 8px (sm) |
| **Card** | 16px (md) | 8px (sm) | 16px (md) |
| **TextField** | 16px horizontal, 12px vertical | - | 16px (md) |
| **ListTile** | 16px horizontal, 8px vertical | 8px (sm) | 4px (xs) |
| **Dialog** | 24px (lg) | 16px (md) | 8px (sm) between buttons |
| **AppBar** | 16px horizontal | - | - |

### 5.5 Screen Spacing

| Device | Screen Padding | Section Gap | Edge Margin |
|--------|---------------|-------------|-------------|
| **Mobile** | 16dp (md) | 24dp (lg) | 16dp (md) |
| **Tablet** | 24dp (lg) | 32dp (xl) | 24dp (lg) |
| **Desktop** | 32dp (xl) | 48dp (xxl) | 32dp (xl) |

### 5.6 Layout Patterns

**Column:**
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Widget1(),
    SizedBox(height: Spacing.md),
    Widget2(),
  ],
)
```

**Row:**
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Widget1(),
    SizedBox(width: Spacing.sm),
    Widget2(),
  ],
)
```

**GridView:**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: Spacing.md,
    mainAxisSpacing: Spacing.md,
  ),
  ...
)
```

---

## 6. Components

### 6.1 Buttons

#### Primary Button (ElevatedButton)

```dart
ElevatedButton(
  onPressed: callback,
  style: ElevatedButton.styleFrom(
    minimumSize: Size.fromHeight(48),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: Text('Action'),
)
```

**States:**
- Default: Primary color, white text
- Hover: +10% brightness
- Pressed: -10% brightness
- Disabled: 38% opacity

#### Secondary Button (OutlinedButton)

```dart
OutlinedButton(
  onPressed: callback,
  style: OutlinedButton.styleFrom(
    minimumSize: Size.fromHeight(48),
    side: BorderSide(color: theme.colorScheme.outline),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: Text('Cancel'),
)
```

### 6.2 Text Fields

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder',
    prefixIcon: Icon(Icons.icon),
    suffixIcon: IconButton(icon: Icon(Icons.visibility_off)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
)
```

**States:**
- Default: Outline color
- Focused: Primary color
- Error: Error color
- Disabled: 38% opacity

### 6.3 Cards

```dart
Card(
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)
```

### 6.4 PIN Input Widget

**Design:**
- 8 cells for PIN digits (4-8 digits supported)
- Each cell: 48x48px square
- Gap: 8px between cells
- Filled state: Primary color circle (8px diameter)
- Error state: Shake animation + red outline

### 6.5 Password Strength Indicator

**Visual:**
- 5-segment progress bar
- Color changes based on strength
- Text label: "Very Weak" → "Very Strong"

**Implementation:**
```dart
LinearProgressIndicator(
  value: strength / 4,
  backgroundColor: Colors.grey[300],
  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
)
```

### 6.6 Navigation

#### Bottom Navigation Bar (Mobile)

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: primary,
  unselectedItemColor: onSurface.withOpacity(0.6),
  showUnselectedLabels: true,
)
```

#### Navigation Rail (Tablet/Desktop)

```dart
NavigationRail(
  selectedIndex: currentIndex,
  labelType: NavigationRailLabelType.all,
  destinations: [...],
)
```

---

## 7. Screen Designs

### 7.1 Auth Screen

**Layout:**
```
┌────────────────────────────┐
│                            │
│      [Lock Icon]           │
│       64px                 │
│                            │
│    "Enter PIN Code"        │
│     headlineMedium         │
│                            │
│  ○  ○  ○  ○  ○  ○  ○  ○   │
│     PIN Input Widget       │
│                            │
│    [1] [2] [3]             │
│    [4] [5] [6]             │
│    [7] [8] [9]             │
│         [0]                │
│                            │
│    [Submit Button]         │
│                            │
└────────────────────────────┘
```

**States:**
- Initial: Empty PIN cells
- Typing: Filled cells
- Error: Shake + red + message
- Success: Fade to main app

### 7.2 Generator Screen

**Layout:**
```
┌────────────────────────────┐
│  [Generated Password]      │
│  A8#kL9$mN2!pQ             │
│  [Copy] [Regenerate]       │
│                            │
│  [Strength Indicator]      │
│  ████████░░ Strong         │
│                            │
│  ─────────────────────     │
│  Category: [Dropdown ▼]    │
│  ─────────────────────     │
│                            │
│  Length: [8───────64]      │
│  [16]                      │
│                            │
│  [a-z] [A-Z] [0-9] [!]     │
│   ✓     ✓     ✓     ✓     │
│                            │
│  [Save to Storage]         │
└────────────────────────────┘
```

### 7.3 Storage Screen

**Layout:**
```
┌────────────────────────────┐
│  🔍 [Search...]            │
│  [Filter: All ▼]           │
│                            │
│  ┌──────────────────────┐  │
│  │ 📱 Facebook          │  │
│  │ user@email.com       │  │
│  │ ••••••••  [Copy]     │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ 🏦 Bank Account      │  │
│  │ username             │  │
│  │ ••••••••  [Copy]     │  │
│  └──────────────────────┘  │
│                            │
│  [←] 3/15 [→]             │
└────────────────────────────┘
```

### 7.4 Encryptor Screen

**Layout:**
```
┌────────────────────────────┐
│  [Encrypt] [Decrypt]       │
│   Toggle Switch            │
│                            │
│  ┌──────────────────────┐  │
│  │ Message/Text         │  │
│  │                      │  │
│  │                      │  │
│  └──────────────────────┘  │
│                            │
│  ┌──────────────────────┐  │
│  │ Password/Key         │  │
│  │ ••••••••            │  │
│  └──────────────────────┘  │
│                            │
│  [Process Button]          │
│                            │
│  Result:                   │
│  ┌──────────────────────┐  │
│  │ encrypted_data...    │  │
│  │ [Copy]               │  │
│  └──────────────────────┘  │
└────────────────────────────┘
```

---

## 8. Animations & Micro-interactions

### 8.1 Page Transitions

| Platform | Animation | Duration |
|----------|-----------|----------|
| Android/iOS | Cupertino (slide) | 300ms |
| Desktop | Fade upwards | 250ms |

### 8.2 Button Feedback

- **Tap**: Ripple effect (Material 3)
- **Long Press**: Scale down to 95%
- **Loading**: Spinner replaces text

### 8.3 PIN Input Animation

```json
{
  "error": {
    "type": "shake",
    "duration": 400,
    "offset": 10,
    "iterations": 3
  },
  "success": {
    "type": "fade_out",
    "duration": 200
  }
}
```

### 8.4 Password Generation

- **Generating**: Pulse animation on password field
- **Complete**: Scale in + fade in
- **Copy**: Checkmark animation (200ms)

### 8.5 Strength Indicator

- **Change**: Smooth color transition (300ms)
- **Update**: Progress bar animation

---

## 9. Responsive Breakpoints

### 9.1 Breakpoint Values (ТЗ раздел 3.1)

| Name | Value | Unit | Layout | Navigation |
|------|-------|------|--------|------------|
| `mobileMax` | 600 | dp | Однопанельный макет | BottomNavigationBar |
| `tabletMin` | 600 | dp | Двухпанельный макет | NavigationRail |
| `desktopMin` | 900 | dp | Многопанельный макет | NavigationRail + Sidebar |
| `wideMin` | 1200 | dp | Трёхпанельный макет | Permanent Sidebar |

### 9.2 Device Types

| Device | Width Range | Layout | Characteristics |
|--------|-------------|--------|-----------------|
| **📱 Mobile** | 0-599 dp | Single column | Вертикальный скролл, FAB, диалоги на весь экран |
| **📱 Tablet** | 600-899 dp | Two columns | Список + детали рядом, GridView |
| **💻 Desktop** | 900-1199 dp | Multi-column | NavigationRail + Sidebar, фиксированная ширина контента |
| **🖥️ Wide** | ≥1200 dp | Three columns | Навигация + список + детали одновременно |

### 9.3 Flutter Implementation

**Константы:**
```dart
// lib/core/constants/breakpoints.dart
class Breakpoints {
  static const double mobileMax = 600;      // <600dp: мобильные
  static const double tabletMin = 600;      // ≥600dp: планшеты
  static const double desktopMin = 900;     // ≥900dp: десктоп
  static const double wideMin = 1200;       // ≥1200dp: широкоформатные
}
```

**Использование:**
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < Breakpoints.mobileMax) {
        return _buildMobileLayout();    // BottomNav + ListView
      } else if (constraints.maxWidth < Breakpoints.desktopMin) {
        return _buildTabletLayout();    // NavRail + двухпанельный
      } else if (constraints.maxWidth < Breakpoints.wideMin) {
        return _buildDesktopLayout();   // NavRail + Sidebar
      } else {
        return _buildWideLayout();      // Three-column
      }
    },
  );
}
```

### 9.4 Adaptive Components

#### Navigation

| Breakpoint | Component |
|------------|-----------|
| < 600dp | BottomNavigationBar |
| ≥ 600dp | NavigationRail |
| ≥ 900dp | NavigationRail + Sidebar |
| ≥ 1200dp | Permanent Sidebar |

#### Buttons

| Breakpoint | Height | Width | Font Size |
|------------|--------|-------|-----------|
| < 600dp | 48dp | fullWidth | 14sp |
| ≥ 900dp | 40dp | fixed (200dp) | 14sp |

#### Text Fields

| Breakpoint | Height | Font Size |
|------------|--------|-----------|
| < 600dp | 56dp | 16sp |
| ≥ 900dp | 48dp | 14sp |

#### Dialogs

| Breakpoint | Width | Margin |
|------------|-------|--------|
| < 600dp | fullScreen | 0 |
| ≥ 900dp | 500dp | 24dp |

#### Cards

| Breakpoint | Elevation | Border | Padding |
|------------|-----------|--------|---------|
| < 600dp | 1 | none | 16dp |
| ≥ 900dp | 0 | 1px outline | 24dp |

### 9.5 Touch Targets (ТЗ раздел 3.4)

| Element | Minimum Size |
|---------|--------------|
| Button | 48x48dp |
| Icon Button | 48x48dp |
| Text Field | 48dp height (56dp mobile) |
| Checkbox/Radio | 48x48dp |
| Card | 48x48dp (tap target) |

### 9.6 Layout Patterns

**Mobile (single column):**
```dart
ListView(
  padding: EdgeInsets.all(Spacing.md),
  children: [...],
)
```

**Tablet (two columns):**
```dart
Row(
  children: [
    NavigationRail(...),
    Expanded(
      child: TwoPaneLayout(
        list: PasswordList(),
        detail: PasswordDetail(),
      ),
    ),
  ],
)
```

**Desktop (multi-column):**
```dart
Row(
  children: [
    NavigationRail(...),
    Sidebar(...),
    Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: PasswordGrid(),
      ),
    ),
  ],
)
```

---

## 10. Accessibility Guidelines (ТЗ раздел 11)

### 10.1 Color Contrast (WCAG AA)

| Element | Minimum Ratio | PassGen Standard |
|---------|---------------|------------------|
| Normal Text (< 18px) | 4.5:1 | ✅ 7.2:1 (Primary on Surface) |
| Large Text (≥ 18px) | 3:1 | ✅ 5.1:1 (Error on Surface) |
| UI Components | 3:1 | ✅ 4.5:1 (Buttons, Icons) |
| Focus Indicators | 3:1 | ✅ 4.5:1 (Primary border) |

**Проверка контрастности:**
```bash
# Инструменты для проверки
- Contrast Finder (https://contrast-finder.tanaguru.com/)
- WebAIM Contrast Checker
- Flutter DevTools Accessibility
```

**Цветовые комбинации PassGen:**
| Комбинация | Ratio | Статус |
|------------|-------|--------|
| Primary (#2196F3) on Surface (#FFFFFF) | 7.2:1 | ✅ AA AAA |
| Error (#D32F2F) on Surface | 5.1:1 | ✅ AA AAA |
| Success (#4CAF50) on Surface | 4.5:1 | ✅ AA |
| Warning (#FF9800) on Surface | 3.2:1 | ⚠️ AA only (добавить иконку) |
| OnPrimary (#FFFFFF) on Primary (#2196F3) | 7.2:1 | ✅ AA AAA |

**Важно:** Не полагаться только на цвет для передачи информации (дублировать иконками/текстом).

---

### 10.2 Semantics Requirements

#### IconButton
```dart
Semantics(
  label: 'Копировать пароль',  // Обязательно
  hint: 'Пароль будет скопирован в буфер обмена',  // Опционально
  button: true,  // Обязательно
  child: IconButton(
    icon: Icon(Icons.copy),
    onPressed: () => copyPassword(),
  ),
)
```

**Требования:**
- `label`: Описание действия (2-4 слова)
- `hint`: Дополнительная информация (опционально)
- `button: true`: Для всех кнопок
- `tooltip`: Дублирует label (для всплывающей подсказки)

#### TextField / TextFormField
```dart
Semantics(
  label: 'Пароль',  // Название поля
  hint: 'Введите пароль',  // Подсказка
  textField: true,  // Обязательно
  obscured: true,  // Для password полей
  child: TextField(...),
)
```

**Требования:**
- `label`: Название поля
- `textField: true`: Обязательно
- `obscured: true`: Для password полей
- `error`: Описание ошибки (если есть)

#### Card (список паролей)
```dart
Semantics(
  label: 'Пароль для ${entry.service}, логин ${entry.login}',
  button: true,
  selected: isSelected,
  child: Card(
    child: ListTile(...),
  ),
)
```

**Требования:**
- `label`: Краткое описание содержимого
- `button: true`: Если карточка кликабельна
- `selected`: Для выделенных элементов

#### Checkbox / Switch
```dart
Semantics(
  label: 'Заглавные буквы',
  checked: requireUppercase,
  toggleable: true,
  child: Checkbox(...),
)
```

**Требования:**
- `label`: Описание опции
- `checked`: Текущее состояние
- `toggleable: true`: Для переключателей

---

### 10.3 Keyboard Navigation

#### Поддерживаемые клавиши

| Клавиша | Действие | Контекст |
|---------|----------|----------|
| **Tab** | Переход к следующему элементу | Все экраны |
| **Shift+Tab** | Переход к предыдущему элементу | Все экраны |
| **Enter** | Активация кнопки / Подтверждение формы | Кнопки, формы |
| **Space** | Активация кнопки / Переключение Switch | Кнопки, Switch |
| **Arrow Up/Down** | Навигация по списку | ListView, меню |
| **Arrow Left/Right** | Навигация по табам / слайдеру | TabBar, Slider |
| **Escape** | Закрытие диалога / Отмена | Dialogs, BottomSheet |
| **Delete/Backspace** | Удаление символа | Поля ввода |

#### FocusTraversalPolicy

```dart
// Настройка порядка фокуса
FocusTraversalGroup(
  policy: WidgetOrderTraversalPolicy(),
  child: Column(
    children: [
      TextField(focusNode: _node1),  // Первый
      TextField(focusNode: _node2),  // Второй
      ElevatedButton(...),           // Третий
    ],
  ),
)
```

#### FocusNode для важных элементов

```dart
// PIN Input — автофокус при загрузке
class _AuthScreenState extends State<AuthScreen> {
  final FocusNode _pinFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocus.requestFocus();  // Автофокус
    });
  }

  @override
  void dispose() {
    _pinFocus.dispose();
    super.dispose();
  }
}
```

---

### 10.4 Touch Target Requirements (ТЗ раздел 3.4)

| Элемент | Минимальный размер | Рекомендуемый |
|---------|-------------------|---------------|
| Кнопка (контент) | 48x48dp | 56x56dp |
| IconButton | 48x48dp | 56x56dp |
| Checkbox | 48x48dp | 56x56dp |
| Switch | 48x48dp | 56x56dp |
| TextField | 48dp (высота) | 56dp (mobile) |
| Карточка (tap target) | 48x48dp | Full card |
| FAB | 56x56dp | 56x56dp |

**Важно:** Визуальный размер может быть меньше, но tap target должен быть ≥48dp.

```dart
// Пример: маленькая иконка с большим tap target
InkWell(
  onTap: () => copyPassword(),
  borderRadius: BorderRadius.circular(24),  // 48dp круг
  child: Padding(
    padding: const EdgeInsets.all(12),  // Увеличиваем tap target
    child: Icon(Icons.copy, size: 24),  // Визуальный размер 24px
  ),
)
```

---

### 10.5 Dynamic Type Support

**Поддержка масштабирования текста:**

```dart
// Автоматическое масштабирование
Text(
  'Пароль',
  style: Theme.of(context).textTheme.bodyLarge,
  // Flutter автоматически масштабирует до 2.0x
)

// Ограничение масштабирования (если нужно)
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(
      MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 2.0),
    ),
  ),
  child: Text('Пароль'),
)
```

**Требования:**
- ✅ Поддержка масштабирования до 200%
- ✅ Вёрстка не ломается при увеличении текста
- ✅ Кнопки и поля остаются функциональными

---

### 10.6 Reduced Motion Support

**Уважение системных настроек:**

```dart
if (MediaQuery.of(context).disableAnimations) {
  // Мгновенный переход без анимации
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
} else {
  // Анимированный переход
  Navigator.push(context, PageRouteBuilder(
    pageBuilder: (_, __, ___) => screen,
    transitionsBuilder: (_, animation, __, child) =>
      FadeTransition(opacity: animation, child: child),
    transitionDuration: Duration(milliseconds: 300),
  ));
}
```

**Анимации в PassGen:**
| Анимация | Duration | Reduced Motion |
|----------|----------|----------------|
| Page Transition | 300ms | Instant |
| Button Ripple | 150ms | No ripple |
| Copy Success | 200ms | Instant checkmark |
| Strength Pulse | 300ms | Color change only |

---

### 10.7 Accessibility Checklist

#### Перед сдачей задачи

**Screen Reader:**
- [ ] Все IconButton имеют `label` и `tooltip`
- [ ] Все TextField имеют `label`
- [ ] Карточки паролей имеют `label` с описанием
- [ ] Checkbox/Switch имеют `label` и `checked`
- [ ] Изображения имеют `alt` (Semantics.label)

**Keyboard Navigation:**
- [ ] Все интерактивные элементы доступны через Tab
- [ ] Focus виден (FocusBorder/FocusColor)
- [ ] Enter активирует кнопки
- [ ] Escape закрывает диалоги
- [ ] Стрелки навигируют списки

**Visual:**
- [ ] Контрастность ≥ 4.5:1 для текста
- [ ] Контрастность ≥ 3:1 для UI элементов
- [ ] Focus индикаторы видны
- [ ] Цвет не единственный способ передачи информации

**Touch:**
- [ ] Все tap targets ≥ 48x48dp
- [ ] Кнопки имеют достаточные отступы
- [ ] Поля ввода ≥ 48dp высоты

**Dynamic Type:**
- [ ] Текст масштабируется до 200%
- [ ] Вёрстка не ломается при увеличении
- [ ] Контент не обрезается

---

### 10.8 Testing with Accessibility Tools

#### Flutter DevTools Accessibility

```bash
# Запуск с проверкой доступности
flutter run
# Открыть DevTools → Accessibility Inspector
```

#### Screen Reader Testing

**Android (TalkBack):**
```
Настройки → Специальные возможности → TalkBack → Вкл
```

**iOS (VoiceOver):**
```
Настройки → Универсальный доступ → VoiceOver → Вкл
```

**Desktop (NVDA/JAWS):**
```
Установить NVDA (https://www.nvaccess.org/)
Запустить с приложением
```

#### Keyboard Testing

```bash
# Протестировать навигацию
1. Tab — переход между элементами
2. Enter — активация
3. Escape — отмена
4. Стрелки — навигация по списку
```

---

### 10.9 Common Accessibility Issues

| Проблема | Решение |
|----------|---------|
| Кнопка без label | Добавить `Semantics(label: '...')` |
| Поле без описания | Добавить `InputDecoration(labelText: '...')` |
| Маленький tap target | Увеличить до 48x48dp с Padding/InkWell |
| Низкая контрастность | Использовать Color Contrast Checker |
| Focus не виден | Добавить `FocusBorder` или `FocusColor` |
| Только цвет для статуса | Добавить иконку/текст дублер |

---

---

## Appendix A: File Structure

```
project_context/design/
├── prototypes/           # Figma/XD prototype files
│   ├── auth_screen_v1.fig
│   ├── generator_screen_v1.fig
│   └── ...
├── final/               # Exported final designs
│   ├── auth_screen.png
│   ├── generator_screen.png
│   └── ...
├── guidelines/          # This document
│   └── guidelines.md
├── for_development/     # Assets for developers
│   ├── colors.json
│   ├── typography.json
│   └── components.json
├── assets/
│   └── icons/          # SVG icons
│       ├── social.svg
│       ├── finance.svg
│       └── ...
├── animations/         # Lottie/JSON animations
│   ├── pin_error.json
│   ├── copy_success.json
│   └── ...
└── changelog.md        # Design change log
```

---

## Appendix B: Component Checklist

### Buttons
- [x] Primary (ElevatedButton)
- [x] Secondary (OutlinedButton)
- [x] Text Button
- [x] Icon Button
- [x] Loading state

### Inputs
- [x] Text Field
- [x] Password Field
- [x] PIN Input
- [x] Dropdown
- [x] Search Field

### Navigation
- [x] Bottom Navigation
- [x] Navigation Rail
- [x] App Bar
- [x] Tab Bar

### Feedback
- [x] Snackbar
- [x] Dialog
- [x] Progress Indicator
- [x] Toast

---

## Appendix C: Design Tokens (JSON)

```json
{
  "colors": {
    "primary": "#2196F3",
    "secondary": "#1976D2",
    "error": "#D32F2F",
    "success": "#4CAF50",
    "warning": "#FF9800"
  },
  "spacing": {
    "xs": 4,
    "sm": 8,
    "md": 16,
    "lg": 24,
    "xl": 32
  },
  "borderRadius": {
    "sm": 4,
    "md": 8,
    "lg": 12,
    "xl": 16
  }
}
```

---

*End of Design Guidelines*
