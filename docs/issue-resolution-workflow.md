# Issue Resolution Workflow

This document defines the required workflow for resolving an issue in
flutter_inappwebview_forge. It applies to upstream issues, locally discovered
bugs, crash reports, performance regressions, security findings, compatibility
problems, and build failures.

An issue is not complete merely because the code compiles or a local test
passes. Completion requires a reproducible explanation, a scoped fix, focused
regression coverage, affected-platform validation, and updated project
documentation.

## Lifecycle

Every issue follows this sequence:

1. Intake and scope
2. Reproduction and baseline
3. Ownership and call-path tracing
4. Implementation plan
5. Fix and regression coverage
6. Validation
7. Documentation and release metadata
8. Review, commit, and delivery

If a step cannot be completed, record the limitation and keep the issue open
for the missing evidence. Source-level validation and device/runtime
validation must never be presented as equivalent.

## 1. Intake and scope

Create a local issue record before changing code. Capture:

- The upstream issue or pull request URL, if one exists.
- The local status: investigating, reproduced, planned, implemented,
  source-validated, device-validated, or blocked.
- The affected federated package and platform.
- The first affected and last known-good versions.
- OS version, device or emulator model, Android System WebView package or
  WebKit/Xcode version, Flutter/Dart version, and build mode.
- The complete exception, native stack, Dart stack, or performance symptom.
- Whether the exported issue state is OPEN or CLOSED. An export is historical
  metadata; it does not prove the local branch has or has not fixed the issue.
- Severity and user impact: crash, data loss, security, freeze/ANR,
  incorrect behavior, performance, API compatibility, or build failure.

For crash reports, preserve the original frame addresses and the runtime
package/version. Do not infer a root cause from a symbol-stripped native
stack alone. For performance reports, record a before measurement instead of
relying on a subjective improvement.

Use this minimal record:

    Upstream reference:
    Local status:
    Affected package/platform:
    First affected version:
    Environment:
    Reproduction:
    User impact:
    Initial hypothesis:
    Required evidence:

## 2. Reproduction and baseline

Reproduce the issue with the smallest useful scenario:

1. Reduce the report to one page, one WebView, one navigation, or one
   lifecycle transition where possible.
2. Confirm whether the failure requires a specific OS, WebView provider,
   WebKit version, composition mode, content world, renderer state, or
   Flutter platform-view lifecycle.
3. Record the baseline behavior and the expected behavior.
4. Add a failing regression test before the implementation when the behavior
   can be tested without a device.
5. If a device or provider is required, add the closest deterministic
   source-level/static test and explicitly record the missing runtime gate.

A useful baseline includes:

- Reproduction rate and number of attempts.
- Crash, ANR, timeout, or callback-loss count.
- Event or channel call rate for high-frequency issues.
- p50, p95, worst-case latency, dropped frames, and memory where relevant.
- The exact final position, callback payload, or error contract expected by
  the caller.

For Android and iOS lifecycle reports, test creation, attach, detach,
reattach, KeepAlive reuse, renderer/process failure, and disposal. A fix that
works only during the initial attach path is incomplete.

## 3. Ownership and call-path tracing

Identify the complete federated path before editing:

    public Dart API
      -> platform interface
      -> method/event channel or platform view
      -> native implementation
      -> WebView/WebKit/WebView2/WPE callback
      -> native callback completion
      -> Dart event or result

Use the repository code knowledge graph first:

- search_graph: find the owning function, class, channel, or variable.
- trace_path: find callers, callees, and lifecycle impact.
- get_code_snippet: inspect the exact implementation after its qualified name
  is known.
- query_graph: inspect multi-hop relationships or hot paths.

Use rg for string literals, configuration values, generated metadata, shell
files, and other files that are not represented reliably in the graph.

During tracing, identify:

- The owning package and platform layer.
- Public API and generated capability metadata affected by the change.
- Channel names, method names, event payload keys, platform-view IDs, and
  JavaScript bridge names that must remain compatible.
