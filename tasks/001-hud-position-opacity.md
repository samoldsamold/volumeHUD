# Adjustable HUD Size Position And Opacity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent HUD size, height, and opacity preferences so the HUD defaults to screen center, keeps the existing 200 px HUD at 30%, and previews live while users adjust appearance.

**Architecture:** `volumeHUD/HUDPreferences.swift` owns preference keys, defaults, clamping, size scaling, and window geometry. `HUDController` reads those preferences for the actual overlay window size, position, and alpha. `HUDView` scales from the 200 px baseline. `AboutView` exposes three persisted sliders and calls the actual HUD controller for live preview.

**Tech Stack:** Swift 6, SwiftUI, AppKit, UserDefaults, Xcode file-system-synchronized groups, command-line Swift tests via `xcrun swiftc`.

---

Status: Approved by user delegation
Spec: `specs/001-hud-position-opacity.md`
Owner: Codex

## Acceptance Criteria Covered

- AC1: Default HUD center position and correct window-origin math.
- AC2: Existing target-screen behavior remains unchanged.
- AC3: `HUD Size` slider, `hudSize` key, default `0.3`, and 30% maps to 200 px.
- AC4: `HUD Height` slider, `hudVerticalPosition` key, default `0.5`.
- AC5: `HUD Opacity` slider, `hudOpacity` key, default `1.0`, minimum `0.2`.
- AC6: HUD window uses stored size and opacity, and fade-out resets to stored opacity.
- AC7: Size, height, and opacity changes show the real HUD overlay as live preview.
- AC8: Visible `Relative HUD Position` setting removed from active UI.
- AC9: README mentions configurable HUD size, position, opacity, and live preview.
- AC10: Command-line tests cover defaults, scaling, and clamping.

## File Structure

- Create `volumeHUD/HUDPreferences.swift`: shared constants, UserDefaults readers, clamping, size scaling, and HUD window rectangle calculation.
- Create `tests/HUDPreferencesTests.swift`: command-line Swift tests for defaults, scaling, and clamping behavior.
- Modify `volumeHUD/HUDController.swift`: use `HUDPreferences` for window size, position, opacity, and live preview.
- Modify `volumeHUD/HUDView.swift`: scale the HUD surface, icon, spacers, bars, and corner radius from the selected HUD size.
- Modify `volumeHUD/AboutView.swift`: remove `useRelativePositioning`, add size, height, and opacity sliders, clamp persisted values, and call live preview on changes.
- Modify `volumeHUD/VolumeHUDApp.swift`: resize the about/settings panel and expose `showHUDPreview()` on `AppDelegate`.
- Modify `README.md`: document configurable HUD size, position, opacity, and live preview.

## Implementation Steps

- [x] Read `AGENTS.md`, `specs/001-hud-position-opacity.md`, this task file, and `docs/adr/0000-template.md`.
- [x] Write failing command-line tests in `tests/HUDPreferencesTests.swift`.
- [x] Run `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` and verify failure before size APIs exist.
- [x] Implement `volumeHUD/HUDPreferences.swift` with `hudSize`, `hudVerticalPosition`, `hudOpacity`, defaults, clamping, size scaling, and window rectangle calculation.
- [x] Run the command-line tests and verify pass output.
- [x] Wire `HUDController` to stored size, height, and opacity preferences.
- [x] Add `HUDController.showPreviewHUD()` for real overlay preview.
- [x] Update `HUDView` to scale from the 200 px baseline.
- [x] Replace the old visible `Relative HUD Position` setting with `HUD Size`, `HUD Height`, and `HUD Opacity` sliders in `AboutView`.
- [x] Call the real HUD preview path when any of the three sliders changes.
- [x] Resize the about/settings panel in `VolumeHUDApp.swift`.
- [x] Update `README.md`.
- [x] Run spec compliance review, fix findings, and re-review.
- [x] Run code quality review, fix findings, and re-review.
- [x] Run final verification commands and record actual output below.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` before `HUDPreferences.swift` existed | 1 | `error opening input file 'volumeHUD/HUDPreferences.swift' (No such file or directory)` |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` before size APIs existed | 1 | `type 'HUDPreferences' has no member 'defaultSize'`; `no member 'windowSideLength'`; `no member 'clampedSize'` |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` after implementation | 0 | `PASS: default vertical position is centered`; `PASS: HUD size scales relative to current 30 percent baseline`; `All HUDPreferences tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug` | 65 | Signing environment failure: `No signing certificate "Mac Development" found... team ID "PL2FTGT24W"` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| `git diff --check` | 0 | No output. |
| Spec compliance review | 0 | `SPEC COMPLIANT` |
| Code quality review, first pass | 1 | Findings fixed: settings panel width, fade-out race, stale size subtitle, and missing UserDefaults reader tests. |
| Code quality re-review | 0 | `CODE QUALITY APPROVED` |
| Final `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests` | 0 | No output. |
| Final `/tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored preferences clamp persisted values`; `All HUDPreferences tests passed.` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| Final `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Final `git diff --check` | 0 | No output. |

## Follow-Up Candidates

- Add horizontal HUD position controls under a separate spec if needed later.
