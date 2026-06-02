import Foundation

/// MVI-style intent enum dispatched into `TranslatorViewModel.onIntent(...)`.
///
/// **Sprint 1 scope only.** Future sprints will extend this enum:
///   - Sprint 2A/2C — `.micTapped`, `.permissionResult(Bool)`, `.speechEvent(...)`
///   - Sprint 3A    — `.playTtsTapped`, `.stopTtsTapped`, `.ttsEvent(TtsState)`
///   - Sprint 3B    — `.voiceSelected(TtsVoice)`
///   - Sprint 3C    — `.toggleAutoplay(Bool)`
///   - Sprint 4     — `.copyTranslation`, `.copyOriginal`,
///                    `.pasteIntoInput(String)`, `.shareVoiceTapped`,
///                    `.shareWithMode(ShareMode)`
///
/// Mirrors the Sprint 1 portion of Android `TranslatorIntent.kt`. The Android
/// file currently holds all sprints' intents because Android is at v0.4.6
/// (Sprint 4C). iOS rolls out sprint by sprint, so this enum grows over time.
enum TranslatorIntent: Sendable, Equatable {
    case inputChanged(String)
    case translate
    case toggleDirection
    case clear
    case dismissError
}
