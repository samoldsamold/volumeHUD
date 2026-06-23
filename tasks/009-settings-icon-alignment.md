# Settings Icon Alignment Implementation Plan

**Goal:** Fix visually misaligned settings icons by replacing per-row leading frames with a shared centered icon slot.

**Architecture:** `AboutView.swift` owns the About/settings UI. A private `SettingIcon` helper will provide one centered SF Symbol slot used by toggle rows and `HUDSliderSetting`. Source-level Swift tests verify the helper exists, all visible setting icons use it, and legacy leading icon frames are gone.

**Tech Stack:** SwiftUI, command-line Swift source tests, Xcode no-sign builds.

---

Status: Completed
Spec: `specs/009-settings-icon-alignment.md`
Owner: Codex

## Acceptance Criteria Coverage

- AC1: Covered by `tests/SettingsIconAlignmentTests.swift`, checking `private struct SettingIcon` and helper call sites.
- AC2: Covered by `tests/SettingsIconAlignmentTests.swift`, rejecting `.frame(width: 14, alignment: .leading)`.
- AC3: Covered by `tests/SettingsIconAlignmentTests.swift`, checking subtitle rows use `settingIconSlotWidth`.
- AC4: Covered by `tests/SettingsIconAlignmentTests.swift`, checking `Set to Default` padding uses `settingIconSlotWidth + settingIconTextSpacing`.
- AC5: Covered by `tests/DisplaySelectionCopyTests.swift`.
- AC6: Covered by the focused source-level icon alignment test.

## Implementation Steps

- [x] Create `specs/009-settings-icon-alignment.md`.
- [x] Create this task plan.
- [x] Write failing test in `tests/SettingsIconAlignmentTests.swift`.
- [x] Run RED test and record expected failure.
- [x] Implement centered `SettingIcon` and replace icon call sites.
- [x] Update `CHANGELOG.md` and `docs/CHANGE_SUMMARY.md`.
- [x] Run GREEN focused test.
- [x] Run regression tests for display copy and HUD surface.
- [x] Run Xcode builds for normal and sandbox schemes.
- [x] Restart Debug app.
- [x] Run `git diff --check`.
- [x] Run spec compliance review and code quality review.
- [x] Record verification output.

## Planned Commands

```bash
xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests
xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests
xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests
xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO
xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO
git diff --check
```

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests` | 1 | `FAIL: shared setting icon helper: missing private struct SettingIcon: View` |
| GREEN `xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests` | 0 | `PASS: settings icons use a shared centered helper`; `PASS: legacy leading icon frames are removed`; `PASS: subtitle rows reserve the same icon slot`; `PASS: default button uses icon slot alignment constants`; `All SettingsIconAlignment tests passed.` |
| Regression `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests` | 0 | `All DisplaySelectionCopy tests passed.` |
| Regression `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `All HUDViewSurface tests passed.` |
| Regression `xcrun swiftc -parse-as-library tests/AboutAttributionTests.swift -o /tmp/volumeHUD-about-attribution-tests && /tmp/volumeHUD-about-attribution-tests` | 0 | `All AboutAttribution tests passed.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftDriverJobDiscovery normal arm64 Compiling AboutView.swift`; `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftCompile normal arm64 /Users/zyyzyy_51674/Documents/volumeHUD/volumeHUD/AboutView.swift`; `** BUILD SUCCEEDED **` |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| Debug app restart and screenshot attempt | 0 | `Stopping volumeHUD processes: 50200`; `Running volumeHUD processes: 83309`; screenshot captured Codex, not the About window. |
| Window inspection with `xcrun swift` CoreGraphics script | 0 | `id=97250 owner=volumeHUD name=volumeHUD layer=0 bounds={ Height = 0; Width = 0; X = 735; Y = 494; }` |
| User visual confirmation | 0 | User confirmed the settings icon alignment is corrected. |
| `git diff --check` | 0 | No output. |

## Review Log

### Spec Compliance Review

- AC1 passed: `SettingIcon` exists and `SettingsIconAlignmentTests` verifies at least five setting icon call sites use it.
- AC2 passed: `SettingsIconAlignmentTests` rejects `.frame(width: 14, alignment: .leading)`, and the focused test passes.
- AC3 passed: subtitle rows use `settingIconSlotWidth` for their spacer slot.
- AC4 passed: the `Set to Default` button uses `settingPadding + settingIconSlotWidth + settingIconTextSpacing`.
- AC5 passed: `DisplaySelectionCopyTests` still passes after the icon-slot change.
- AC6 passed: the focused source-level icon alignment test covers the shared slot and legacy frame removal.

### Code Quality Review

- Passed: the root cause is addressed by one shared centered slot instead of per-symbol optical nudges.
- Passed: the text column stays at the same x-position because the old `14 + 20` spacing is preserved as `24 + 10`.
- Passed: behavior, storage keys, defaults, copy, toggles, sliders, and HUD rendering are unchanged.
- Local screenshot attempts did not capture the About window because the running app exposed only a `0x0` volumeHUD window to CoreGraphics at capture time. The visual pass is based on the user's direct inspection.
