# Change Summary

## Recommendation

Maintain this as a fork first, then consider upstreaming small pieces later.

The original project describes itself as feature-complete and no longer under active development, so a large PR that adds persistent customization, Liquid Glass options, reset behavior, extra tests, and docs is less likely to fit upstream scope. A public fork gives users a clear installable version without waiting on maintainer review. If upstream contribution is still desired, split it into small PRs, such as HUD foreground contrast in Liquid Glass mode or the login item modernization, rather than one large customization PR.

Fork release target: `samoldsamold/volumeHUD`

Recommended release tag: `v3.4.0`

## User-Facing Changes

- HUD size is adjustable while keeping `30%` as the original 200 px baseline.
- HUD height is adjustable and can be centered or restored to the original lower placement.
- HUD opacity is adjustable.
- HUD Glass Effect can be toggled.
- HUD appearance changes show a live preview.
- Slider percentage values can be edited directly.
- Settings sliders use a custom clean track without native tick-like marks.
- `Set to Default` restores original-author HUD appearance defaults.
- HUD foreground contrast is improved in both classic and Liquid Glass modes.
- The About window keeps the original author attribution and adds `modified by Zhou Yongyu`.
- The display-selection setting is renamed from `HUD Follows Mouse` to clearer mouse-display copy.
- Settings-row icons now use a shared centered slot so SF Symbols align consistently.

## Technical Changes

- `HUDPreferences` centralizes persisted HUD preference keys, defaults, clamping, window sizing, window positioning, and original-author default conversion.
- `HUDController` reads the new preferences for HUD size, position, opacity, and glass mode.
- `HUDView` scales from the 200 px baseline and separates Liquid Glass background rendering from foreground HUD content.
- `HUDVisualStyle` centralizes icon and bar foreground opacity.
- `HUDPercentageValue` handles percentage field conversion and clamping.
- `HUDSliderInteraction` handles custom slider pointer and keyboard behavior.
- Command-line Swift tests cover preferences, glass style selection, percentage conversion, slider behavior, content refresh policy, and source-level HUD surface wiring.

## Release Notes Draft

### Added

- Adjustable HUD size, height, opacity, and glass effect.
- Live HUD preview while adjusting appearance controls.
- Direct numeric percentage input for HUD controls.
- `Set to Default` for restoring original volumeHUD appearance defaults.

### Changed

- Improved HUD bar contrast in light, dark, classic material, and Liquid Glass modes.
- Replaced native settings sliders with clean custom sliders.

### Fixed

- Liquid Glass no longer applies foreground glass effects directly to HUD icons and bars.

## Original Project Release Pattern

- Releases are created as GitHub Releases with tags such as `v3.3.1`.
- The latest observed release is `v3.3.1`, published on 2026-03-23.
- Recent releases attach two downloadable assets:
  - `volumeHUD-x.y.z.dmg`
  - `volumeHUD-x.y.z.zip`
- There is no `.github/workflows` release automation in the original repository.
- Release notes are written manually with short `Added`, `Changed`, or `Fixed` sections and a full changelog comparison link when applicable.

## Attribution

Original project:
https://github.com/dannystewart/volumeHUD

Original copyright:
Copyright (c) 2025 Danny Stewart

Modifications in this fork:
Copyright (c) 2026 ZHOU YONGYU
