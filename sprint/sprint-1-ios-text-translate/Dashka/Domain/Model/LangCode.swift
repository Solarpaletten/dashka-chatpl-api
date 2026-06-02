import Foundation

/// Mirrors the `LangCode` enum from Android `LangCode.kt` and the union from
/// web `features/translator/types.ts`.
///
/// Sprint 1 only uses `.ru` and `.pl`, but the full set is declared so that:
///   - It stays in sync with the backend's `ALLOWED_LANGS` guard (REC-005).
///   - Adding a new partner language later requires no enum change.
///
/// - `rawValue` is the wire format sent to the backend (uppercase ISO-like).
/// - `displayName` is shown in Russian UI labels.
/// - `nativeName` is the language's self-name.
/// - `flag` is a Unicode flag emoji (matches web LANG_META).
/// - `speechLocale` is BCP-47 for `SFSpeechRecognizer` (used in Sprint 2A+).
///
/// Marked `Codable` so `HistoryEntry` (Sprint 4C) can persist by raw value.
enum LangCode: String, Codable, CaseIterable, Sendable {
    case ru = "RU"
    case de = "DE"
    case en = "EN"
    case pl = "PL"
    case zh = "ZH"
    case fr = "FR"
    case it = "IT"
    case es = "ES"
    case lv = "LV"
    case lt = "LT"
    case ua = "UA"

    var displayName: String {
        switch self {
        case .ru: return "Русский"
        case .de: return "Немецкий"
        case .en: return "English"
        case .pl: return "Польский"
        case .zh: return "Китайский"
        case .fr: return "Французский"
        case .it: return "Итальянский"
        case .es: return "Испанский"
        case .lv: return "Латышский"
        case .lt: return "Литовский"
        case .ua: return "Украинский"
        }
    }

    var nativeName: String {
        switch self {
        case .ru: return "Русский"
        case .de: return "Deutsch"
        case .en: return "English"
        case .pl: return "Polski"
        case .zh: return "中文"
        case .fr: return "Français"
        case .it: return "Italiano"
        case .es: return "Español"
        case .lv: return "Latviešu"
        case .lt: return "Lietuvių"
        case .ua: return "Українська"
        }
    }

    var flag: String {
        switch self {
        case .ru: return "🇷🇺"
        case .de: return "🇩🇪"
        case .en: return "🇺🇸"
        case .pl: return "🇵🇱"
        case .zh: return "🇨🇳"
        case .fr: return "🇫🇷"
        case .it: return "🇮🇹"
        case .es: return "🇪🇸"
        case .lv: return "🇱🇻"
        case .lt: return "🇱🇹"
        case .ua: return "🇺🇦"
        }
    }

    /// BCP-47 locale for `SFSpeechRecognizer`. Used in Sprint 2A.
    var speechLocale: String {
        switch self {
        case .ru: return "ru-RU"
        case .de: return "de-DE"
        case .en: return "en-US"
        case .pl: return "pl-PL"
        case .zh: return "zh-CN"
        case .fr: return "fr-FR"
        case .it: return "it-IT"
        case .es: return "es-ES"
        case .lv: return "lv-LV"
        case .lt: return "lt-LT"
        case .ua: return "uk-UA"
        }
    }

    /// Case-insensitive lookup by wire-format code (e.g. "pl", "PL", "Pl").
    /// Mirrors `LangCode.fromCode(...)` in Android.
    static func from(code: String) -> LangCode? {
        Self.allCases.first { $0.rawValue.caseInsensitiveCompare(code) == .orderedSame }
    }
}
