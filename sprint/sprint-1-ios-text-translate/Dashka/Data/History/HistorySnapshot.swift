import Foundation

/// **Foundation for Sprint 4C.** Versioned wrapper around the history
/// entries list, persisted as a single JSON blob to `Documents/`.
///
/// Per architect direction: store `schemaVersion` from day 1 so future
/// migrations (cloud sync, AI memory, embeddings, summaries) don't run
/// into "storage hell". Adding fields later is fine — adding versioning
/// later is painful.
///
/// **Sprint 1 status:** declared but no persistence flow exists yet.
///
/// Mirrors Android `HistorySnapshot.kt`.
struct HistorySnapshot: Codable, Sendable, Equatable {
    let schemaVersion: Int
    let entries: [HistoryEntry]

    init(
        schemaVersion: Int = Self.currentSchemaVersion,
        entries: [HistoryEntry] = []
    ) {
        self.schemaVersion = schemaVersion
        self.entries       = entries
    }

    /// Sprint 4C: v1 = `entries` is `[HistoryEntry]`, newest first.
    /// When schema changes (adding `tags`, `pinned`, `cloudId`), bump this
    /// and add a migration branch in `HistoryStorage.parse(...)`.
    static let currentSchemaVersion: Int = 1

    /// Rolling cap — newest entries kept, older dropped on `save(...)`.
    /// Per architect direction: Lite is "recent conversation memory",
    /// not enterprise archive. Increased only in AdvancedHistory Pro feature.
    static let maxEntries: Int = 30
}
