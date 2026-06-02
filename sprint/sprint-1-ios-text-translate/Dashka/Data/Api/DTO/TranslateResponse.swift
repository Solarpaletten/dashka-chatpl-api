import Foundation

/// Response from `POST /api/translate`. Field shape matches the actual
/// `app/api/translate/route.ts` response on success:
///
///   {
///     "status": "success",
///     "original_text": "...",
///     "translated_text": "...",
///     "source_language": "ru",
///     "target_language": "pl",
///     "confidence": 0.95,
///     "processing_time": 234,
///     "provider": "openai",
///     "from_cache": false
///   }
///
/// On error the backend returns `{ status: "error", message: "..." }` with
/// an HTTP non-2xx code — that path is handled by `DashkaApi`, not by this
/// DTO. So `status`, `originalText`, `translatedText`, etc. are non-optional
/// here: a 2xx body always has them.
struct TranslateResponse: Decodable, Sendable {
    let status: String
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let confidence: Double
    let processingTime: Int
    let provider: String
    let fromCache: Bool

    enum CodingKeys: String, CodingKey {
        case status
        case originalText   = "original_text"
        case translatedText = "translated_text"
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
        case confidence
        case processingTime = "processing_time"
        case provider
        case fromCache      = "from_cache"
    }
}
