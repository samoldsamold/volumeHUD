# Release Attribution Summary Spec

## Goal

Document the fork-vs-upstream recommendation, preserve MIT license attribution, add ZHOU YONGYU modification attribution, and summarize the local HUD customization changes for publishing or PR preparation.

## Non-Goals

- Do not create a GitHub repository.
- Do not push, open a PR, tag a release, notarize, or package release artifacts.
- Do not change app behavior beyond documentation and attribution.

## Brainstorming

- The original project appears feature-complete and inactive, so a broad customization PR is likely harder to land than a maintained fork.
- MIT redistribution requires preserving the existing copyright and permission notice in copies or substantial portions of the software.
- A fork should make modification ownership explicit without replacing the original author attribution.
- Release guidance should be evidence-backed from the upstream repository, not inferred from local files only.

## Design

- Keep the original MIT license text.
- Add a separate ZHOU YONGYU copyright line in `LICENSE`.
- Add `NOTICE` to separate original project attribution from fork modification attribution.
- Add `docs/CHANGE_SUMMARY.md` as the human-readable summary for PR, fork README, or release notes.
- Update `CHANGELOG.md` and `README.md` to point readers at the new attribution and change summary.

## Acceptance Criteria

- AC1: `LICENSE` preserves Danny Stewart's original copyright and includes ZHOU YONGYU attribution.
- AC2: `NOTICE` identifies the original project, original copyright, fork modification copyright, and MIT license.
- AC3: `README.md` points to the fork attribution notice.
- AC4: `CHANGELOG.md` includes the local customization and documentation changes under `Unreleased`.
- AC5: `docs/CHANGE_SUMMARY.md` summarizes the recommendation, user-facing changes, technical changes, release notes draft, upstream release pattern, and attribution.
- AC6: The upstream release pattern is verified from GitHub metadata and recorded with command output.
- AC7: Documentation changes pass `git diff --check`.

## Test Plan

- Run the upstream release metadata query and record decisive output.
- Inspect `LICENSE`, `NOTICE`, `CHANGELOG.md`, `README.md`, and `docs/CHANGE_SUMMARY.md`.
- Run `git diff --check`.

## Docs/ADR Impact

- Adds `NOTICE`.
- Adds `docs/CHANGE_SUMMARY.md`.
- No ADR required because this is documentation and attribution only; no architectural or operational decision is made inside the app.
