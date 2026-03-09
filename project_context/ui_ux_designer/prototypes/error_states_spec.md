# 🚨 Error Handling UI Specification

**Version:** 1.0
**Date:** 2026-03-08
**Task:** IMPROVEMENT_PLAN_v0.6.0 — Задача 2.2
**ТЗ Section:** 10

---

## 1. Overview

Спецификации обработки и отображения ошибок в пользовательском интерфейсе PassGen.

---

## 2. Types of Errors

### 2.1 Error Classification

| Type | Component | Duration | Example |
|------|-----------|----------|---------|
| **Validation Error** | TextField helper text | While field active | "PIN must be 4-8 digits" |
| **Success** | SnackBar | 2 seconds | "Password copied" |
| **Warning** | Banner | Until dismissed | "Buffer clears in 60s" |
| **Critical Error** | AlertDialog | Until action | "Encryption failed" |

---

## 3. Validation Errors

### 3.1 TextField Validation

**When to use:** Real-time form validation

**Component:** TextField with helper text

**Specification:**
- **Color:** error (#D32F2F)
- **Position:** Below text field
- **Icon:** Error icon (optional)
- **Dismiss:** On valid input or field blur

**Implementation:**
```dart
TextFormField(
  controller: pinController,
  decoration: InputDecoration(
    labelText: 'PIN-код',
    errorText: _pinError,
    errorIcon: Icon(Icons.error, size: 20),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите PIN-код';
    }
    if (!RegExp(r'^\d{4,8}$').hasMatch(value)) {
      return 'PIN должен быть 4-8 цифр';
    }
    return null;
  },
)
```

**Error Messages:**
| Field | Error | Message |
|-------|-------|---------|
| PIN | Empty | "Введите PIN-код" |
| PIN | Invalid format | "PIN должен быть 4-8 цифр" |
| PIN | Too short | "Минимум 4 цифры" |
| PIN | Too long | "Максимум 8 цифр" |
| Password | Empty | "Введите пароль" |
| Password | Weak | "Пароль слишком слабый" |
| Email | Invalid | "Некорректный email" |

---

## 4. Success Notifications

### 4.1 SnackBar (Success)

**When to use:** Brief success messages

**Specification:**
- **Duration:** 2 seconds
- **Position:** Bottom (floating)
- **Color:** success (#4CAF50)
- **Icon:** Check circle
- **Action:** Optional (e.g., "Open")

**Implementation:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Пароль скопирован!'),
      ],
    ),
    backgroundColor: Theme.of(context).colorScheme.success,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Открыть',
      textColor: Colors.white,
      onPressed: () => _openStorage(context),
    ),
  ),
);
```

**Success Messages:**
| Action | Message |
|--------|---------|
| Copy password | "Пароль скопирован" |
| Save password | "Пароль сохранён" |
| Delete password | "Пароль удалён" |
| Export data | "Данные экспортированы" |
| Import data | "Данные импортированы" |
| Change PIN | "PIN-код изменён" |

---

## 5. Warning Notifications

### 5.1 Banner (Warning)

**When to use:** Persistent warnings that don't block interaction

**Specification:**
- **Position:** Top of screen
- **Color:** warning (#FF9800)
- **Icon:** Warning icon
- **Dismiss:** Manual or auto (after action)

**Implementation:**
```dart
if (_showClipboardWarning) {
  Banner(
    message: 'Буфер обмена будет очищен через 60 секунд',
    location: BannerLocation.top,
    color: Theme.of(context).colorScheme.warning,
    child: IconButton(
      icon: Icon(Icons.close),
      onPressed: () => setState(() => _showClipboardWarning = false),
    ),
  );
}
```

**Warning Messages:**
| Context | Message |
|---------|---------|
| Clipboard | "Буфер будет очищен через 60 сек" |
| Weak password | "Этот пароль легко взломать" |
| Auto-lock | "Приложение заблокируется через 5 мин" |
| Unsaved changes | "Изменения не сохранены" |

---

## 6. Critical Errors

### 6.1 AlertDialog (Critical)

**When to use:** Errors that require user action

**Specification:**
- **Modal:** Yes (blocks interaction)
- **Color:** error (#D32F2F)
- **Icon:** Error icon
- **Actions:** Retry / Cancel OR OK

**Implementation:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    icon: Icon(Icons.error, color: Colors.red, size: 48),
    title: Text('Ошибка шифрования'),
    content: Text(
      'Не удалось зашифровать данные. Проверьте правильность пароля и попробуйте снова.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Отмена'),
      ),
      ElevatedButton(
        onPressed: () => _retryEncryption(),
        child: Text('Повторить'),
      ),
    ],
  ),
);
```

