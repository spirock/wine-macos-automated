#!/bin/bash
#
# Package Wine build for distribution
#

set -e

WINE_VERSION="${WINE_VERSION:-11.0}"
BUILD_DIR="${BUILD_DIR:-.}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"

echo "============================================"
echo "  Packaging Wine Build"
echo "============================================"
echo ""

create_package() {
    local arch="$1"
    local build_path="$BUILD_DIR/build-wine-$arch"
    local package_name="wine-proton-${WINE_VERSION}-$(date +%Y%m%d)-macos-$arch"
    
    if [ ! -d "$build_path" ]; then
        echo "Build directory not found: $build_path"
        return 1
    fi
    
    echo "Creating package for $arch..."
    
    # Create Wine directory structure
    local wine_dir="$OUTPUT_DIR/Wine"
    mkdir -p "$wine_dir/bin"
    mkdir -p "$wine_dir/lib"
    mkdir -p "$wine_dir/share"
    
    # Copy binaries and libraries
    cp -r "$build_path/bin/"* "$wine_dir/bin/" 2>/dev/null || true
    cp -r "$build_path/libraries/"* "$wine_dir/lib/" 2>/dev/null || true
    cp -r "$build_path/programs/"* "$wine_dir/share/" 2>/dev/null || true
    cp -r "$build_path/server/"* "$wine_dir/lib/" 2>/dev/null || true
    cp -r "$build_path/tools/"* "$wine_dir/bin/" 2>/dev/null || true
    
    # Copy DLLs
    find "$build_path" -name "*.dll" -exec cp {} "$wine_dir/lib/" \; 2>/dev/null || true
    find "$build_path" -name "*.so" -exec cp {} "$wine_dir/lib/" \; 2>/dev/null || true
    
    # Create symlinks for wine64
    if [ ! -L "$wine_dir/bin/wine64" ] && [ -f "$wine_dir/bin/wine" ]; then
        ln -sf wine "$wine_dir/bin/wine64"
    fi
    
    # Create symlinks for common commands
    for cmd in winecfg wineboot wineserver msiexec regedit; do
        if [ ! -L "$wine_dir/bin/$cmd" ] && [ -f "$wine_dir/bin/wine" ]; then
            ln -sf wine "$wine_dir/bin/$cmd"
        fi
    done
    
    # Create tarball
    local tarball="$OUTPUT_DIR/${package_name}.tar.xz"
    tar -cvJf "$tarball" Wine/
    
    echo "Created: $tarball"
    ls -lh "$tarball"
}

# Package x86_64
if [ -d "$BUILD_DIR/build-wine-x86_64" ]; then
    create_package "x86_64"
fi

# Package ARM64
if [ -d "$BUILD_DIR/build-wine-arm64" ]; then
    create_package "arm64"
fi

# Package universal
if [ -d "$BUILD_DIR/build-wine-x86_64" ] && [ -d "$BUILD_DIR/build-wine-arm64" ]; then
    echo "Creating universal package..."
    
    mkdir -p Wine-universal/bin
    mkdir -p Wine-universal/lib
    mkdir -p Wine-universal/share
    
    # Copy x86_64 as base
    cp -r "$BUILD_DIR/build-wine-x86_64/"* Wine-universal/
    
    # Package
    tar -cvJf "wine-proton-${WINE_VERSION}-$(date +%Y%m%d)-macos-universal.tar.xz" Wine-universal/
    rm -rf Wine-universal
fi

# Cleanup
rm -rf Wine/

echo ""
echo "Packaging complete!"
echo ""
ls -lh *.tar.xz 2>/dev/null || echo "No packages created"
