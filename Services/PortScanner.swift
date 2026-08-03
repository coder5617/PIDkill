import Foundation

/// Service responsible for scanning active listening TCP ports using `/usr/sbin/lsof`.
public final class PortScanner: @unchecked Sendable {
    public init() {}

    public enum ScanError: Error, LocalizedError {
        case lsofExecutionFailed(String)
        case outputParsingFailed

        public var errorDescription: String? {
            switch self {
            case .lsofExecutionFailed(let message):
                return "Failed to execute lsof: \(message)"
            case .outputParsingFailed:
                return "Failed to parse listening ports output."
            }
        }
    }

    /// Asynchronously scans active TCP listening ports off the main thread.
    /// - Returns: Sorted array of deduplicated `PortEntry` items.
    public func fetchListeningPorts() async throws -> [PortEntry] {
        return try await Task.detached(priority: .userInitiated) {
            let output = try self.executeLsofCommand()
            return self.parseLsofOutput(output)
        }.value
    }

    /// Executes `/usr/sbin/lsof -n -P -iTCP -sTCP:LISTEN`
    private func executeLsofCommand() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-n", "-P", "-iTCP", "-sTCP:LISTEN"]

        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw ScanError.lsofExecutionFailed(error.localizedDescription)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 || process.terminationStatus == 1 else {
            // Note: lsof returns 1 if no matching files/ports were found
            let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errMessage = String(data: errData, encoding: .utf8) ?? "Unknown error"
            throw ScanError.lsofExecutionFailed(errMessage)
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Parses output lines into deduplicated `PortEntry` objects.
    public func parseLsofOutput(_ output: String) -> [PortEntry] {
        let lines = output.components(separatedBy: .newlines)
        var entriesDict = [String: PortEntry]()

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || index == 0 && trimmed.hasPrefix("COMMAND") {
                continue
            }

            if let entry = parseLine(trimmed) {
                // Deduplicate by PID, port, and protocol (entry.id)
                if entriesDict[entry.id] == nil {
                    entriesDict[entry.id] = entry
                }
            }
        }

        return entriesDict.values.sorted { $0.port < $1.port }
    }

    /// Parses a single line from lsof output.
    private func parseLine(_ line: String) -> PortEntry? {
        let tokens = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        // We expect at least: COMMAND, PID, USER, FD, TYPE, DEVICE, SIZE/OFF, NODE, NAME
        guard tokens.count >= 9 else { return nil }

        // Find PID (first token after token 0 that is a valid Int32)
        guard let pidIndex = tokens.enumerated().first(where: { $0.offset > 0 && Int32($0.element) != nil })?.offset,
              let pid = Int32(tokens[pidIndex]) else {
            return nil
        }

        let command = tokens[0..<pidIndex].joined(separator: " ")
        
        // NAME is token at or near the end (e.g. *:57524 (LISTEN) or 127.0.0.1:8080 (LISTEN))
        // Find token containing a colon ':' (address:port)
        guard let nameTokenIndex = tokens.enumerated().first(where: { $0.offset > pidIndex && $0.element.contains(":") })?.offset else {
            return nil
        }

        let nameToken = tokens[nameTokenIndex] // e.g. *:57524 or 127.0.0.1:8080 or [::1]:3000
        
        guard let lastColonIndex = nameToken.lastIndex(of: ":") else { return nil }
        
        let localAddress = String(nameToken[..<lastColonIndex])
        let portString = String(nameToken[nameToken.index(after: lastColonIndex)...])
        
        guard let port = Int(portString) else { return nil }

        let executablePath = ProcessPathResolver.resolveExecutablePath(for: pid, fallbackName: command)

        return PortEntry(
            port: port,
            protocolName: "TCP",
            pid: pid,
            processName: command,
            executablePath: executablePath,
            localAddress: localAddress
        )
    }
}
