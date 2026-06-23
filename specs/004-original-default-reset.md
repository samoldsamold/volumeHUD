# Original Default Reset Spec

## Goal

Add a settings-page `Set to Default` action that returns the adjustable HUD appearance parameters to the original author's behavior while keeping the new height/size/opacity controls available.

## Decisions

- Keep the existing adjustable controls for HUD size, height, opacity, and glass.
- Treat the original author HUD placement as the pre-change relative position: window origin at `17%` of the selected screen height from the bottom.
- Convert that original origin rule into the current stored center-position percentage when the reset button is clicked.
- Reset HUD appearance parameters only:
  - `HUD Follows Mouse`: `true`, matching the original app default.
  - `HUD Glass Effect`: `false`, matching the original non-Liquid-Glass material style.
  - `HUD Size`: `0.3`, the current 200 px HUD baseline.
  - `HUD Height`: computed from original `17%` window-origin placement for the selected screen and 200 px default window.
  - `HUD Opacity`: `1.0`.
- Do not reset `Open at Login` or `Brightness HUD`; those are app/feature preferences, not HUD appearance defaults.
- Trigger a live HUD preview immediately after reset.

## Acceptance Criteria

- AC1: `HUDPreferences` exposes original-author HUD defaults and converts original `17%` bottom-origin placement into a clamped center-position percentage.
- AC2: The settings page shows a `Set to Default` control near the HUD appearance controls.
- AC3: Activating the control resets HUD size, height, opacity, glass, and follows-mouse values to original-author defaults.
- AC4: Activating the control calls the existing HUD preview path.
- AC5: Automated checks cover the original-author height conversion and source-level reset wiring.
