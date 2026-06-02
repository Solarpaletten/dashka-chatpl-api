import SwiftUI

/// Theme container. SwiftUI doesn't have a Compose `MaterialTheme {}`
/// equivalent — semantics live on environment values and view modifiers.
/// We expose a single typography preset and let `DashkaColors` provide
/// tokens.
///
/// Mirrors Android `DashkaTheme.kt` in role, not in mechanism.
enum DashkaTypography {
    static let titleLarge   = Font.title2.weight(.semibold)
    static let titleMedium  = Font.headline
    static let bodyLarge    = Font.body
    static let bodyMedium   = Font.callout
    static let bodySmall    = Font.footnote
    static let labelLarge   = Font.subheadline.weight(.medium)
    static let labelMedium  = Font.caption.weight(.medium)
    static let labelSmall   = Font.caption2
}
