# Agent Guide

This repository is the `flutter_inappwebview_forge` federated Flutter plugin. It is a maintained fork of Flutter InAppWebView, so changes must preserve both the public Dart API and the native platform contracts unless a breaking change is explicitly intended.

## Repository map

| Path | Responsibility |
| --- | --- |
| `flutter_inappwebview_forge/` | Public Dart package, shared widgets, assets, and the main example app |
| `flutter_inappwebview_forge_platform_interface/` | Federated platform interface, shared types, generated serializers, and capability metadata |
| `flutter_inappwebview_forge_android/` | Android WebView, Kotlin native implementation, and Android example |
| `flutter_inappwebview_forge_ios/` | iOS `WKWebView`, Swift Package Manager/CocoaPods integration, and iOS example |
| `flutter_inappwebview_forge_macos/` | macOS `WKWebView`, Swift Package Manager/CocoaPods integration, and macOS example |
| `flutter_inappwebview_forge_windows/` | Windows WebView2 C++ implementation and Windows example |
| `flutter_inappwebview_forge_linux/` | Linux WPE WebKit C++ implementation and Linux example |
| `flutter_inappwebview_forge_web/` | Browser iframe implementation and Web example |
| `dev_packages/` | Internal annotations and code generators |
| `tool/` | Repository checks, including Android 16 KB artifact validation |
| `docs/` | Architecture, development, migration, triage, and release notes |

## Working rules

- Keep the federated package name `flutter_inappwebview_forge` and the `com.emirkanacar.flutter_inappwebview_forge_android` Android namespace. Do not reintroduce upstream package names in active source.
- Treat MethodChannel/EventChannel names, method names, event payload maps, platform-view IDs, JavaScript bridge names, and generated capability metadata as compatibility surfaces.
- Change the platform interface before or together with a platform implementation when a public setting, enum, event, or method changes.
- Native callbacks are versioned and nullable input. Do not force-unwrap values from WebView2, Android WebView, WebKit, WPE, or platform channels.
- Lifecycle callbacks are not guaranteed during renderer, GPU, surface, process, or window failure. Disposal and fallback paths must be idempotent.
- Keep security-sensitive filesystem and URL mappings least-privilege. Do not broaden `FileProvider`, local-origin, or universal file access without a documented threat-model decision.
- Update the affected package `CHANGELOG.md` for behavior, API, compatibility, or release changes. Link related issue/PR records when the change is based on the triage log.
- Do not hand-edit generated `*.g.dart`, plugin registrants, lockfiles, or native generated metadata unless the package explicitly owns that generated file. Regenerate and inspect the result instead.
- Use ASCII for new documentation and source unless the existing file requires another character set.

## Toolchain baseline

- FVM selects Flutter `3.38.6` from `.fvmrc`.
- The root package requires Dart `^3.8.0` and Flutter `>=3.38.6`.
- iOS support starts at iOS 15.0. macOS starts at 10.14. Android declares `minSdkVersion 19`; verify effective AndroidX requirements before changing that contract.
- Android native code is Kotlin and the Android build uses Kotlin DSL. The built-in Kotlin/AGP 9 migration is tracked in [`docs/android-kotlin-kts-migration-plan.md`](docs/android-kotlin-kts-migration-plan.md).
- iOS and macOS support Swift Package Manager while retaining CocoaPods. The design is documented in [`docs/ios-uiscene-spm-migration-plan.md`](docs/ios-uiscene-spm-migration-plan.md).
- Linux requires WPE WebKit and its development packages. Read `flutter_inappwebview_forge_linux/WPE_BACKEND.md` before changing CMake or rendering code.
- Windows depends on the WebView2 runtime and native C++/WinRT tooling.

## Dependency and code generation workflow

Run commands from the repository root. Prefer the FVM binary when it is available:

```sh
fvm flutter pub get
fvm flutter analyze --no-pub
fvm flutter test --no-pub
```

The repository scripts in `package.json` are the canonical multi-package commands:

```sh
npm run build
npm run format
npm run docs:gen
```

`npm run build` runs `build_runner` for the platform-interface package. After generation, inspect all changed generated files and run the platform-interface tests.

