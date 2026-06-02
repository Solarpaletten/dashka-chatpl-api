import Foundation

/// Concrete `TranslationRepository` — calls `DashkaApi` and maps low-level
/// transport errors into the domain `DashkaResult` enum so the use case /
/// view model never touches `URLError` or HTTP codes directly.
///
/// Mirrors Android `TranslationRepositoryImpl.kt`.
final class TranslationRepositoryImpl: TranslationRepository, Sendable {
    private let api: DashkaApi

    init(api: DashkaApi) {
        self.api = api
    }

    func translate(
        text: String,
        from sourceLang: LangCode?,
        to targetLang: LangCode
    ) async -> DashkaResult<TranslationResult> {
        let request = TranslateRequest(
            text: text,
            sourceLanguage: sourceLang?.rawValue,
            targetLanguage: targetLang.rawValue
        )

        do {
            let response = try await api.translate(request)
            return .success(TranslationResult(
                originalText:     response.originalText,
                translatedText:   response.translatedText,
                sourceLanguage:   response.sourceLanguage,
                targetLanguage:   response.targetLanguage,
                confidence:       response.confidence,
                processingTimeMs: response.processingTime,
                provider:         response.provider
            ))
        } catch let nsError as NSError {
            return .error(mapToDashkaError(nsError))
        } catch {
            return .error(.unknown(description: "\(error)"))
        }
    }

    /// Translate `DashkaApi`'s internal `NSError` domains into typed
    /// `DashkaError` cases. The Api layer guarantees these domains.
    private func mapToDashkaError(_ error: NSError) -> DashkaError {
        switch error.domain {
        case "DashkaApi.timeout":
            return .timeout
        case "DashkaApi.network":
            return .networkError
        case "DashkaApi.http":
            if error.code == 401 { return .unauthorized }
            return .server(
                code: error.code,
                message: error.localizedDescription
            )
        default:
            return .unknown(description: error.localizedDescription)
        }
    }
}
