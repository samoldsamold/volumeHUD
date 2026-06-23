# Settings Icon Alignment Spec

## Goal

Fix visually misaligned settings-row icons by rendering all right-column setting icons in a consistent centered slot.

## Non-Goals

- Do not change settings behavior, storage keys, defaults, or HUD behavior.
- Do not redesign the About window layout.
- Do not change the app icon, left information column, toggles, sliders, or text copy.
- Do not individually nudge specific symbols unless the shared slot still leaves a measured problem.

## Root Cause

The settings rows render SF Symbols with `.frame(width: 14, alignment: .leading)`. SF Symbols have different intrinsic widths and optical centers, so leading-aligning each symbol in a very narrow frame makes icons appear horizontally inconsistent. Wider symbols such as display/laptop and arrow symbols are especially noticeable.

## Design

- Add a small `SettingIcon` SwiftUI helper in `AboutView.swift`.
- Render each setting icon in a fixed-width, fixed-height centered slot.
- Keep the text column's existing x-position by replacing the old `14 + 20` icon/spacing pair with a `24 + 10` icon slot/spacing pair.
- Use the same icon slot for toggle rows and `HUDSliderSetting`.
- Use the same slot width in subtitle rows and the `Set to Default` left padding so text alignment remains stable.

## Acceptance Criteria

- AC1: Settings-row icons use a shared centered `SettingIcon` helper.
- AC2: No settings-row icon uses `.frame(width: 14, alignment: .leading)`.
- AC3: Subtitle rows reserve the same icon slot width as title rows.
- AC4: The `Set to Default` button stays aligned with setting text by using the icon slot width and icon-text spacing constants.
- AC5: Existing display-selection copy and behavior are unchanged.
- AC6: Automated verification covers the shared icon slot and legacy leading-frame removal.

## Test Plan

- Run `xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests`.
- Run `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests`.
- Run `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `git diff --check`.

## Docs/ADR Impact

- Update `CHANGELOG.md` under `Unreleased`.
- Update `docs/CHANGE_SUMMARY.md`.
- No ADR required because this is a local SwiftUI layout polish change.
