import Foundation

/// Mirrors `TtsVoice` from Android `TtsVoice.kt` and web
/// `features/translator/types-runtime.ts`.
///
/// **Sprint 1 status:** declared and stored in `PaneState.voice` for forward
/// compatibility, but no audio is played. TTS playback lands in Sprint 3A.
/// The voice picker UI is Sprint 3B.
///
/// `Codable` so `HistoryEntry` (Sprint 4C) can persist by raw value.
enum TtsVoice: String, Codable, CaseIterable, Sendable {
    case eve, ara, leo, rex, sal

    var displayName: String {
        switch self {
        case .eve: return "Eve"
        case .ara: return "Ara"
        case .leo: return "Leo"
        case .rex: return "Rex"
        case .sal: return "Sal"
        }
    }

    var isFemale: Bool {
        switch self {
        case .eve, .ara: return true
        case .leo, .rex, .sal: return false
        }
    }

    /// Russian short description shown as dropdown subtitle (Sprint 3B).
    /// Pre-populated in Sprint 1 so the picker is one-shot drop-in later.
    var shortDescription: String {
        switch self {
        case .leo: return "спокойный"
        case .rex: return "глубокий"
        case .sal: return "нейтральный"
        case .eve: return "мягкий"
        case .ara: return "выразительный"
        }
    }

    /// 👨 / 👩 — used by Sprint 3B picker.
    var emoji: String { isFemale ? "👩" : "👨" }

    /// Mirror of Android `DEFAULT_LEFT` / `DEFAULT_RIGHT`. Mobile uses ONE
    /// global voice (architectural decision, Solar Team v3.0): default is
    /// `.eve` to mirror the female contrast against typical male input voice.
    static let defaultVoice: TtsVoice = .eve
}
