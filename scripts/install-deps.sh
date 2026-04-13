#!/bin/bash
#
# Install dependencies for Wine build
#

set -e

echo "============================================"
echo "  Installing Wine Build Dependencies"
echo "============================================"
echo ""

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script only works on macOS"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install build dependencies
echo "Installing build tools..."
brew install \
    bison \
    mingw-w64 \
    pkg-config \
    gstreamer \
    gst-libav \
    cmake \
    autoconf \
    automake \
    libtool \
    flex \
    ninja \
    ccache \
    nasm \
    fontconfig \
    freetype \
    zlib \
    libpng \
    libjpeg \
    libtiff \
    libxml2 \
    libxslt \
    openssl@3 \
    libtasn1 \
    gnutls \
    nettle \
    jpeg \
    pixman \
    cairo \
    pango \
    atk \
    gtk+3 \
    libsamplerate \
    alsa-lib \
    mpg123 \
    libvorbis \
    flac \
    libsndfile \
    audiofile \
    mpg123 \
    unixodbc \
    sqlite3 \
    gdbm \
    perl \
    python@3.11 \
    rust \
    cargo \
    wine

echo ""
echo "============================================"
echo "  Dependencies installed successfully!"
echo "============================================"
echo ""
echo "Note: Some packages may require Rosetta 2 for x86_64 builds on Apple Silicon:"
echo "  softwareupdate --install-rosetta"
