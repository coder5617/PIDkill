import SwiftUI

public struct MenuBarView: View {
    @ObservedObject public var viewModel: PortListViewModel

    public init(viewModel: PortListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // First Launch Autostart Banner
            if viewModel.showLaunchAtLoginPrompt {
                LaunchAtLoginBannerView(
                    onEnable: { viewModel.enableLaunchAtLogin() },
                    onDismiss: { viewModel.dismissLaunchAtLoginPrompt() }
                )
            }

            // Header Search Bar
            SearchBarView(
                text: $viewModel.searchText,
                onClear: { viewModel.clearSearch() }
            )
            .padding(10)

            Divider()

            // Process List or Empty / Error States
            ZStack {
                if viewModel.isScanning && viewModel.entries.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.regular)
                        Text("Scanning active listening ports...")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else if let scanError = viewModel.scanErrorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        Text("Port Scan Failed")
                            .font(.system(size: 13, weight: .bold))
                        Text(scanError)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        Button("Retry Scan") {
                            viewModel.scanPorts()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 30)
                } else if viewModel.entries.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No Listening Ports Found")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else if viewModel.filteredEntries.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No Matching Ports")
                            .font(.system(size: 13, weight: .semibold))
                        Text("No ports match \"\(viewModel.searchText)\"")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(viewModel.filteredEntries) { entry in
                                PortRowView(
                                    entry: entry,
                                    isKilling: viewModel.killingPIDs.contains(entry.pid),
                                    errorMessage: viewModel.rowErrors[entry.pid],
                                    onOpenBrowser: {
                                        viewModel.openInBrowser(for: entry)
                                    },
                                    onKill: {
                                        viewModel.killProcess(for: entry)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                    }
                    .frame(maxHeight: 520)
                }
            }

            Divider()

            // Footer Component
            FooterView(
                totalCount: viewModel.totalCount,
                filteredCount: viewModel.filteredCount,
                isSearching: !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                isScanning: viewModel.isScanning,
                isLaunchAtLoginEnabled: viewModel.isLaunchAtLoginEnabled,
                onRefresh: { viewModel.scanPorts() },
                onToggleLaunchAtLogin: { viewModel.toggleLaunchAtLogin() },
                onQuit: { NSApplication.shared.terminate(nil) }
            )
        }
        .frame(width: 460)
        .onAppear {
            viewModel.scanPorts()
        }
    }
}
