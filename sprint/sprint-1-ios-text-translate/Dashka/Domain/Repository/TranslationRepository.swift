import Foundation

/// Translation repository protocol. The implementation lives in
/// `Data/Repository/TranslationRepositoryImpl.swift` and depends on
/// `DashkaApi`.
///
/// Mirrors Android `TranslationRepository.kt`.
protocol TranslationRepository: Sendable {
    /// Translate `text` from `sourceLang` to `targetLang`.
    ///
    /// - Parameter sourceLang: optional. When `nil`, backend auto-detects.
    ///   Sprint 1 always passes an explicit source for predictability.
    func translate(
        text: String,
        from sourceLang: LangCode?,
        to targetLang: LangCode
    ) async -> DashkaResult<TranslationResult>
}
