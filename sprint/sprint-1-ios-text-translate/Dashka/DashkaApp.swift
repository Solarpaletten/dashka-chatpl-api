import SwiftUI

/// App entry point. Mirrors Android `DashkaApplication.kt` +
/// `MainActivity.kt` collapsed into a single SwiftUI `App` value.
///
/// iOS 17+ deployment target required (`@Observable` macro in
/// `TranslatorViewModel`).
@main
struct DashkaApp: App {
    var body: some Scene {
        WindowGroup {
            TranslatorScreen(
                viewModel: AppContainer.shared.makeTranslatorViewModel()
            )
        }
    }
}
