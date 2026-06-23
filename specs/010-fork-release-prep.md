# Fork Release Preparation Spec

## Goal

Prepare the customized volumeHUD fork for publication under the `samoldsamold/volumeHUD`
repository.

## Non-Goals

- Do not change HUD appearance behavior, persisted setting keys, defaults, or UI layout.
- Do not change original-author source headers, bundle identifiers, or MIT license ownership.
- Do not create a GitHub Release or notarized distribution asset in this task.
- Do not retarget Homebrew install instructions in this task.

## Brainstorming

- The fork should keep upstream attribution intact while making the app's release/update
  path point at the fork owner.
- The current feature set is user-facing and larger than a patch, so the next fork version
  should be `3.4.0` rather than another `3.3.x` patch.
- The app's update check is driven by `githubOwner` and `githubRepo` in `AboutView.swift`,
  so changing those constants is the smallest runtime change.
- The original repository release pattern can stay documented as context, but the fork
  needs an explicit recommended tag and repository target.

## Design

- Keep `githubRepo` as `volumeHUD`.
- Change only the update-check repository owner from `dannystewart` to `samoldsamold`.
- Bump every Xcode `MARKETING_VERSION` setting from `3.3.2` to `3.4.0`.
- Promote the current changelog notes into a `3.4.0` release section dated `2026-06-23`.
- Add source-level metadata tests that fail before the owner/version update and pass after.

## Acceptance Criteria

- AC1: The non-sandbox update check and releases link target `samoldsamold/volumeHUD`.
- AC2: All Xcode build configurations use `MARKETING_VERSION = 3.4.0;`.
- AC3: The changelog has a `3.4.0` release section for this fork's customization release.
- AC4: `docs/CHANGE_SUMMARY.md` names `samoldsamold/volumeHUD` as the fork release target
  and recommends tag `v3.4.0`.
- AC5: Automated metadata verification covers the fork owner, repo name, and marketing version.
- AC6: Existing source-level tests and Xcode no-sign builds still pass, with lint command
  availability recorded exactly.
- AC7: The release-prep changes are committed and pushed to the current fork branch when
  verification passes.

## Test Plan

- Run `xcrun swiftc -parse-as-library tests/ForkReleaseMetadataTests.swift -o /tmp/volumeHUD-fork-release-metadata-tests && /tmp/volumeHUD-fork-release-metadata-tests`.
- Run all existing source-level tests in `tests/`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `swiftformat --lint .`.
- Run `swiftlint lint`.
- Run `git diff --check`.

## Docs/ADR Impact

- Update `CHANGELOG.md`.
- Update `docs/CHANGE_SUMMARY.md`.
- No ADR required because this is release metadata and documentation, not an architecture
  or dependency decision.
