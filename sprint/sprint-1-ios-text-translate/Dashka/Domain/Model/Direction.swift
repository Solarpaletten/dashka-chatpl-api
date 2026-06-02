import Foundation

/// Translation direction. Mobile is single-pane (unlike web's two simultaneous
/// panes) — the user flips between these two directions via the direction
/// toggle.
///
/// Sprint 1: RU ↔ partner language. Partner is sourced from
/// `Bundle.main.partnerLang` (xcconfig → Info.plist) and resolved in the
/// `TranslatorViewModel`.
enum Direction: String, Codable, Sendable {
    /// User speaks Russian, output is in the partner language.
    case ruToPartner = "RU_TO_PARTNER"

    /// Partner speaks their language, output is Russian.
    case partnerToRu = "PARTNER_TO_RU"

    /// Returns the flipped direction. Pure function — no mutation.
    func toggled() -> Direction {
        switch self {
        case .ruToPartner: return .partnerToRu
        case .partnerToRu: return .ruToPartner
        }
    }
}
