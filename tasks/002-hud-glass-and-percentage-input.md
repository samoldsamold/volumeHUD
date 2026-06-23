# Optional HUD Glass Effect And Editable Percentages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional native HUD glass background and direct numeric percentage editing for existing HUD appearance sliders.

**Architecture:** `HUDPreferences` owns the persisted glass toggle. `HUDGlassStyle` stores the renderer choice and scaled corner radius. `HUDView` applies SwiftUI Liquid Glass directly to the HUD content with a continuous rounded rectangle shape, and keeps `.regularMaterial` as the disabled fallback. `HUDContentRefreshPolicy` keeps HUD content rebuild decisions testable. `HUDPercentageValue` keeps the numeric percentage text-field conversion testable. `AboutView`, `HUDView`, and `HUDController` wire those units into the settings UI and live preview path.

**Tech Stack:** Swift 6, SwiftUI Liquid Glass, UserDefaults, command-line Swift tests with `xcrun swiftc`, Xcode no-sign builds.

---

Status: Approved by user delegation
Spec: `specs/002-hud-glass-and-percentage-input.md`
Owner: Codex

## Acceptance Criteria Covered

- AC1: `hudGlassEffectEnabled` default and explicit stored values.
- AC2: Native SwiftUI Liquid Glass renderer configuration.
- AC3: Classic `.regularMaterial` fallback when glass is disabled.
- AC4: `HUDController` refreshes content when glass state changes.
- AC5: Settings toggle plus live preview.
- AC6: Slider rows include editable numeric percentage fields.
- AC7: Numeric percentage edits clamp and store unit values.
- AC8: README documents the optional glass effect and editable percentages.
- AC9: Automated command-line tests cover preference, glass style, content refresh, and percentage conversion behavior.
- AC10: Glass HUD avoids square-corner artifacts and gray/dirty custom tinting by delegating the surface to system-shaped Liquid Glass.

## File Structure

- Modify `volumeHUD/HUDPreferences.swift`: add `glassEffectEnabledKey`, default enabled value, and stored reader.
- Create `volumeHUD/HUDGlassStyle.swift`: testable glass renderer selection and scaled corner radius.
- Create `volumeHUD/HUDContentRefreshPolicy.swift`: testable HUD content refresh decision helper.
- Create `volumeHUD/HUDPercentageValue.swift`: testable formatting and percent-to-unit conversion helper for settings fields.
- Modify `volumeHUD/HUDView.swift`: accept `glassEffectEnabled`, choose glass or classic material background, and keep scaled sizing.
- Modify `volumeHUD/HUDController.swift`: pass stored glass preference to `HUDView` and refresh when it changes.
- Modify `volumeHUD/AboutView.swift`: add glass toggle, editable percentage fields, and live preview on edits.
- Modify `volumeHUD/VolumeHUDApp.swift`: increase settings panel height enough for the new row.
- Modify `README.md`: document optional glass and direct percentage editing.
- Modify `tests/HUDPreferencesTests.swift`: add glass preference tests.
- Create `tests/HUDGlassStyleTests.swift`: test Liquid Glass renderer selection and scaled corner radius.
- Create `tests/HUDViewSurfaceTests.swift`: static regression tests for the actual `HUDView` glass and fallback surface branches.
- Create `tests/HUDContentRefreshPolicyTests.swift`: test content refresh decisions including glass toggles.
- Create `tests/HUDPercentageValueTests.swift`: test numeric percentage formatting and clamping.

## Implementation Steps

