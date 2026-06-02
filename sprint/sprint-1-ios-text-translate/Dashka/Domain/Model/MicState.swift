import Foundation

/// Speech recognition state. **Foundation for Sprint 2A** — declared now so
/// `PaneState` doesn't need a breaking change when STT is added.
///
/// Sprint 1: only `.idle` is ever set. No transitions occur because no STT
/// flow exists yet.
enum MicState: Sendable, Equatable {
    case idle
    case requestingPermission
    case listening
    case processing
    case error(String)

    static func == (lhs: MicState, rhs: MicState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.requestingPermission, .requestingPermission),
             (.listening, .listening),
             (.processing, .processing):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
