#!/bin/bash
#
# Wine macOS Build Script
# Compiles Wine with Proton patches for macOS
#

set -e

# Configuration
WINE_VERSION="${WINE_VERSION:-11.0}"
PROTON_GE_BRANCH="${PROTON_GE_BRANCH:-wine-11.0}"
BUILD_TYPE="${BUILD_TYPE:-proton}"
ENABLE_ARM64="${ENABLE_ARM64:-1}"
ENABLE_X86_64="${ENABLE_X86_64:-1}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "============================================"
echo "  Wine macOS Automated Build Script"
echo "============================================"
echo ""
log_info "Wine Version: $WINE_VERSION"
log_info "Proton Branch: $PROTON_GE_BRANCH"
log_info "Build Type: $BUILD_TYPE"
log_info "ARM64: $ENABLE_ARM64"
log_info "x86_64: $ENABLE_X86_64"
echo ""

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode not found. Please install Xcode from App Store."
        exit 1
    fi
    
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found. Please install from https://brew.sh"
        exit 1
    fi
    
    log_info "Prerequisites OK"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    brew install bison mingw-w64 pkg-config gstreamer cmake ccache autoconf automake libtool flex ninja
    
    log_info "Dependencies installed"
}

# Clone GE-Proton source
clone_source() {
    log_info "Cloning GE-Proton source..."
    
    local temp_dir="/tmp/wine-build-$(date +%s)"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    log_info "Cloning to $temp_dir"
    
    git clone --recurse-submodules --depth=1 --branch "$PROTON_GE_BRANCH" \
        https://github.com/GloriousEggroll/proton-ge-custom.git
    
    cd proton-ge-custom
    export PROTON_DIR="$temp_dir/proton-ge-custom"
    
    log_info "Source cloned successfully"
}

# Build for x86_64
build_x86_64() {
    if [ "$ENABLE_X86_64" != "1" ]; then
        log_warn "Skipping x86_64 build"
        return
    fi
    
    log_info "Building Wine for x86_64..."
    
    cd "$PROTON_DIR/wine"
    
    # Configure
    CFLAGS="-O2" CXXFLAGS="-O2" ./configure \
        --build=x86_64-apple-darwin \
        --enable-archs=i386,x86_64 \
        --disable-tests \
        --with-mingw \
        --with-gstreamer \
        --without-alsa \
        --without-oss \
        --without-pulse \
        --without-wayland \
        --without-x
    
    # Build
    make -j$(sysctl -n hw.ncpu) prefix=/usr/local
  
    # Package
    local output_dir="build-wine-x86_64"
    mkdir -p "$output_dir"
    
    # Copy binaries
    cp -r programs libraries server tools "$output_dir/" 2>/dev/null || true
    cp -r "$PROTON_DIR/wine"/*.dll "$output_dir/" 2>/dev/null || true
    
    # Create bin directory with symlinks
    mkdir -p "$output_dir/bin"
    ln -sf ../wine "$output_dir/bin/wine"
    ln -sf ../wineserver "$output_dir/bin/wineserver"
    ln -sf ../wine "$output_dir/bin/wine64"
    
    log_info "x86_64 build complete"
}

# Build for ARM64
build_arm64() {
    if [ "$ENABLE_ARM64" != "1" ]; then
        log_warn "Skipping ARM64 build"
        return
    fi
    
    log_info "Building Wine for ARM64..."
    
    # Check if we're on Apple Silicon
    if [[ $(uname -m) != "arm64" ]]; then
        log_warn "Not running on Apple Silicon. Cross-compilation not yet supported."
        log_warn "Skipping ARM64 build"
        return
    fi
    
    cd "$PROTON_DIR/wine"
    
    # Configure for ARM64
    CFLAGS="-O2" CXXFLAGS="-O2" ./configure \
        --build=arm64-apple-darwin \
        --disable-tests \
        --with-mingw \
        --with-gstreamer \
        --without-alsa \
        --without-oss \
        --without-pulse \
        --without-wayland \
        --without-x
    
    # Build
    make -j$(sysctl -n hw.ncpu) prefix=/usr/local
    
    # Package
    local output_dir="build-wine-arm64"
    mkdir -p "$output_dir"
    
    cp -r programs libraries server tools "$output_dir/" 2>/dev/null || true
    
    mkdir -p "$output_dir/bin"
    ln -sf ../wine "$output_dir/bin/wine"
    ln -sf ../wineserver "$output_dir/bin/wineserver"
    
    log_info "ARM64 build complete"
}

# Package final release
package_release() {
    log_info "Packaging release..."
    
    local timestamp=$(date +%Y%m%d)
    local output_file="wine-proton-${WINE_VERSION}-${timestamp}-macos"
    
    # Package x86_64
    if [ -d "build-wine-x86_64" ]; then
        tar -cvjf "${output_file}-x86_64.tar.xz" build-wine-x86_64/
        log_info "Created ${output_file}-x86_64.tar.xz"
    fi
    
    # Package ARM64
    if [ -d "build-wine-arm64" ]; then
        tar -cvjf "${output_file}-arm64.tar.xz" build-wine-arm64/
        log_info "Created ${output_file}-arm64.tar.xz"
    fi
    
    # Combined package (universal)
    if [ -d "build-wine-x86_64" ] && [ -d "build-wine-arm64" ]; then
        mkdir -p "wine-universal"
        cp -r build-wine-x86_64/* wine-universal/
        # Add ARM64 binaries with suffix
        for binary in wine-universal/bin/*; do
            cp "$binary" "${binary}-x86_64"
        done
        cp -r build-wine-arm64/bin/* wine-universal/bin/
        
        tar -cvjf "${output_file}-universal.tar.xz" wine-universal/
        log_info "Created ${output_file}-universal.tar.xz"
    fi
    
    log_info "Packaging complete"
}

# Main execution
main() {
    log_info "Starting Wine build process..."
    
    check_prerequisites
    install_dependencies
    clone_source
    
    if [ "$ENABLE_X86_64" == "1" ]; then
        build_x86_64
    fi
    
    if [ "$ENABLE_ARM64" == "1" ]; then
        build_arm64
    fi
    
    package_release
    
    log_info "Build complete!"
    echo ""
    echo "Output files:"
    ls -la *.tar.xz 2>/dev/null || true
}

# Run
main "$@"
