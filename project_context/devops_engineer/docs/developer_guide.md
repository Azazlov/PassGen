# PassGen Developer Documentation

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Build Process](#build-process)
4. [Deployment](#deployment)
5. [Testing](#testing)
6. [Code Style](#code-style)
7. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.24.0 or higher
- **Dart SDK**: 3.9.0 or higher
- **Java**: 17 or higher (for Android builds)
- **Xcode**: Latest version (for iOS builds, macOS only)
- **Git**: Latest version

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/passgen.git
cd passgen

# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### IDE Setup

**VS Code**
- Install Flutter extension
- Install Dart extension

**Android Studio**
- Install Flutter plugin
- Install Dart plugin

---

## Development Workflow

### Branch Strategy

```
main          - Production-ready code
develop       - Integration branch for features
feature/*     - New features
bugfix/*      - Bug fixes
release/*     - Release preparation
hotfix/*      - Production hotfixes
```

### Commit Convention

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

**Example:**
```
feat(password): add strength indicator

Added visual password strength meter
- Integrated zxcvbn library
- Added color-coded strength levels

Closes #123
```

---

## Build Process

### Local Builds

```bash
# Debug build
flutter build apk --debug          # Android
flutter build ios --debug          # iOS
flutter build web --debug          # Web
flutter build linux --debug        # Linux
flutter build windows --debug      # Windows
flutter build macos --debug        # macOS

# Release build
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
flutter build web --release        # Web
```

### Using Build Scripts

```bash
# Navigate to scripts directory
cd project_context/devops/scripts

# Make scripts executable
chmod +x *.sh

# Build for specific platform
./build_android.sh release
./build_ios.sh release
./build_web.sh release
./build_desktop.sh linux release
```

---

## Deployment

### Test Environment

```bash
cd project_context/devops/scripts

# Deploy to test environment
./deploy_test.sh web latest
./deploy_test.sh android latest
```

### Production Environment

```bash
cd project_context/devops/scripts

# Dry run (recommended first)
./deploy_prod.sh web latest --dry-run

# Actual deployment (requires confirmation)
./deploy_prod.sh web latest
```

### Environment Variables

Create `.env` file in project root:

```bash
# Firebase
FIREBASE_APP_ID=your-app-id
FIREBASE_TOKEN=your-token

# Slack Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
SLACK_CHANNEL=#ci-cd-notifications

# Telegram Notifications
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_CHAT_ID=your-chat-id

# AWS (for web deployment)
PROD_S3_BUCKET=passgen-production
PROD_CLOUDFRONT_ID=your-cloudfront-id
PROD_DOMAIN=passgen.example.com
```

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test file
flutter test test/widgets/password_generator_test.dart

# Watch mode
flutter test --watch
```

### Test Structure

```
test/
├── widgets/           # Widget tests
│   └── password_generator_test.dart
├── sqlite_test.dart   # Database tests
└── unit/              # Unit tests (create as needed)
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordGenerator', () {
    test('generates password with correct length', () {
      // Arrange
      final generator = PasswordGenerator();
      
      // Act
      final password = generator.generate(length: 16);
      
      // Assert
      expect(password.length, 16);
    });
  });
}
```

---

## Code Style

### Formatting

```bash
# Check formatting
dart format --set-exit-if-changed lib/ test/

# Fix formatting
dart format lib/ test/
```

### Analysis

```bash
# Run static analysis
flutter analyze

# With fix suggestions
flutter analyze --fix
```

### Linting Rules

See `analysis_options.yaml` for configured lint rules.

---

## Troubleshooting

### Common Issues

**Build fails with "Gradle error"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**iOS build fails**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Web build has routing issues**
- Ensure base href is set in `web/index.html`
- Check Flutter web renderer settings

**Desktop build fails on Linux**
```bash
# Install required dependencies
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### Getting Help

1. Check existing issues in the repository
2. Review Flutter documentation: https://docs.flutter.dev
3. Check project documentation in `project_context/devops/docs/`

---

## CI/CD Pipeline

### GitHub Actions

Workflows are triggered on:
- Push to `main` or `develop`
- Pull requests
- Version tags (`v*`)

**Jobs:**
1. Code Quality (formatting, analysis)
2. Tests (unit, widget)
3. Build (Android, iOS, Web, Desktop)
4. Deploy (on tags)
5. Notify (Slack/Telegram)

### Viewing Build Status

- GitHub Actions: https://github.com/your-org/passgen/actions
- Firebase App Distribution: Check email invitations
- Sentry: https://sentry.io/organizations/your-org/

---

## Contact

For questions or issues:
- Open an issue in the repository
- Contact the DevOps team
- Check `project_context/devops/access.md` for access details
