# PassGen — Project Context

## Project Overview

**PassGen** is a cross-platform password manager built with Flutter for Windows, Linux, and Android. It provides password generation, secure storage, and management using modern cryptographic methods (ChaCha20-Poly1305, PBKDF2) with a local SQLite database.

**Current Version:** 0.5.0 (Release Ready)  
**Last Updated:** March 10, 2026  
**Security Score:** 98/100

### Key Features

| Feature | Description |
|---------|-------------|
| **🔐 Authentication** | PIN-code (4-8 digits) with PBKDF2 key derivation (10,000 iterations, HMAC-SHA256), brute-force protection (30s lockout after 5 attempts), auto-lock after 5 min inactivity |
| **🎲 Password Generator** | Length 8-64 chars, 4 character categories, 5 difficulty presets, strength evaluation (zxcvbn + heuristics), category selection |
| **🗄️ Secure Storage** | SQLite database (5 tables), CRUD operations, 7 system + custom categories, search & filtering |
| **📦 Import/Export** | JSON (minified) and `.passgen` encrypted format with ChaCha20-Poly1305 |
| **🔧 Message Encryptor** | Encrypt/decrypt text messages using ChaCha20-Poly1305 (AEAD) |
| **📊 Security Logging** | Event logging for auth attempts, password operations, exports/imports |

---

## Building and Running

### Prerequisites

| Component | Version |
|-----------|---------|
| Flutter SDK | ^3.24.0 |
| Dart SDK | ^3.9.0 |
| Android Studio | For APK builds |
| Xcode | For iOS/macOS builds (optional) |

### Setup

```bash
# Clone repository
git clone https://github.com/azazlov/passgen.git
cd passgen

# Install dependencies
flutter pub get

# Run on specific device
flutter run -d <device>  # linux, windows, android
```

### Build Commands

```bash
# Windows
flutter build windows

# Linux
flutter build linux

# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/sqlite_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality

```bash
# Static analysis
flutter analyze

# Fix formatting
dart format .
```

---

## Architecture

### Clean Architecture (5 Layers)

```
┌─────────────────────────────────────────────────────────┐
│                    App Layer                            │
│            (DI, Navigation, Theme)                      │
├─────────────────────────────────────────────────────────┤
│               Presentation Layer                        │
│         (UI, Controllers, Widgets)                      │
├─────────────────────────────────────────────────────────┤
│                 Domain Layer                            │
│    (Entities, Use Cases, Repository Interfaces)         │
├─────────────────────────────────────────────────────────┤
│                  Data Layer                             │
│   (Repository Implementations, Data Sources, SQLite)    │
├─────────────────────────────────────────────────────────┤
│                  Core Layer                             │
│        (Utils, Constants, Errors)                       │
└─────────────────────────────────────────────────────────┘
```

**Principles:**
- Dependencies point inward (toward Domain)
- Domain Layer has no external dependencies
- State Management: Provider + ChangeNotifier

### Project Structure

```
lib/
├── app/                          # Entry point, DI, navigation, themes
│   ├── app.dart                  # Main widget, Provider setup
│   └── theme.dart                # Material 3 themes
│
├── core/                         # Shared utilities, constants, errors
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── event_types.dart
│   ├── errors/
│   │   └── failures.dart
│   └── utils/
│       ├── crypto_utils.dart
│       └── password_utils.dart
│
├── domain/                       # Business logic (no external deps)
│   ├── entities/                 # 8 business entities
│   │   ├── auth_state.dart
│   │   ├── auth_result.dart
│   │   ├── category.dart
│   │   ├── password_config.dart
│   │   ├── password_entry.dart
│   │   ├── password_generation_settings.dart
│   │   ├── password_result.dart
│   │   └── security_log.dart
│   ├── repositories/             # 10 repository interfaces
│   │   ├── auth_repository.dart
│   │   ├── category_repository.dart
│   │   ├── encryptor_repository.dart
│   │   ├── password_entry_repository.dart
│   │   ├── password_generator_repository.dart
│   │   ├── password_export_repository.dart
│   │   ├── password_import_repository.dart
│   │   ├── security_log_repository.dart
│   │   ├── app_settings_repository.dart
│   │   └── storage_repository.dart
│   └── usecases/                 # 25+ business rules
│       ├── auth/ (5)
│       ├── category/ (4)
│       ├── encryptor/ (2)
│       ├── log/ (2)
│       ├── password/ (2)
│       ├── settings/ (3)
│       └── storage/ (6-8)
│
├── data/                         # Data layer (depends on domain)
│   ├── database/
│   │   ├── database_helper.dart
│   │   ├── database_schema.dart
│   │   ├── database_migrations.dart
│   │   └── migration_from_shared_prefs.dart
│   ├── datasources/              # 4 local data sources
│   │   ├── auth_local_datasource.dart
│   │   ├── encryptor_local_datasource.dart
│   │   ├── password_generator_local_datasource.dart
│   │   └── storage_local_datasource.dart
│   ├── formats/
│   │   └── passgen_format.dart
│   ├── models/                   # 5 data models (extend entities)
│   │   ├── app_settings_model.dart
│   │   ├── category_model.dart
│   │   ├── password_config_model.dart
│   │   ├── password_entry_model.dart
│   │   └── security_log_model.dart
│   └── repositories/             # 9 repository implementations
│
├── presentation/                 # UI layer (depends on domain)
│   ├── features/                 # 8 screens
│   │   ├── auth/
│   │   ├── generator/
│   │   ├── storage/
│   │   ├── encryptor/
│   │   ├── settings/
│   │   ├── categories/
│   │   ├── logs/
│   │   └── about/
│   └── widgets/                  # Reusable widgets
│       ├── app_button.dart
│       ├── app_dialogs.dart
│       ├── app_switch.dart
│       ├── app_text_field.dart
│       ├── copyable_password.dart
│       └── shimmer_effect.dart
│
└── shared/                       # Shared components
    ├── dialog.dart
    └── interface.dart
