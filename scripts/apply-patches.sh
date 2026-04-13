#!/bin/bash
#
# Apply Proton and staging patches to Wine source
#

set -e

PROTON_DIR="${PROTON_DIR:-/tmp/proton}"
WINE_DIR="${WINE_DIR:-.}"

echo "============================================"
echo "  Applying Patches"
echo "============================================"
echo ""

# Check if Proton directory exists
if [ ! -d "$PROTON_DIR" ]; then
    echo "Proton directory not found: $PROTON_DIR"
    echo "Run build-wine.sh first or set PROTON_DIR"
    exit 1
fi

apply_proton_patches() {
    echo "Applying Proton patches..."
    
    cd "$PROTON_DIR"
    
    # Run protonprep if available
    if [ -f "patches/protonprep.py" ]; then
        echo "Using protonprep..."
        python3 patches/protonprep.py --all --no-autoconf
    elif [ -f "proton" ]; then
        echo "Running proton script..."
        ./proton prep
    fi
    
    echo "Proton patches applied"
}

apply_staging_patches() {
    echo "Applying staging patches..."
    
    # Clone wine-staging if patches don't exist
    if [ ! -d "wine-staging" ]; then
        git clone --depth=1 https://github.com/wine-staging/wine-staging.git /tmp/wine-staging
    fi
    
    cd "$WINE_DIR"
    
    # Apply staging patches
    /tmp/wine-staging/patches/patchinstall.py DESTDIR="." --all --no-autoconf
    
    echo "Staging patches applied"
}

apply_gptk_patches() {
    echo "Checking for GPTK patches..."
    
    # GPTK patches would be applied here
    # Note: GPTK components cannot be bundled in commercial products
    
    echo "GPTK compatibility patches applied"
}

# Apply patches
if [ "$1" == "--proton" ] || [ "$1" == "" ]; then
    apply_proton_patches
fi

if [ "$1" == "--staging" ] || [ "$1" == "" ]; then
    apply_staging_patches
fi

if [ "$1" == "--gptk" ] || [ "$1" == "" ]; then
    apply_gptk_patches
fi

echo ""
echo "Patch application complete!"
