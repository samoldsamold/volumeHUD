# SPEC-003: HUD Contrast And Slider Polish

Status: Approved by user delegation
Owner: Codex
Date: 2026-06-23
Related tasks: `tasks/003-hud-contrast-and-slider-polish.md`

## Goal

Improve HUD legibility in both light and dark appearances by making the value bars visually match the icon/sun foreground, and remove the visible tick-like marks under the settings sliders.

## Non-Goals

- Do not add new user-facing preferences.
- Do not change HUD size, position, opacity, glass, fade timing, media-key handling, or brightness monitoring behavior.
- Do not redesign the settings window or replace the existing numeric percentage fields.

## Design

- Add a small `HUDVisualStyle` helper for testable HUD foreground opacity tokens.
- Use one shared opacity for the HUD icon and filled value bars so the bottom bars match the speaker/sun color strength.
- Increase empty/muted bar opacity enough to remain visible on light and dark glass while staying clearly inactive.
- Replace the native macOS slider in `HUDSliderSetting` with a SwiftUI `CleanHUDSlider`:
  - no native tick marks
  - fixed-height rounded track
  - accent-colored fill
  - compact circular thumb
  - drag and click-to-jump behavior
  - keyboard arrow-key adjustment when focused
  - row-specific accessibility label from the setting title
- Keep each slider row's label, subtitle, numeric percent field, preference binding, and live preview behavior unchanged.

## Acceptance Criteria

- [ ] AC1: HUD icons and filled bars use the same foreground opacity token.
- [ ] AC2: Empty and muted bars use the same inactive opacity token, and that token is stronger than the previous `0.2`.
- [ ] AC3: Partial bars use inactive opacity for the background segment and filled opacity for the filled segment.
- [ ] AC4: Settings slider rows no longer use native `Slider`, so default tick marks are removed.
- [ ] AC5: Replacement sliders preserve range clamping, drag/click interaction, and existing bindings.
- [ ] AC6: Automated checks cover the HUD style tokens and the actual `HUDView`/`AboutView` source branches.

## Test Plan

| Command | Expected result |
| --- | --- |
| `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | Prints passing tests for shared icon/filled-bar opacity and inactive contrast, then exits `0`. |
| `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | Prints passing tests for slider location mapping, clamping, and keyboard adjustment behavior, then exits `0`. |
| `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | Prints passing static tests proving `HUDView` uses the shared style tokens and `AboutView` uses `CleanHUDSlider`, then exits `0`. |
| Existing command-line tests from SPEC-001 and SPEC-002 | Continue passing. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **`. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **`. |
| `git diff --check` | Exits `0` with no whitespace errors. |

## Review Notes

- The replacement slider is intentionally local to `AboutView` because it is only used by the three HUD appearance rows.
- The HUD foreground tokens stay semantic by using `.primary.opacity(...)`; only opacity is centralized.
