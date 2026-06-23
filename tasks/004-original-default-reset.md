# Original Default Reset Implementation Plan

**Goal:** Add a `Set to Default` action that restores adjustable HUD appearance settings to the original author's defaults.

**Architecture:** `HUDPreferences` owns the original-author default constants and height conversion. `AboutView` owns the settings-page action and screen selection needed to convert original bottom-origin placement into the current center-position slider value. Existing preview behavior remains through `showHUDPreview()`.

**Tech Stack:** Swift 6, SwiftUI, command-line Swift tests with `xcrun swiftc`, Xcode no-sign builds.

---

Status: Approved by user request
Spec: `specs/004-original-default-reset.md`
Owner: Codex

## Implementation Steps

- [x] Write RED tests for original-author default conversion and settings-page reset wiring.
- [x] Implement original-author default constants and conversion in `HUDPreferences`.
- [x] Add the `Set to Default` button and reset action in `AboutView`.
- [x] Run focused GREEN tests.
- [x] Run regression tests and Xcode builds.
- [x] Restart the Debug app and record evidence.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 1 | `type 'HUDPreferences' has no member 'originalAuthorDefaultSize'` |
| RED `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `FAIL: reset button label: missing Set to Default` |
| GREEN `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: original author defaults restore lower HUD placement`; `All HUDPreferences tests passed.` |
| GREEN `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: settings page exposes original defaults reset`; `All HUDViewSurface tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `All HUDGlassStyle tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 0 | `All HUDVisualStyle tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 0 | `All HUDSliderInteraction tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `All HUDContentRefreshPolicy tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `All HUDPercentageValue tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final normal-app rebuild/restart | 0 | `** BUILD SUCCEEDED **`; `Started Debug volumeHUD process: 38893`; `bundle=com.dannystewart.volumehud.debug` |
| `git diff --check` | 0 | No output. |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Spec compliance review | 0 | Local AC review passed: AC1 covered by `HUDPreferences` constants/conversion; AC2-AC4 covered by `AboutView` reset button/action; AC5 covered by focused tests. |
| Code quality review | 0 | Local review passed: reset is scoped to HUD appearance/placement settings, avoids resetting login or brightness feature state, and reuses the existing preview path. |
