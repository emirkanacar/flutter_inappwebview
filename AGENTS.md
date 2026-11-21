# Agent Guide

`flutter_inappwebview_forge` is a federated Flutter plugin forked from Flutter
InAppWebView. Preserve the public Dart API and the native platform contracts
unless a breaking change is explicitly intended.

Packages: `flutter_inappwebview_forge/` (public API and main example),
`_platform_interface/` (contract, types, generated serializers, capability
metadata), and `_android/`, `_ios/`, `_macos/`, `_windows/`, `_linux/`,
`_web/` implementations, each with an `example/`. Repository folders,
toolchain baselines, and platform notes are in
[`docs/project-overview.md`](docs/project-overview.md); commands, CI, and
release steps are in [`docs/development.md`](docs/development.md).

## Working rules

- Keep the `flutter_inappwebview_forge` package names and the `com.emirkanacar.flutter_inappwebview_forge_android` Android namespace. Do not reintroduce upstream package names in active source.
- MethodChannel/EventChannel names, method names, event payload maps, platform-view IDs, JavaScript bridge names, and generated capability metadata are compatibility surfaces.
- Change the platform interface before or together with an implementation when a public setting, enum, event, or method changes.
- Native callbacks are versioned, nullable input. Never force-unwrap values from WebView2, Android WebView, WebKit, WPE, or platform channels.
- Lifecycle callbacks are not guaranteed during renderer, GPU, surface, process, or window failure. Disposal and fallback paths must be idempotent.
- Keep the iOS 26 `WKUIDelegate` geolocation decision callback compiler- and availability-guarded for iOS 15, forward `allow` through the existing channel contract, and call WebKit's decision handler exactly once.
- Keep filesystem and URL mappings least-privilege. Do not broaden `FileProvider`, local-origin, or universal file access without a documented threat-model decision.
- Do not hand-edit generated `*.g.dart`, plugin registrants, lockfiles, or native generated metadata; regenerate and inspect. `web_support/` builds `flutter_inappwebview_forge_web/lib/assets/web/web_support.js`; do not edit the bundle.
- Use ASCII for new documentation and source unless the file already needs another character set.
- Never publish (`npm run publish:*`), commit, or push without explicit authorization.

## Commands

Run from the repository root with the FVM SDK. Run `fvm flutter pub get`
before any `--no-pub` command.

```sh
fvm flutter pub get
fvm flutter analyze --no-pub
fvm flutter test --no-pub
npm run build    # build_runner for the platform interface; inspect generated diffs
npm run format
```

## Test selection

- Dart API / platform interface: test the platform interface and the root package.
- Android, iOS/macOS, Windows, Linux native: run the package tests and build the native example on the target OS. A Dart-only test is not enough for native changes. IME, fullscreen, keyboard, scene, WebView-provider, and renderer behavior need a real device.
- Web: package tests plus browser integration tests, same-origin and cross-origin separately.
- Integration behavior: `flutter_inappwebview_forge/example/integration_test/` or the platform example's integration tests.

Focused commands and tool scripts are listed under "Test ladder" in `docs/development.md`.

## Issues and records

Follow [`docs/issue-resolution-workflow.md`](docs/issue-resolution-workflow.md):
record, reproduce, trace both the Dart and native side of the whole call path,
add a failing regression test, make the smallest idempotent fix, validate, then
update records. An issue is not locally resolved until source, regression
coverage, validation status, changelog, and records agree.

Record each fact once:

- `docs/known-issues.md` holds the detailed record (root cause, fix, evidence, remaining gaps).
- `docs/issue-pr-resolution-log.md`, `docs/open-work-plan.md`, and `docs/runtime-validation-pending.md` get a short status entry that links to it. Do not copy root cause or evidence text into them.
- Implemented but missing device/runtime evidence: list it in `runtime-validation-pending.md`, not as resolved. A failed runtime gate moves it back to `open-work-plan.md`.
- Never present a CSV `OPEN` value as an upstream-closed issue; export metadata and local status are separate.
- These files are large: search for the issue number and read only the matching section.
- Engineering records go in `docs/`; application-facing guides go in `documentation/`. Update the relevant `docs/` document when behavior, support, migration, or validation status changes.

Changelogs: put the full entry under `## Unreleased` in the affected package's
`CHANGELOG.md`. The root package changelog gets one short line per
user-visible change. Bump versions only for a release.

## Review checklist

- Correct federated layer; nullability and unknown-enum handling at every native/Dart boundary.
- Attach, detach, reattach, KeepAlive, renderer-loss, and dispose paths.
- A regression test exists before a platform-specific workaround changes.
- Generated files, versions, lockfiles, changelogs, and README requirements are consistent.
- No unrelated or personal files in the diff; `git diff --check` is clean.
