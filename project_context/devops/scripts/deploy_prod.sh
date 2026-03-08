#!/bin/bash
# ===========================================
# Deployment Script for Production Environment
# ===========================================
# Usage: ./deploy_prod.sh [android|ios|web|desktop] [version] --dry-run
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PLATFORM="${1:-web}"
VERSION="${2:-latest}"
DRY_RUN="${3:-}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVOPS_DIR="$PROJECT_ROOT/project_context/devops"
LOGS_DIR="$DEVOPS_DIR/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOGS_DIR/deploy_prod_${TIMESTAMP}.log"

# Production environment configuration
PROD_FIREBASE_APP_ID="${PROD_FIREBASE_APP_ID:-}"
PROD_FIREBASE_TOKEN="${PROD_FIREBASE_TOKEN:-}"
PROD_S3_BUCKET="${PROD_S3_BUCKET:-passgen-production}"
PROD_PLAY_STORE_SERVICE_ACCOUNT="${PROD_PLAY_STORE_SERVICE_ACCOUNT:-}"
PROD_APP_STORE_CONNECT_API_KEY="${PROD_APP_STORE_CONNECT_API_KEY:-}"

# Require confirmation for production
require_confirmation() {
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_info "DRY RUN MODE - No changes will be made"
        return 0
    fi
    
    log_warn "=========================================="
    log_warn "PRODUCTION DEPLOYMENT"
    log_warn "=========================================="
    log_warn "Platform: $PLATFORM"
    log_warn "Version: $VERSION"
    log_warn "=========================================="
    read -p "Are you sure you want to deploy to PRODUCTION? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Deployment cancelled"
        exit 0
    fi
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

# Setup logging
setup_logging() {
    mkdir -p "$LOGS_DIR"
    touch "$LOG_FILE"
    log_info "Production deployment log started: $LOG_FILE"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."
    
    # Check version tag
    if [ "$VERSION" != "latest" ]; then
        if ! git rev-parse "$VERSION" >/dev/null 2>&1; then
            log_error "Version tag '$VERSION' not found"
            exit 1
        fi
        log_info "Version tag verified: $VERSION"
    fi
    
    # Check if on main branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$current_branch" != "main" ]; then
        log_warn "Not on main branch (current: $current_branch)"
        read -p "Continue anyway? (yes/no): " continue_deploy
        if [ "$continue_deploy" != "yes" ]; then
            exit 0
        fi
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "Uncommitted changes detected"
        read -p "Continue anyway? (yes/no): " continue_deploy
        if [ "$continue_deploy" != "yes" ]; then
            exit 0
        fi
    fi
    
    log_info "Pre-deployment checks passed"
}

# Get build artifact
get_build_artifact() {
    log_info "Getting build artifact for $PLATFORM (version: $VERSION)..."
    
    case "$PLATFORM" in
        android)
            if [ "$VERSION" == "latest" ]; then
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/app/outputs/bundle/release" -name "*.aab" -type f | sort | tail -1)
            else
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/app/outputs/bundle/release" -name "*.aab" -type f | head -1)
            fi
            ;;
        ios)
            ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/ios/archive" -name "*.ipa" -type f | sort | tail -1)
            ;;
        web)
            ARTIFACT_PATH="$PROJECT_ROOT/build/web"
            ;;
        *)
            log_error "Unknown platform: $PLATFORM"
            exit 1
            ;;
    esac
    
    if [ -z "$ARTIFACT_PATH" ] || [ ! -e "$ARTIFACT_PATH" ]; then
        log_error "Build artifact not found. Please build first."
        exit 1
    fi
    
    log_info "Artifact found: $ARTIFACT_PATH"
}

# Deploy to Google Play Store
deploy_play_store() {
    log_info "Deploying to Google Play Store (production track)..."
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_info "[DRY RUN] Would deploy to Play Store"
        return 0
    fi
    
    if ! command -v fastlane &> /dev/null; then
        log_error "Fastlane is required for Play Store deployment"
        exit 1
    fi
    
    cd "$PROJECT_ROOT/android"
    
    fastlane supply \
        --aab "$ARTIFACT_PATH" \
        --track production \
        --skip_upload_apk false \
        --skip_upload_changelog true \
        --skip_upload_screenshots true
    
    cd "$PROJECT_ROOT"
    
    log_info "Play Store deployment initiated (review required)"
}

