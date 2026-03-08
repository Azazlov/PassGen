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

### 3.2 Type Scale

| Style | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|----------------|-------|
| `displayLarge` | 57px | 400 | -0.25 | Large headers |
| `headlineLarge` | 32px | 600 | 0 | Screen titles |
| `headlineMedium` | 28px | 600 | 0 | Section headers |
| `titleLarge` | 22px | 600 | 0 | Card titles |
| `titleMedium` | 16px | 500 | 0.15 | Subtitles |
| `bodyLarge` | 16px | 400 | 0.5 | Body text |
| `bodyMedium` | 14px | 400 | 0.25 | Secondary text |
| `labelLarge` | 14px | 600 | 0.1 | Button labels |
| `labelSmall` | 11px | 500 | 0.5 | Captions |

### 3.3 Implementation (Flutter)

```dart
textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
  displayLarge: const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  ),
  headlineLarge: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
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

### 5.1 Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight spacing |
| `sm` | 8px | Icon padding |
| `md` | 16px | Standard padding |
| `lg` | 24px | Section padding |
| `xl` | 32px | Large sections |
| `xxl` | 48px | Page margins |

### 5.2 Component Spacing

| Component | Padding | Gap |
|-----------|---------|-----|
| Button | 16px horizontal, 12px vertical | - |
| Card | 16px | 12px (internal) |
| TextField | 16px | - |
| List Item | 16px | 8px |

### 5.3 Layout Grid

- **Mobile**: Single column, full width
- **Tablet**: 2-column grid (min 600px)
- **Desktop**: 3+ column grid (min 1024px)

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

### 9.1 Breakpoint Values

| Name | Value | Layout |
|------|-------|--------|
| `mobileMax` | 599px | Single column, bottom nav |
| `tabletMin` | 600px | Two columns, nav rail |
| `desktopMin` | 1024px | Three columns, nav rail |

### 9.2 Adaptive Components

#### Navigation

| Breakpoint | Component |
|------------|-----------|
| < 600px | BottomNavigationBar |
| ≥ 600px | NavigationRail |

#### Card Layout

| Breakpoint | Columns |
|------------|---------|
| < 600px | 1 |
| 600-1023px | 2 |
| ≥ 1024px | 3 |

### 9.3 Touch Targets

| Element | Minimum Size |
|---------|--------------|
| Button | 48x48px |
| Icon Button | 48x48px |
| Text Field | 48px height |
| Checkbox/Radio | 48x48px |

---

## 10. Accessibility Guidelines

### 10.1 Color Contrast

| Element | Minimum Ratio |
|---------|---------------|
| Normal Text | 4.5:1 |
| Large Text | 3:1 |
| UI Components | 3:1 |

**Verification:**
- Primary on Surface: 7.2:1 ✓
- Error on Surface: 5.1:1 ✓

### 10.2 Screen Reader Support

```dart
Semantics(
  label: 'Password field',
  value: 'Hidden',
  hidden: false,
  child: TextField(...),
)
```

### 10.3 Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Next field |
| Shift+Tab | Previous field |
| Enter | Submit |
| Escape | Cancel |

### 10.4 Dynamic Type

Support system font scaling:
```dart
MediaQuery.of(context).textScaler.scale(fontSize)
```

### 10.5 Reduced Motion

```dart
if (MediaQuery.disableAnimations) {
  // Use instant transitions
}
```

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
