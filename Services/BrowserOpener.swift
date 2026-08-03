import Foundation
import AppKit

/// Service for opening localhost web links in the default browser.
public enum BrowserOpener {
    /// Opens `http://localhost:<port>` in the user's default browser.
    /// - Parameter port: Target TCP port number.
    /// - Returns: Boolean indicating if URL opening succeeded.
    @discardableResult
    public static func openLocalhost(port: Int) -> Bool {
        guard port > 0 && port <= 65535,
              let url = URL(string: "http://localhost:\(port)") else {
            return false
        }
        return NSWorkspace.shared.open(url)
    }
}
