# 🎬 Micro-interactions & Animations Specification

**Version:** 1.0
**Date:** 2026-03-08
**Task:** IMPROVEMENT_PLAN_v0.6.0 — Задача 2.1
**ТЗ Section:** 10.2

---

## 1. Overview

Спецификации микро-интеракций и анимаций для PassGen.

---

## 2. Button Press Animation (Ripple Effect)

### 2.1 Specification

| Property | Value |
|----------|-------|
| **Type** | Material Ripple |
| **Duration** | 150ms |
| **Easing** | easeOut |
| **Color** | primary.withOpacity(0.1) |
| **Radius** | Expanding circle |

### 2.2 Implementation

```dart
InkWell(
  onTap: () => onPressed(),
  borderRadius: BorderRadius.circular(8),
  splashColor: theme.colorScheme.primary.withOpacity(0.1),
  highlightColor: theme.colorScheme.primary.withOpacity(0.05),
  child: child,
)
```

---

## 3. Copy Success Animation

### 3.1 Specification

| Property | Value |
|----------|-------|
| **Type** | Scale + Fade |
| **Duration** | 200ms |
| **Easing** | easeOutCubic |
| **Stages** | 3 (start, peak, end) |

### 3.2 Animation Stages

```json
{
  "copy_success": {
    "duration_ms": 200,
    "type": "scale_fade",
    "stages": [
      {"time": 0, "scale": 0.8, "opacity": 0},
      {"time": 100, "scale": 1.2, "opacity": 1},
      {"time": 200, "scale": 1.0, "opacity": 1}
    ],
    "easing": "ease_out_cubic"
  }
}
```

### 3.3 Implementation

```dart
AnimatedScale(
  scale: _copied ? 1.2 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeOutCubic,
  child: AnimatedOpacity(
    opacity: _copied ? 1.0 : 0.0,
    duration: Duration(milliseconds: 100),
    child: Icon(Icons.check_circle, color: Colors.green),
  ),
)
```

### 3.4 Lottie Animation

**File:** `project_context/design/animations/copy_success.json`

**Properties:**
- Duration: 0.2s
- Loop: false
- Size: 24x24px
- Colors: Green (#4CAF50)

---

## 4. Password Strength Pulse

### 4.1 Specification

| Property | Value |
|----------|-------|
| **Type** | Color transition + Scale |
| **Duration** | 300ms |
| **Easing** | easeInOut |
| **Trigger** | Password change |

### 4.2 Strength Colors

| Strength | Color | Hex |
|----------|-------|-----|
| Very Weak | Red | #D32F2F |
| Weak | Orange | #FF9800 |
| Medium | Yellow | #FFEB3B |
| Strong | Light Green | #8BC34A |
| Very Strong | Green | #4CAF50 |

### 4.3 Implementation

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: strengthColor,
    borderRadius: BorderRadius.circular(4),
  ),
  child: LinearProgressIndicator(
    value: strengthValue,
    backgroundColor: Colors.transparent,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  ),
)
```

---

## 5. List Item Swipe-to-Delete

### 5.1 Specification

| Property | Value |
|----------|-------|
| **Type** | Dismissible |
| **Duration** | 300ms |
| **Direction** | EndToStart |
| **Background** | Red with delete icon |

### 5.2 Implementation

```dart
Dismissible(
  key: Key(entry.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (direction) => showDeleteConfirmation(),
  onDismissed: (direction) => deletePassword(entry),
  child: PasswordCard(entry: entry),
)
```

---

## 6. PIN Input Animations

### 6.1 PIN Dot Fill

| Property | Value |
|----------|-------|
| **Type** | Scale + Color |
| **Duration** | 150ms |
| **Easing** | easeOut |

**Implementation:**
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 150),
  width: isFilled ? 12 : 8,
  height: isFilled ? 12 : 8,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isFilled ? primary : outline,
  ),
)
```

### 6.2 PIN Error Shake

| Property | Value |
|----------|-------|
| **Type** | Shake |
| **Duration** | 400ms |
| **Iterations** | 3 |
| **Offset** | 10px |

**Lottie:** `project_context/design/animations/pin_error.json`

**Implementation:**
```dart
AnimatedShake(
  duration: Duration(milliseconds: 400),
  offset: 10,
  iterations: 3,
  child: PINInputWidget(),
)
```

---

## 7. Page Transitions

### 7.1 Specification

| Property | Value |
|----------|-------|
| **Type** | Fade + Slide |
| **Duration** | 300ms |
| **Easing** | easeInOut |

### 7.2 Implementation

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => screen,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

---

## 8. Loading States

### 8.1 Button Loading

| Property | Value |
|----------|-------|
| **Type** | Text → Spinner |
| **Duration** | 200ms |
| **Widget** | CircularProgressIndicator |

**Implementation:**
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  child: isLoading
      ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.onPrimary,
          ),
        )
      : Text(label),
)
```

### 8.2 List Loading (Shimmer)

| Property | Value |
|----------|-------|
| **Type** | Shimmer Effect |
| **Duration** | 1.5s |
| **Loop** | true |

**Implementation:**
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: ListView.builder(
    itemCount: 5,
    itemBuilder: (_, __) => PasswordCardShimmer(),
  ),
)
```

---

## 9. Reduced Motion Support

### 9.1 Detection

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
```

### 9.2 Fallback

```dart
if (reduceMotion) {
  // Instant transition
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
} else {
  // Animated transition
  Navigator.push(context, createFadeSlideRoute(screen));
}
```

---

## 10. Animation Timing Chart

| Animation | Duration | Easing | Use Case |
|-----------|----------|--------|----------|
| Button Press | 150ms | easeOut | All buttons |
| Copy Success | 200ms | easeOutCubic | Password copy |
| Strength Change | 300ms | easeInOut | Generator |
| Page Transition | 300ms | easeInOut | Navigation |
| PIN Dot Fill | 150ms | easeOut | Auth screen |
| PIN Error Shake | 400ms | linear | Auth error |
| List Swipe | 300ms | easeOut | Delete item |
| Loading Spinner | 200ms | linear | Async operations |
| Shimmer | 1500ms | linear | Loading state |

---

## 11. Files for Developers

Location: `project_context/design/`

| File | Purpose |
|------|---------|
| `animations/copy_success.json` | Lottie animation |
| `animations/pin_error.json` | Lottie animation |
| `animations/strength_pulse.json` | Lottie animation |
| `guidelines/guidelines.md` (Section 8) | Documentation |

---

**Document Version:** 1.0
**Last Updated:** 2026-03-08
**Status:** Ready for implementation
