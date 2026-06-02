import Foundation

/// Single-pane UI state. Mobile (unlike web's dual-pane layout) shows ONE
/// active pane at a time; the user toggles direction.
///
/// **Forward-compatible:** all Sprint 1-4 fields are declared from day one so
/// later sprints add behavior, not breaking schema changes. The Sprint 1
/// `TranslatorViewModel` simply doesn't read/write the post-Sprint-1 fields.
///
/// Mirrors Android `PaneState.kt`.
struct PaneState: Sendable, Equatable {
    // ── Sprint 1 — text translation core ─────────────────────────────────
    var direction: Direction         = .ruToPartner
    var inputText: String            = ""
    var translatedText: String       = ""
    var isTranslating: Bool          = false
    var errorMessage: String?        = nil

    // ── Sprint 2A — voice input foundation (idle in Sprint 1) ────────────
    var micState: MicState           = .idle

    // ── Sprint 3A/3B/3C — TTS + voice picker + autoplay foundations ──────
    var voice: TtsVoice              = TtsVoice.defaultVoice  // .eve
    var ttsState: TtsState           = .idle
    var autoplayEnabled: Bool        = false

    // ── Sprint 4B — share preparation flag (false in Sprint 1) ───────────
    var isPreparingShareVoice: Bool  = false
}
