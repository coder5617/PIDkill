# PIDkill

*Created August 3, 2026 at 12:17 AM*

# PIDkill — Development Plan

A lightweight native macOS menu-bar app for viewing and terminating processes that are listening on local ports.

## 1. Requirements

* Native SwiftUI macOS application
* Apple Silicon arm64 only
* Minimum macOS version: macOS 13
* Menu-bar-only application
* No Dock icon or main application window
* Display currently listening TCP ports
* Show:

  * Process name
  * Port number
  * PID
  * Full executable path
* Search by:

  * Port
  * Process name
  * PID
  * Executable path
* One-click process termination
* One-click browser launch for TCP ports
* Manual refresh
* Refresh whenever the menu opens
* Display total listening-port count
* No required configuration

## 2. Technology

* Swift 6
* SwiftUI
* `MenuBarExtra`
* `lsof` for listening-port discovery
* `libproc` and `proc_pidpath()` for executable paths
* Darwin signals for process termination
* `NSWorkspace` for opening browser URLs
* Xcode for building, signing, and packaging

## 3. Project Structure

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
│   └── BrowserOpener.swift
├── ViewModels/
│   └── PortListViewModel.swift
├── Views/
│   ├── MenuBarView.swift
│   ├── PortRowView.swift
│   ├── SearchBarView.swift
│   └── FooterView.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## 4. Data Model

`PortEntry` should contain:

```swift
struct PortEntry: Identifiable, Hashable {
    let id: String
    let port: Int
    let protocolName: String
    let pid: Int32
    let processName: String
    let executablePath: String
    let localAddress: String
}
```

Use a stable identifier based on:

```text
PID + port + protocol
```

## 5. Port Discovery

Run:

```bash
/usr/sbin/lsof -n -P -iTCP -sTCP:LISTEN
```

Parse each result into a `PortEntry`.

Implementation requirements:

* Run scanning outside the main UI thread
* Ignore malformed output safely
* Deduplicate entries by PID, port, and protocol
* Resolve the full executable path with `proc_pidpath()`
* Fall back to the process name from `lsof` when path resolution fails
* Handle processes that exit during scanning
* Sort results by port number by default

## 6. Menu-Bar Interface

Clicking the menu-bar icon opens a compact popover.

### Header

* Search field
* Placeholder:

```text
Search port, process, PID, or path
```

* Clear button when search text is present

### Process List

Each listening port appears as one row.

Each row contains:

* Open-in-browser button
* Process name
* Port number
* Full executable path
* PID
* Kill button

Suggested layout:

```text
[Open] Process Name                     :3000
       /full/path/to/executable       PID 1234   [Kill]
```

The list must scroll when its contents exceed the popover height.

### Footer

* Refresh button
* Total listening-port count
* Filtered count while searching

Examples:

```text
14 listening ports
```

```text
3 of 14 listening ports
```

## 7. Search

Filter the existing in-memory results without rescanning.

Search must support:

* Exact or partial port number
* Case-insensitive process-name match
* Exact or partial PID
* Case-insensitive executable-path match

Update results immediately as the user types.

## 8. Process Termination

When the Kill button is pressed:

1. Send `SIGTERM`.
2. Wait approximately 750 milliseconds.
3. Check whether the process still exists.
4. Send `SIGKILL` when the process remains active.
5. Remove the row after successful termination.
6. Refresh the list to confirm the final state.

Handle these results:

* Process terminated successfully
* Process already exited
* Permission denied
* Invalid PID
* Unknown termination error

Display errors inline within the affected row.

Disable the Kill button and show progress while termination is running.

## 9. Open in Browser

For each TCP listener:

```text
http://localhost:<port>
```

Open the URL using:

```swift
NSWorkspace.shared.open(url)
```

The browser button should remain available for TCP ports without attempting to detect whether the service uses HTTP.

## 10. Refresh Behavior

Refresh the list:

* When the menu-bar popover opens
* When the Refresh button is pressed
* After terminating a process

While refreshing:

* Keep the interface responsive
* Disable duplicate refresh actions
* Show a loading state on the Refresh button
* Replace the displayed entries only after the new scan completes

## 11. Application Configuration

Configure:

```text
LSUIElement = true
```

Build settings:

```text
Architecture: arm64
Deployment target: macOS 13.0
```

Use a monochrome template image for the menu-bar icon so it adapts to light and dark mode.

