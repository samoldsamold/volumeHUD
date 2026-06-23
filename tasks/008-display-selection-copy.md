# Display Selection Copy Implementation Plan

**Goal:** Replace the confusing `HUD Follows Mouse` setting text with clearer display-selection copy.

**Architecture:** `AboutView` continues to own the visible settings copy. A source-level Swift test verifies the old label is gone, the new title/subtitles are present, and the existing preference key/default remain unchanged.

**Tech Stack:** SwiftUI, command-line Swift source test, Xcode no-sign builds.

---

Status: Completed
Spec: `specs/008-display-selection-copy.md`
Owner: Codex

## Acceptance Criteria Coverage

- AC1: Covered by `tests/DisplaySelectionCopyTests.swift`, checking `AboutView.swift` does not contain `Text("HUD Follows Mouse")`.
- AC2: Covered by `tests/DisplaySelectionCopyTests.swift`, checking `Text("Use Mouse Display")`.
- AC3: Covered by `tests/DisplaySelectionCopyTests.swift`, checking `Show HUD on the display with cursor`.
- AC4: Covered by `tests/DisplaySelectionCopyTests.swift`, checking `Show HUD on the primary display`.
- AC5: Covered by `tests/DisplaySelectionCopyTests.swift`, checking `@AppStorage("volumeHUDFollowsMouse")` and `HUDPreferences.originalAuthorVolumeHUDFollowsMouse`.
- AC6: Covered by the focused command-line Swift test.

## Implementation Steps

- [x] Create `specs/008-display-selection-copy.md`.
- [x] Create this task plan.
- [x] Write failing test in `tests/DisplaySelectionCopyTests.swift`.
- [x] Run RED test and record expected failure.
- [x] Replace the display-selection title and subtitles in `volumeHUD/AboutView.swift`.
- [x] Update `CHANGELOG.md` and `docs/CHANGE_SUMMARY.md`.
- [x] Run GREEN focused test.
- [x] Run Xcode builds for normal and sandbox schemes.
- [x] Run `git diff --check`.
- [x] Run spec compliance review and code quality review.
- [x] Record verification output.

## Planned Commands

```bash
xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests
xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO
xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO
git diff --check
```

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests` | 1 | `FAIL: legacy ambiguous display selection title: unexpected Text("HUD Follows Mouse")` |
| GREEN `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests` | 0 | `PASS: display selection title describes display behavior`; `PASS: display selection subtitles explain enabled and disabled states`; `PASS: display selection behavior keys remain unchanged`; `All DisplaySelectionCopy tests passed.` |
| Regression `xcrun swiftc -parse-as-library tests/AboutAttributionTests.swift -o /tmp/volumeHUD-about-attribution-tests && /tmp/volumeHUD-about-attribution-tests` | 0 | `All AboutAttribution tests passed.` |
| Regression `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `All HUDViewSurface tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftDriverJobDiscovery normal arm64 Compiling AboutView.swift`; `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftCompile normal arm64 /Users/zyyzyy_51674/Documents/volumeHUD/volumeHUD/AboutView.swift`; `** BUILD SUCCEEDED **` |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Debug app restart | 0 | `Stopping volumeHUD processes: 24206`; `Running volumeHUD processes: 50200` |
| `git diff --check` | 0 | No output. |

## Review Log

### Spec Compliance Review

- AC1 passed: `DisplaySelectionCopyTests` rejects `Text("HUD Follows Mouse")`, and the focused test passes.
- AC2 passed: `volumeHUD/AboutView.swift` displays `Text("Use Mouse Display")`.
- AC3 passed: enabled subtitle is `Show HUD on the display with cursor`.
- AC4 passed: disabled subtitle is `Show HUD on the primary display`.
- AC5 passed: the test verifies `@AppStorage("volumeHUDFollowsMouse")` and `HUDPreferences.originalAuthorVolumeHUDFollowsMouse` remain unchanged.
- AC6 passed: the focused source-level test covers old and new display-selection copy.

### Code Quality Review

- Passed: the change is limited to user-facing copy in the existing display-selection row and related documentation.
- Passed: no behavior, preference keys, icons, layout, or default values were changed.
- Passed: the new title is shorter than the originally considered alternatives and fits the existing settings column better.
