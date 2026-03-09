#!/bin/bash
# ===========================================
# Build Script for Web
# ===========================================
# Usage: ./build_web.sh [debug|release] [--wasm]
# ===========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BUILD_TYPE="${1:-release}"
USE_WASM="${2:-}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/build/web_dist"
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
    
    log_info "Flutter version: $(flutter --version --short)"
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

# Build Web
build_web() {
    log_info "Building Web ($BUILD_TYPE)..."
    
    mkdir -p "$OUTPUT_DIR"
    
    local build_args="--output=$OUTPUT_DIR"
    
    if [ "$BUILD_TYPE" == "debug" ]; then
        build_args="$build_args --debug"
    else
        build_args="$build_args --release"
    fi
    
    if [ "$USE_WASM" == "--wasm" ]; then
        build_args="$build_args --wasm"
        log_info "Building with WebAssembly support"
    fi
    
    # Enable web renderer
    export FLUTTER_WEB_RENDERER=canvaskit
    
    flutter build web $build_args
    
    log_info "Web build completed: $OUTPUT_DIR"
}

# Optimize build
optimize_build() {
    log_info "Optimizing web build..."
    
    if ! command -v gzip &> /dev/null; then
        log_warn "gzip not found, skipping compression"
        return
    fi
    
    # Compress assets for better delivery
    find "$OUTPUT_DIR" -type f \( -name "*.js" -o -name "*.css" -o -name "*.html" -o -name "*.json" \) \
        -exec gzip -k {} \;
    
    log_info "Compression completed"
}

# Generate service worker
generate_service_worker() {
    log_info "Generating service worker..."
    
    # Create basic service worker if not exists
    if [ ! -f "$OUTPUT_DIR/flutter_service_worker.js" ]; then
        cat > "$OUTPUT_DIR/flutter_service_worker.js" << 'EOF'
const CACHE_NAME = 'passgen-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => response || fetch(event.request))
  );
});
EOF
    fi
    
    log_info "Service worker generated"
}

# Create deployment package
create_deployment_package() {
    log_info "Creating deployment package..."
    
    local package_dir="$PROJECT_ROOT/build/deployments"
    mkdir -p "$package_dir"
    
    cd "$OUTPUT_DIR"
    tar -czf "$package_dir/web-build-$TIMESTAMP.tar.gz" .
    cd "$PROJECT_ROOT"
    
    log_info "Deployment package created: $package_dir/web-build-$TIMESTAMP.tar.gz"
}

# Main
main() {
    log_info "=========================================="
    log_info "Web Build Script"
    log_info "Build type: $BUILD_TYPE"
    log_info "WASM: $([ "$USE_WASM" == "--wasm" ] && echo "Yes" || echo "No")"
    log_info "=========================================="
    
    check_prerequisites
    setup_environment
    build_web
    optimize_build
    generate_service_worker
    create_deployment_package
    
    log_info "=========================================="
    log_info "Build completed successfully!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "=========================================="
}

main "$@"
