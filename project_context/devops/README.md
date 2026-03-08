# PassGen DevOps Configuration

This directory contains all DevOps configurations, scripts, and documentation for the PassGen Flutter project.

## Directory Structure

```
devops/
├── ci_cd/                      # CI/CD Configuration Files
│   ├── github-actions-flutter.yml    # Main GitHub Actions workflow
│   ├── github-actions-pr.yml         # PR validation workflow
│   └── gitlab-ci.yml                 # GitLab CI configuration (alternative)
│
├── scripts/                    # Build and Deployment Scripts
│   ├── build_android.sh        # Android build script
│   ├── build_ios.sh            # iOS build script
│   ├── build_web.sh            # Web build script
│   ├── build_desktop.sh        # Desktop build script (Linux, Windows, macOS)
│   ├── build_all.sh            # Unified build script for all platforms
│   ├── deploy_test.sh          # Test environment deployment
│   ├── deploy_prod.sh          # Production environment deployment
│   ├── notify_slack.py         # Slack notification script
│   └── notify_telegram.py      # Telegram notification script
│
├── monitoring/                 # Monitoring Configuration
│   ├── sentry.yaml             # Sentry configuration
│   ├── firebase_crashlytics.yaml # Firebase Crashlytics config
│   ├── sentry_integration.md   # Sentry integration guide
│   └── fastlane_config.rb      # Fastlane configuration
│
├── logs/                       # Deployment Logs (generated)
│   └── *.log                   # Build and deployment logs
│
├── docs/                       # Documentation
│   ├── developer_guide.md      # Developer documentation
│   ├── cicd_setup.md           # CI/CD setup guide
│   └── README.md               # This file
│
└── access.md                   # Access information and credentials guide
```

## Quick Start

### For Developers

1. **Build locally:**
   ```bash
   cd project_context/devops/scripts
   chmod +x *.sh
   ./build_android.sh release
   ```

2. **Run tests:**
   ```bash
   flutter test
   ```

3. **Deploy to test:**
   ```bash
   ./deploy_test.sh web latest
   ```

### For CI/CD Setup

1. Copy workflow files:
   ```bash
   cp project_context/devops/ci_cd/github-actions-flutter.yml .github/workflows/
   ```

2. Configure secrets in GitHub repository settings

3. Push to trigger builds

## Available Commands

### Build Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `build_android.sh` | Build Android APK/AAB | `./build_android.sh [debug|release]` |
| `build_ios.sh` | Build iOS app | `./build_ios.sh [debug|release] [--no-codesign]` |
| `build_web.sh` | Build web app | `./build_web.sh [debug|release] [--wasm]` |
| `build_desktop.sh` | Build desktop app | `./build_desktop.sh [linux|windows|macos] [debug|release]` |
| `build_all.sh` | Build all platforms | `./build_all.sh [debug|release]` |

### Deployment Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `deploy_test.sh` | Deploy to test environment | `./deploy_test.sh [android|ios|web] [version]` |
| `deploy_prod.sh` | Deploy to production | `./deploy_prod.sh [android|ios|web] [version] [--dry-run]` |

### Notification Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `notify_slack.py` | Send Slack notification | `python notify_slack.py --status success --build 123` |
| `notify_telegram.py` | Send Telegram notification | `python notify_telegram.py --status success --build 123` |

## Environment Variables

Create a `.env` file or configure in your CI/CD system:

```bash
# Firebase
FIREBASE_APP_ID=your-app-id
FIREBASE_TOKEN=your-token

# Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
SLACK_CHANNEL=#ci-cd-notifications
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_CHAT_ID=your-chat-id

# AWS (Web Deployment)
PROD_S3_BUCKET=passgen-production
PROD_CLOUDFRONT_ID=your-cloudfront-id
PROD_DOMAIN=passgen.example.com

# Test Environment
TEST_FIREBASE_APP_ID=test-app-id
TEST_FIREBASE_TOKEN=test-token
TEST_S3_BUCKET=passgen-test-builds
TEST_SERVER_URL=user@server.com
```

## Monitoring

### Sentry
- Configure DSN in `monitoring/sentry.yaml`
- Follow integration guide in `monitoring/sentry_integration.md`

### Firebase Crashlytics
- Add dependencies as per `monitoring/firebase_crashlytics.yaml`
- Initialize in `lib/main.dart`

### Fastlane
- Install: `brew install fastlane`
- Configure: See `monitoring/fastlane_config.rb`
- Run: `cd android && fastlane [lane_name]`

## Documentation

- **Developer Guide**: `docs/developer_guide.md`
- **CI/CD Setup**: `docs/cicd_setup.md`
- **Access Info**: `access.md`

## Support

For issues or questions:
1. Check documentation in `docs/`
2. Review logs in `logs/`
3. Contact DevOps team

---

**Last Updated**: 2026-03-08
**Version**: 1.0.0
