import Foundation

/// Represents a listening port and its associated process details.
public struct PortEntry: Identifiable, Hashable, Sendable {
    public let id: String
    public let port: Int
    public let protocolName: String
    public let pid: Int32
    public let processName: String
    public let executablePath: String
    public let localAddress: String

    public init(
        port: Int,
        protocolName: String = "TCP",
        pid: Int32,
        processName: String,
        executablePath: String,
        localAddress: String = "127.0.0.1"
    ) {
        self.id = "\(pid)-\(port)-\(protocolName)"
        self.port = port
        self.protocolName = protocolName
        self.pid = pid
        self.processName = processName
        self.executablePath = executablePath
        self.localAddress = localAddress
    }
}
