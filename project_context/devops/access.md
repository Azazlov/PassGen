# PassGen Access Guide

## Overview

This document provides access information for all PassGen infrastructure and services.

---

## Repository Access

### GitHub Repository

- **URL**: https://github.com/your-org/passgen
- **Access Level Required**: Read for viewing, Write for contributing
- **Contact**: Repository owners

### Branch Protection

| Branch | Protection | Required Reviews |
|--------|-----------|------------------|
| main   | Required  | 2 approvals      |
| develop| Recommended| 1 approval      |

---

## CI/CD Access

### GitHub Actions

- **Access**: All repository collaborators
- **Logs**: Available in Actions tab
- **Artifacts**: Downloadable for 14 days

### Firebase

| Environment | App ID | Access |
|------------|--------|--------|
| Test | `TEST_FIREBASE_APP_ID` | Testers group |
| Production | `PROD_FIREBASE_APP_ID` | Stakeholders group |

**Setup:**
1. Request access from project admin
2. Accept email invitation
3. Install Firebase App Distribution app

---

## Monitoring & Analytics

### Sentry

- **URL**: https://sentry.io/organizations/your-org/
- **Access Levels**:
  - Admin: Full access
  - Member: View issues, resolve, comment
  - Viewer: Read-only

**Getting Access:**
1. Contact project admin
2. Provide Sentry account email
3. Accept team invitation

### Firebase Crashlytics

- Access via Firebase Console
- URL: https://console.firebase.google.com/
- Requires Google account

---

## Deployment Targets

### Web Hosting

| Environment | URL | Access |
|------------|-----|--------|
| Test | https://test.passgen.app | Team members |
| Production | https://passgen.app | Public |

### Mobile Distribution

| Platform | Store | Access |
|----------|-------|--------|
| Android | Google Play Internal | Testers |
| iOS | TestFlight | Internal testers |

---

## Secrets Management

### Required Secrets

| Secret | Description | Where to Set |
|--------|-------------|--------------|
| `FIREBASE_TOKEN` | Firebase CLI token | GitHub Secrets |
| `FIREBASE_APP_ID` | Firebase App ID | GitHub Secrets |
| `SLACK_WEBHOOK_URL` | Slack notifications | GitHub Secrets |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | GitHub Secrets |
| `TELEGRAM_CHAT_ID` | Telegram chat ID | GitHub Secrets |
| `CODECOV_TOKEN` | Code coverage token | GitHub Secrets |
| `PROD_S3_BUCKET` | Production S3 bucket | GitHub Secrets |
| `PROD_CLOUDFRONT_ID` | CloudFront distribution | GitHub Secrets |

### Setting GitHub Secrets

1. Go to Repository Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add name and value
4. Save

---

## Service Accounts

### Google Play Store

- **Service Account**: Required for automated deployments
- **Setup**:
  1. Create service account in Google Cloud Console
  2. Grant "Release Manager" role
  3. Download JSON key
  4. Add to GitHub Secrets as `PLAY_STORE_SERVICE_ACCOUNT`

### Apple App Store Connect

- **API Key**: Required for automated deployments
- **Setup**:
  1. Create API key in App Store Connect
  2. Grant appropriate permissions
  3. Download key file
  4. Add key ID, issuer ID, and key content to secrets

---

## Notification Channels

### Slack

- **Channel**: #ci-cd-notifications
- **Webhook**: Admin must create incoming webhook
- **Setup**:
  1. Go to Slack App Directory
  2. Create Incoming Webhook
  3. Select channel
  4. Copy webhook URL to secrets

### Telegram

- **Bot**: @PassGenCIBot (example)
- **Chat ID**: Group or channel ID
- **Setup**:
  1. Create bot via @BotFather
  2. Get bot token
  3. Add bot to channel/group
  4. Get chat ID via @getidsbot
  5. Add to secrets

---

## Access Request Template

```
Subject: Access Request - [Service Name]

Hi Team,

I need access to the following service:
- Service: [Name]
- Purpose: [Why you need access]
- Required Level: [Read/Write/Admin]
- Account Email: [Your email]

Thanks,
[Your Name]
```

---

## Security Notes

- Never commit secrets to the repository
- Rotate tokens and keys regularly
- Use least-privilege access principle
- Report suspicious access immediately

---

## Contact

For access issues, contact:
- DevOps Team: devops@your-org.com
- Project Admin: admin@your-org.com
