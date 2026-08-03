import Foundation

#if canImport(Darwin)
import Darwin
#endif

/// Resolves the full executable filesystem path for a given process ID.
public enum ProcessPathResolver {
    /// Resolves executable path using Darwin `proc_pidpath`.
    /// - Parameters:
    ///   - pid: The target process ID.
    ///   - fallbackName: Fallback string if path resolution fails.
    /// - Returns: Absolute executable path string or fallback.
    public static func resolveExecutablePath(for pid: Int32, fallbackName: String = "") -> String {
        guard pid > 0 else { return fallbackName }
        let bufferSize = Int(MAXPATHLEN)
        var buffer = [CChar](repeating: 0, count: bufferSize)
        
        let result = proc_pidpath(pid, &buffer, UInt32(bufferSize))
        if result > 0 {
            let path = buffer.withUnsafeBufferPointer { ptr in
                ptr.baseAddress.map { String(cString: $0) } ?? ""
            }
            if !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return path
            }
        }
        return fallbackName
    }
}
