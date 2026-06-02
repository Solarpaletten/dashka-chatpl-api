import Foundation

/// TTS playback state — drives the play button's visual state.
///
/// **Foundation for Sprint 3A.** Sprint 1 only ever sees `.idle`.
enum TtsState: Sendable, Equatable {
    case idle
    case loading
    case playing
    case error(String)

    static func == (lhs: TtsState, rhs: TtsState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.playing, .playing):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
