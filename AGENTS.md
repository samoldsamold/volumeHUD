# AGENTS.md

## Repository SDD Contract

This repository uses Specification Driven Development (SDD). Codex must follow this
contract for every task. Engineering quality takes priority over time and token savings.
Do not skip process gates to make the work look faster.

## Required Structure

- `AGENTS.md`: this repository operating contract.
- `specs/`: specifications with goal, non-goals, acceptance criteria, test plan, and docs/ADR impact.
- `tasks/`: task plans linked to specs, with acceptance criteria coverage and verification logs.
- `tests/`: automated tests, test helpers, documented verification entry points, or explicit test gaps.
- `docs/adr/`: Architecture Decision Records for architectural, data contract, dependency, operational, or irreversible decisions.

## Task Gate

1. Read this file, the relevant spec in `specs/`, the relevant task in `tasks/`, and relevant ADRs before editing.
2. If no relevant spec exists, stop and create the smallest useful spec first.
3. List the acceptance criteria that the task will satisfy before implementing.
4. Do not skip, weaken, reinterpret, or replace acceptance criteria privately.
5. If an acceptance criterion is wrong, quote it, explain the issue with evidence, propose replacement wording, and wait for explicit approval.
6. Do not expand scope privately. Put extra improvements into a follow-up spec or task unless the user approves expanding the current spec.
7. Run the tests named in the spec or task before claiming completion. If no automated test applies, run concrete objective checks such as `git diff --check`, a docs build, a formatter check, a linter, or a project-specific smoke test, then record the remaining test gap.
8. Report exact verification commands and actual output before claiming tests pass, builds succeed, or behavior works.

## Engineering Quality Rules

- Non-trivial work must complete the full flow: brainstorming, design, plan, implement, review, and verify.
- Claims require evidence. Do not say tests pass, builds succeed, or the app works without exact command output.
- Do not omit required code with placeholders such as "same as above", "similar", or "TODO".
- Review is mandatory: spec compliance review and code quality review must both run, and findings must be fixed and re-reviewed.
- Do not pretend to run commands. If a command fails, show the failure and explain it.
- Implement the accepted scope completely. YAGNI removes unneeded work, not accepted requirements.
- Use TDD for code and behavior changes when the project has a reasonable automated test path. When no test target exists yet, the task plan must either add the smallest useful test target or record the objective verification gap.

## Required Workflow

Every task must move through these gates in order:

1. **Brainstorming:** clarify purpose, constraints, risks, and success criteria against the relevant spec.
2. **Design:** choose the smallest approach that satisfies the spec and record any spec amendment before relying on it.
3. **Plan:** create or update a task plan that maps acceptance criteria to implementation steps and verification commands.
4. **Implement:** change only the approved scope and use failing tests first for code or behavior changes when the repo has a test framework.
5. **Review:** run spec compliance review, fix findings, re-review, then run code quality review, fix findings, and re-review.
6. **Verify:** run the planned tests; when no automated test applies, run objective checks and record both command output and the remaining test gap.

## Review Gate

- Run a spec compliance review: every acceptance criterion is satisfied or explicitly blocked.
- Fix spec compliance findings and re-review.
- Run a code quality review: focused change, local patterns, maintainable tests, and no unrelated refactors.
- Fix code quality findings and re-review.

## Scope Rule

YAGNI removes unneeded work; it does not remove required acceptance criteria. Any scope change must be visible in the spec or task before implementation relies on it.

## Project Commands

Use these commands in specs and tasks unless a narrower command is justified:

```bash
xcodebuild -list -project volumeHUD.xcodeproj
xcodebuild test -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug
xcodebuild build -project volumeHUD.xcodeproj -scheme volumeHUD -configuration Debug
xcodebuild build -project volumeHUD.xcodeproj -scheme "volumeHUD (Sandbox)" -configuration Debug
swiftformat --lint .
swiftlint lint
git diff --check
```

If `swiftformat` or `swiftlint` is not installed locally, record the actual command failure
and use the closest available objective checks without claiming those tools passed.