```

---

## Key Technologies

| Category | Packages |
|----------|----------|
| **State Management** | `provider` ^6.1.1 |
| **Database** | `sqflite` ^2.4.2, `sqflite_common_ffi` ^2.4.0+2 |
| **Cryptography** | `cryptography` ^2.7.0 (ChaCha20-Poly1305, PBKDF2, CSPRNG) |
| **Password Strength** | `zxcvbn` ^1.0.0, `password_strength` ^0.2.0 |
| **Functional** | `dartz` ^0.10.1 (Either, Option) |
| **File Operations** | `file_picker` ^10.3.2, `path_provider` ^2.1.5, `share_plus` ^12.0.0 |
| **UI** | `google_fonts` ^6.3.2, `lottie` ^3.0.0, Material 3 |
| **Utilities** | `uuid` ^4.5.1, `url_launcher` ^6.2.4, `shared_preferences` ^2.5.3 |

---

## Database Schema (5 Tables)

```sql
-- Categories (7 system + user-defined)
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT,
  is_system INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- Password Entries (encrypted)
CREATE TABLE password_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER REFERENCES categories(id),
  service TEXT NOT NULL,
  login TEXT,
  encrypted_password BLOB NOT NULL,
  nonce BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Password Configurations
CREATE TABLE password_configs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER UNIQUE REFERENCES password_entries(id),
  strength INTEGER,
  min_length INTEGER,
  max_length INTEGER,
  flags INTEGER,
  require_unique INTEGER DEFAULT 0,
  encrypted_config BLOB
);

-- Security Logs
CREATE TABLE security_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_type TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  details TEXT
);

