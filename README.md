# Wine macOS Automated Builds

Automated Wine builds for macOS with Proton patches, supporting both Intel and Apple Silicon.

## Features

- **Weekly stable builds** of Wine with Proton patches
- **Apple Silicon (ARM64)** support
- **Intel (x86_64)** support
- **Proton patches** for better game compatibility
- **DXVK** for DirectX to Vulkan translation

## Quick Start

### Using with Whisky

1. Download the latest release from [Releases](../../releases)
2. Extract to `~/Library/Application Support/com.isaacmarovitz.Whisky/Libraries/`
3. Rename folder to `Wine`

Or let Whisky download automatically from the releases.

### Manual Installation

```bash
# Download latest release
curl -L https://github.com/YOUR_USER/wine-macos-automated/releases/latest/download/wine-proton-macos.tar.xz -o wine.tar.xz

# Extract
tar -xf wine.tar.xz

# Install
cp -r Wine ~/Library/Application\ Support/com.isaacmarovitz.Whisky/Libraries/
```

## Available Builds

| Build | Description | Download |
|-------|-------------|----------|
| `wine-proton-x86_64` | Intel builds with Proton patches | [Releases](../../releases) |
| `wine-proton-arm64` | Apple Silicon with Proton patches | [Releases](../../releases) |

## Game Porting Toolkit Integration

This project doesn't bundle Apple's Game Porting Toolkit due to licensing restrictions.

To use D3DMetal with your Wine installation:

1. Download Game Porting Toolkit from [Apple Developer](https://developer.apple.com/games/game-porting-toolkit/)
2. Mount the DMG
3. Copy `D3DMetal.framework` to your Wine prefix:
   ```bash
   cp -r "/Volumes/Game Porting Toolkit/D3DMetal.framework" ~/Library/Application\ Support/com.isaacmarovitz.Whisky/Libraries/
   ```

## Building from Source

### Prerequisites

- macOS 13+ (Ventura or later)
- Xcode 15+
- Homebrew

```bash
# Install dependencies
brew install bison mingw-w64 pkg-config gstreamer cmake

# Clone repository
git clone https://github.com/YOUR_USER/wine-macos-automated.git
cd wine-macos-automated

# Run build
./scripts/build-wine.sh
```

## License

- **Wine**: [LGPL 2.1](https://www.winehq.org/site/legal)
- **Proton patches**: [BSD-3-Clause](https://github.com/ValveSoftware/Proton/blob/ge_proton/LICENSE)
- **Build scripts and automation**: [MIT License](LICENSE)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)

For commercial support and consulting, contact via [Patreon/Ko-fi](#).

## Acknowledgments

- [Wine Project](https://www.winehq.org/) - The core Wine implementation
- [Valve Software](https://github.com/ValveSoftware/Proton) - Proton patches
- [GloriousEggroll](https://github.com/GloriousEggroll/proton-ge-custom) - GE-Proton builds
- [Gcenx](https://github.com/Gcenx) - macOS Wine build expertise
