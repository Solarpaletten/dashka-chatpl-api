import Foundation

/// Domain-level translation result. Returned by `TranslationRepository`,
/// does not leak the raw DTO into the presentation layer.
///
/// Mirrors Android `TranslationResult.kt`.
struct TranslationResult: Sendable, Equatable {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let confidence: Double
    let processingTimeMs: Int
    let provider: String
}