- Main-thread, background-thread, WebView-thread, and callback-thread
  requirements.
- Nullable values, unknown enum values, renderer loss, window loss, and
  disposal races.
- Existing fallbacks and the behavior when the Dart side is slow or absent.

Do not patch only the first stack frame. Trace the caller and completion path
so that the fix does not move the failure to a different lifecycle state.

### Federated full-stack requirement

Every issue must be reviewed across both sides of the federated contract:

- Flutter/Dart API, widget, controller, event handler, serialization, and
  error handling.
- Platform interface methods, events, capability metadata, and generated
  serializers when applicable.
- The affected native implementation: Kotlin/Android, Swift/iOS or macOS,
  C++/Windows or Linux, or JavaScript/Web as applicable.

If the report appears to be native, inspect the Flutter call site,
platform-interface contract, payload decoding, callback completion, and
lifecycle assumptions before declaring the native fix complete. If the report
appears to be Dart-side, inspect the native channel dispatch, payload shape,
threading, WebView/WebKit callback, and disposal path as well.

A one-sided fix is incomplete when the other side still has an incompatible
method signature, event payload, nullability assumption, generated capability,
fallback, lifecycle path, documentation example, or regression gap. The
resolution record must state which Flutter and native files were inspected and
why an implementation change was or was not required on each side.

## 4. Implementation plan

Write or update the appropriate plan before a multi-file or behavior-changing
implementation. The plan must state:

- Root cause or current hypothesis, with evidence.
- Exact files and federated layers to change.
- Public-contract impact and whether the change is breaking.
- Older-runtime and unsupported-feature fallback behavior.
- Regression test and validation matrix.
- Rollback boundary if the change affects startup, channels, composition,
  lifecycle, or dependency versions.
- Documentation and release metadata that must change after implementation.

Use these documents for planning:

- docs/open-work-plan.md for prioritized unresolved work and acceptance gates.
- docs/known-issues.md for issue root cause, mitigation, and validation gaps.
- docs/performance-and-webview-upgrade-plan.md for performance and dependency
  work.
- docs/android-kotlin-kts-migration-plan.md for Android build/native migration.
- docs/ios-uiscene-spm-migration-plan.md for Apple lifecycle/package migration.

Do not treat an upstream PR as an implementation plan. Re-implement the
necessary behavior against the current fork, preserve the fork package names,
and add local regression coverage.

## 5. Fix and regression coverage

Implement the smallest change that addresses the proven failure:

- Update the platform interface before or together with native implementations
  when a public setting, enum, method, event, or capability changes.
- Review the corresponding Flutter/Dart and native paths for every issue. Do
  not close an issue after fixing only one side of the federated contract.
  Update both sides when their behavior, payload, lifecycle, or assumptions
  are coupled; record an explicit no-change justification when one side only
  needs verification.
- Regenerate generated Dart/native metadata through the repository generator.
  Do not hand-edit generated files.
- Preserve MethodChannel/EventChannel names, payload shape, platform-view IDs,
  and JavaScript bridge names unless a breaking migration is intentional.
- Treat native input as nullable and unknown. Do not use force unwraps for
  WebView, WebKit, WebView2, WPE, or platform-channel values.
- Make disposal, fallback, retry, renderer-loss, and reattach paths idempotent.
- Keep security-sensitive mappings least-privilege and document any threat
  model decision before broadening access.
- Keep high-frequency work off the UI/main thread where the platform allows
  it, but do not make a callback asynchronous when the native API requires a
  synchronous response without a documented fallback.
- Preserve terminal events and callback completion when coalescing or
  throttling events.

The regression test should fail for the original scenario and pass because of
the fix. Prefer behavioral tests. Static source assertions are acceptable for
native code when a host runtime is unavailable, but the remaining device
validation must be recorded.

## 6. Validation

