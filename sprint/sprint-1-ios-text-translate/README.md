# Sprint 1 — iOS Dashka · text-translate

**Scope:** text translation end-to-end against `dashka-chatpl-api.vercel.app`.
**Parity target:** Android Dashka Sprint 1.
**Deployment target:** iOS 17+.

---

## What this sprint delivers (functional)

- Text input pane, output pane, direction toggle (RU ↔ PL)
- Translate button → `POST /api/translate` → render result
- Error banner with dismiss
- Clear button
- REC-001 `X-Dashka-Token` header injection (if token configured)
- REC-004 10-second timeout
- REC-005 — server-side language validation (clients send canonical codes)

## What this sprint declares but does not implement

Forward-compatibility hooks so Sprint 2-4 won't need breaking changes:

| Foundation | File | Future sprint |
|---|---|---|
| `MicState` enum | `Domain/Model/MicState.swift` | 2A (STT) |
| `TtsState` enum | `Domain/Model/TtsState.swift` | 3A (TTS playback) |
| `TtsVoice` enum + `PaneState.voice` | `Domain/Model/TtsVoice.swift` | 3B (voice picker) |
| `PaneState.autoplayEnabled` | `Domain/Model/PaneState.swift` | 3C (autoplay) |
| `ShareMode` enum | `Domain/Model/ShareMode.swift` | 4B (share popover) |
| `PaneState.isPreparingShareVoice` | `Domain/Model/PaneState.swift` | 4B (share async prep) |
| `HistoryEntry`, `HistorySnapshot` | `Data/History/*.swift` | 4C (history sheet) |

None of these are wired into the ViewModel in Sprint 1 — they sit as
schema and types only. The Sprint 1 `TranslatorIntent` has only the
5 text-translate cases.

## What is intentionally NOT in this sprint

- `SFSpeechRecognizer` / mic permission flow
- `AVAudioPlayer` / TTS playback
- `TtsCache`
- `UserDefaults` voice/autoplay persistence
- `HistoryStorage` (no `FileManager` writes in Sprint 1)
- Voice picker UI / autoplay switch / share popover / history sheet
- Copy / paste handlers
- Feature flags / Tier gating

These land in their designated sprints, following the same rollout that
Android went through (visible in the comments throughout
`TranslatorIntent.kt` v0.4.6).

---

## File layout

```
Dashka/
├── DashkaApp.swift                          @main entry
├── AppContainer.swift                       manual DI
│
├── Domain/
│   ├── Model/
│   │   ├── LangCode.swift                  full 11 langs (mirror Android)
│   │   ├── Direction.swift                 RU↔partner + toggled()
│   │   ├── PaneState.swift                 all Sprint 1-4 fields, forward-compat
│   │   ├── TranslationResult.swift         domain result
│   │   ├── TtsVoice.swift                  foundation enum (no audio yet)
│   │   ├── MicState.swift                  foundation
│   │   ├── TtsState.swift                  foundation
│   │   └── ShareMode.swift                 foundation
│   ├── Repository/
│   │   └── TranslationRepository.swift     protocol
│   └── UseCase/
│       └── TranslateUseCase.swift          callAsFunction
│
├── Data/
│   ├── Api/
│   │   ├── DashkaApi.swift                 actor + URLSession + REC-001 + REC-004
│   │   ├── DashkaResult.swift              DashkaResult<T> + DashkaError
│   │   └── DTO/
│   │       ├── TranslateRequest.swift      snake_case CodingKeys
│   │       ├── TranslateResponse.swift     snake_case CodingKeys
│   │       ├── HealthResponse.swift
│   │       └── ErrorEnvelope.swift
│   ├── Repository/
│   │   └── TranslationRepositoryImpl.swift NSError → DashkaError mapping
│   └── History/
│       ├── HistoryEntry.swift              foundation (Sprint 4C)
│       └── HistorySnapshot.swift           foundation (Sprint 4C)
│
├── Presentation/
│   ├── Theme/
│   │   ├── DashkaColors.swift              system-aware + brand orange
│   │   └── DashkaTheme.swift               typography presets
│   └── Translator/
│       ├── TranslatorIntent.swift          Sprint 1 cases only
│       ├── TranslatorViewModel.swift       @Observable, @MainActor
│       └── TranslatorScreen.swift          SwiftUI screen
│
└── Resources/
    └── Info.plist                          xcconfig→runtime bridge

Configs/
├── Debug.xcconfig                          DASHKA_BASE_URL/TOKEN/PARTNER_LANG
└── Release.xcconfig
```

**Total: 26 Swift + 1 Info.plist + 2 xcconfig + 1 README + 1 manifest = 31 files.**

---

## How to apply this sprint

This archive is shaped for **`solar-apply-swift-v1`** (Council-validated 30
May 2026):

### One-time project setup (manual, operator)

The sprint archive does not contain an `.xcodeproj` — Xcode projects are
machine-generated and per-developer. Set up once:

1. Xcode → New → App → name `Dashka`, language Swift, interface SwiftUI,
   deployment target **iOS 17.0**, **no** "Use Core Data", **no** tests
   (Sprint 1 has no unit tests).
2. In project settings → Build Settings → search `xcconfig`, set the
   project's **Configurations** to point Debug → `Configs/Debug.xcconfig`,
   Release → `Configs/Release.xcconfig`.
3. Build Settings → search `Info.plist File` → set to
   `Dashka/Resources/Info.plist`.
4. Close Xcode.

### Apply the sprint (every sprint)

From the project root (the directory containing `Dashka.xcodeproj`):

```bash
node ../solar-apply-swift-v1/solar-apply-swift.js \
    sprint-1-ios-text-translate.tar.gz
```

The installer will:

1. Pre-audit (NEW × 25, since this is the first sprint)
2. Backup nothing (no existing files to overwrite)
3. Apply files into `Dashka/` and `Configs/`
4. Run `xcodebuild -list` (read-only validation if Xcode CLT available)
5. Print next manual Xcode steps

### After apply — manual Xcode work

1. Open `Dashka.xcodeproj` in Xcode.
2. Drag the `Dashka/` and `Configs/` directories from Finder into the
   Project Navigator → **Create groups**, **Add to targets: Dashka**.
3. Verify each `.swift` file shows the app target in the File Inspector
   (right pane).
4. **⌘B Build** — first compile catches any signature drift.
5. **⌘R Run** — text translate against production Vercel backend
   (no token = guard disabled, free local testing).

---

## Verifying Sprint 1 manually

Acceptance:

- [ ] App launches without crash
- [ ] Default direction is RU → 🇵🇱
- [ ] Typing in input enables Translate button
- [ ] Tapping Translate hits `dashka-chatpl-api.vercel.app/api/translate`
- [ ] Response shows in output pane
- [ ] Direction toggle swaps source/target, clears both panes
- [ ] Clear button empties both panes
- [ ] Airplane-mode → translate → "Нет подключения к интернету."
- [ ] No mic permission prompt (Sprint 2A territory)
- [ ] No TTS play button visible (Sprint 3A territory)

---

## Out-of-scope reminders for council audit

- ❌ No history persistence — `HistorySnapshot` is type-only
- ❌ No `UserDefaults` writes
- ❌ No `FileManager` writes
- ❌ No share/copy/paste
- ❌ No autoplay
- ❌ No voice picker UI

Any of these appearing in code = escalation trigger (Sprint scope violation).