# Deploy to Apple App Store
deploy_app_store() {
    log_info "Deploying to Apple App Store..."
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_info "[DRY RUN] Would deploy to App Store"
        return 0
    fi
    
    if ! command -v fastlane &> /dev/null; then
        log_error "Fastlane is required for App Store deployment"
        exit 1
    fi
    
    cd "$PROJECT_ROOT/ios"
    
    fastlane deliver \
        --ipa "$ARTIFACT_PATH" \
        --skip_binary_upload false \
        --skip_metadata true \
        --skip_screenshots true
    
    cd "$PROJECT_ROOT"
    
    log_info "App Store deployment initiated (review required)"
}

# Deploy web to production
deploy_web_production() {
    log_info "Deploying web to production..."
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_info "[DRY RUN] Would deploy web to production"
        return 0
    fi
    
    if [ -z "$PROD_S3_BUCKET" ]; then
        log_error "Production S3 bucket not configured"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is required for web deployment"
        exit 1
    fi
    
    # Deploy to S3
    aws s3 sync "$ARTIFACT_PATH" "s3://$PROD_S3_BUCKET" \
        --delete \
        --cache-control "public,max-age=31536000,immutable"
    
    # Invalidate CloudFront
    if [ -n "$PROD_CLOUDFRONT_ID" ]; then
        aws cloudfront create-invalidation \
            --distribution-id "$PROD_CLOUDFRONT_ID" \
            --paths "/*"
    fi
    
    log_info "Web production deployment completed"
}

# Deploy to Firebase App Distribution (production)
deploy_firebase_production() {
    log_info "Deploying to Firebase (production)..."
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_info "[DRY RUN] Would deploy to Firebase"
        return 0
    fi
    
    if [ -z "$PROD_FIREBASE_TOKEN" ]; then
        log_warn "Firebase token not set, skipping"
        return 0
    fi
    
    if ! command -v firebase &> /dev/null; then
        log_warn "Firebase CLI not installed, skipping"
        return 0
    fi
    
    case "$PLATFORM" in
        android|ios)
            firebase appdistribution:distribute "$ARTIFACT_PATH" \
                --app "$PROD_FIREBASE_APP_ID" \
                --groups stakeholders \
                --token "$PROD_FIREBASE_TOKEN" \
                --release-notes "Production release $VERSION"
            ;;
    esac
    
    log_info "Firebase deployment completed"
}

# Post-deployment verification
post_deployment_verification() {
    log_info "Running post-deployment verification..."
    
    case "$PLATFORM" in
        web)
            if [ -n "$PROD_DOMAIN" ]; then
                local status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$PROD_DOMAIN")
                if [ "$status_code" -eq 200 ]; then
                    log_info "Production verification successful (HTTP $status_code)"
                else
                    log_error "Production verification failed (HTTP $status_code)"
                    exit 1
                fi
            fi
            ;;
    esac
    
    log_info "Post-deployment verification completed"
}

# Notify stakeholders
notify_stakeholders() {
    log_info "Notifying stakeholders..."
    
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚀 Production Deployment Completed\\nPlatform: $PLATFORM\\nVersion: $VERSION\\nStatus: Success\"}" \
            "$SLACK_WEBHOOK_URL" || true
    fi
    
    log_info "Stakeholder notifications sent"
}

# Cleanup
cleanup() {
    log_info "Cleaning up..."
    # Add cleanup logic if needed
}

# Main
main() {
    log_info "=========================================="
    log_info "PRODUCTION DEPLOYMENT"
    log_info "Platform: $PLATFORM"
    log_info "Version: $VERSION"
    log_info "Timestamp: $TIMESTAMP"
    log_info "=========================================="
    
    setup_logging
    require_confirmation
    pre_deployment_checks
    get_build_artifact
    
    case "$PLATFORM" in
        android)
            deploy_play_store
            deploy_firebase_production
            ;;
        ios)
            deploy_app_store
            deploy_firebase_production
            ;;
        web)
            deploy_web_production
            ;;
        *)
            log_error "Unsupported platform for production: $PLATFORM"
            exit 1
            ;;
    esac
    
    post_deployment_verification
    notify_stakeholders
    cleanup
    
    log_info "=========================================="
    log_info "Production deployment completed!"
    log_info "Log file: $LOG_FILE"
    log_info "=========================================="
}

# Trap for cleanup on error
trap cleanup EXIT

main "$@"
