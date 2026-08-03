import SwiftUI

public struct FooterView: View {
    public let totalCount: Int
    public let filteredCount: Int
    public let isSearching: Bool
    public let isScanning: Bool
    public let isLaunchAtLoginEnabled: Bool
    public let onRefresh: () -> Void
    public let onToggleLaunchAtLogin: () -> Void
    public let onQuit: () -> Void

    public init(
        totalCount: Int,
        filteredCount: Int,
        isSearching: Bool,
        isScanning: Bool,
        isLaunchAtLoginEnabled: Bool,
        onRefresh: @escaping () -> Void,
        onToggleLaunchAtLogin: @escaping () -> Void,
        onQuit: @escaping () -> Void = { NSApplication.shared.terminate(nil) }
    ) {
        self.totalCount = totalCount
        self.filteredCount = filteredCount
        self.isSearching = isSearching
        self.isScanning = isScanning
        self.isLaunchAtLoginEnabled = isLaunchAtLoginEnabled
        self.onRefresh = onRefresh
        self.onToggleLaunchAtLogin = onToggleLaunchAtLogin
        self.onQuit = onQuit
    }

    private var countText: String {
        if isSearching {
            return "\(String(filteredCount)) of \(String(totalCount)) listening port\(totalCount == 1 ? "" : "s")"
        } else {
            return "\(String(totalCount)) listening port\(totalCount == 1 ? "" : "s")"
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text(countText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            // Launch at Login Toggle Button
            Button(action: onToggleLaunchAtLogin) {
                HStack(spacing: 3) {
                    Image(systemName: isLaunchAtLoginEnabled ? "checkmark.seal.fill" : "arrow.triangle.2.circlepath")
                        .font(.system(size: 10, weight: .semibold))
                    Text(isLaunchAtLoginEnabled ? "Autostart ON" : "Autostart OFF")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(isLaunchAtLoginEnabled ? .green : .secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(isLaunchAtLoginEnabled ? Color.green.opacity(0.12) : Color.secondary.opacity(0.1))
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .help(isLaunchAtLoginEnabled ? "PIDkill starts automatically at login. Click to disable." : "Click to enable PIDkill autostart at login.")
            .accessibilityLabel("Toggle launch at login")

            // Refresh Button
            Button(action: onRefresh) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .rotationEffect(.degrees(isScanning ? 360 : 0))
                        .animation(isScanning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isScanning)
                    
                    Text(isScanning ? "Scanning..." : "Refresh")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .disabled(isScanning)
            .help("Refresh listening ports list")
            .accessibilityLabel("Refresh listening ports list")

            // Quit App Power Button
            Button(action: onQuit) {
                HStack(spacing: 3) {
                    Image(systemName: "power")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.red)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.12))
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .help("Quit PIDkill application")
            .accessibilityLabel("Quit PIDkill application")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}