## 12. Error and Empty States

Provide clear states for:

* No listening ports found
* No search results
* Port scan failed
* `lsof` execution failed
* Process path unavailable
* Process termination denied
* Process already exited

Errors should not block the rest of the process list.

## 13. Development Phases

### Phase 0 — Project Setup

* [ ] Create the SwiftUI macOS project
* [ ] Set the deployment target to macOS 13
* [ ] Restrict builds to arm64
* [ ] Configure the app as menu-bar-only
* [ ] Add the menu-bar icon
* [ ] Create the project directory structure
* [ ] Confirm the popover opens and closes correctly

### Phase 1 — Port Scanner

* [ ] Create `PortEntry`
* [ ] Execute `lsof`
* [ ] Parse TCP listening-port results
* [ ] Deduplicate results
* [ ] Resolve executable paths
* [ ] Sort results by port
* [ ] Add scanner error handling
* [ ] Validate results against Terminal output

### Phase 2 — Process List UI

* [ ] Create the menu-bar popover layout
* [ ] Create the scrollable process list
* [ ] Create reusable process rows
* [ ] Display process name and port
* [ ] Display executable path and PID
* [ ] Add empty and loading states
* [ ] Confirm long paths do not break the layout

### Phase 3 — Search

* [ ] Add the search field
* [ ] Filter by port
* [ ] Filter by process name
* [ ] Filter by PID
* [ ] Filter by executable path
* [ ] Add search clearing
* [ ] Display filtered and total counts

### Phase 4 — Process Termination

* [ ] Implement `SIGTERM`
* [ ] Check whether the process remains active
* [ ] Implement `SIGKILL` escalation
* [ ] Add progress state
* [ ] Remove terminated rows
* [ ] Refresh after termination
* [ ] Display permission and process-exited errors
* [ ] Prevent duplicate termination actions

### Phase 5 — Browser Launch

* [ ] Build localhost URLs from port numbers
* [ ] Open URLs in the default browser
* [ ] Add browser buttons to process rows
* [ ] Handle malformed URL creation safely

### Phase 6 — Refresh and Footer

* [ ] Refresh whenever the popover opens
* [ ] Add manual refresh
* [ ] Refresh after process termination
* [ ] Add refresh progress animation
* [ ] Display total listening-port count
* [ ] Display filtered count during searches

### Phase 7 — UI Polish

* [ ] Add button hover states
* [ ] Add Kill-button progress state
* [ ] Support light and dark mode
* [ ] Refine spacing and typography
* [ ] Improve path truncation and tooltips
* [ ] Add accessible labels
* [ ] Add keyboard focus support

### Phase 8 — Validation

* [ ] Test with Node.js servers
* [ ] Test with Python servers
* [ ] Test with npm development servers
* [ ] Test with multiple processes on different ports
* [ ] Test with rapidly restarting processes
* [ ] Test permission-denied results
* [ ] Test process-exited race conditions
* [ ] Compare displayed results with `lsof`
* [ ] Confirm browser buttons open the correct ports
* [ ] Confirm terminated processes disappear
* [ ] Confirm no Dock icon appears
* [ ] Confirm the application runs on Apple Silicon

### Phase 9 — Packaging

* [ ] Create a Release build
* [ ] Enable Hardened Runtime
* [ ] Sign with a Developer ID certificate
* [ ] Notarize the application
* [ ] Staple the notarization ticket
* [ ] Package the application in a DMG
* [ ] Test installation on a clean macOS account

## 14. Post-v1 Features

* Launch at login
* Optional automatic refresh while the popover is open
* Sort by port, process name, or PID
* UDP socket display
* Copy PID, port, path, or command
* Keyboard shortcuts
* Ignore list
* Pinned processes
* Administrative process termination
* Automatic updates

## 15. Definition of Done

The v1 release is complete when:

* [ ] Clicking the menu-bar icon displays current TCP listening ports
* [ ] Every row shows the process name, port, PID, and executable path
* [ ] Search filters by port, process name, PID, and path
* [ ] Kill terminates processes and updates the list
* [ ] Permission errors appear without disrupting the application
* [ ] Browser buttons open `localhost` using the selected port
* [ ] Refresh retrieves current port information
* [ ] The footer displays accurate total and filtered counts
* [ ] The application has no Dock icon
* [ ] The Release build is arm64-only
* [ ] The signed and notarized DMG installs and runs successfully
