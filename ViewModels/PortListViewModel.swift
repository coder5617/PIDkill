import Foundation
import Combine

/// ViewModel managing state, searching, scanning, process termination, and autostart settings for PIDkill.
@MainActor
public final class PortListViewModel: ObservableObject {
    @Published public var entries: [PortEntry] = []
    @Published public var searchText: String = ""
    @Published public var isScanning: Bool = false
    @Published public var killingPIDs: Set<Int32> = []
    @Published public var rowErrors: [Int32: String] = [:]
    @Published public var scanErrorMessage: String? = nil

    @Published public var isLaunchAtLoginEnabled: Bool = LaunchAtLoginManager.isEnabled
    @Published public var showLaunchAtLoginPrompt: Bool = false

    private let scanner: PortScanner

    public init(scanner: PortScanner = PortScanner(), autoScan: Bool = true) {
        self.scanner = scanner
        checkFirstLaunchAutostartPrompt()
        if autoScan {
            scanPorts()
        }
    }

    private func checkFirstLaunchAutostartPrompt() {
        let hasPrompted = UserDefaults.standard.bool(forKey: "hasPromptedLaunchAtLogin")
        if !hasPrompted && !isLaunchAtLoginEnabled {
            self.showLaunchAtLoginPrompt = true
        }
    }

    public func enableLaunchAtLogin() {
        LaunchAtLoginManager.setEnabled(true)
        self.isLaunchAtLoginEnabled = LaunchAtLoginManager.isEnabled
        UserDefaults.standard.set(true, forKey: "hasPromptedLaunchAtLogin")
        self.showLaunchAtLoginPrompt = false
    }

    public func dismissLaunchAtLoginPrompt() {
        UserDefaults.standard.set(true, forKey: "hasPromptedLaunchAtLogin")
        self.showLaunchAtLoginPrompt = false
    }

    public func toggleLaunchAtLogin() {
        let newState = !isLaunchAtLoginEnabled
        LaunchAtLoginManager.setEnabled(newState)
        self.isLaunchAtLoginEnabled = LaunchAtLoginManager.isEnabled
    }

    /// Filtered entries based on `searchText` matching port, PID, process name, or executable path.
    public var filteredEntries: [PortEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return entries }

        return entries.filter { entry in
            String(entry.port).contains(query) ||
            String(entry.pid).contains(query) ||
            entry.processName.lowercased().contains(query) ||
            entry.executablePath.lowercased().contains(query)
        }
    }

    /// Total number of listening ports detected.
    public var totalCount: Int {
        entries.count
    }

    /// Number of matching listening ports based on current search filter.
    public var filteredCount: Int {
        filteredEntries.count
    }

    /// Triggers port scanning off the main thread.
    public func scanPorts() {
        guard !isScanning else { return }
        isScanning = true
        scanErrorMessage = nil

        Task {
            do {
                let results = try await scanner.fetchListeningPorts()
                self.entries = results
                self.isScanning = false
            } catch {
                self.scanErrorMessage = error.localizedDescription
                self.isScanning = false
            }
        }
    }

    /// Terminates a process and refreshes list state.
    public func killProcess(for entry: PortEntry) {
        let pid = entry.pid
        guard !killingPIDs.contains(pid) else { return }

        killingPIDs.insert(pid)
        rowErrors.removeValue(forKey: pid)

        Task {
            let result = await ProcessKiller.terminateProcess(pid: pid)
            self.killingPIDs.remove(pid)

            if result.isSuccess {
                // Immediately remove row locally for crisp feedback
                self.entries.removeAll { $0.pid == pid }
                // Rescan to confirm final system state
                self.scanPorts()
            } else if let errorMsg = result.userFacingMessage {
                self.rowErrors[pid] = errorMsg
            }
        }
    }

    /// Opens the localhost URL for the specified port entry in the default browser.
    public func openInBrowser(for entry: PortEntry) {
        BrowserOpener.openLocalhost(port: entry.port)
    }

    /// Clears the active search query.
    public func clearSearch() {
        searchText = ""
    }
}
