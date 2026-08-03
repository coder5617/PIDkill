import Foundation

#if canImport(Darwin)
import Darwin
#endif

/// Result of a process termination attempt.
public enum ProcessKillResult: Sendable, Equatable {
    case success
    case alreadyExited
    case permissionDenied
    case invalidPID
    case failure(String)

    public var isSuccess: Bool {
        switch self {
        case .success, .alreadyExited:
            return true
        default:
            return false
        }
    }

    public var userFacingMessage: String? {
        switch self {
        case .success:
            return nil
        case .alreadyExited:
            return "Process already exited."
        case .permissionDenied:
            return "Permission denied. (Root privileges required)"
        case .invalidPID:
            return "Invalid process ID."
        case .failure(let msg):
            return msg
        }
    }
}

/// Service that handles process termination using Darwin signals (SIGTERM & SIGKILL escalation).
public enum ProcessKiller {
    /// Attempts to terminate a process by PID.
    /// First sends SIGTERM, waits 750ms, checks if process is alive, and escalates to SIGKILL if needed.
    public static func terminateProcess(pid: Int32) async -> ProcessKillResult {
        guard pid > 0 else {
            return .invalidPID
        }

        // 1. Initial check if process exists
        if kill(pid, 0) != 0 {
            let err = errno
            if err == ESRCH {
                return .alreadyExited
            } else if err == EPERM {
                return .permissionDenied
            }
        }

        // 2. Send SIGTERM
        if kill(pid, SIGTERM) != 0 {
            let err = errno
            if err == ESRCH {
                return .alreadyExited
            } else if err == EPERM {
                return .permissionDenied
            } else {
                return .failure("SIGTERM failed (errno \(err)).")
            }
        }

        // 3. Wait approximately 750 milliseconds
        do {
            try await Task.sleep(nanoseconds: 750_000_000)
        } catch {
            // Task cancelled
        }

        // 4. Check whether process still exists
        if kill(pid, 0) != 0 {
            let err = errno
            if err == ESRCH {
                return .success
            }
        }

        // 5. Escalate to SIGKILL if process remains active
        if kill(pid, SIGKILL) != 0 {
            let err = errno
            if err == ESRCH {
                return .success
            } else if err == EPERM {
                return .permissionDenied
            } else {
                return .failure("SIGKILL failed (errno \(err)).")
            }
        }

        // Brief delay after SIGKILL to let kernel sweep process entry
        try? await Task.sleep(nanoseconds: 100_000_000)
        return .success
    }
}