## Test selection

- Dart API/platform-interface change: test `flutter_inappwebview_forge_platform_interface` and the root package.
- Android channel, lifecycle, security, or WebView change: run the Android package tests and build the Android example; use a real device for IME, fullscreen, WebView-provider, and renderer behavior.
- iOS/macOS change: run package tests, native static tests, Swift package checks, and an Xcode build; use physical Apple devices for scene, keyboard, fullscreen, and WebKit behavior.
- Windows/Linux native change: run the package tests and native example build on the target OS. A Dart-only test is not sufficient for C++/WinRT/WPE changes.
- Web change: run the Web package tests and browser integration tests; same-origin and cross-origin behavior must be tested separately.
- Integration behavior: use the main example under `flutter_inappwebview_forge/example/integration_test/` or the platform example integration test.

Useful focused commands:

```sh
cd flutter_inappwebview_forge_platform_interface && fvm flutter test
cd flutter_inappwebview_forge_android && fvm flutter test
cd flutter_inappwebview_forge_ios && fvm flutter test
cd flutter_inappwebview_forge_web && fvm flutter test
tool/check_android_16k_alignment.sh <release.apk-or-aab>
```

For Apple package validation, use `swift package dump-package` in each native package and build with the full Xcode installation. For Linux, verify the required `pkg-config` modules before running Flutter.

## Review checklist

- Confirm the change is in the correct federated layer.
- Check nullability and unknown-enum handling at every native/Dart boundary.
- Check attach, detach, reattach, KeepAlive, renderer-loss, and dispose paths.
- Add or update a regression test before changing a platform-specific workaround.
- Verify generated files, package versions, lockfiles, changelogs, and README requirements.
- Update the relevant document in `docs/` when behavior, support, migration, or validation status changes.
- Never represent a CSV `OPEN` value as an upstream-closed issue. The local implementation status and the export metadata are separate; see [`docs/issue-pr-resolution-log.md`](docs/issue-pr-resolution-log.md).

## Issue resolution workflow

Follow [docs/issue-resolution-workflow.md](docs/issue-resolution-workflow.md) for every issue. The required sequence is:

1. Record the upstream reference, local status, affected package/platform, environment, severity, and original evidence.
2. Reproduce the issue and capture a baseline. Mark source-only validation separately from device/runtime validation.
3. Trace both the Flutter/Dart and native sides of the complete platform-interface, channel, WebView/WebKit, and callback lifecycle path. A fix is incomplete if one side is changed while the other side's contract, payload, nullability, fallback, or lifecycle behavior is left inconsistent.
4. Write the root cause hypothesis, affected files, compatibility/fallback behavior, acceptance criteria, and documentation updates into the relevant plan.
5. Add a failing regression test, inspect and test both Flutter and native paths, then implement the smallest idempotent fix while preserving public and native contracts. If one side requires no code change, record why it was verified and left unchanged.
6. Run focused tests, affected native builds, generation/format checks, and required device/provider validation.
7. After the fix is validated, update the affected package changelog and version metadata, plus docs/known-issues.md, docs/issue-pr-resolution-log.md, docs/open-work-plan.md, and any relevant architecture, migration, performance, security, API, README, or support documentation.
8. Review the diff for unrelated or personal files, run git diff --check, and commit/push only with authorization.

An issue must not be marked locally resolved until the source, regression coverage, validation status, changelog, release metadata, and relevant documentation agree. An upstream CSV state remains historical metadata and must not be changed to imply local resolution.

## Documentation index

- [`docs/README.md`](docs/README.md): documentation entry point.
- [`docs/project-overview.md`](docs/project-overview.md): architecture and package responsibilities.
- [`docs/development.md`](docs/development.md): setup, tests, native validation, and release workflow.
- [`docs/known-issues.md`](docs/known-issues.md): detailed issue triage and remaining validation.
- [`docs/issue-pr-resolution-log.md`](docs/issue-pr-resolution-log.md): supplied issue/PR export and local resolution history.
- [`docs/open-work-plan.md`](docs/open-work-plan.md): unresolved work, priorities, acceptance criteria, and implementation sequence.
