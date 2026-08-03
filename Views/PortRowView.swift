import SwiftUI

public struct PortRowView: View {
    public let entry: PortEntry
    public let isKilling: Bool
    public let errorMessage: String?
    public let onOpenBrowser: () -> Void
    public let onKill: () -> Void

    @State private var isHovering: Bool = false

    public init(
        entry: PortEntry,
        isKilling: Bool,
        errorMessage: String?,
        onOpenBrowser: @escaping () -> Void,
        onKill: @escaping () -> Void
    ) {
        self.entry = entry
        self.isKilling = isKilling
        self.errorMessage = errorMessage
        self.onOpenBrowser = onOpenBrowser
        self.onKill = onKill
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                // Open in Browser Button
                Button(action: onOpenBrowser) {
                    Image(systemName: "globe")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                .help("Open http://localhost:\(String(entry.port)) in browser")
                .accessibilityLabel("Open http://localhost:\(String(entry.port)) in browser")

                // Process Name
                Text(entry.processName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                // Port Number
                Text(":\(String(entry.port))")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(4)
            }

            HStack(alignment: .center, spacing: 8) {
                // Executable Path (Truncated middle/tail with help tooltip)
                Text(entry.executablePath)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(entry.executablePath)

                Spacer(minLength: 8)

                // PID Badge
                Text("PID \(String(entry.pid))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)

                // Kill Button with progress state
                Button(action: onKill) {
                    HStack(spacing: 4) {
                        if isKilling {
                            ProgressView()
                                .controlSize(.small)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "xmark.square.fill")
                                .font(.system(size: 11))
                            Text("Kill")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isKilling ? Color.gray : Color.red)
                    .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .disabled(isKilling)
                .help("Terminate process \(entry.processName) (PID \(entry.pid))")
                .accessibilityLabel("Kill process \(entry.processName), PID \(entry.pid)")
            }

            // Inline error message if termination fails or permission is denied
            if let errorMsg = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 10))
                    Text(errorMsg)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding(.top, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? Color.secondary.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}
