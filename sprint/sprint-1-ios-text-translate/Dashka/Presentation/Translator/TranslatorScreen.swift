import SwiftUI

/// Sprint 1 screen — one input pane, one output pane, direction toggle,
/// translate button, error banner.
///
/// **Out of scope for Sprint 1** (future sprint additions):
///   - mic button (Sprint 2A)
///   - play/voice picker (Sprint 3A/3B)
///   - autoplay switch (Sprint 3C)
///   - share popover, copy/paste icons (Sprint 4B/4C)
///   - history bottom sheet (Sprint 4C)
///
/// Mirrors the Sprint 1 surface of Android `TranslatorScreen.kt`.
struct TranslatorScreen: View {

    @State private var viewModel: TranslatorViewModel

    init(viewModel: TranslatorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // Computed direction labels for the toggle.
    private var sourceLang: LangCode {
        switch viewModel.state.direction {
        case .ruToPartner: return .ru
        case .partnerToRu: return AppContainer.shared.partnerLang
        }
    }
    private var targetLang: LangCode {
        switch viewModel.state.direction {
        case .ruToPartner: return AppContainer.shared.partnerLang
        case .partnerToRu: return .ru
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                directionToggle
                inputPane
                translateButton
                outputPane
                if let error = viewModel.state.errorMessage {
                    errorBanner(error)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DashkaColors.surface.ignoresSafeArea())
            .navigationTitle("Dashka")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Direction toggle

    private var directionToggle: some View {
        HStack(spacing: 8) {
            Text("\(sourceLang.flag) \(sourceLang.nativeName)")
                .font(DashkaTypography.labelLarge)
                .foregroundStyle(DashkaColors.onSurface)
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(DashkaColors.onSurfaceMuted)
            Text("\(targetLang.flag) \(targetLang.nativeName)")
                .font(DashkaTypography.labelLarge)
                .foregroundStyle(DashkaColors.onSurface)
            Spacer()
            Button {
                viewModel.onIntent(.toggleDirection)
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .imageScale(.large)
                    .foregroundStyle(DashkaColors.onSurfaceMuted)
            }
            .accessibilityLabel("Сменить направление")
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Input pane

    private var inputPane: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(sourceLang.flag) \(sourceLang.displayName)")
                    .font(DashkaTypography.labelMedium)
                    .foregroundStyle(DashkaColors.onSurfaceMuted)
                Spacer()
                if !viewModel.state.inputText.isEmpty {
                    Button("Очистить") {
                        viewModel.onIntent(.clear)
                    }
                    .font(DashkaTypography.labelMedium)
                    .foregroundStyle(DashkaColors.onSurfaceMuted)
                    .accessibilityLabel("Очистить ввод")
                }
            }
            TextEditor(text: Binding(
                get: { viewModel.state.inputText },
                set: { viewModel.onIntent(.inputChanged($0)) }
            ))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(DashkaColors.surfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .frame(minHeight: 120)
            .font(DashkaTypography.bodyLarge)
        }
    }

    // MARK: - Translate button

    private var translateButton: some View {
        Button {
            viewModel.onIntent(.translate)
        } label: {
            HStack(spacing: 8) {
                if viewModel.state.isTranslating {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.small)
                }
                Text(viewModel.state.isTranslating ? "Перевожу…" : "Перевести →")
                    .font(DashkaTypography.labelLarge)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                viewModel.state.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? DashkaColors.onSurfaceDim
                    : DashkaColors.brandOrange
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(
            viewModel.state.isTranslating ||
            viewModel.state.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
        .accessibilityLabel("Перевести")
    }

    // MARK: - Output pane

    private var outputPane: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(targetLang.flag) \(targetLang.displayName)")
                .font(DashkaTypography.labelMedium)
                .foregroundStyle(DashkaColors.onSurfaceMuted)
            ScrollView {
                Text(
                    viewModel.state.translatedText.isEmpty
                        ? "Перевод появится здесь…"
                        : viewModel.state.translatedText
                )
                .font(DashkaTypography.bodyLarge)
                .foregroundStyle(
                    viewModel.state.translatedText.isEmpty
                        ? DashkaColors.onSurfaceDim
                        : DashkaColors.onSurface
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .background(DashkaColors.surfaceLow)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .frame(minHeight: 120)
        }
    }

    // MARK: - Error banner

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DashkaColors.error)
            Text(message)
                .font(DashkaTypography.bodyMedium)
                .foregroundStyle(DashkaColors.onSurface)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                viewModel.onIntent(.dismissError)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(DashkaColors.onSurfaceMuted)
            }
            .accessibilityLabel("Закрыть ошибку")
        }
        .padding(12)
        .background(DashkaColors.errorContainer)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
