#!/bin/bash
# ===========================================
# Build Script for Android
# ===========================================
# Usage: ./build_android.sh [debug|release]
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUILD_TYPE="${1:-release}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/build/android"
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
    
    if ! command -v java &> /dev/null; then
        log_error "Java is not installed"
        exit 1
    fi
    
    log_info "Flutter version: $(flutter --version --short)"
    log_info "Java version: $(java -version 2>&1 | head -n 1)"
}

# Setup environment
setup_environment() {
    log_info "Setting up build environment..."
    
    cd "$PROJECT_ROOT"
    
    # Get dependencies
    flutter pub get
    
    # Clean previous builds
    flutter clean
}

# Build APK
build_apk() {
    log_info "Building Android APK ($BUILD_TYPE)..."
    
    mkdir -p "$OUTPUT_DIR"
    
    if [ "$BUILD_TYPE" == "debug" ]; then
        flutter build apk --debug
        cp build/app/outputs/flutter-apk/debug/app-debug.apk "$OUTPUT_DIR/app-debug-$TIMESTAMP.apk"
    else
        flutter build apk --release --split-per-abi
        cp build/app/outputs/flutter-apk/release/*.apk "$OUTPUT_DIR/"
        
        # Rename with timestamp
        for apk in build/app/outputs/flutter-apk/release/*.apk; do
            filename=$(basename "$apk")
            cp "$apk" "$OUTPUT_DIR/${filename%.apk}-$TIMESTAMP.apk"
        done
    fi
    
    log_info "APK build completed: $OUTPUT_DIR"
}

# Build App Bundle
build_appbundle() {
    log_info "Building Android App Bundle (release)..."
    
    mkdir -p "$OUTPUT_DIR"
    
    flutter build appbundle --release
    
    cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/app-release-$TIMESTAMP.aab"
    
    log_info "App Bundle build completed: $OUTPUT_DIR"
}

# Generate SHA fingerprints
generate_fingerprints() {
    log_info "Generating SHA fingerprints..."
    
    KEYSTORE_PATH="${KEYSTORE_PATH:-$PROJECT_ROOT/android/app/upload-keystore.jks}"
    
    if [ -f "$KEYSTORE_PATH" ]; then
        keytool -list -v -keystore "$KEYSTORE_PATH" -alias upload > "$OUTPUT_DIR/fingerprints-$TIMESTAMP.txt"
        log_info "Fingerprints saved: $OUTPUT_DIR/fingerprints-$TIMESTAMP.txt"
    else
        log_warn "Keystore not found, skipping fingerprint generation"
    fi
}

# Main
main() {
    log_info "=========================================="
    log_info "Android Build Script"
    log_info "Build type: $BUILD_TYPE"
    log_info "=========================================="
    
    check_prerequisites
    setup_environment
    build_apk
    build_appbundle
    generate_fingerprints
    
    log_info "=========================================="
    log_info "Build completed successfully!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "=========================================="
}

main "$@"
