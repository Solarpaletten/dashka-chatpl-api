import Foundation

/// Manual DI container. iOS-idiomatic alternative to Hilt — no annotations,
/// no codegen, no runtime resolution. Singletons are constructed lazily on
/// first access and cached.
///
/// Mirrors the role of Android `NetworkModule` + `RepositoryModule` (Hilt),
/// not the mechanism.
///
/// Access pattern: `AppContainer.shared.translatorViewModel()` for fresh
/// per-screen ViewModels; `AppContainer.shared.api` for singletons.
@MainActor
final class AppContainer {

    // MARK: - Singleton

    static let shared = AppContainer()

    // MARK: - Configuration (read from xcconfig → Info.plist)

    let baseURL: URL
    let token: String?
    let partnerLang: LangCode

    private init() {
        let bundle = Bundle.main
        self.baseURL     = bundle.dashkaBaseURL
        self.token       = bundle.dashkaApiToken
        self.partnerLang = LangCode.from(code: bundle.partnerLang) ?? .pl
    }

    // MARK: - Singletons (lazy)

    private(set) lazy var api: DashkaApi = DashkaApi(
        baseURL: baseURL,
        token:   token
    )

    private(set) lazy var translationRepository: TranslationRepository =
        TranslationRepositoryImpl(api: api)

    private(set) lazy var translateUseCase: TranslateUseCase =
        TranslateUseCase(repository: translationRepository)

    // MARK: - Factories (fresh instances)

    /// Fresh `TranslatorViewModel` per call. View models are not cached at
    /// container level — SwiftUI owns lifecycle via `@State`.
    func makeTranslatorViewModel() -> TranslatorViewModel {
        TranslatorViewModel(
            translateUseCase: translateUseCase,
            partnerLang:      partnerLang
        )
    }
}

// MARK: - Bundle helpers
//
// Bridge between xcconfig variables and typed Swift accessors. Variables
// must also be referenced in `Info.plist` via `$(VAR_NAME)` for the build
// system to materialize them into the bundle.

extension Bundle {
    /// Reads `DASHKA_BASE_URL` from Info.plist (sourced from xcconfig).
    /// Falls back to the production Vercel URL so the app stays runnable
    /// without local configuration during early development.
    var dashkaBaseURL: URL {
        let raw = (object(forInfoDictionaryKey: "DASHKA_BASE_URL") as? String)
            ?? "https://dashka-chatpl-api.vercel.app"
        return URL(string: raw) ?? URL(string: "https://dashka-chatpl-api.vercel.app")!
    }

    /// Optional API token (REC-001). Returns nil if not set — backend will
    /// also accept this when `DASHKA_API_TOKEN` is unset server-side
    /// (`lib/api-guards.ts verifyToken` short-circuits to "guard disabled").
    var dashkaApiToken: String? {
        let raw = object(forInfoDictionaryKey: "DASHKA_API_TOKEN") as? String
        guard let raw, !raw.isEmpty else { return nil }
        return raw
    }

    /// Reads `PARTNER_LANG` (default `"PL"`). Mirrors Android
    /// `BuildConfig.PARTNER_LANG`.
    var partnerLang: String {
        (object(forInfoDictionaryKey: "PARTNER_LANG") as? String) ?? "PL"
    }
}