**Critical Error Messages:**
| Error | Title | Message |
|-------|-------|---------|
| Encryption failed | "Ошибка шифрования" | "Не удалось зашифровать данные" |
| Decryption failed | "Ошибка расшифровки" | "Неверный пароль или повреждённые данные" |
| Database error | "Ошибка базы данных" | "Не удалось сохранить данные" |
| Import failed | "Ошибка импорта" | "Не удалось импортировать файл" |
| Export failed | "Ошибка экспорта" | "Не удалось экспортировать данные" |
| Authentication failed | "Ошибка аутентификации" | "Неверный PIN-код" |

---

## 7. Empty States

### 7.1 No Passwords

**When to use:** Storage is empty

**Specification:**
- **Icon:** Archive icon (64px)
- **Title:** "Нет сохранённых паролей"
- **Subtitle:** "Создайте первый пароль прямо сейчас"
- **Action:** "Добавить пароль" button

**Implementation:**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.archive, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text(
        'Нет сохранённых паролей',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      SizedBox(height: 8),
      Text(
        'Создайте первый пароль прямо сейчас',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _addPassword(),
        icon: Icon(Icons.add),
        label: Text('Добавить пароль'),
      ),
    ],
  ),
)
```

### 7.2 No Search Results

**When to use:** Search returns no results

**Specification:**
- **Icon:** Search off icon (64px)
- **Title:** "Ничего не найдено"
- **Subtitle:** "По запросу \"[query]\""
- **Action:** "Очистить поиск" button

---

## 8. Loading States

### 8.1 Shimmer Effect

**When to use:** While loading data

**Specification:**
- **Type:** Shimmer
- **Duration:** 1.5s loop
- **Colors:** Grey shades

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

### 8.2 Circular Progress

**When to use:** Single operation loading

**Specification:**
- **Size:** 40x40dp
- **Color:** primary
- **Stroke width:** 4dp

---

## 9. Error Handling Best Practices

### 9.1 User-Friendly Messages

**Do:**
- ✅ "Неверный PIN-код. Осталось 3 попытки."
- ✅ "Пароль скопирован. Буфер будет очищен через 60 сек."
- ✅ "Ошибка подключения. Проверьте интернет."

**Don't:**
- ❌ "Error 401: Unauthorized"
- ❌ "Null check operator used on a null value"
- ❌ "Exception: CryptoException at line 123"

### 9.2 Error Recovery

Always provide:
1. **Clear explanation** of what went wrong
2. **Actionable steps** to fix the issue
3. **Recovery option** (retry, cancel, alternative)

### 9.3 Error Logging

Log all errors with context:
```dart
_logEventUseCase.execute(
  EventTypes.errorOccurred,
  details: {
    'error_type': error.type,
    'error_message': error.message,
    'screen': 'StorageScreen',
    'action': 'delete_password',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

---

## 10. Accessibility

### 10.1 Screen Reader Support

```dart
Semantics(
  label: 'Ошибка: PIN должен быть 4-8 цифр',
  isError: true,
  child: Text(_pinError),
)
```

### 10.2 Color Independence

Never use color alone:
- ✅ Error icon + red color + text
- ❌ Only red text

---

## 11. Files for Developers

Location: `project_context/design/`

| File | Purpose |
|------|---------|
| `prototypes/error_states_spec.md` | This document |
| `guidelines/guidelines.md` (Section 11) | Documentation |

---

**Document Version:** 1.0
**Last Updated:** 2026-03-08
**Status:** Ready for implementation
