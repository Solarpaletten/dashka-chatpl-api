import Foundation

/// Result type used across the Data layer. Mirrors Android `DashkaResult.kt`,
/// which is itself a port of the Kotlin `sealed class` pattern.
///
/// Swift's built-in `Result<Success, Failure>` is intentionally NOT used here
/// because we need **typed enum cases** for specific error categories (so
/// the UI can pattern-match and produce category-specific messages without
/// inspecting an `Error` instance).
enum DashkaResult<T: Sendable>: Sendable {
    case success(T)
    case error(DashkaError)
}

/// Error categories that the UI layer pattern-matches on for user-facing
/// messages. Strings live in the presentation layer, not here.
enum DashkaError: Sendable, Equatable {
    /// 401 — `X-Dashka-Token` missing or wrong. REC-001 guard rejected us.
    case unauthorized

    /// `URLError.notConnectedToInternet`, `.networkConnectionLost`, etc.
    case networkError

    /// `URLError.timedOut` or our own client-side timeout.
    case timeout

    /// Any 4xx/5xx the server returned with a structured body. `message` is
    /// the backend-provided error string, suitable to surface verbatim.
    case server(code: Int, message: String)

    /// Anything else — JSON decode failures, malformed bodies, unknown
    /// `URLError` codes. `description` is for diagnostics, not UI.
    case unknown(description: String)
}
