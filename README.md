# PIDkill

A lightweight, high-performance native macOS menu-bar application for instantly viewing and terminating processes listening on local ports.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)
![Apple Silicon](https://img.shields.io/badge/Architecture-arm64-brightgreen.svg)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple.svg)

---

## Features

- **Menu-Bar Native**: Operates strictly as a menu-bar popover (`LSUIElement`). Zero Dock clutter.
- **Port & Process Inspection**: Displays active listening TCP ports, PIDs, process names, and full binary paths (`libproc` / `proc_pidpath`).
- **One-Click Browser Launch**: Click the globe icon to immediately open `http://localhost:<port>` in your default browser.
- **Two-Stage Process Termination**: Issues `SIGTERM`, waits ~750ms to verify exit status, and automatically escalates to `SIGKILL` if active. Provides inline feedback for permission or exit errors.
- **Real-Time Live Search**: Instantly filter active ports by port number, process name, PID, or binary path as you type.
- **Launch at Login**: Native macOS `SMAppService` autostart toggle directly in the UI.

---

## Quick Start

### Build Standalone `.app` Bundle

To build `PIDkill.app` for double-clicking in Finder or dragging to `/Applications`:

```bash
./scripts/build_app.sh
```

Then open `PIDkill.app`:

```bash
open PIDkill.app
```

### Build & Run via Swift SPM

```bash
# Debug Mode
swift run

# Release Mode
swift run -c release
```

---

## Project Structure

```text
PIDkill/
├── App/
│   └── PIDkillApp.swift
├── Models/
│   └── PortEntry.swift
├── Services/
│   ├── PortScanner.swift
│   ├── ProcessPathResolver.swift
│   ├── ProcessKiller.swift
│   ├── BrowserOpener.swift
│   └── LaunchAtLoginManager.swift
├── ViewModels/
│   └── PortListViewModel.swift
├── Views/
│   ├── MenuBarView.swift
│   ├── PortRowView.swift
│   ├── SearchBarView.swift
│   ├── FooterView.swift
│   └── LaunchAtLoginBannerView.swift
├── Resources/
│   ├── Info.plist
│   └── AppIcon.icns
├── scripts/
│   ├── build_app.sh
│   ├── make_icns.sh
│   └── generate_icon.swift
└── Tests/
    └── PortScannerTests.swift
```

---

## Requirements

- **Operating System**: macOS 13.0 (Ventura) or later
- **Architecture**: Apple Silicon (`arm64`)
- **Toolchain**: Xcode 15+ / Swift 6.0+

---

## Running Tests

Run unit tests via SPM:

```bash
swift test
```

---

## Author & License

Created by **[coder5617](https://github.com/coder5617)**.

Licensed under the MIT License.
