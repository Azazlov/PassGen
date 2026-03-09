# Sentry Integration Guide for Flutter

## 1. Add Dependencies

```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

## 2. Initialize Sentry

Add to `lib/main.dart`:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-dsn@sentry.io/your-project-id';
      options.environment = 'production';
      options.release = 'passgen@0.3.2+1';
      options.tracesSampleRate = 0.1;
      options.profilesSampleRate = 0.1;
      options.sendDefaultPii = false;
      
      // Filter sensitive data
      options.beforeSend = (SentryEvent event, {hint}) {
        // Remove sensitive data from events
        if (event.request?.data != null) {
          event.request = event.request?.copyWith(data: null);
        }
        return event;
      };
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

## 3. Capture Errors

```dart
// Automatic error capturing (wrapped in runApp)
SentryFlutter.captureException(error, stackTrace: stack);

// Manual error capturing
try {
  // Your code
} catch (error, stackTrace) {
  await Sentry.captureException(error, stackTrace: stackTrace);
}

// Add breadcrumbs for context
await Sentry.addBreadcrumb(
  Breadcrumb(
    message: 'User generated password',
    category: 'user.action',
    level: SentryLevel.info,
  ),
);

// Set user context (use hashed identifiers!)
await Sentry.setUser(
  id: hash(userId),
  username: null, // Don't send actual username
);
```

## 4. Performance Monitoring

```dart
// Transaction for screen navigation
final transaction = Sentry.startTransaction(
  'home_screen',
  'navigation',
  bindToScope: true,
);

// Your code here

await transaction.finish();

// Span for specific operations
final span = transaction.startChild(
  'password_generation',
  description: 'Generate secure password',
);

// Your operation

await span.finish();
```

## 5. Platform-Specific Setup

### Android
- No additional setup required

### iOS
- No additional setup required

### Web
- Add to `web/index.html`:
```html
<script src="https://browser.sentry-cdn.com/7.0.0/bundle.min.js"></script>
```

### Desktop (Linux, Windows, macOS)
- No additional setup required

## 6. Testing Integration

```dart
// Test error reporting
@pragma('vm:entry-point')
void crash() => throw Exception('Test crash for Sentry');

// Call this in debug mode only
if (kDebugMode) {
  crash();
}
```

## 7. Dashboard Setup

1. Create project at https://sentry.io
2. Configure alerts:
   - New issue detected
   - Regression in release
   - Performance degradation
3. Set up integrations:
   - Slack notifications
   - Jira issue creation
   - GitHub commit linking

## 8. Privacy Considerations

- Never send passwords or encryption keys
- Hash user identifiers
- Disable PII collection
- Review error messages for sensitive data
- Use `beforeSend` to filter events
