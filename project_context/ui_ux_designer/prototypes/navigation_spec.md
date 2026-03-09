# 📐 Navigation Prototype Specification

**Version:** 1.0
**Date:** 2026-03-08
**Task:** 5.1 Adaptive Navigation
**ТЗ Section:** 3.2, 3.4

---

## 1. Overview

This document describes the adaptive navigation patterns for PassGen across different device types.

---

## 2. Navigation Types

### 2.1 Mobile Navigation (< 600dp)

**Component:** `BottomNavigationBar`

**Characteristics:**
- Height: 80dp
- Icon size: 24px
- Label font size: 12sp
- Type: Fixed (all items visible)
- Show unselected labels: true
- Selected item color: Primary (#2196F3)
- Unselected item color: OnSurface.withOpacity(0.6)

**Items (5 tabs):**
| Index | Icon | Label | Route |
|-------|------|-------|-------|
| 0 | `Icons.create` | Генератор | /generator |
| 1 | `Icons.lock` | Шифратор | /encryptor |
| 2 | `Icons.archive` | Хранилище | /storage |
| 3 | `Icons.settings` | Настройки | /settings |
| 4 | `Icons.info` | О приложении | /about |

**Layout:**
```
┌─────────────────────────────────┐
│                                 │
│         Content Area            │
│                                 │
├─────────────────────────────────┤
│ [📝] [🔒] [📦] [⚙️] [ℹ️]       │ ← BottomNavigationBar (80dp)
│  Ген  Шиф  Хран  Настр  О прил  │
└─────────────────────────────────┘
```

**Flutter Implementation:**
```dart
BottomNavigationBar(
  currentIndex: currentIndex,
  onTap: onTabTapped,
  type: BottomNavigationBarType.fixed,
  selectedItemColor: theme.colorScheme.primary,
  unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
  items: AppTab.values.map((tab) {
    return BottomNavigationBarItem(
      icon: Icon(tab.icon),
      label: tab.label,
    );
  }).toList(),
)
```

---

### 2.2 Tablet Navigation (600-899dp)

**Component:** `NavigationRail`

**Characteristics:**
- Width: 72dp
- Icon size: 24px
- Label type: All (always show labels)
- Background: surfaceContainerHighest
- Selected icon color: Primary (#2196F3)
- Unselected icon color: OnSurface.withOpacity(0.6)

**Layout:**
```
┌────────────────────────────────────────────────────┐
│ App Bar (56dp)                                     │
├────────┬───────────────────────────────────────────┤
│        │                                           │
│ [📝]   │          Content Area                     │
│  Ген   │                                           │
│        │                                           │
│ [🔒]   │                                           │
│  Шиф   │                                           │
│        │                                           │
│ [📦]   │                                           │
│  Хран  │                                           │
│        │                                           │
│ [⚙️]   │                                           │
│ Настр  │                                           │
│        │                                           │
│ [ℹ️]   │                                           │
│ О прил │                                           │
│        │                                           │
└────────┴───────────────────────────────────────────┘
   72dp              Expanded
```

**Flutter Implementation:**
```dart
Row(
  children: [
    NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabTapped,
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
    ),
    VerticalDivider(thickness: 1, width: 1),
    Expanded(
      child: Scaffold(
        appBar: AppBar(title: Text(currentTab.title)),
        body: currentTab.content,
      ),
    ),
  ],
)
```

---

### 2.3 Desktop Navigation (900-1199dp)

**Component:** `NavigationRail` + `Sidebar`

**Characteristics:**
- NavigationRail width: 80dp
- Icon size: 28px
- Sidebar width: 240dp (collapsible)
- Content max width: 800dp

**Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ App Bar (64dp)                                                  │
├────────┬────────────┬───────────────────────────────────────────┤
│        │            │                                           │
│ [📝]   │  🔍 Поиск  │          Content Area                     │
│  Ген   │  ────────  │          (max-width: 800dp)               │
│        │  📂 Все    │                                           │
│ [🔒]   │  👥 Соцсети│                                           │
│  Шиф   │  🏦 Банки  │                                           │
│        │  📧 Почта  │                                           │
│ [📦]   │            │                                           │
│  Хран  │            │                                           │
│        │            │                                           │
│ [⚙️]   │            │                                           │
│ Настр  │            │                                           │
│        │            │                                           │
│ [ℹ️]   │            │                                           │
│ О прил │            │                                           │
│        │            │                                           │
└────────┴────────────┴───────────────────────────────────────────┘
   80dp    240dp         Expanded (centered)
```

**Flutter Implementation:**
```dart
Row(
  children: [
    NavigationRail(
      minWidth: 80,
      selectedIndex: currentIndex,
      onDestinationSelected: onTabTapped,
      labelType: NavigationRailLabelType.all,
      iconTheme: IconThemeData(size: 28),
      destinations: AppTab.values.map((tab) {
        return NavigationRailDestination(
          icon: Icon(tab.icon, size: 28),
          label: Text(tab.label),
        );
      }).toList(),
    ),
    VerticalDivider(thickness: 1, width: 1),
    if (currentTab == AppTab.storage)
      Sidebar(
        width: 240,
        child: FilterPanel(),
      ),
    Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: currentTab.content,
        ),
      ),
    ),
  ],
)
```

---

### 2.4 Wide Navigation (≥ 1200dp)

**Component:** `Permanent Sidebar` + `NavigationRail`

**Characteristics:**
- Permanent sidebar always visible
- Three-column layout (Nav + List + Details)
- Content centered with max-width 800dp

**Layout:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ App Bar (64dp)                                                              │
├────────┬─────────────────┬──────────────────────────────────────────────────┤
│        │                 │                                                   │
│ [📝]   │  🔍 Поиск       │  Детали записи                                   │
│  Ген   │  ────────       │                                                   │
│        │  📂 Категории   │  🏦 Сбербанк                                     │
│ [🔒]   │  • Сбербанк ●   │  ─────────────────                               │
│  Шиф   │  • Тинькофф     │  Логин: [user123        ]                       │
│        │  • Альфа        │                                                   │
│ [📦]   │  • ВТБ          │  Пароль: [••••••••    ] [👁]                    │
│  Хран  │                 │  [📋 Копировать]                                 │
│        │  ▼ Почта (2)    │                                                   │
│ [⚙️]   │  • Gmail        │  Категория: [Банки ▼]                           │
│ Настр  │  • Yahoo        │                                                   │
│        │                 │  Создан: 01.01.24                                │
│ [ℹ️]   │                 │  Обновлено: сегодня                              │
│ О прил │                 │                                                   │
│        │                 │  [✏️ Редактировать] [🗑️ Удалить]                │
└────────┴─────────────────┴──────────────────────────────────────────────────┘
   80dp      280dp              Expanded (centered, max-width: 800dp)
```

