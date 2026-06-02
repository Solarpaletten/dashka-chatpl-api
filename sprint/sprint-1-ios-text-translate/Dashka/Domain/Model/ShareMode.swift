import Foundation

/// Defines what gets attached when sharing a translation.
///
/// **Foundation for Sprint 4B.1.** Sprint 1 does not invoke share.
///
/// Mirrors Android `ShareMode.kt`. The dedicated 🔊 voice-only button is
/// a separate intent (`ShareVoiceTapped`) — not modeled here because it
/// has no mode choice. Only the popover-driven flow uses `ShareMode`.
enum ShareMode: Sendable, Equatable {
    /// Plain text only — quick text-share use case.
    case textOnly

    /// Both attached: one MP3 + text as caption.
    /// Mirrors web v3.0.2 "сообщение и MP3" pattern. Receiver apps
    /// (Telegram et al.) show the message text inline next to the audio
    /// attachment — strong UX for users driving (audio + visible caption).
    case textAndVoice
}
