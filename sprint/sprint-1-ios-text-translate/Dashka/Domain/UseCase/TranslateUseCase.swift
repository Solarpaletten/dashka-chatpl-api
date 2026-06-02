import Foundation

/// Sprint 1 use case — invokes the translation repository with explicit
/// source and target language codes.
///
/// Mirrors Android `TranslateUseCase.kt`. Implemented as a callable struct
/// (Swift's `callAsFunction`) to match the Kotlin `operator fun invoke`
/// idiom — call sites read `translateUseCase(...)` not `.execute(...)`.
struct TranslateUseCase: Sendable {
    private let repository: TranslationRepository

    init(repository: TranslationRepository) {
        self.repository = repository
    }

    func callAsFunction(
        _ text: String,
        _ sourceLang: LangCode,
        _ targetLang: LangCode
    ) async -> DashkaResult<TranslationResult> {
        await repository.translate(text: text, from: sourceLang, to: targetLang)
    }
}
