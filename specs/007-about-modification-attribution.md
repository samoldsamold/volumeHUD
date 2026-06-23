# About Modification Attribution Spec

## Goal

Show the fork modification attribution in the About window by adding `modified by Zhou Yongyu` while preserving the original `by Danny Stewart` attribution.

## Non-Goals

- Do not rename the app.
- Do not change the bundle identifier, repository owner, update-check repository, or version number.
- Do not remove or replace the original author attribution.
- Do not change HUD behavior or settings behavior.

## Brainstorming

- The fork should make the modified build's authorship clear to users without implying the original author made the fork-specific changes.
- The least disruptive UI change is a second muted attribution line below the original author line.
- The existing About left column already groups app icon, app name, author, and version, so the new text belongs there.
- Keeping the line in `.secondary` at the same small size as the original author line keeps the visual hierarchy unchanged.

## Design

- Add a `Text("modified by Zhou Yongyu")` line directly below `Text("by Danny Stewart")` in `volumeHUD/AboutView.swift`.
- Use the same font size and secondary foreground style as the existing author line.
- Add a source-level regression test that proves both attribution strings are present.

## Acceptance Criteria

- AC1: The About window preserves `by Danny Stewart`.
- AC2: The About window displays `modified by Zhou Yongyu`.
- AC3: The modification attribution appears in the About left-column attribution area, before the version/build toggle.
- AC4: The new attribution uses the existing muted About attribution styling.
- AC5: Automated verification covers the original and modification attribution strings.

## Test Plan

- Run `xcrun swiftc -parse-as-library tests/AboutAttributionTests.swift -o /tmp/volumeHUD-about-attribution-tests && /tmp/volumeHUD-about-attribution-tests`.
- Run `xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug CODE_SIGNING_ALLOWED=NO`.
- Run `git diff --check`.

## Docs/ADR Impact

- Update `CHANGELOG.md` under `Unreleased`.
- No ADR required because this is a small UI attribution change with no architectural impact.
