import SwiftUI
import AppKit

@main
struct PIDkillApp: App {
    @StateObject private var viewModel = PortListViewModel()

    init() {
        // Ensure application runs as menu-bar accessory (no Dock icon)
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "terminal.fill")
                if viewModel.totalCount > 0 {
                    Text("\(viewModel.totalCount)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
