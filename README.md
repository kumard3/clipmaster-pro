# ClipMaster Pro

<div align="center">

![ClipMaster Pro Logo](Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/yourusername/clipmaster-pro)](https://github.com/yourusername/clipmaster-pro/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://github.com/yourusername/clipmaster-pro)

A powerful, lightweight clipboard manager for macOS that lives in your menu bar.

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Contributing](#contributing) • [License](#license)

</div>

## Features

- 🚀 **Lightning Fast**: Instant access to your clipboard history
- 🔍 **Smart Search**: Quickly find past clips with powerful search
- 🎯 **Menu Bar Integration**: Always accessible, never in your way
- ⚡ **Efficient Storage**: Optimized CoreData storage with auto-cleanup
- 🛠 **Customizable Settings**:
  - Auto-delete old items
  - Maximum history size
  - Launch at startup
- 🎨 **Modern UI**: Clean, native macOS design
- 🔐 **Privacy Focused**: All data stored locally

## Installation

### Option 1: Direct Download

1. Download the latest release from the [releases page](https://github.com/yourusername/clipmaster-pro/releases)
2. Extract the zip file
3. Move ClipMaster Pro to your Applications folder
4. Double-click to start

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/clipmaster-pro.git

# Open in Xcode
cd clipmaster-pro
open ClipMaster\ Pro.xcodeproj

# Build and run
# Press Cmd + R in Xcode
```

## Usage

### Basic Usage

1. ClipMaster Pro runs in your menu bar (look for the clipboard icon)
2. Click the icon to see your recent clips
3. Click any clip to copy it back to your clipboard
4. Use the search bar to find specific clips

### Advanced Features

- **View All History**: Click the "View All" button to see your complete clipboard history
- **Settings**:
  - Configure auto-deletion of old items
  - Set maximum history size
  - Enable/disable launch at startup
- **Keyboard Shortcuts**: (Coming Soon)
  - Quick access to recent clips
  - Search functionality
  - Paste without formatting

## Development

### Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.5 or later

### Tech Stack

- SwiftUI for the user interface
- CoreData for persistent storage
- Combine for reactive programming
- Native macOS APIs for clipboard management

### Project Structure

```
ClipMaster Pro/
├── Sources/
│   ├── App/                 # App initialization
│   ├── Views/              # SwiftUI views
│   ├── Models/             # Data models
│   ├── Services/           # Business logic
│   └── Utilities/          # Helper functions
├── Resources/              # Assets and resources
└── Tests/                 # Unit and UI tests
```

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [ ] Keyboard shortcuts
- [ ] iCloud sync support
- [ ] Rich text support
- [ ] Image clipboard support
- [ ] Snippets management
- [ ] Multiple clipboard rings
- [ ] Plugin system

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors who have helped shape ClipMaster Pro
- Built with SwiftUI and ❤️

---

<div align="center">
Made with ❤️ for the macOS community
</div>
