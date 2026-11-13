# CLAUDE.md

@AGENTS.md

The imported `AGENTS.md` is the authoritative project guide (repository map,
working rules, toolchain baseline, test selection, issue workflow, and
documentation index). Keep project rules there so every agent reads the same
contract; this file only adds Claude Code specifics.

## Current release line (2026-11-13)

| Package | Version |
| --- | ---: |
| `flutter_inappwebview_forge` | 2.1.77 |
| `flutter_inappwebview_forge_platform_interface` | 1.1.22 |
| `flutter_inappwebview_forge_android` | 1.0.56 |
| `flutter_inappwebview_forge_ios` | 2.1.35 |
| `flutter_inappwebview_forge_macos` | 1.1.10 |
| `flutter_inappwebview_forge_windows` | 1.0.15 |
| `flutter_inappwebview_forge_linux` | 1.0.8 |
| `flutter_inappwebview_forge_web` | 1.0.4 |

Read versions from each `pubspec.yaml` before writing release notes; this
table is a snapshot. When a version changes, update this table,
`docs/project-overview.md`, the root `README.md` install snippet, and
`documentation/changelog.md` together.

## Claude Code notes

- Use the FVM SDK (`fvm flutter`, or `.fvm/flutter_sdk/bin/flutter` as the
  `package.json` scripts do). Run `fvm flutter pub get` before `--no-pub`
  commands so `package_config.json` matches Flutter 3.44.8.
- Engineering records go in `docs/`; application-facing guides go in
  `documentation/`. Do not mix them.
- `docs/known-issues.md`, `docs/issue-pr-resolution-log.md`,
  `docs/open-work-plan.md`, and `docs/runtime-validation-pending.md` are
  large; search them for the issue number instead of reading them whole.
- Historical changelog entries and plan checkpoints keep the values that were
  true at the time (for example `minSdk 19` before Android 1.0.56). Update only
  "current state" statements when a baseline changes.
- Do not commit, push, or run any `npm run publish:*` script without explicit
  authorization.
