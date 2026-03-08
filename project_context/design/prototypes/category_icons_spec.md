# 🎨 Category Icons Specification

**Version:** 1.0
**Date:** 2026-03-08
**Task:** IMPROVEMENT_PLAN_v0.6.0 — Задача 2.3
**ТЗ Section:** 6.4

---

## 1. Overview

Спецификации иконок категорий для PassGen.

---

## 2. Icon Set

### 2.1 System Categories (7 icons)

| Category | Icon | SVG File | Usage |
|----------|------|----------|-------|
| **Social** | 👥 | `social.svg` | Social networks, messaging |
| **Finance** | 🏦 | `finance.svg` | Banks, finance, payments |
| **Shopping** | 🛒 | `shopping.svg` | Stores, shopping, e-commerce |
| **Entertainment** | 🎬 | `entertainment.svg` | Movies, music, games |
| **Work** | 💼 | `work.svg` | Work, business, tools |
| **Health** | ❤️ | `health.svg` | Health, medical, fitness |
| **Other** | 📁 | `other.svg` | Default, uncategorized |

---

## 3. Icon Specifications

### 3.1 Technical Requirements

| Property | Value |
|----------|-------|
| **Format** | SVG 1.1 |
| **Size** | 24x24px (viewBox) |
| **Stroke** | 2px |
| **Fill** | CurrentColor |
| **Style** | Material Design Outlined |

### 3.2 Color Usage

| Context | Color |
|---------|-------|
| Default | onSurface (60%) |
| Selected | primary (#2196F3) |
| Active | primary |
| Disabled | outlineVariant |

---

## 4. Implementation

### 4.1 Flutter Usage

```dart
// Import SVG
import 'package:flutter_svg/flutter_svg.dart';

// Usage in widget
SvgPicture.asset(
  'assets/icons/social.svg',
  width: 24,
  height: 24,
  colorFilter: Theme.of(context).colorScheme.primary,
);
```

### 4.2 Category Icon Mapping

```dart
// lib/domain/entities/category.dart
enum CategoryType {
  social,
  finance,
  shopping,
  entertainment,
  work,
  health,
  other;

  String get iconPath {
    switch (this) {
      case CategoryType.social:
        return 'assets/icons/social.svg';
      case CategoryType.finance:
        return 'assets/icons/finance.svg';
      case CategoryType.shopping:
        return 'assets/icons/shopping.svg';
      case CategoryType.entertainment:
        return 'assets/icons/entertainment.svg';
      case CategoryType.work:
        return 'assets/icons/work.svg';
      case CategoryType.health:
        return 'assets/icons/health.svg';
      case CategoryType.other:
        return 'assets/icons/other.svg';
    }
  }

  IconData get materialIcon {
    switch (this) {
      case CategoryType.social:
        return Icons.people;
      case CategoryType.finance:
        return Icons.account_balance;
      case CategoryType.shopping:
        return Icons.shopping_cart;
      case CategoryType.entertainment:
        return Icons.movie;
      case CategoryType.work:
        return Icons.business;
      case CategoryType.health:
        return Icons.favorite;
      case CategoryType.other:
        return Icons.folder;
    }
  }
}
```

---

## 5. Icon Descriptions

### 5.1 social.svg

**Description:** Two person silhouettes (group)

**Use cases:**
- Social networks (Facebook, VK, Telegram)
- Messaging apps (WhatsApp, Viber)
- Contact management

**Visual:**
```
┌────────────────────────────┐
│         👥                  │
│    ┌───┐  ┌───┐           │
│    │ ○ │  │ ○ │           │
│    │/|\│  │/|\│           │
│    └───┘  └───┘           │
└────────────────────────────┘
```

### 5.2 finance.svg

**Description:** Bank building with columns

**Use cases:**
- Banks (Sberbank, Tinkoff)
- Payment systems (PayPal, YooMoney)
- Investment accounts

**Visual:**
```
┌────────────────────────────┐
│         🏦                  │
│     ┌─────────┐            │
│     │__|__|__│            │
│     │  |  |  │            │
│     │__|__|__│            │
└────────────────────────────┘
```

### 5.3 shopping.svg

**Description:** Shopping cart

**Use cases:**
- Online stores (Amazon, Ozon)
- Shopping accounts
- Payment cards for shopping

**Visual:**
```
┌────────────────────────────┐
│         🛒                  │
│    ┌──────┐                │
│    │      │====○           │
│    └──────┘  ○             │
└────────────────────────────┘
```

### 5.4 entertainment.svg

**Description:** Film clapperboard

**Use cases:**
- Streaming (Netflix, YouTube)
- Gaming (Steam, Epic Games)
- Music (Spotify, Apple Music)

**Visual:**
```
┌────────────────────────────┐
│         🎬                  │
│    ┌──────┐                │
│    │//////│                │
│    └──────┘                │
└────────────────────────────┘
```

### 5.5 work.svg

**Description:** Briefcase

**Use cases:**
- Work accounts
- Business tools
- Professional services

**Visual:**
```
┌────────────────────────────┐
│         💼                  │
│    ┌──────┐                │
│    │ ┌──┐ │                │
│    └─┴──┴─┘                │
│      └──┘                  │
└────────────────────────────┘
```

### 5.6 health.svg

**Description:** Heart

**Use cases:**
- Medical portals
- Health insurance
- Fitness apps

**Visual:**
```
┌────────────────────────────┐
│         ❤️                  │
│     ┌─┐ ┌─┐               │
│     │ │ │ │               │
│     └─┘ └─┘               │
│       └─┘                 │
└────────────────────────────┘
```

### 5.7 other.svg

**Description:** Folder

**Use cases:**
- Default category
- Uncategorized accounts
- Miscellaneous

**Visual:**
```
┌────────────────────────────┐
│         📁                  │
│    ┌──────┐                │
│    │      │                │
│    │      │                │
│    └──────┘                │
└────────────────────────────┘
```

---

## 6. Asset Organization

```
project_context/design/assets/icons/
├── social.svg          # Social networks
├── finance.svg         # Banks, finance
├── shopping.svg        # Shopping, stores
├── entertainment.svg   # Entertainment, media
├── work.svg            # Work, business
├── health.svg          # Health, medical
└── other.svg           # Default, other
```

---

## 7. Export Formats

| Format | Size | Usage |
|--------|------|-------|
| **SVG** | 24x24px | Design files, Flutter app |
| **PNG** | 24x24px | Fallback |
| **PNG** | 48x48px | Touch targets |
| **PNG** | 96x96px | High DPI displays |

---

## 8. Accessibility

### 8.1 Alt Text

```dart
Semantics(
  label: 'Категория: Социальные сети',
  child: SvgPicture.asset('assets/icons/social.svg'),
)
```

### 8.2 Color Contrast

- **Normal:** onSurface.withOpacity(0.6) — 4.5:1 minimum
- **Selected:** primary (#2196F3) — 7.2:1 on surface

---

## 9. Files for Developers

Location: `project_context/design/`

| File | Purpose |
|------|---------|
| `assets/icons/*.svg` | 7 category icons |
| `guidelines/guidelines.md` (Section 4.3) | Documentation |
| `for_development/components.json` | Component specs |

---

**Document Version:** 1.0
**Last Updated:** 2026-03-08
**Status:** Ready for implementation
