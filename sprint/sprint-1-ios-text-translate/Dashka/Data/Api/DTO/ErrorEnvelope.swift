import Foundation

/// Standard backend error envelope. Used by `DashkaApi` to decode non-2xx
/// response bodies and lift the user-facing `message` into `DashkaError.server`.
///
///   { "status": "error", "message": "Text too long (max 5000 chars)" }
///
/// Some endpoints add `details` (e.g. `/api/tts` proxy passes Grok diagnostics).
struct ErrorEnvelope: Decodable, Sendable {
    let status: String
    let message: String
    let details: String?
}
