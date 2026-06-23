# Fork Release Preparation Implementation Plan

**Goal:** Prepare the customized fork for publication from `samoldsamold/volumeHUD` on the
current branch.

**Architecture:** Runtime update discovery is controlled by `AboutView.swift`; app display
version is controlled by Xcode `MARKETING_VERSION`; release context lives in
`CHANGELOG.md` and `docs/CHANGE_SUMMARY.md`. A focused source-level test will verify those
metadata values directly.

**Tech Stack:** SwiftUI source files, Xcode project metadata, command-line Swift source
tests, Xcode no-sign builds, Git.

---

Status: Completed
Spec: `specs/010-fork-release-prep.md`
Owner: Codex

## Acceptance Criteria Coverage

- AC1: Covered by `tests/ForkReleaseMetadataTests.swift`, checking `githubOwner` and `githubRepo`.
- AC2: Covered by `tests/ForkReleaseMetadataTests.swift`, checking all `MARKETING_VERSION` values.
- AC3: Covered by `tests/ForkReleaseMetadataTests.swift`, checking the `3.4.0` changelog section.
- AC4: Covered by `tests/ForkReleaseMetadataTests.swift`, checking fork target and tag text.
- AC5: Covered by the focused metadata test.
- AC6: Covered by the verification commands below.
- AC7: Covered by `git commit` and `git push -u origin codex/hud-position-opacity`.

## Implementation Steps

- [x] Create `specs/010-fork-release-prep.md`.
- [x] Create this task plan.
- [x] Write failing test in `tests/ForkReleaseMetadataTests.swift`.
- [x] Run RED metadata test and record expected failure.
- [x] Update `volumeHUD/AboutView.swift` GitHub owner to `samoldsamold`.
- [x] Bump `volumeHUD.xcodeproj/project.pbxproj` marketing versions to `3.4.0`.
- [x] Update `CHANGELOG.md` with the `3.4.0` fork release section.
- [x] Update `docs/CHANGE_SUMMARY.md` with fork release target and tag.
- [x] Run GREEN metadata test.
- [x] Run existing source-level regression tests.
- [x] Run Xcode no-sign builds for normal and sandbox schemes.
- [x] Run lint/diff checks and record exact availability/output.
- [x] Run spec compliance review, fix findings, and re-review.
- [x] Run code quality review, fix findings, and re-review.
- [x] Commit and push the current branch to `origin`.

## Planned Commands

