# CLAUDE.md

@AGENTS.md

`AGENTS.md` is the shared project contract; keep project rules there. This
file only adds Claude Code specifics.

- Use the FVM SDK (`fvm flutter`, or `.fvm/flutter_sdk/bin/flutter` as the
  `package.json` scripts do).
- Read package versions from each `pubspec.yaml`; `docs/project-overview.md`
  has the release table. When a version changes, update that table, the root
  `README.md` install snippet, and `documentation/changelog.md` together.
- Historical changelog entries and plan checkpoints keep the values that were
  true at the time (for example `minSdk 19` before Android 1.0.56). Update only
  "current state" statements when a baseline changes.
