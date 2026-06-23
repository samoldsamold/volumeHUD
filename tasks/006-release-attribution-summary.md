# Release Attribution Summary Implementation Plan

**Goal:** Prepare local attribution and change-summary documentation for a fork release or future upstream PR discussion.

**Architecture:** Documentation-only change. License attribution remains in `LICENSE`, detailed fork attribution lives in `NOTICE`, and release/PR guidance lives in `docs/CHANGE_SUMMARY.md`.

**Tech Stack:** Markdown, MIT license text, GitHub repository metadata query.

---

Status: Implemented
Spec: `specs/006-release-attribution-summary.md`
Owner: Codex

## Acceptance Criteria Coverage

- AC1: `LICENSE` contains Danny Stewart and ZHOU YONGYU copyright lines.
- AC2: `NOTICE` identifies original project, original copyright, fork modification copyright, and MIT license.
- AC3: `README.md` points to `NOTICE`.
- AC4: `CHANGELOG.md` records the local customization and documentation changes under `Unreleased`.
- AC5: `docs/CHANGE_SUMMARY.md` summarizes recommendation, changes, release notes draft, upstream release pattern, and attribution.
- AC6: Upstream release metadata was queried from GitHub and recorded below.
- AC7: `git diff --check` was run and produced no output.

## Implementation Steps

- [x] Add ZHOU YONGYU attribution to `LICENSE`.
- [x] Add `NOTICE`.
- [x] Update `README.md` license section.
- [x] Update `CHANGELOG.md`.
- [x] Add `docs/CHANGE_SUMMARY.md`.
- [x] Verify upstream release pattern.
- [x] Run documentation whitespace check.

## Verification Log

| Command | Exit code | Decisive output |
| --- | ---: | --- |
| `python3 - <<'PY' ... GitHub releases query ... PY` | 0 | `v3.3.1 published=2026-03-23T23:59:37Z ... assets=volumeHUD-3.3.1.dmg, volumeHUD-3.3.1.zip`; `workflows_http_status=404` |
| `sed -n '1,80p' LICENSE` | 0 | `Copyright (c) 2025 Danny Stewart`; `Copyright (c) 2026 ZHOU YONGYU` |
| `sed -n '1,120p' NOTICE` | 0 | `Original project: https://github.com/dannystewart/volumeHUD`; `Modifications in this fork: Copyright (c) 2026 ZHOU YONGYU` |
| `rg -n "License|NOTICE|ZHOU YONGYU|MIT" README.md CHANGELOG.md NOTICE docs/CHANGE_SUMMARY.md LICENSE` | 0 | `README.md:69:This fork preserves... ZHOU YONGYU. See [NOTICE](./NOTICE).`; `LICENSE:4:Copyright (c) 2026 ZHOU YONGYU` |
| `git diff --check` | 0 | No output. |

## Review Log

### Spec Compliance Review

- AC1: Passed. `LICENSE` preserves original author attribution and adds ZHOU YONGYU.
- AC2: Passed. `NOTICE` separates original project and fork modifications.
- AC3: Passed. `README.md` references `NOTICE`.
- AC4: Passed. `CHANGELOG.md` has an `Unreleased` entry for customization and documentation.
- AC5: Passed. `docs/CHANGE_SUMMARY.md` contains recommendation, change lists, release draft, release pattern, and attribution.
- AC6: Passed. GitHub metadata output is recorded above.
- AC7: Passed. `git diff --check` produced no output.

### Code Quality Review

- Passed. Scope is documentation and attribution only, with no unrelated app behavior changes.
- Passed. Attribution does not replace the original MIT copyright notice.
- Passed. Release guidance is backed by recorded upstream metadata rather than assumptions.
