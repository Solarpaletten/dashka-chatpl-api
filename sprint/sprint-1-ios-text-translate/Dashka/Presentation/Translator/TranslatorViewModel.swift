import Foundation
import Observation

/// Sprint 1 ViewModel — text translation only.
///
/// Architecture parity with Android `TranslatorViewModel.kt`:
///   - Single source of truth: `state: PaneState`
///   - Intents dispatched via `onIntent(_:)` → `case` branches
///   - In-flight translation owned by a cancellable `Task`
///     (mirrors Kotlin `translateJob: Job?`)
///
/// **Out of scope for Sprint 1** (lives in `PaneState` as foundation only):
///   - voice picker (Sprint 3B)
///   - autoplay (Sprint 3C)
///   - share (Sprint 4B)
///   - history persistence (Sprint 4C)
///   - STT (Sprint 2A)
///   - TTS playback (Sprint 3A)
///
/// **iOS 17+** — uses `@Observable` macro. `@MainActor` because all state
/// mutations are observed by SwiftUI on the main thread.
@Observable
@MainActor
final class TranslatorViewModel {

    // MARK: - State

    private(set) var state: PaneState = PaneState()

    // MARK: - Dependencies

    private let translateUseCase: TranslateUseCase
    private let partnerLang: LangCode

    // MARK: - In-flight work

    /// Mirrors Kotlin `translateJob: Job?` — cancelling a stale request
    /// before starting a new one prevents "last-write-wins" race conditions
    /// where an older response clobbers a newer one.
    private var translateTask: Task<Void, Never>?

    // MARK: - Init

    init(
        translateUseCase: TranslateUseCase,
        partnerLang: LangCode
    ) {
        self.translateUseCase = translateUseCase
        self.partnerLang      = partnerLang
    }

    // MARK: - Intent dispatch

    func onIntent(_ intent: TranslatorIntent) {
        switch intent {
        case .inputChanged(let text):
            updateInput(text)
        case .translate:
            performTranslation(isUserInitiated: true)
        case .toggleDirection:
            toggleDirection()
        case .clear:
            clear()
        case .dismissError:
            state.errorMessage = nil
        }
    }

    // MARK: - Text input

    private func updateInput(_ text: String) {
        state.inputText = text
    }

    private func toggleDirection() {
        translateTask?.cancel()
        state.direction       = state.direction.toggled()
        state.inputText       = ""
        state.translatedText  = ""
        state.errorMessage    = nil
        // micState/ttsState are foundation fields — already .idle.
    }

    private func clear() {
        translateTask?.cancel()
        state.inputText      = ""
        state.translatedText = ""
        state.errorMessage   = nil
    }

    // MARK: - Translation

    /// Runs a translation. Cancels any in-flight call (last-write-wins).
    ///
    /// - Parameter isUserInitiated: in Sprint 1 always `true` (the orange
    ///   Translate button is the only entry point). In Sprint 2C the
    ///   parameter is wired up so silence-detected continuous mode can
    ///   trigger translations without UI flicker / history spam. Kept
    ///   in the signature for parity with Android.
    private func performTranslation(isUserInitiated: Bool) {
        let trimmed = state.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        translateTask?.cancel()

        let (source, target): (LangCode, LangCode) = {
            switch state.direction {
            case .ruToPartner: return (.ru, partnerLang)
            case .partnerToRu: return (partnerLang, .ru)
            }
        }()

        if isUserInitiated {
            state.isTranslating = true
            state.errorMessage  = nil
        }

        translateTask = Task { [weak self] in
            guard let self else { return }
            let result = await self.translateUseCase(trimmed, source, target)
            // Task cancellation check — if a newer request started, drop this
            // response on the floor. Mirrors Kotlin's cancelled-Job semantics.
            if Task.isCancelled { return }

            switch result {
            case .success(let translation):
                self.state.translatedText = translation.translatedText
                self.state.isTranslating  = false
                // Sprint 3C+ would call maybeAutoplay() here. Not in Sprint 1.
                // Sprint 4C+ would call saveToHistory(...) here. Not in Sprint 1.

            case .error(let dashkaError):
                self.state.isTranslating = false
                // Only surface translation errors during user-initiated taps.
                // Background incremental fails (Sprint 2C) are silent.
                if isUserInitiated {
                    self.state.errorMessage = userMessage(for: dashkaError)
                }
            }
        }
    }

    // MARK: - Lifecycle

    deinit {
        translateTask?.cancel()
    }
}

// MARK: - Error → Russian user message
//
// Matches the strings in Android `TranslatorViewModel.kt`'s
// `DashkaResult.Error.toUserMessage()` extension.

private func userMessage(for error: DashkaError) -> String {
    switch error {
    case .unauthorized:
        return "Неверный токен доступа. Проверьте DASHKA_API_TOKEN."
    case .networkError:
        return "Нет подключения к интернету."
    case .timeout:
        return "Сервер не ответил вовремя."
    case .server(_, let message):
        return message
    case .unknown(let description):
        return description.isEmpty ? "Неизвестная ошибка" : description
    }
}
