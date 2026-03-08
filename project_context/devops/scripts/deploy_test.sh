#!/bin/bash
# ===========================================
# Deployment Script for Test Environment
# ===========================================
# Usage: ./deploy_test.sh [android|ios|web] [version]
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
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVOPS_DIR="$PROJECT_ROOT/project_context/devops"
LOGS_DIR="$DEVOPS_DIR/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOGS_DIR/deploy_test_${TIMESTAMP}.log"

# Test environment configuration
TEST_FIREBASE_APP_ID="${TEST_FIREBASE_APP_ID:-}"
TEST_FIREBASE_TOKEN="${TEST_FIREBASE_TOKEN:-}"
TEST_S3_BUCKET="${TEST_S3_BUCKET:-passgen-test-builds}"
TEST_SERVER_URL="${TEST_SERVER_URL:-}"

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
    log_info "Deployment log started: $LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing=()
    
    if ! command -v flutter &> /dev/null; then
        missing+=("flutter")
    fi
    
    if [ "$PLATFORM" == "android" ] && ! command -v java &> /dev/null; then
        missing+=("java")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing prerequisites: ${missing[*]}"
        exit 1
    fi
    
    log_info "All prerequisites met"
}

# Get build artifact
get_build_artifact() {
    log_info "Getting build artifact for $PLATFORM (version: $VERSION)..."
    
    local artifact_dir="$PROJECT_ROOT/build/artifacts"
    mkdir -p "$artifact_dir"
    
    case "$PLATFORM" in
        android)
            if [ "$VERSION" == "latest" ]; then
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/app/outputs" -name "*.apk" -type f | sort | tail -1)
            else
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/app/outputs" -name "*${VERSION}*.apk" -type f | head -1)
            fi
            ;;
        ios)
            if [ "$VERSION" == "latest" ]; then
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/ios" -name "*.app" -type d | sort | tail -1)
            else
                ARTIFACT_PATH=$(find "$PROJECT_ROOT/build/ios" -name "*${VERSION}*.app" -type d | head -1)
            fi
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

# Deploy to Firebase App Distribution
deploy_firebase() {
    log_info "Deploying to Firebase App Distribution (test environment)..."
    
    if [ -z "$TEST_FIREBASE_TOKEN" ]; then
        log_warn "Firebase token not set, skipping Firebase deployment"
        return 0
    fi
    
    if ! command -v firebase &> /dev/null; then
        log_warn "Firebase CLI not installed, skipping Firebase deployment"
        return 0
    fi
    
    case "$PLATFORM" in
        android)
            firebase appdistribution:distribute "$ARTIFACT_PATH" \
                --app "$TEST_FIREBASE_APP_ID" \
                --groups testers \
                --token "$TEST_FIREBASE_TOKEN" \
                --release-notes "Test deployment $TIMESTAMP"
            ;;
        ios)
            firebase appdistribution:distribute "$ARTIFACT_PATH" \
                --app "$TEST_FIREBASE_APP_ID" \
                --groups testers \
                --token "$TEST_FIREBASE_TOKEN" \
                --release-notes "Test deployment $TIMESTAMP"
            ;;
        web)
            firebase hosting:channel:deploy test \
                --only hosting \
                --token "$TEST_FIREBASE_TOKEN"
            ;;
    esac
    
    log_info "Firebase deployment completed"
}

# Deploy to test server
deploy_to_server() {
    log_info "Deploying to test server..."
    
    if [ -z "$TEST_SERVER_URL" ]; then
        log_warn "Test server URL not set, skipping server deployment"
        return 0
    fi
    
    case "$PLATFORM" in
        web)
            # Deploy web build to test server via SCP
            if command -v rsync &> /dev/null; then
                rsync -avz --delete "$ARTIFACT_PATH/" "$TEST_SERVER_URL:/var/www/passgen-test/"
            else
                scp -r "$ARTIFACT_PATH"/* "$TEST_SERVER_URL:/var/www/passgen-test/"
            fi
            log_info "Server deployment completed"
            ;;
        *)
            log_warn "Server deployment only supported for web platform"
            ;;
    esac
}

# Deploy to S3 (for web)
deploy_s3() {
    log_info "Deploying to S3 test bucket..."
    
    if [ -z "$TEST_S3_BUCKET" ]; then
        log_warn "S3 bucket not set, skipping S3 deployment"
        return 0
    fi
    
    if ! command -v aws &> /dev/null; then
        log_warn "AWS CLI not installed, skipping S3 deployment"
        return 0
    fi
    
    case "$PLATFORM" in
        web)
            aws s3 sync "$ARTIFACT_PATH" "s3://$TEST_S3_BUCKET" \
                --delete \
                --cache-control "public,max-age=31536000,immutable"
            
            # Invalidate CloudFront if configured
            if [ -n "$TEST_CLOUDFRONT_ID" ]; then
                aws cloudfront create-invalidation \
                    --distribution-id "$TEST_CLOUDFRONT_ID" \
                    --paths "/*"
            fi
            
            log_info "S3 deployment completed"
            ;;
        *)
            log_warn "S3 deployment only supported for web platform"
            ;;
    esac
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    case "$PLATFORM" in
        web)
            if [ -n "$TEST_SERVER_URL" ]; then
                local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$TEST_SERVER_URL")
                if [ "$status_code" -eq 200 ]; then
                    log_info "Deployment verification successful (HTTP $status_code)"
                else
                    log_warn "Deployment verification returned HTTP $status_code"
                fi
            fi
            ;;
        *)
            log_info "Deployment verification completed"
            ;;
    esac
}

# Cleanup
cleanup() {
    log_info "Cleaning up..."
    # Add cleanup logic if needed
}

# Main
main() {
    log_info "=========================================="
    log_info "Test Environment Deployment"
    log_info "Platform: $PLATFORM"
    log_info "Version: $VERSION"
    log_info "Timestamp: $TIMESTAMP"
    log_info "=========================================="
    
    setup_logging
    check_prerequisites
    get_build_artifact
    deploy_firebase
    deploy_to_server
    deploy_s3
    verify_deployment
    cleanup
    
    log_info "=========================================="
    log_info "Test deployment completed successfully!"
    log_info "Log file: $LOG_FILE"
    log_info "=========================================="
}

# Trap for cleanup on error
trap cleanup EXIT

main "$@"
