import Foundation

/// Request body for `POST /api/translate`.
///
/// Backend (`lib/translator.ts`) accepts several aliases for source/target —
/// `source_language` / `fromLang` / `from`, and `target_language` / `toLang`
/// / `to`. We always send the canonical snake_case pair (`source_language`,
/// `target_language`) to stay aligned with REC-005 validation.
///
/// `source_language` is optional — when `nil` the backend auto-detects.
struct TranslateRequest: Encodable, Sendable {
    let text: String
    let sourceLanguage: String?
    let targetLanguage: String

    enum CodingKeys: String, CodingKey {
        case text
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
    }
}