---

## 3. Adaptive Behavior

### 3.1 Breakpoint Detection

```dart
class AdaptiveNavigation extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < Breakpoints.mobileMax) {
          return _buildMobileNavigation();
        } else if (width < Breakpoints.desktopMin) {
          return _buildTabletNavigation();
        } else if (width < Breakpoints.wideMin) {
          return _buildDesktopNavigation();
        } else {
          return _buildWideNavigation();
        }
      },
    );
  }
}
```

### 3.2 State Management

```dart
class _AdaptiveNavigationState extends State<AdaptiveNavigation> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigate to selected tab
    widget.tabs[index].navigate(context);
  }
}
```

---

## 4. Component Specifications

### 4.1 BottomNavigationBar (Mobile)

| Property | Value |
|----------|-------|
| `height` | 80dp |
| `elevation` | 8 |
| `type` | fixed |
| `iconSize` | 24 |
| `selectedFontSize` | 12 |
| `unselectedFontSize` | 12 |
| `showSelectedLabels` | true |
| `showUnselectedLabels` | true |

### 4.2 NavigationRail (Tablet/Desktop)

| Property | Value |
|----------|-------|
| `minWidth` | 72dp (tablet), 80dp (desktop) |
| `iconSize` | 24 (tablet), 28 (desktop) |
| `labelType` | all |
| `backgroundColor` | surfaceContainerHighest |
| `elevation` | 0 |

### 4.3 Sidebar (Desktop/Wide)

| Property | Value |
|----------|-------|
| `width` | 240dp |
| `collapsible` | true (desktop only) |
| `backgroundColor` | surfaceContainerHighest |
| `dividerColor` | outlineVariant |

---

## 5. Accessibility

### 5.1 Screen Reader Support

```dart
BottomNavigationBarItem(
  icon: Semantics(
    label: 'Генератор паролей',
    child: Icon(Icons.create),
  ),
  label: 'Генератор',
  tooltip: 'Перейти к генератору паролей',
)
```

### 5.2 Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Focus next nav item |
| Shift+Tab | Focus previous nav item |
| Enter | Select focused item |
| Arrow Left/Right | Move between items (horizontal) |
| Arrow Up/Down | Move between items (vertical) |

### 5.3 Touch Targets

- All navigation items: minimum 48x48dp
- Icon + label combined tap target
- Visual feedback on press (ripple effect)

---

## 6. Animations

### 6.1 Tab Switching

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  switchInCurve: Curves.easeInOut,
  switchOutCurve: Curves.easeInOut,
  child: currentTabWidget,
)
```

### 6.2 Icon Animation

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  transform: Matrix4.scale(isSelected ? 1.1 : 1.0),
  child: Icon(tab.icon),
)
```

---

## 7. Files for Developers

Location: `project_context/design/for_development/`

| File | Purpose |
|------|---------|
| `navigation.json` | Navigation specifications |
| `breakpoints.json` | Breakpoint values |
| `components.json` | Component specs (updated) |

---

## 8. Export Files

Location: `project_context/design/final/`

| File | Description |
|------|-------------|
| `navigation_mobile.png` | Mobile navigation mockup |
| `navigation_tablet.png` | Tablet navigation mockup |
| `navigation_desktop.png` | Desktop navigation mockup |
| `navigation_wide.png` | Wide screen navigation mockup |

---

**Document Version:** 1.0
**Last Updated:** 2026-03-08
**Status:** Ready for implementation
