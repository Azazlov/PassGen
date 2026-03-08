# 📐 Storage Screen Two-Pane Layout Specification

**Version:** 1.0
**Date:** 2026-03-08
**Task:** 5.2 Two-Pane Storage Layout
**ТЗ Section:** 6.3

---

## 1. Overview

This document describes the two-pane master-detail layout for the Storage Screen on tablet and desktop devices.

---

## 2. Layout Types

### 2.1 Mobile Layout (< 600dp)

**Pattern:** Single pane with navigation

**Characteristics:**
- Full-screen list of passwords
- Search and filter at top
- FAB for adding new password
- Tap on item → Detail screen (new page)

**Navigation Flow:**
```
StorageScreen (list) → Tap item → PasswordDetailScreen (full screen)
```

---

### 2.2 Tablet Layout (600-899dp)

**Pattern:** Two-pane master-detail (side by side)

**Characteristics:**
- Left pane (40%): Password list with search/filter
- Right pane (60%): Password details
- No navigation on item tap (selection only)
- Edit/Delete actions in detail pane

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│ Storage                              [+] [⋮]        │
├──────────────────┬──────────────────────────────────┤
│ LIST (40%)       │ DETAIL (60%)                     │
│ ──────────────── │ ───────────────────────────────  │
│ 🔍 Search...     │ 🏦 Service Name                  │
│ 📂 All [▼]       │                                   │
│                  │ Login:                           │
│ • Сбербанк ●     │ [user123                      ]  │
│ • Тинькофф       │                                   │
│ • Альфа-Банк     │ Password:                        │
│ • ВТБ            │ [•••••••••••      ] [👁] [📋]   │
│                  │                                   │
│ ▼ Email (2)      │ Category: [Banking ▼]            │
│ • Gmail          │                                   │
│ • Yahoo          │ Created: Jan 1, 2024             │
│                  │ Updated: Today                   │
│ [➕ Add]         │                                   │
│                  │ [✏️ Edit] [🗑️ Delete]            │
└──────────────────┴──────────────────────────────────┘
    ~360dp              ~540dp
```

---

### 2.3 Desktop Layout (900-1199dp)

**Pattern:** Three-pane (Navigation + List + Detail)

**Characteristics:**
- Left pane (80dp): NavigationRail
- Middle pane (280dp): Password list with search/filter
- Right pane (Expanded): Password details
- All panes visible simultaneously

**Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ PassGen                                          [+] [⋮]        │
├────────┬─────────────────┬──────────────────────────────────────┤
│        │ LIST (280dp)    │ DETAIL (Expanded, max 800dp)         │
│ [📝]   │ ─────────────── │ ───────────────────────────────────  │
│  Ген   │ 🔍 Search...    │ 🏦 Service Name                      │
│        │ ─────────────── │                                       │
│ [🔒]   │ 📂 All [▼]      │ Login:                               │
│  Шифр  │                 │ [user123                          ]  │
│        │ ▼ Banking (3)   │                                       │
│ [📦]   │ • Сбербанк ●    │ Password:                            │
│  Хран  │ • Тинькофф      │ [••••••••••••••      ] [👁] [📋]    │
│        │ • Альфа-Банк    │                                       │
│ [⚙️]   │                 │ Category: [Banking ▼]                │
│ Настр  │ ▼ Email (2)     │                                       │
│        │ • Gmail         │ Created: Jan 1, 2024                 │
│ [ℹ️]   │ • Yahoo         │ Updated: Today                       │
│ О прил │                 │                                       │
│        │ [➕ Add]        │ [✏️ Edit] [🗑️ Delete]                │
└────────┴─────────────────┴──────────────────────────────────────┘
   80dp       280dp              Expanded (centered)
```

---

## 3. Component Specifications

### 3.1 List Pane

| Property | Value |
|----------|-------|
| **Width** | 40% (tablet), 280dp (desktop) |
| **Search Field** | 48dp height, full width |
| **Category Filter** | DropdownButton or FilterChip |
| **List Items** | ListTile with leading icon |
| **Selected Item** | Highlighted with primary color |
| **Scroll** | Vertical (ListView) |

### 3.2 Detail Pane

