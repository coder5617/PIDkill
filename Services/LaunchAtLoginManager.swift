import Foundation
import ServiceManagement

/// Helper for managing Launch at Login on macOS 13+ using SMAppService.
public enum LaunchAtLoginManager {
    /// Returns true if PIDkill is currently set to start at login.
    public static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    /// Enables or disables launch at login.
    /// - Parameter enabled: Boolean target state.
    /// - Returns: Boolean indicating if operation succeeded.
    @discardableResult
    public static func setEnabled(_ enabled: Bool) -> Bool {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
                return true
            } catch {
                print("Failed to toggle Launch at Login: \(error)")
                return false
            }
        }
        return false
    }
}