Run the smallest useful check first, then expand to the affected platform:

1. Format the changed Dart/Kotlin/Swift files.
2. Run the focused package tests.
3. Run platform-interface and root tests for public API changes.
4. Run the native compile/build for the affected example.
5. Run device or runtime integration tests for lifecycle, WebView provider,
   WebKit, composition, IME, fullscreen, renderer, and native crash changes.
6. Run analysis and generation checks when source models or public APIs
   changed.
7. Run release-artifact and dependency checks for build/dependency changes.

Record each check as one of:

- Passed: command and relevant environment are known.
- Not run: explain why it was outside the issue scope.
- Blocked: identify the missing tool, device, provider, or external state.
- Source-only: static coverage passed but runtime behavior is not proven.

For performance fixes, compare before and after on the same fixture and
environment. Report the metric, sample count, p50, p95, worst case, dropped
frames, memory, and error/timeout counts. Do not claim a performance
improvement from a code inspection alone.

For Android, include API level, device model, Android System WebView package,
composition mode, and release/profile mode. For iOS, include OS version,
device/simulator, Xcode/SDK, WebKit behavior, and SPM/CocoaPods path when
relevant.

## 7. Documentation and release metadata

Documentation updates are mandatory after an issue is resolved. Update the
documents that describe the affected behavior, not only the source code.

At minimum, update:

- The affected package CHANGELOG.md with the behavior, compatibility,
  security, performance, or build change.
- The root package CHANGELOG.md when the public package behavior, dependency
  graph, or release contains the fix.
- docs/known-issues.md with the root cause, local resolution, validation
  status, and remaining device/provider limitations.
- docs/issue-pr-resolution-log.md with the issue/PR reference, local status,
  changed package, tests/builds, and commit or release reference. Keep the
  imported CSV state unchanged and distinguish it from local status.
- docs/open-work-plan.md by checking off completed work, updating counts and
  priorities, and leaving explicit follow-up validation items.
- The relevant architecture, migration, performance, security, API, README,
  or support-matrix document when the issue changes those contracts.
- docs/README.md when a new durable document is added.

Also verify:

- Package versions and dependency constraints are consistent.
- Lockfiles are regenerated with the package manager and inspected, never
  manually edited.
- Generated files, plugin registrants, native manifests, podspecs, Gradle
  files, and SPM manifests are regenerated or validated as appropriate.
- README deployment targets, prerequisites, and examples still match the
  implementation.

An issue is resolved only when the issue record, source, tests, release
metadata, and relevant documentation tell the same story.

## 8. Review, commit, and delivery

Before committing:

1. Review git diff and git status.
2. Run git diff --check.
3. Confirm no personal absolute paths, local build outputs, unrelated edits,
   or generated artifacts were included.
4. Confirm the changelog and version changes match the actual scope.
5. Confirm validation gaps are written down.

Use a commit message that describes the user-visible or technical outcome,
for example:

    fix(android): guard disposed WebView callbacks
    perf(ios): coalesce content-size KVO updates
    docs: document issue resolution workflow

Push only when explicitly requested or authorized. After pushing, verify the
remote branch, commit hash, and clean working tree. If a release or issue
tracker update is not authorized, leave it as a documented follow-up instead
of performing it implicitly.

## Definition of done

An issue is ready to mark locally resolved when all applicable conditions hold:

- The root cause is documented with evidence.
- A regression test or an explicit device-test scenario covers the failure.
- The fix preserves the public/native contract or documents the breaking
  migration.
- Focused tests and the affected native build pass.
- Runtime/device validation is complete or the limitation is explicit.
- Affected changelogs, versions, lockfiles, and generated outputs are
  consistent.
- known-issues.md, issue-pr-resolution-log.md, open-work-plan.md, and any
  relevant technical document are updated.
- The diff contains no unrelated or personal files.
- The commit and remote state are recorded when delivery was authorized.
