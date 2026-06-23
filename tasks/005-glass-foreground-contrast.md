# Glass Foreground Contrast Implementation Plan

**Goal:** Keep HUD bars visually consistent with the icon in Liquid Glass mode.

**Architecture:** `HUDView` separates glass rendering from foreground content. A shaped `glassSurface` receives `.glassEffect`, and `hudContent` is layered above it. Existing `HUDVisualStyle` tokens still control foreground opacity.

**Tech Stack:** Swift 6, SwiftUI, command-line Swift tests with `xcrun swiftc`, Xcode no-sign builds.

---

Status: Approved by bug report
Spec: `specs/005-glass-foreground-contrast.md`
Owner: Codex

## Implementation Steps

- [x] Write RED static test for Liquid Glass/content separation.
- [x] Implement `glassSurface` layering in `HUDView`.
- [x] Run focused GREEN tests.
- [x] Run regression tests and Xcode builds.
- [x] Restart Debug app and record evidence.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `FAIL: glass branch layers: missing ZStack` |
| GREEN `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: enabled glass branch uses shaped SwiftUI Liquid Glass`; `All HUDViewSurface tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `All HUDPreferences tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `All HUDGlassStyle tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 0 | `All HUDVisualStyle tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 0 | `All HUDSliderInteraction tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `All HUDContentRefreshPolicy tests passed.` |
| Regression `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `All HUDPercentageValue tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final normal-app rebuild/restart | 0 | `** BUILD SUCCEEDED **`; `Started Debug volumeHUD process: 59109`; `bundle=com.dannystewart.volumehud.debug`; `hudGlassEffectEnabled=1` |
| `git diff --check` | 0 | No output. |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Visual capture attempt | 0 | Computer Use and full-screen `screencapture` captured the About window, but did not capture the independent HUD overlay. No visual pass claim is made from this attempt. |
| Spec compliance review | 0 | Local AC review passed: `HUDView` now places `glassSurface` and `hudContent` in a `ZStack`; `.glassEffect` lives in `glassSurface`; classic material branch remains separate; source tests cover the layering and foreground tokens. |
| Code quality review | 0 | Local review passed: the fix is scoped to `HUDView`, removes Liquid Glass foreground processing from HUD content, and keeps shared shape/corner-radius handling for both glass and classic paths. |