```bash
xcrun swiftc -parse-as-library tests/ForkReleaseMetadataTests.swift -o /tmp/volumeHUD-fork-release-metadata-tests && /tmp/volumeHUD-fork-release-metadata-tests
xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests
xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests
xcrun swiftc -parse-as-library tests/AboutAttributionTests.swift -o /tmp/volumeHUD-about-attribution-tests && /tmp/volumeHUD-about-attribution-tests
xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests
xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests
xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests
xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests
xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests
xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests
xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests
xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO
xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO
swiftformat --lint .
swiftlint lint
git diff --check
git status --short
git add .
git commit -m "feat: add customizable HUD appearance"
git push -u origin codex/hud-position-opacity
```

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| RED `xcrun swiftc -parse-as-library tests/ForkReleaseMetadataTests.swift -o /tmp/volumeHUD-fork-release-metadata-tests && /tmp/volumeHUD-fork-release-metadata-tests` | 1 | `FAIL: update check uses the fork owner: missing private let githubOwner = "samoldsamold"` |
| GREEN `xcrun swiftc -parse-as-library tests/ForkReleaseMetadataTests.swift -o /tmp/volumeHUD-fork-release-metadata-tests && /tmp/volumeHUD-fork-release-metadata-tests` | 0 | `PASS: update check targets samoldsamold/volumeHUD`; `PASS: all marketing versions are 3.4.0`; `All ForkReleaseMetadata tests passed.` |
| `xcrun swiftc -parse-as-library tests/SettingsIconAlignmentTests.swift -o /tmp/volumeHUD-settings-icon-alignment-tests && /tmp/volumeHUD-settings-icon-alignment-tests` | 0 | `PASS: settings icons use a shared centered helper`; `All SettingsIconAlignment tests passed.` |
| `xcrun swiftc -parse-as-library tests/DisplaySelectionCopyTests.swift -o /tmp/volumeHUD-display-selection-copy-tests && /tmp/volumeHUD-display-selection-copy-tests` | 0 | `PASS: display selection title describes display behavior`; `All DisplaySelectionCopy tests passed.` |
| `xcrun swiftc -parse-as-library tests/AboutAttributionTests.swift -o /tmp/volumeHUD-about-attribution-tests && /tmp/volumeHUD-about-attribution-tests` | 0 | `PASS: About view preserves original and fork attribution text`; `All AboutAttribution tests passed.` |
| `xcrun swiftc -parse-as-library tests/HUDViewSurfaceTests.swift -o /tmp/volumeHUD-hud-view-surface-tests && /tmp/volumeHUD-hud-view-surface-tests` | 0 | `PASS: enabled glass branch uses shaped SwiftUI Liquid Glass`; `All HUDViewSurface tests passed.` |
| `xcrun swiftc volumeHUD/HUDPreferences.swift tests/HUDPreferencesTests.swift -o /tmp/volumeHUD-hud-preferences-tests && /tmp/volumeHUD-hud-preferences-tests` | 0 | `PASS: default vertical position is centered`; `PASS: original author defaults restore lower HUD placement`; `All HUDPreferences tests passed.` |
| `xcrun swiftc volumeHUD/HUDGlassStyle.swift tests/HUDGlassStyleTests.swift -o /tmp/volumeHUD-hud-glass-style-tests && /tmp/volumeHUD-hud-glass-style-tests` | 0 | `PASS: glass style uses SwiftUI Liquid Glass renderer when enabled`; `All HUDGlassStyle tests passed.` |
| `xcrun swiftc volumeHUD/HUDVisualStyle.swift tests/HUDVisualStyleTests.swift -o /tmp/volumeHUD-hud-visual-style-tests && /tmp/volumeHUD-hud-visual-style-tests` | 0 | `PASS: filled bars match icon foreground strength`; `All HUDVisualStyle tests passed.` |
| `xcrun swiftc volumeHUD/HUDSliderInteraction.swift tests/HUDSliderInteractionTests.swift -o /tmp/volumeHUD-hud-slider-interaction-tests && /tmp/volumeHUD-hud-slider-interaction-tests` | 0 | `PASS: track locations map to clamped range values`; `All HUDSliderInteraction tests passed.` |
| `xcrun swiftc volumeHUD/HUDContentRefreshPolicy.swift tests/HUDContentRefreshPolicyTests.swift -o /tmp/volumeHUD-hud-content-refresh-policy-tests && /tmp/volumeHUD-hud-content-refresh-policy-tests` | 0 | `PASS: glass toggle refreshes content`; `All HUDContentRefreshPolicy tests passed.` |
| `xcrun swiftc volumeHUD/HUDPercentageValue.swift tests/HUDPercentageValueTests.swift -o /tmp/volumeHUD-hud-percentage-value-tests && /tmp/volumeHUD-hud-percentage-value-tests` | 0 | `PASS: numeric percent input converts to unit values`; `All HUDPercentageValue tests passed.` |
| `xcodebuild -list -project volumeHUD.xcodeproj` | 0 | `Targets: volumeHUD; volumeHUD (Sandbox)`; `Schemes: volumeHUD; volumeHUD (Sandbox)` |
| `xcodebuild test -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 66 | `xcodebuild: error: Scheme volumeHUD is not currently configured for the test action.` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftDriverJobDiscovery normal arm64 Compiling AboutView.swift`; `** BUILD SUCCEEDED **` |
| `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO` | 0 | `SwiftCompile normal arm64 /Users/zyyzyy_51674/Documents/volumeHUD/volumeHUD/AboutView.swift`; `** BUILD SUCCEEDED **` |
| `swiftformat --lint .` | 127 | `zsh:1: command not found: swiftformat` |
| `swiftlint lint` | 127 | `zsh:1: command not found: swiftlint` |
| `git diff --check` | 0 | No output. |
| `git diff --cached --stat && git commit -m "feat: add customizable HUD appearance"` | 0 | `53 files changed, 3665 insertions(+), 130 deletions(-)`; `[codex/hud-position-opacity 5dbfd12] feat: add customizable HUD appearance` |
| `git status --short && git push -u origin codex/hud-position-opacity` | 0 | `* [new branch] codex/hud-position-opacity -> codex/hud-position-opacity`; `branch 'codex/hud-position-opacity' set up to track 'origin/codex/hud-position-opacity'.` |

## Review Log

### Spec Compliance Review

- AC1 passed: `ForkReleaseMetadataTests` verifies `githubOwner = "samoldsamold"` and `githubRepo = "volumeHUD"`.
- AC2 passed: `ForkReleaseMetadataTests` finds four `MARKETING_VERSION` entries and verifies all are `3.4.0`.
- AC3 passed: `ForkReleaseMetadataTests` verifies `CHANGELOG.md` contains `## [3.4.0] (2026-06-23)`.
- AC4 passed: `ForkReleaseMetadataTests` verifies `docs/CHANGE_SUMMARY.md` names `samoldsamold/volumeHUD` and `v3.4.0`.
- AC5 passed: the focused metadata test covers fork owner, repo, and marketing version.
- AC6 passed with a recorded environment gap: source-level tests and both Xcode builds pass; `swiftformat` and `swiftlint` are not installed locally.
- AC7 passed: commit `5dbfd12` was created and branch `codex/hud-position-opacity` was pushed to `origin`.

### Spec Compliance Re-Review

- Passed after recording the `xcodebuild test` gap: the scheme has no test action, and source-level Swift tests provide the objective automated coverage for this repository.

### Code Quality Review

- Passed: release-prep runtime changes are limited to the existing GitHub owner constant and do not alter HUD behavior.
- Passed: version bump touches all four existing Xcode build configurations consistently.
- Passed: original source headers, bundle identifiers, and MIT attribution remain unchanged.
- Passed: release notes and change summary are consistent with the selected fork version and repository owner.

### Code Quality Re-Review

- Passed: no unrelated implementation changes were introduced during release-prep beyond the already completed HUD customization work on this branch.
