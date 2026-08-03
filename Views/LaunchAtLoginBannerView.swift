import SwiftUI

public struct LaunchAtLoginBannerView: View {
    public let onEnable: () -> Void
    public let onDismiss: () -> Void

    public init(onEnable: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.onEnable = onEnable
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.amberColor)
                    .font(.system(size: 13, weight: .bold))

                Text("Start PIDkill automatically at login?")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                Button(action: onEnable) {
                    Text("Enable Autostart")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)

                Button(action: onDismiss) {
                    Text("Not Now")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .padding(.top, 4)
    }
}

private extension Color {
    static let amberColor = Color(red: 0.95, green: 0.65, blue: 0.15)
}
