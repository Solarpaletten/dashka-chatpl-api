import SwiftUI

/// Brand color tokens. Where possible we lean on system colors so light/dark
/// mode follow user preference. Brand-specific accents stay explicit.
///
/// Mirrors Android `Color.kt` (Material 3 tokens).
enum DashkaColors {
    // ── Brand ────────────────────────────────────────────────────────────
    /// Orange used for primary actions (Translate button, mic active state).
    /// Matches Android `Color(0xFFD97706)`.
    static let brandOrange = Color(red: 0xD9 / 255, green: 0x76 / 255, blue: 0x06 / 255)

    // ── System-driven (auto light/dark) ──────────────────────────────────
    static let surface         = Color(.systemBackground)
    static let surfaceVariant  = Color(.secondarySystemBackground)
    static let surfaceLow      = Color(.tertiarySystemBackground)
    static let onSurface       = Color(.label)
    static let onSurfaceMuted  = Color(.secondaryLabel)
    static let onSurfaceDim    = Color(.tertiaryLabel)
    static let divider         = Color(.separator)

    // ── Semantic ─────────────────────────────────────────────────────────
    static let error           = Color(.systemRed)
    static let errorContainer  = Color(.systemRed).opacity(0.12)
}
