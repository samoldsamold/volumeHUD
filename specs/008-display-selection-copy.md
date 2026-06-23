# Display Selection Copy Spec

## Goal

Rename the confusing `HUD Follows Mouse` setting copy so users understand it controls which display shows the HUD, not whether the HUD physically follows the cursor.

## Non-Goals

- Do not change `volumeHUDFollowsMouse` storage, defaults, or behavior.
- Do not change HUD placement math.
- Do not change icons, toggles, layout, or slider behavior.
- Do not rename historical changelog entries.

## Brainstorming

- The old title can be read as "the HUD moves with the mouse pointer," which is not the actual behavior.
- The actual behavior is display selection: when enabled, the HUD appears on the display containing the cursor; when disabled, it appears on the primary display.
- The title should stay short enough for the existing settings column.
- The subtitle can carry the precise state-specific explanation.
- User context: this is a macOS utility settings screen for a user adjusting HUD behavior, likely while comparing one or more displays.
- Tone: plain, direct, desktop-system style; avoid clever naming.

## Design

- Replace the title `HUD Follows Mouse` with `Use Mouse Display`.
- Replace the enabled subtitle with `Show HUD on the display with cursor`.
- Replace the disabled subtitle with `Show HUD on the primary display`.
- Keep the existing app storage key, icon state, toggle behavior, animation, and logging unchanged.

## Acceptance Criteria

- AC1: The About/settings view no longer displays `HUD Follows Mouse`.
- AC2: The setting title displays `Use Mouse Display`.
- AC3: The enabled subtitle displays `Show HUD on the display with cursor`.
- AC4: The disabled subtitle displays `Show HUD on the primary display`.
- AC5: The copy change does not rename the `volumeHUDFollowsMouse` storage key or change its reset default.
- AC6: Automated verification covers the old and new display-selection copy.

## Test Plan

- Run `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `git diff --check`.

## Docs/ADR Impact

- Update `CHANGELOG.md` under `Unreleased`.
- No ADR required because this is a settings copy-only change.
