import SwiftUI

public struct FooterView: View {
    public let totalCount: Int
    public let filteredCount: Int
    public let isSearching: Bool
    public let isScanning: Bool
    public let onRefresh: () -> Void

    public init(
        totalCount: Int,
        filteredCount: Int,
        isSearching: Bool,
        isScanning: Bool,
        onRefresh: @escaping () -> Void
    ) {
        self.totalCount = totalCount
        self.filteredCount = filteredCount
        self.isSearching = isSearching
        self.isScanning = isScanning
        self.onRefresh = onRefresh
    }

    private var countText: String {
        if isSearching {
            return "\(filteredCount) of \(totalCount) listening port\(totalCount == 1 ? "" : "s")"
        } else {
            return "\(totalCount) listening port\(totalCount == 1 ? "" : "s")"
        }
    }

    public var body: some View {
        HStack {
            Text(countText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

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
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}
