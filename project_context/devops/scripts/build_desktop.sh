#!/bin/bash
# ===========================================
# Build Script for Desktop (Linux, Windows, macOS)
# ===========================================
# Usage: ./build_desktop.sh [linux|windows|macos] [debug|release]
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
TARGET="${1:-linux}"
BUILD_TYPE="${2:-release}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/build/desktop/$TARGET"
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
    
    case "$TARGET" in
        linux)
            if [[ "$OSTYPE" != "linux-gnu"* ]]; then
                log_warn "Linux builds are recommended on Linux"
            fi
            ;;
        windows)
            if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "win32" ]]; then
                log_warn "Windows builds are recommended on Windows"
            fi
            ;;
        macos)
            if [[ "$OSTYPE" != "darwin"* ]]; then
                log_error "macOS builds require macOS"
                exit 1
            fi
            ;;
        *)
            log_error "Unknown target: $TARGET. Supported: linux, windows, macos"
            exit 1
            ;;
    esac
    
    log_info "Flutter version: $(flutter --version --short)"
    log_info "Target: $TARGET"
}

# Setup environment
setup_environment() {
    log_info "Setting up build environment..."
    
    cd "$PROJECT_ROOT"
    
    # Get dependencies
    flutter pub get
    
    # Clean previous builds
    flutter clean
    
    # Enable desktop support
    flutter config --enable-${TARGET}-desktop
}

# Build Desktop
build_desktop() {
    log_info "Building Desktop ($TARGET, $BUILD_TYPE)..."
    
    mkdir -p "$OUTPUT_DIR"
    
    local build_args=""
    
    if [ "$BUILD_TYPE" == "debug" ]; then
        build_args="--debug"
    else
        build_args="--release"
    fi
    
    flutter build $TARGET $build_args
    
    # Copy build artifacts
    case "$TARGET" in
        linux)
            cp -r build/linux/x64/release/bundle/* "$OUTPUT_DIR/" 2>/dev/null || \
            cp -r build/linux/x64/debug/bundle/* "$OUTPUT_DIR/" 2>/dev/null || true
            ;;
        windows)
            cp -r build/windows/x64/runner/Release/* "$OUTPUT_DIR/" 2>/dev/null || \
            cp -r build/windows/x64/runner/Debug/* "$OUTPUT_DIR/" 2>/dev/null || true
            ;;
        macos)
            cp -r build/macos/Build/Products/Release/passgen.app "$OUTPUT_DIR/" 2>/dev/null || \
            cp -r build/macos/Build/Products/Debug/passgen.app "$OUTPUT_DIR/" 2>/dev/null || true
            ;;
    esac
    
    log_info "Desktop build completed: $OUTPUT_DIR"
}

# Create distribution package
create_package() {
    log_info "Creating distribution package..."
    
    local package_dir="$PROJECT_ROOT/build/deployments"
    mkdir -p "$package_dir"
    
    case "$TARGET" in
        linux)
            # Create AppImage or tar.gz
            cd "$OUTPUT_DIR"
            tar -czf "$package_dir/passgen-linux-$TIMESTAMP.tar.gz" .
            cd "$PROJECT_ROOT"
            log_info "Package created: $package_dir/passgen-linux-$TIMESTAMP.tar.gz"
            ;;
        windows)
            # Create ZIP
            cd "$OUTPUT_DIR"
            zip -r "$package_dir/passgen-windows-$TIMESTAMP.zip" .
            cd "$PROJECT_ROOT"
            log_info "Package created: $package_dir/passgen-windows-$TIMESTAMP.zip"
            ;;
        macos)
            # Create DMG (requires additional tools)
            if command -v create-dmg &> /dev/null; then
                create-dmg \
                    --volname "PassGen" \
                    --window-pos 200 120 \
                    --window-size 600 400 \
                    --icon-size 100 \
                    --app-drop-link 400 200 \
                    "$package_dir/PassGen-$TIMESTAMP.dmg" \
                    "$OUTPUT_DIR/passgen.app"
                log_info "DMG created: $package_dir/PassGen-$TIMESTAMP.dmg"
            else
                cd "$OUTPUT_DIR"
                tar -czf "$package_dir/passgen-macos-$TIMESTAMP.tar.gz" passgen.app
                cd "$PROJECT_ROOT"
                log_info "Package created: $package_dir/passgen-macos-$TIMESTAMP.tar.gz"
            fi
            ;;
    esac
}

# Main
main() {
    log_info "=========================================="
    log_info "Desktop Build Script"
    log_info "Target: $TARGET"
    log_info "Build type: $BUILD_TYPE"
    log_info "=========================================="
    
    check_prerequisites
    setup_environment
    build_desktop
    create_package
    
    log_info "=========================================="
    log_info "Build completed successfully!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "=========================================="
}

main "$@"