- [x] Read `AGENTS.md`, `specs/001-hud-position-opacity.md`, `specs/002-hud-glass-and-percentage-input.md`, and this task file.
- [x] Write RED tests in `tests/HUDPreferencesTests.swift`, `tests/HUDGlassStyleTests.swift`, and `tests/HUDPercentageValueTests.swift`.
- [x] Run the three `xcrun swiftc` commands and record expected failures before production helpers exist.
- [x] Implement `HUDPreferences` glass preference reader.
- [x] Implement `HUDGlassStyle`, `HUDContentRefreshPolicy`, and `HUDPercentageValue`.
- [x] Update `HUDView` to select native glass or classic material based on `glassEffectEnabled`.
- [x] Update `HUDController` to pass and track glass state for live preview refresh.
- [x] Update `AboutView` with `HUD Glass Effect` toggle and numeric percentage fields.
- [x] Resize the settings panel in `VolumeHUDApp.swift`.
- [x] Update `README.md`.
- [x] Add RED tests for light-mode glass contrast tokens in `tests/HUDGlassStyleTests.swift`.
- [x] Implement adaptive light/dark glass contrast in `HUDGlassStyle` and `HUDView`.
- [x] Add RED regression tests proving light-mode glass uses no dirty surface tint.
- [x] Remove the light-mode glass surface scrim while keeping edge/shadow separation.
- [x] Research Apple Liquid Glass guidance for custom macOS glass surfaces.
- [x] Add RED regression tests proving enabled glass uses SwiftUI Liquid Glass and no custom chrome.
- [x] Replace the legacy `NSVisualEffectView` background bridge with SwiftUI `.glassEffect(.regular, in:)`.
- [x] Delete the old `HUDGlassBackground` bridge.
- [x] Add RED static regression tests for the actual `HUDView` glass and fallback surface branches.
- [x] Remove unused glass chrome policy after code quality review.
- [x] Run spec compliance review, fix findings, and re-review.
- [x] Run code quality review, fix findings, and re-review.
- [x] Run final verification commands and record actual output below.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 1 | `type 'HUDPreferences' has no member 'storedGlassEffectEnabled'`; `type 'HUDPreferences' has no member 'glassEffectEnabledKey'` |
| RED `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 1 | `error opening input file 'volumeHUD/HUDGlassStyle.swift' (No such file or directory)` |
| RED `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 1 | `error opening input file 'volumeHUD/HUDPercentageValue.swift' (No such file or directory)` |
| GREEN `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| GREEN `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses native HUD material`; `All HUDGlassStyle tests passed.` |
| GREEN `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: numeric percent input clamps to supported range`; `All HUDPercentageValue tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Spec compliance review | 0 | `SPEC COMPLIANT` |
| Code quality review, first pass | 1 | Important finding fixed: fractional percentage input stored hidden non-rounded state. |
| RED regression `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 1 | `FAIL: fractional percent rounds to whole percent before storing: expected 0.31, got 0.307` |
| GREEN regression `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Re-run `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Re-run `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass corner radius scales with HUD size`; `All HUDGlassStyle tests passed.` |
| Code quality re-review | 0 | `CODE QUALITY APPROVED` |
| Final `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses native HUD material`; `All HUDGlassStyle tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| Final `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Final `git diff --check` | 0 | No output. |
| Light-background RED `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 1 | `type 'HUDGlassStyle' has no member 'surfaceScrimOpacity'` |
| Light-background GREEN `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: light mode glass adds separation from white backgrounds`; `PASS: dark mode glass preserves subtle approved appearance`; `All HUDGlassStyle tests passed.` |
| Review-fix `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: disabled glass preserves classic fallback chrome`; `All HUDGlassStyle tests passed.` |
| Review-fix `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `PASS: glass toggle refreshes content`; `All HUDContentRefreshPolicy tests passed.` |
| Light-background re-run `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Light-background re-run `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Light-background concurrent `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 65 | `database is locked Possibly there are two concurrent builds running in the same filesystem location.` |
| Light-background concurrent `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Light-background sequential `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Review-fix `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Review-fix `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Review-fix `git diff --check` | 0 | No output. |
| Review-fix `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Review-fix `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Spec compliance re-review | 0 | `SPEC COMPLIANT` |
| Code quality re-review after light-background fix | 0 | `CODE QUALITY APPROVED` |
| Final light-background `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Final light-background `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: disabled glass preserves classic fallback chrome`; `All HUDGlassStyle tests passed.` |
| Final light-background `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `PASS: glass toggle refreshes content`; `All HUDContentRefreshPolicy tests passed.` |
| Final light-background `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Final light-background `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final light-background `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final light-background `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| Final light-background `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Final light-background `git diff --check` | 0 | No output. |
| No-dirty-glass RED `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 1 | `FAIL: light surface scrim: expected 0.0, got 0.1` |
| No-dirty-glass GREEN `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: light mode glass separates without dirty surface tint`; `All HUDGlassStyle tests passed.` |
| No-dirty-glass review | 0 | Spec/code self-review passed for AC1-AC10; subagent review was attempted but blocked by usage quota. |
| No-dirty-glass final `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| No-dirty-glass final app restart | 0 | `Stopping existing volumeHUD processes: 26165`; `Started volumeHUD processes: 68671`; `hudSize=0.3`; `hudVerticalPosition=0.5`; `hudOpacity=1`; `hudGlassEffectEnabled=1` |
| No-dirty-glass final `git diff --check` | 0 | No output. |
| Liquid Glass renderer RED `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 1 | `type 'HUDGlassStyle' has no member 'renderMode'`; `type 'HUDGlassStyle' has no member 'RenderMode'` |
| Liquid Glass renderer GREEN `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses SwiftUI Liquid Glass renderer when enabled`; `PASS: light mode glass delegates tinting and edges to system glass`; `All HUDGlassStyle tests passed.` |
| Liquid Glass renderer build `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| View surface RED compile attempt `xcrun swiftc tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `'main' attribute cannot be used in a module that contains top-level code`; corrected by adding `-parse-as-library`. |
| View surface RED `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `PASS: enabled glass branch uses shaped SwiftUI Liquid Glass`; `PASS: classic material branch keeps regular material fallback`; `FAIL: dead chrome policy: unexpected SurfaceConfiguration` |
| View surface GREEN `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: enabled glass branch uses shaped SwiftUI Liquid Glass`; `PASS: classic material branch keeps regular material fallback`; `PASS: glass style exposes no unused custom chrome policy`; `All HUDViewSurface tests passed.` |
| Final shaped glass `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: stored glass effect honors explicit false`; `All HUDPreferences tests passed.` |
| Final shaped glass `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses SwiftUI Liquid Glass renderer when enabled`; `All HUDGlassStyle tests passed.` |
| Final shaped glass `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: enabled glass branch uses shaped SwiftUI Liquid Glass`; `PASS: glass style exposes no unused custom chrome policy`; `All HUDViewSurface tests passed.` |
| Final shaped glass `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `PASS: glass toggle refreshes content`; `All HUDContentRefreshPolicy tests passed.` |
| Final shaped glass `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: fractional percent input rounds before storing`; `All HUDPercentageValue tests passed.` |
| Final shaped glass `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final shaped glass `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final shaped glass spec compliance review | 0 | `SPEC COMPLIANT`; no spec issues found after the SwiftUI Liquid Glass replacement. |
| Final shaped glass code quality review | 0 | First pass found dead-policy test coverage risk; fixed by adding `HUDViewSurfaceTests` and deleting unused custom chrome policy; re-review approved. |
| Final shaped glass `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| Final shaped glass `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Final shaped glass `git diff --check` | 0 | No output. |
| Final shaped glass app restart | 0 | `No existing volumeHUD process found.`; `Started volumeHUD processes: 45060`; `hudSize=0.3`; `hudVerticalPosition=0.5`; `hudOpacity=1`; `hudGlassEffectEnabled=1` |
