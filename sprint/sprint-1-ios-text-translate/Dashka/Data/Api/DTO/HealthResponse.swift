import Foundation

/// Response from `GET /api/health`.
struct HealthResponse: Decodable, Sendable {
    let status: String
    let version: String
    let timestamp: String
}
