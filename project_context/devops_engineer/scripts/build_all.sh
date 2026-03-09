#!/bin/bash
# ===========================================
# Unified Build Script for All Platforms
# ===========================================
# Usage: ./build_all.sh [debug|release]
# ===========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BUILD_TYPE="${1:-release}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"
LOGS_DIR="$(dirname "${BASH_SOURCE[0]}")/../logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${BLUE}=========================================${NC}"; }

# Create logs directory
mkdir -p "$LOGS_DIR"

log_header
log_info "PassGen Unified Build Script"
log_info "Build Type: $BUILD_TYPE"
log_info "Timestamp: $TIMESTAMP"
log_header

# Check prerequisites
log_info "Checking prerequisites..."
if ! command -v flutter &> /dev/null; then
    log_error "Flutter is not installed"
    exit 1
fi

cd "$PROJECT_ROOT"

# Get dependencies
log_info "Getting dependencies..."
flutter pub get

# Run tests (optional, skip in release mode)
if [ "$BUILD_TYPE" == "debug" ]; then
    log_info "Running tests..."
    flutter test || log_warn "Tests failed, continuing build..."
fi

# Build for each platform
build_platform() {
    local platform=$1
    local script="$SCRIPTS_DIR/build_${platform}.sh"
    
    log_header
    log_info "Building for $platform..."
    log_header
    
    if [ -f "$script" ]; then
        chmod +x "$script"
        "$script" "$BUILD_TYPE" 2>&1 | tee "$LOGS_DIR/build_${platform}_${TIMESTAMP}.log"
        log_info "$platform build completed"
    else
        log_warn "Build script not found for $platform"
    fi
}

# Build all platforms
build_platform "android"
build_platform "ios"
build_platform "web"
build_platform "desktop"

log_header
log_info "All builds completed!"
log_info "Check logs in: $LOGS_DIR"
log_header
