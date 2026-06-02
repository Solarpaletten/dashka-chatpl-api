import Foundation

/// **Foundation for Sprint 4C.** Single translation history entry.
///
/// Designed backend-ready from day 1: UUID + ISO timestamp + serializable
/// primitives only. When Sprint 4G+ adds cloud sync, no schema migration
/// needed — same struct travels to backend.
///
/// **Sprint 1 status:** declared but not written anywhere. `HistoryStorage`
/// arrives in Sprint 4C.
///
/// Mirrors Android `HistoryEntry.kt`.
struct HistoryEntry: Codable, Sendable, Identifiable, Equatable {
    /// Stable UUID. Generated locally on save. Used as primary key in
    /// future cloud sync (last-write-wins) and as `List` row identity.
    let id: String

    /// Unix epoch milliseconds (UTC). Display formatting happens in UI.
    let timestampMillis: Int64

    let sourceText: String
    let translatedText: String
    let sourceLang: LangCode
    let targetLang: LangCode

    /// `TtsVoice` persona used for this translation. Reload restores it so
    /// the user gets the same audio character.
    let voice: TtsVoice

    init(
        id: String = UUID().uuidString,
        timestampMillis: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        sourceText: String,
        translatedText: String,
        sourceLang: LangCode,
        targetLang: LangCode,
        voice: TtsVoice
    ) {
        self.id              = id
        self.timestampMillis = timestampMillis
        self.sourceText      = sourceText
        self.translatedText  = translatedText
        self.sourceLang      = sourceLang
        self.targetLang      = targetLang
        self.voice           = voice
    }
}
