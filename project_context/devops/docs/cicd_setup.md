# CI/CD Setup Guide

## Quick Start

1. Copy CI/CD configuration to `.github/workflows/`
2. Configure secrets in GitHub repository settings
3. Push to trigger first build

---

## GitHub Actions Setup

### Step 1: Copy Workflow Files

```bash
# Copy workflow files
cp project_context/devops/ci_cd/github-actions-flutter.yml .github/workflows/
cp project_context/devops/ci_cd/github-actions-pr.yml .github/workflows/
```

### Step 2: Configure Repository Secrets

Navigate to: **Settings > Secrets and variables > Actions**

Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `FIREBASE_TOKEN` | Firebase CLI token | `1//0e...` |
| `FIREBASE_APP_ID` | Firebase App ID | `1:123...` |
| `SLACK_WEBHOOK_URL` | Slack webhook URL | `https://hooks...` |
| `CODECOV_TOKEN` | Codecov token (optional) | `uuid-here` |

### Step 3: Enable Required Services

**Firebase:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Get token
firebase login:ci

# Copy token to GitHub Secrets as FIREBASE_TOKEN
```

**Firebase Project Setup:**
```bash
# Initialize Firebase in project
firebase init

# Select:
# - Hosting (for web)
# - App Distribution (for mobile)
```

---

## GitLab CI Setup (Alternative)

### Step 1: Copy Configuration

```bash
cp project_context/devops/ci_cd/gitlab-ci.yml .gitlab-ci.yml
```

### Step 2: Configure CI/CD Variables

Navigate to: **Settings > CI/CD > Variables**

Add variables:
- `FIREBASE_TOKEN`
- `FIREBASE_APP_ID`
- `SLACK_WEBHOOK_URL`
- `CODECOV_TOKEN`

### Step 3: Configure Runners

Ensure GitLab runners are available for:
- Linux (ubuntu-latest)
- macOS (for iOS builds)
- Windows (for Windows builds)

---

## Firebase Configuration

### Create Firebase Project

1. Go to https://console.firebase.google.com
2. Create new project "PassGen"
3. Add Android app:
   - Package name: `com.yourorg.passgen`
   - Download `google-services.json`
   - Place in `android/app/`
4. Add iOS app:
   - Bundle ID: `com.yourorg.passgen`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`
5. Add Web app:
   - Register app
   - Copy config to `lib/firebase_options.dart`

### Enable Services

**App Distribution:**
1. Enable App Distribution
2. Add tester groups (testers, stakeholders)
3. Configure release notes template

**Hosting (for web):**
1. Enable Hosting
2. Configure custom domain (optional)
3. Set up deploy targets

---

## Sentry Configuration

### Create Sentry Project

1. Go to https://sentry.io
2. Create new project (Flutter)
3. Copy DSN

### Add to Flutter

```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0
```

```dart
// lib/main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'your-dsn-here';
  },
  appRunner: () => runApp(MyApp()),
);
```

### Configure GitHub Integration

1. Go to Sentry Settings > Integrations
2. Enable GitHub integration
3. Connect repository
4. Configure commit tracking

---

## Slack Integration

### Create Incoming Webhook

1. Go to https://your-workspace.slack.com/apps
2. Search "Incoming Webhooks"
3. Add to workspace
4. Create webhook
5. Select channel: `#ci-cd-notifications`
6. Copy webhook URL
7. Add to GitHub Secrets as `SLACK_WEBHOOK_URL`

### Test Integration

```bash
# Test webhook
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message from CI/CD"}' \
  https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

---

## Telegram Integration

### Create Bot

1. Message @BotFather on Telegram
2. Send `/newbot`
3. Follow prompts
4. Copy bot token
5. Add to secrets as `TELEGRAM_BOT_TOKEN`

### Get Chat ID

1. Add bot to channel/group
2. Send message in channel
3. Use @getidsbot to get chat ID
4. Add to secrets as `TELEGRAM_CHAT_ID`

---

## Codecov Integration (Optional)

### Setup

1. Go to https://codecov.io
2. Sign in with GitHub
3. Enable repository
4. Copy token
5. Add to secrets as `CODECOV_TOKEN`

### Upload Coverage

Already configured in workflow. Coverage uploads automatically after tests.

---

## Verification

### Trigger Test Build

```bash
# Create test commit
git commit --allow-empty -m "ci: trigger test build"
git push
```

### Verify Jobs

Check GitHub Actions for:
- ✅ Code Quality passed
- ✅ Tests passed
- ✅ Builds completed
- ✅ Artifacts uploaded
- ✅ Notifications sent

### Download Artifacts

After successful build:
1. Go to Actions tab
2. Select workflow run
3. Scroll to Artifacts section
4. Download desired artifact

---

## Troubleshooting

### Build Fails on Checkout

- Verify repository access
- Check branch protection rules

### Firebase Deployment Fails

- Verify token is valid (regenerate if expired)
- Check App ID matches
- Ensure app is registered in Firebase

### Slack Notifications Not Working

- Test webhook URL manually
- Check channel exists
- Verify webhook has post permissions

### iOS Build Fails

- Ensure running on macOS runner
- Check code signing settings
- Verify provisioning profiles

---

## Optimization Tips

### Reduce Build Time

1. Enable caching (already configured)
2. Use specific Flutter version
3. Split jobs by platform
4. Cancel redundant workflows

### Reduce Resource Usage

1. Use `fetch-depth: 1` for checkout
2. Limit artifact retention
3. Use matrix builds for similar jobs
4. Set appropriate timeouts

---

## Next Steps

1. Configure production deployment
2. Set up release automation
3. Add performance monitoring
4. Configure alerting rules
