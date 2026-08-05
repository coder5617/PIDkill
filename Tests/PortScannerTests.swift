import XCTest
@testable import PIDkill

final class PortScannerTests: XCTestCase {
    func testLsofOutputParsingAndDeduplication() {
        let sampleOutput = """
        COMMAND     PID  USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
        rapportd    631 testuser   10u  IPv4 0xfb0f5cbb03991562      0t0  TCP *:57524 (LISTEN)
        rapportd    631 testuser   11u  IPv6 0xedebf155f00c1bb1      0t0  TCP *:57524 (LISTEN)
        Electron  13839 testuser   65u  IPv4 0x50cc25f43d4e043d      0t0  TCP 127.0.0.1:3000 (LISTEN)
        node      14000 testuser    7u  IPv4 0xe05029ab42705a91      0t0  TCP 127.0.0.1:8080 (LISTEN)
        """

        let scanner = PortScanner()
        let entries = scanner.parseLsofOutput(sampleOutput)

        // Should have 3 deduplicated entries (rapportd on 57524 deduplicated between IPv4/IPv6)
        XCTAssertEqual(entries.count, 3)

        // Sorted by port ascending: 3000, 8080, 57524
        XCTAssertEqual(entries[0].port, 3000)
        XCTAssertEqual(entries[0].processName, "Electron")

        XCTAssertEqual(entries[1].port, 8080)
        XCTAssertEqual(entries[1].processName, "node")

        XCTAssertEqual(entries[2].port, 57524)
        XCTAssertEqual(entries[2].processName, "rapportd")
    }

    func testPortEntryStableIdentifier() {
        let entry = PortEntry(port: 3000, protocolName: "TCP", pid: 1234, processName: "node", executablePath: "/usr/local/bin/node")
        XCTAssertEqual(entry.id, "1234-3000-TCP")
    }

    @MainActor
    func testViewModelSearchFiltering() {
        let viewModel = PortListViewModel(autoScan: false)
        viewModel.entries = [
            PortEntry(port: 3000, pid: 100, processName: "node", executablePath: "/usr/bin/node"),
            PortEntry(port: 8080, pid: 200, processName: "python", executablePath: "/usr/bin/python3"),
            PortEntry(port: 5432, pid: 999, processName: "postgres", executablePath: "/opt/homebrew/bin/postgres")
        ]

        // Search by port
        viewModel.searchText = "8080"
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries.first?.processName, "python")

        // Search by process name
        viewModel.searchText = "Node"
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries.first?.port, 3000)

        // Search by PID
        viewModel.searchText = "999"
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries.first?.processName, "postgres")

        // Search by path
        viewModel.searchText = "homebrew"
        XCTAssertEqual(viewModel.filteredEntries.count, 1)

        // Empty search
        viewModel.clearSearch()
        XCTAssertEqual(viewModel.filteredEntries.count, 3)
    }
}
