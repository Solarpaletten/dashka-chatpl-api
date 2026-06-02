import Foundation

/// Networking actor for the Dashka backend (post-REC-001…005 deployment).
///
/// Sprint 1 uses only `translate(...)`. `tts(...)` and `health(...)` are
/// declared so the API surface mirrors Android's `DashkaApi.kt` exactly and
/// later sprints (3A — TTS, ops — health) need only call, not extend.
///
/// **Authentication (REC-001):** every request gets the `X-Dashka-Token`
/// header injected if `Bundle.main.dashkaApiToken` is non-nil. The header is
/// never logged.
///
/// **Timeout (REC-004):** 10 seconds per request via `URLRequest.timeoutInterval`.
/// Mirrors Android's `OkHttpClient.callTimeout(10, SECONDS)`.
///
/// **Error mapping:** non-2xx responses are decoded as `ErrorEnvelope` and
/// surfaced as `DashkaError.server(code, message)` so the UI layer can
/// pattern-match without inspecting raw `Error`s.
actor DashkaApi {
    private let baseURL: URL
    private let token: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, token: String?, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token   = token
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Endpoints

    func translate(_ request: TranslateRequest) async throws -> TranslateResponse {
        let body = try encoder.encode(request)
        let req  = buildRequest(path: "api/translate", method: "POST", body: body)
        return try await perform(req)
    }

    /// Returns raw MP3 bytes. Used by Sprint 3A TTS playback.
    func tts(_ request: TtsRequest) async throws -> Data {
        let body = try encoder.encode(request)
        let req  = buildRequest(path: "api/tts", method: "POST", body: body)
        let (data, response) = try await session.data(for: req)
        try validateBinary(response: response, data: data)
        return data
    }

    func health() async throws -> HealthResponse {
        let req = buildRequest(path: "api/health", method: "GET", body: nil)
        return try await perform(req)
    }

    // MARK: - Internals

    /// Builds a `URLRequest` with:
    ///   - JSON content type (when body is non-nil)
    ///   - `X-Dashka-Token` header if token configured (REC-001)
    ///   - 10s timeout (REC-004)
    ///
    /// Mirrors Android `DashkaTokenInterceptor.kt` — same shape, different
    /// platform mechanics (URLRequest vs OkHttp `Chain.proceed`).
    private func buildRequest(path: String, method: String, body: Data?) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod        = method
        req.timeoutInterval   = 10.0  // REC-004
        req.httpBody          = body
        if body != nil {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token, !token.isEmpty {
            req.setValue(token, forHTTPHeaderField: "X-Dashka-Token")  // REC-001
        }
        return req
    }

    private func perform<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: req)
        } catch let urlError as URLError {
            throw map(urlError: urlError)
        }
        try validateBinary(response: response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NSError(
                domain: "DashkaApi.decode",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Decode failed: \(error)"]
            )
        }
    }

    /// Common HTTP status validation. On non-2xx, attempts to decode an
    /// `ErrorEnvelope` and throws a structured `NSError` whose `code` is
    /// the HTTP status — the repository layer translates this into
    /// `DashkaError.server` / `.unauthorized`.
    private func validateBinary(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "DashkaApi.transport", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Non-HTTP response"])
        }
        if (200..<300).contains(http.statusCode) { return }

        // Try to lift the backend's structured error message.
        let envelope = try? decoder.decode(ErrorEnvelope.self, from: data)
        let message  = envelope?.message
            ?? String(data: data, encoding: .utf8)
            ?? "HTTP \(http.statusCode)"

        throw NSError(
            domain: "DashkaApi.http",
            code: http.statusCode,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    /// Map `URLError` codes to lightweight `NSError`s the repository layer
    /// then translates into `DashkaError`. Keeping the mapping here means
    /// only the API layer touches `URLError` — repositories stay platform-
    /// agnostic.
    private func map(urlError: URLError) -> NSError {
        let domain: String
        switch urlError.code {
        case .timedOut:
            domain = "DashkaApi.timeout"
        case .notConnectedToInternet, .networkConnectionLost,
             .cannotConnectToHost, .dnsLookupFailed:
            domain = "DashkaApi.network"
        default:
            domain = "DashkaApi.urlerror"
        }
        return NSError(
            domain: domain,
            code: urlError.code.rawValue,
            userInfo: [NSLocalizedDescriptionKey: urlError.localizedDescription]
        )
    }
}

// MARK: - TtsRequest DTO (declared here for cross-sprint cohesion)
//
// Sprint 3A wires this in. Declared in Sprint 1 so `DashkaApi.tts(...)` is
// type-safe from day one. The body shape matches `app/api/tts/route.ts`.
struct TtsRequest: Encodable, Sendable {
    let text: String
    let language: String  // lowercase ISO 639-1
    let voice: String     // one of: eve|leo|ara|rex|sal
}
