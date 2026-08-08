# Project Documentation

This directory describes the architecture, development workflow, native-platform constraints, and issue/PR resolution history of `flutter_inappwebview_forge`.

## Start here

- [Project overview](project-overview.md) explains the federated package graph and platform boundaries.
- [Development guide](development.md) covers setup, code generation, tests, native builds, and release checks.
- [Issue resolution workflow](issue-resolution-workflow.md) defines the required triage, implementation, validation, and documentation steps for each issue.
- [Issue and PR resolution log](issue-pr-resolution-log.md) records the supplied CSV snapshots and the local fixes they informed.
- [Open work plan](open-work-plan.md) lists unresolved work, priorities, acceptance criteria, and implementation phases.

## Existing plans and triage

- [Known issues and upstream triage](known-issues.md) contains detailed root-cause notes, mitigations, and validation gaps.
- [Android Kotlin/KTS migration plan](android-kotlin-kts-migration-plan.md) tracks the Android native migration and remaining AGP built-in Kotlin work.
- [Apple UIScene/SPM migration plan](ios-uiscene-spm-migration-plan.md) tracks scene lifecycle and package-manager support.
- [Performance and WebView upgrade plan](performance-and-webview-upgrade-plan.md) tracks startup, channel pressure, lifecycle, and dependency validation.

## Documentation rules

- Record behavior and support changes in the affected package changelog as well as here when the change affects contributors or integrators.
- Use exact package paths and version requirements from `pubspec.yaml`, podspecs, Gradle files, and native manifests.
- Mark device, browser, WebView, WebKit, WPE, and Xcode validation separately from source-level or static-test validation.
- Treat upstream issue/PR state in an export as historical metadata. Local implementation status is documented from repository evidence.
