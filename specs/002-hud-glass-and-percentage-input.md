# SPEC-002: Optional HUD Glass Effect And Editable Percentages

Status: Approved by user delegation
Owner: Codex
Date: 2026-06-22
Related tasks: `tasks/002-hud-glass-and-percentage-input.md`

## Goal

Make the HUD appearance closer to Apple native translucent glass while keeping the effect optional, and let users edit HUD size, height, and opacity percentages directly instead of only dragging sliders.

## Non-Goals

- Do not change media-key interception, display selection, volume/brightness value detection, login item behavior, or update checking.
- Do not add separate glass settings for volume and brightness HUDs.
- Do not add custom color, blur-radius, background-image, or theme controls.
- Do not redesign the full settings window beyond the new glass toggle and editable percentage fields.

## Context

`SPEC-001` added `HUD Size`, `HUD Height`, and `HUD Opacity` sliders with live preview. The current HUD background uses SwiftUI `.regularMaterial`, which is system-backed but not the same as a semantic macOS Liquid Glass surface in the overlay window. The new design keeps the existing classic material as the fallback and adds an opt-in/out system Liquid Glass surface.

The user also requested direct percentage editing for the three existing percentage controls. The settings row should continue to include a slider for quick adjustment, but the displayed percentage should become an editable numeric field.

After testing the live preview over the light settings window, the glass HUD must avoid both gray/dirty custom tints and square-corner artifacts. Apple guidance for macOS 26 custom glass is to use Liquid Glass as the shaped surface for the custom view, not as a sibling background behind content. The HUD should therefore let the system glass shape own tinting, adaptation, and corners.

## Design

- Add a persisted `hudGlassEffectEnabled` preference in `HUDPreferences`, defaulting to `true`.
- Render the HUD with SwiftUI Liquid Glass when glass is enabled:
  - effect: `.glassEffect(.regular, in: RoundedRectangle(cornerRadius: scaledRadius, style: .continuous))`
  - shape: continuous rounded rectangle matching the current HUD scale
  - no sibling `NSVisualEffectView` background
- When glass is disabled, render the existing SwiftUI `.regularMaterial` rounded rectangle so users can keep the previous visual style.
- When glass is enabled, do not add custom surface scrims, strokes, or shadows over the glass; the system Liquid Glass renderer owns adaptive tinting, edge treatment, and corner rendering.
- Add a `HUD Glass Effect` toggle in the settings window near the other HUD appearance controls.
- Toggling glass, dragging sliders, or editing percentage fields must call the existing live preview path.
- Replace the read-only percentage text in each `HUDSliderSetting` row with a compact numeric text field plus a `%` suffix.
- Numeric edits use whole percentage values and clamp to the same ranges as the sliders:
  - HUD Size: `20` through `100`
  - HUD Height: `0` through `100`
  - HUD Opacity: `20` through `100`

## Acceptance Criteria

- [ ] AC1: The app stores `HUD Glass Effect` under `hudGlassEffectEnabled`, defaults it to enabled when unset, and reads explicit `false` values correctly.
- [ ] AC2: When glass is enabled, the HUD uses SwiftUI `.glassEffect(.regular, in:)` with a continuous rounded rectangle shape matching the current HUD scale.
- [ ] AC3: When glass is disabled, the HUD background uses the previous `.regularMaterial` rounded rectangle fallback.
- [ ] AC4: `HUDController` includes glass-enabled state in its content refresh decision so live preview updates immediately when the toggle changes while the HUD is already visible.
- [ ] AC5: The settings panel exposes a `HUD Glass Effect` toggle near the HUD appearance controls and toggling it immediately shows the real HUD preview.
- [ ] AC6: `HUD Size`, `HUD Height`, and `HUD Opacity` rows each keep their sliders and add direct numeric percentage editing.
- [ ] AC7: Direct numeric percentage edits convert back to the stored unit values and clamp to each setting's supported range.
- [ ] AC8: README usage text mentions optional glass effect and editable percentage fields.
- [ ] AC9: Automated checks cover glass default/storage behavior, glass renderer selection, percentage formatting, and percentage clamping.
- [ ] AC10: With glass enabled, the HUD avoids gray/dirty custom tinting and square-corner artifacts by using system-shaped Liquid Glass without extra scrim, border, or shadow layers.

## Test Plan

| Command | Expected result |
| --- | --- |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | Prints passing test lines for existing geometry/preferences plus glass default and explicit stored glass values, then exits `0`. |
| `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | Prints passing test lines for Liquid Glass renderer selection and scaled corner radius, then exits `0`. |
| `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | Prints passing test lines proving `HUDView` applies shaped SwiftUI Liquid Glass in the enabled branch and `.regularMaterial` only in the fallback branch, then exits `0`. |
| `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | Prints passing test lines for HUD content refresh decisions, including glass toggle changes, then exits `0`. |
| `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | Prints passing test lines for display formatting and unit-value clamping from numeric percentages, then exits `0`. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **` when local signing certificates are unavailable. |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | Ends with `** BUILD SUCCEEDED **` when local signing certificates are unavailable. |
| `swiftformat --lint .` | Exits `0`, or if `swiftformat` is not installed, record the actual command failure and do not claim SwiftFormat passed. |
| `swiftlint lint` | Exits `0`, or if `swiftlint` is not installed, record the actual command failure and do not claim SwiftLint passed. |
| `git diff --check` | Exits `0` with no whitespace errors. |

## Docs And ADR Impact

- Docs to update: `README.md`.
- ADR required: no. This is a small visual preference and settings-control update that does not introduce new dependencies or irreversible architecture.
