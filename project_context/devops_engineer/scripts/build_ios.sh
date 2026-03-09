#!/bin/bash
# ===========================================
# Build Script for iOS
# ===========================================
# Usage: ./build_ios.sh [debug|release] [--no-codesign]
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BUILD_TYPE="${1:-release}"
NO_CODESIGN="${2:-}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/build/ios"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed"
        exit 1
    fi
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "iOS builds require macOS"
        exit 1
    fi
    
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode is not installed"
        exit 1
    fi
    
    log_info "Flutter version: $(flutter --version --short)"
    log_info "Xcode version: $(xcodebuild -version | head -n 1)"
}

# Setup environment
setup_environment() {
    log_info "Setting up build environment..."
    
    cd "$PROJECT_ROOT"
    
    # Get dependencies
    flutter pub get
    
    # Clean previous builds
    flutter clean
    
    # Get iOS dependencies
    cd ios
    pod install
    cd ..
}

# Build iOS
build_ios() {
    log_info "Building iOS ($BUILD_TYPE)..."
    
    mkdir -p "$OUTPUT_DIR"
    
    local build_args=""
    
    if [ "$BUILD_TYPE" == "debug" ]; then
        build_args="--debug"
    else
        build_args="--release"
    fi
    
    if [ "$NO_CODESIGN" == "--no-codesign" ]; then
        build_args="$build_args --no-codesign"
        log_info "Building without codesigning"
    fi
    
    flutter build ios $build_args
    
    # Copy build artifacts
    if [ "$BUILD_TYPE" == "release" ]; then
        cp -r build/ios/iphoneos/Runner.app "$OUTPUT_DIR/Runner-$TIMESTAMP.app" 2>/dev/null || true
    fi
    
    log_info "iOS build completed: $OUTPUT_DIR"
}

# Build IPA (requires codesigning)
build_ipa() {
    log_info "Building iOS IPA..."
    
    if [ "$BUILD_TYPE" != "release" ]; then
        log_warn "IPA builds require release mode"
        return
    fi
    
    if [ "$NO_CODESIGN" == "--no-codesign" ]; then
        log_warn "IPA builds require codesigning"
        return
    fi
    
    flutter build ipa
    
    mkdir -p "$OUTPUT_DIR"
    cp build/ios/archive/*.ipa "$OUTPUT_DIR/" 2>/dev/null || true
    
    log_info "IPA build completed"
}

# Export archive for App Store Connect
export_archive() {
    log_info "Preparing archive for App Store Connect..."
    
    if [ "$BUILD_TYPE" != "release" ]; then
        log_warn "Archive export requires release mode"
        return
    fi
    
    # Create archive
    xcodebuild -workspace ios/Runner.xcworkspace \
        -scheme Runner \
        -configuration Release \
        -archivePath "$OUTPUT_DIR/Runner-$TIMESTAMP.xcarchive" \
        archive
    
    log_info "Archive created: $OUTPUT_DIR/Runner-$TIMESTAMP.xcarchive"
}

# Main
main() {
    log_info "=========================================="
    log_info "iOS Build Script"
    log_info "Build type: $BUILD_TYPE"
    log_info "Codesign: $([ "$NO_CODESIGN" == "--no-codesign" ] && echo "No" || echo "Yes")"
    log_info "=========================================="
    
    check_prerequisites
    setup_environment
    build_ios
    
    if [ "$NO_CODESIGN" != "--no-codesign" ] && [ "$BUILD_TYPE" == "release" ]; then
        build_ipa
        export_archive
    fi
    
    log_info "=========================================="
    log_info "Build completed successfully!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "=========================================="
}

main "$@"