| Property | Value |
|----------|-------|
| **Width** | 60% (tablet), Expanded (desktop) |
| **Padding** | 24dp (lg) |
| **Max Content Width** | 800dp (desktop) |
| **Fields** | TextFormField (read-only by default) |
| **Actions** | Edit, Delete, Copy buttons |

### 3.3 Password Card (List Item)

```dart
ListTile(
  leading: Icon(_getCategoryIcon(entry.category), size: 32),
  title: Text(entry.service, style: boldText),
  subtitle: Text('${entry.login} • ${entry.category.name}'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: Icon(Icons.visibility), onPressed: showPassword),
      IconButton(icon: Icon(Icons.copy), onPressed: copyPassword),
      IconButton(icon: Icon(Icons.edit), onPressed: editPassword),
    ],
  ),
  selected: isSelected,
  onTap: () => selectEntry(entry),
  onLongPress: () => showDeleteConfirmation(entry),
)
```

---

## 4. State Management

### 4.1 Selection State

```dart
class StorageState extends State<StorageScreen> {
  PasswordEntryEntity? _selectedEntry;

  void _selectEntry(PasswordEntryEntity entry) {
    setState(() {
      _selectedEntry = entry;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedEntry = null;
    });
  }
}
```

### 4.2 Responsive Behavior

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < Breakpoints.tabletMin) {
    return _buildMobileLayout(); // Single pane
  } else {
    return _buildTwoPaneLayout(); // Master-detail
  }
}
```

---

## 5. Interactions

### 5.1 Item Selection

| Action | Mobile | Tablet/Desktop |
|--------|--------|----------------|
| Tap item | Navigate to detail | Select item (highlight) |
| Long press | Show context menu | Show context menu |
| Tap empty | Clear selection | Clear selection |

### 5.2 Actions

| Action | Mobile | Tablet/Desktop |
|--------|--------|----------------|
| View password | Detail screen | Detail pane (inline) |
| Copy password | Detail screen | Detail pane (inline) |
| Edit password | Detail screen → Edit screen | Dialog or inline edit |
| Delete password | Confirmation dialog | Confirmation dialog |

---

## 6. Empty States

### 6.1 No Passwords

```
┌─────────────────────────────────┐
│                                 │
│         [📦 Icon]               │
│                                 │
│    Нет сохранённых паролей      │
│                                 │
│  Создайте первый пароль прямо   │
│           сейчас                │
│                                 │
│      [➕ Добавить пароль]       │
│                                 │
└─────────────────────────────────┘
```

### 6.2 No Search Results

```
┌─────────────────────────────────┐
│                                 │
│         [🔍 Icon]               │
│                                 │
│   Ничего не найдено по запросу  │
│         "[search query]"        │
│                                 │
│      [Очистить поиск]           │
│                                 │
└─────────────────────────────────┘
```

---

## 7. Accessibility

### 7.1 Screen Reader

- List items: `Semantics(label: 'Password for ${service}, login ${login}')`
- Selected item: `Semantics(selected: true)`
- Actions: `tooltip` on all IconButtons

### 7.2 Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Next field/button |
| Shift+Tab | Previous field/button |
| Arrow Up/Down | Navigate list items |
| Enter | Select focused item |
| Escape | Clear selection |
| Delete | Delete selected item (with confirmation) |

---

## 8. Animations

### 8.1 Selection Animation

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
  child: ListTile(...),
)
```

### 8.2 Pane Transition (Mobile → Tablet)

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: isTablet ? TwoPaneLayout() : MobileLayout(),
)
```

---

## 9. Files for Developers

Location: `project_context/design/for_development/`

| File | Purpose |
|------|---------|
| `storage_layout.json` | Two-pane layout specifications |
| `components.json` | Updated component specs |

---

## 10. Export Files

Location: `project_context/design/final/`

| File | Description |
|------|-------------|
| `storage_mobile.txt` | Mobile layout ASCII mockup |
| `storage_tablet.txt` | Tablet two-pane layout ASCII mockup |
| `storage_desktop.txt` | Desktop three-pane layout ASCII mockup |

---

**Document Version:** 1.0
**Last Updated:** 2026-03-08
**Status:** Ready for implementation
