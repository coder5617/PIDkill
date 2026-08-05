import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure application runs as menu-bar accessory (no Dock icon)
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Activate application when user double-clicks PIDkill.app in Finder or launches manually while already running
        NSApp.activate(ignoringOtherApps: true)
        return true
    }
}

@MainActor
public final class MenuBarBadgeModel: ObservableObject {
    @Published public private(set) var count: Int = 0

    public init() {}

    public func updateCount(_ newCount: Int) {
        if count != newCount {
            count = newCount
        }
    }
}

struct MenuBarLabelView: View {
    @ObservedObject var badgeModel: MenuBarBadgeModel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "terminal.fill")
            if badgeModel.count > 0 {
                Text("\(badgeModel.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
        }
    }
}

@main
struct PIDkillApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var badgeModel = MenuBarBadgeModel()
    @StateObject private var viewModel = PortListViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
                .onReceive(viewModel.$entries) { entries in
                    badgeModel.updateCount(entries.count)
                }
        } label: {
            MenuBarLabelView(badgeModel: badgeModel)
        }
        .menuBarExtraStyle(.window)
    }
}