-- App Settings
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  encrypted INTEGER DEFAULT 0
);
```

---

## Cryptography

### Algorithms

| Algorithm | Purpose | Parameters |
|-----------|---------|------------|
| **ChaCha20-Poly1305** | Data encryption | AEAD, 256-bit key |
| **PBKDF2-HMAC-SHA256** | Key derivation from PIN | 10,000 iterations, 256-bit |
| **CSPRNG** | Random number generation | `Random.secure()` |

### .passgen File Format

```
┌─────────────────────────────────────┐
│ HEADER: "PASSGEN_V1" (10 bytes)     │
├─────────────────────────────────────┤
│ VERSION: 1 (1 byte)                 │
├─────────────────────────────────────┤
│ FLAGS: 0 (1 byte)                   │
├─────────────────────────────────────┤
│ NONCE: random 32 bytes              │
├─────────────────────────────────────┤
│ DATA_LENGTH: length (4 bytes)       │
├─────────────────────────────────────┤
│ DATA: encrypted JSON                │
├─────────────────────────────────────┤
│ MAC: authentication tag (16 bytes)  │
└─────────────────────────────────────┘
```

---

## Development Conventions

### Code Style

- **Quotes:** Single quotes preferred (`prefer_single_quotes: true`)
- **Constants:** Prefer `const` constructors and `final` for immutable variables
- **Null Safety:** Use `??` instead of conditional checks
- **Documentation:** Public API docs optional (disabled for development)
- **Formatting:** Follow `flutter_lints` rules

### Testing Practices

- **Unit Tests:** Located in `test/unit/` and `test/usecases/`
- **Widget Tests:** Located in `test/widgets/`
- **Integration Tests:** Located in `test/`
- **Mocking:** Uses `mockito` for repository mocks
- **Coverage Target:** ~82% (current)

### Commit Conventions

- Follow conventional commits pattern
- Reference issues/PRs in commit messages
- Include scope when applicable (e.g., `feat(auth): add biometric support`)

---

## Testing

### Test Structure

```
test/
├── unit/                       # Unit tests
│   ├── crypto_utils_test.dart
│   ├── integrity_and_versioning_test.dart
│   └── usecases/               # Use case tests
├── usecases/                   # Integration tests
│   └── auth/                   # Auth flow tests
├── widgets/                    # Widget tests
│   ├── copyable_password_test.dart
│   ├── character_set_display_test.dart
│   └── shimmer_effect_test.dart
└── sqlite_test.dart            # Database tests
```

### Test Statistics

| Type | Count | Status |
|------|-------|--------|
| Unit Tests | 33 | ✅ Passed |
| Widget Tests | 82% coverage | ✅ Passed |

---

## Security Fixes (15 Resolved)

- ✅ PIN stored only in SQLite (removed from SharedPreferences)
- ✅ Key wiping after use
- ✅ Auto-clear clipboard after 60 seconds
- ✅ FLAG_SECURE for Android
- ✅ Removed debug logging from production

---

## Documentation

### Primary Documentation

| File | Description |
|------|-------------|
| [README.MD](README.MD) | User-facing overview, features, screenshots |
| [DEVELOPER.md](DEVELOPER.md) | Full developer documentation (architecture, API, crypto, testing) |
| [LICENSE](LICENSE) | MIT License |

### Project Documentation (project_context/)

| Directory | Description |
|-----------|-------------|
| `product-manager-tracker/` | Technical specs, progress tracking, requirements |
| `security-data-flow-analyzer/` | Security audits, data flow analysis |
| `tech-docs-writer/` | User guides, FAQ, changelog |
| `diploma-thesis-specialist/` | Thesis materials (if applicable) |
| `qa-engineer/` | Test reports, coverage analysis |
| `devops-engineer/` | Build & deploy strategies |

### Architecture Diagram

See `pass_gen.drawio` for visual architecture diagram.

---

## Common Tasks

### Add New Feature

1. Create entity in `domain/entities/`
2. Define repository interface in `domain/repositories/`
3. Implement use case in `domain/usecases/`
4. Create data source in `data/datasources/`
5. Implement repository in `data/repositories/`
6. Add controller in `presentation/features/`
7. Create screen/widget
8. Register in `app/app.dart` with Provider
9. Write tests

### Debug Database

```dart
// In lib/data/database/database_helper.dart
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
// Query directly for debugging
```

### Run on Multiple Devices

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d linux       # Linux
flutter run -d <device-id> # Android
```

---

## Troubleshooting

### Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build <platform>
```

### Database Migration Issues

Check `lib/data/database/migration_from_shared_prefs.dart` for migration logic from old SharedPreferences storage to SQLite.

### Dependency Conflicts

```bash
# Upgrade dependencies
flutter pub upgrade

# Check for issues
flutter pub outdated
```

---

## Contact & Support

- **Repository:** https://github.com/azazlov/passgen
- **Issues:** https://github.com/azazlov/passgen/issues
- **Author:** @azazlov

## Qwen Added Memories
- @QWEN.md @.qwen/PROJECT_SUMMARY.md @docs/DOCUMENTATION.md
- @.qwen/ @docs/ @QWEN.md
