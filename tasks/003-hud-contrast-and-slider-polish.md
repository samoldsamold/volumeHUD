# HUD Contrast And Slider Polish Implementation Plan

**Goal:** Improve HUD value bar contrast and visual consistency, and remove native tick-like marks from the settings sliders.

**Architecture:** `HUDVisualStyle` owns HUD foreground opacity tokens. `HUDSliderInteraction` owns testable slider value mapping and keyboard-step behavior. `HUDView` consumes visual tokens for the icon and value bars. `AboutView` keeps the existing settings row structure but replaces native `Slider` with a local `CleanHUDSlider` to remove tick marks while preserving bindings, live preview, keyboard adjustment, and accessibility labels.

**Tech Stack:** Swift 6, SwiftUI, command-line Swift tests with `xcrun swiftc`, Xcode no-sign builds.

---

Status: Approved by user delegation
Spec: `specs/003-hud-contrast-and-slider-polish.md`
Owner: Codex

## Acceptance Criteria Covered

- AC1: HUD icons and filled bars use the same foreground opacity token.
- AC2: Empty and muted bars use a stronger inactive opacity token than the previous `0.2`.
- AC3: Partial bars use inactive opacity for the background and filled opacity for the foreground.
- AC4: Settings slider rows no longer use native `Slider`.
- AC5: Replacement sliders preserve range clamping, pointer interaction, keyboard adjustment, and row-specific accessibility labels.
- AC6: Automated checks cover HUD style tokens and source-level UI wiring.

## File Structure

- Create `volumeHUD/HUDVisualStyle.swift`: foreground opacity tokens.
- Modify `volumeHUD/HUDView.swift`: consume `HUDVisualStyle`.
- Modify `volumeHUD/AboutView.swift`: add `CleanHUDSlider` and replace native `Slider`.
- Create `volumeHUD/HUDSliderInteraction.swift`: testable slider location mapping and keyboard adjustment.
- Create `tests/HUDVisualStyleTests.swift`: unit tests for visual tokens.
- Create `tests/HUDSliderInteractionTests.swift`: unit tests for slider location mapping and keyboard adjustment.
- Modify `tests/HUDViewSurfaceTests.swift`: static source tests for token usage and slider replacement.
- Add this task file and `specs/003-hud-contrast-and-slider-polish.md`.

## Implementation Steps

- [x] Read the current HUD/settings implementation and relevant tests.
- [x] Write SPEC-003 and this plan.
- [x] Write RED tests for `HUDVisualStyle`.
- [x] Write RED static regression tests for `HUDView` token usage and `AboutView` slider replacement.
- [x] Implement `HUDVisualStyle`.
- [x] Update `HUDView` to use shared foreground tokens for icon, filled bars, partial bars, empty bars, and muted bars.
- [x] Update `AboutView` with `CleanHUDSlider` and remove native `Slider` from `HUDSliderSetting`.
- [x] Add review RED tests for row-specific accessibility labels and testable slider interaction.
- [x] Implement `HUDSliderInteraction`.
- [x] Update `CleanHUDSlider` with row-specific accessibility labels, focus support, and arrow-key adjustment.
- [x] Run command-line tests.
- [x] Run both Xcode builds.
- [x] Run spec compliance review and code quality review.
- [x] Run final `git diff --check`, restart app, and record evidence below.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 1 | `error opening input file 'volumeHUD/HUDVisualStyle.swift' (No such file or directory)` |
| RED `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `PASS: glass style exposes no unused custom chrome policy`; `FAIL: icon foreground token: missing HUDVisualStyle.iconOpacity` |
| GREEN `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 0 | `PASS: filled bars match icon foreground strength`; `All HUDVisualStyle tests passed.` |
| Static test correction `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | Initial static check was too broad and matched `CleanHUDSlider(value:)`; fixed the assertion to reject only native `Slider(value:)`. |
| GREEN `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: HUD icon and bars use shared visual style tokens`; `PASS: settings sliders use clean custom track without native tick marks`; `All HUDViewSurface tests passed.` |
| Review RED `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 1 | `error opening input file 'volumeHUD/HUDSliderInteraction.swift' (No such file or directory)` |
| Review RED `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 1 | `PASS: HUD icon and bars use shared visual style tokens`; `FAIL: slider accessibility title: missing title: title` |
| Review GREEN `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 0 | `PASS: track locations map to clamped range values`; `PASS: keyboard adjustments step and clamp values`; `All HUDSliderInteraction tests passed.` |
| Review GREEN `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: HUD icon and bars use shared visual style tokens`; `PASS: settings sliders use clean custom track without native tick marks`; `All HUDViewSurface tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: default HUD size keeps current 200 px window at 30 percent`; `All HUDPreferences tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses SwiftUI Liquid Glass renderer when enabled`; `All HUDGlassStyle tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 0 | `PASS: filled bars match icon foreground strength`; `All HUDVisualStyle tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 0 | `PASS: track locations map to clamped range values`; `All HUDSliderInteraction tests passed.` |
| Final `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: HUD icon and bars use shared visual style tokens`; `PASS: settings sliders use clean custom track without native tick marks`; `All HUDViewSurface tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `PASS: glass toggle refreshes content`; `All HUDContentRefreshPolicy tests passed.` |
| Final `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: numeric percent input converts to unit values`; `All HUDPercentageValue tests passed.` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `** BUILD SUCCEEDED **` |
| Final normal-app rebuild/restart | 0 | `bundle=com.dannystewart.volumehud.debug`; `Started Debug volumeHUD process: 61562`; `hudSize=0.3`; `hudVerticalPosition=0.5`; `hudOpacity=1`; `hudGlassEffectEnabled=1` |
| Final `git diff --check` | 0 | No output. |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Code quality re-review agent | 0 | `No new code-quality findings in the reviewed files.` |
| Spec compliance review | 0 | Local AC review passed: AC1-AC3 are covered by `HUDVisualStyle` usage in `HUDView`; AC4-AC5 are covered by `CleanHUDSlider` plus `HUDSliderInteraction`; AC6 is covered by `HUDVisualStyleTests`, `HUDSliderInteractionTests`, and `HUDViewSurfaceTests`. The original spec-review agent timed out, then later returned `not_found`, so no agent finding is recorded. |
