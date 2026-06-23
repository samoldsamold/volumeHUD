# SPEC-001: Adjustable HUD Size Position And Opacity

Status: Approved by user delegation
Owner: Codex
Date: 2026-06-22
Related tasks: `tasks/001-hud-position-opacity.md`

## Goal

Make volumeHUD's overlay size, position, and transparency user-adjustable, with the default HUD position changed from the current lower-screen placement to the visual center of the selected screen.

## Non-Goals

- Do not add horizontal positioning controls.
- Do not add separate position or opacity settings for volume and brightness HUDs.
- Do not change media-key interception, volume monitoring, brightness monitoring, login item behavior, or update checking.
- Do not redesign the full settings window beyond the controls needed for this feature.

## Context

The repository is a native macOS SwiftUI/Xcode app. The current HUD frame is calculated in `volumeHUD/HUDController.swift` inside `updateWindowPosition(for:)`. It selects the target display correctly, but the vertical placement is hard-coded to either 17% from the bottom of the screen or 140 px from the bottom depending on the `useRelativePositioning` preference. The settings UI is in `volumeHUD/AboutView.swift`, where `useRelativePositioning` is currently exposed as "Relative HUD Position".

The approved design started as approach A from the visual companion and was expanded by user request to three settings sliders plus live HUD preview.

- `HUD Size`: a size percentage. The existing 200 px HUD is defined as `30%`, so users can keep the current visual size by leaving the default unchanged.
- `HUD Height`: a percentage from bottom to top. The percentage describes the HUD window center, not the lower-left frame origin. Default is `50%`, which centers the HUD visually.
- `HUD Opacity`: an opacity percentage. Default is `100%`. Minimum is `20%` so the HUD cannot be accidentally made fully invisible.
- Live preview: when `HUD Size`, `HUD Height`, or `HUD Opacity` changes in settings, the real overlay HUD appears immediately using the updated size, position, and transparency.

## Acceptance Criteria

- [ ] AC1: The default HUD vertical position is the visual center of the selected screen. For the default 200 px HUD on a 900 px-high screen, the window origin y is `(900 * 0.5) - 100 = 350`, not `450`.
- [ ] AC2: Existing target-screen behavior remains intact: volume HUD still follows the mouse or primary display based on `volumeHUDFollowsMouse`, and brightness HUD still prefers the built-in display when available.
- [ ] AC3: The settings panel exposes a `HUD Size` slider with a displayed percentage value, stores it in UserDefaults under `hudSize`, defaults to `0.3`, and maps `0.3` to the existing 200 px HUD size.
- [ ] AC4: The settings panel exposes a `HUD Height` slider with a displayed percentage value, stores it in UserDefaults under `hudVerticalPosition`, and defaults to `0.5`.
- [ ] AC5: The settings panel exposes a `HUD Opacity` slider with a displayed percentage value, stores it in UserDefaults under `hudOpacity`, defaults to `1.0`, and clamps below-range values to `0.2`.
- [ ] AC6: HUD display applies the stored size and opacity to the overlay window when shown, preserves fade-out behavior, and resets the hidden window alpha to the stored opacity rather than hard-coded `1.0`.
- [ ] AC7: Changing HUD size, height, or opacity in settings immediately shows the real HUD overlay as a live preview using the updated appearance and position.
- [ ] AC8: The old `Relative HUD Position` setting no longer controls active HUD placement and is removed from the visible settings UI.
- [ ] AC9: README usage text mentions configurable HUD size, position, opacity, and live preview while adjusting.
- [ ] AC10: Automated checks cover HUD geometry defaults, vertical-position clamping, size defaults, size scaling, size clamping, opacity defaults, and opacity clamping.

## Test Plan

| Command | Expected result |
| --- | --- |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | Prints passing test lines for default center positioning, vertical clamping, default size, size scaling, size clamping, default opacity, and opacity clamping, then exits `0`. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug` | Ends with `** BUILD SUCCEEDED **`, or records the local signing-certificate failure and runs the no-sign compile command below. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **` when local signing certificates are unavailable. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **` when local signing certificates are unavailable. |
| `swiftformat --lint .` | Exits `0`, or if `swiftformat` is not installed, record the actual command failure and do not claim SwiftFormat passed. |
| `swiftlint lint` | Exits `0`, or if `swiftlint` is not installed, record the actual command failure and do not claim SwiftLint passed. |
| `git diff --check` | Exits `0` with no whitespace errors. |

This project currently has no Xcode test target. The feature adds a narrow command-line Swift test under `tests/` that compiles the real production preference/geometry helper with `xcrun swiftc`.

## Docs And ADR Impact

- Docs to update: `README.md`.
- ADR required: no. This is a small preference and geometry extraction, not an architectural, dependency, data-contract, operational, or irreversible decision.

## Scope Control

Changes outside these acceptance criteria require a visible spec or task amendment before implementation.
