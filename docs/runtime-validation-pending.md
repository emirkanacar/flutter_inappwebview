# Runtime Validation Pending

Last reviewed: 2026-08-13

This register contains issue records whose local implementation or mitigation
is complete, but whose target device, provider, browser, native runtime, or
release artifact has not yet been exercised. These records are not active
implementation work and are excluded from the counts in
[open-work-plan.md](open-work-plan.md). Their root-cause notes and acceptance
details remain in [known-issues.md](known-issues.md).

The counts table and issue register above are authoritative for the current
snapshot. Dated validation notes below retain the count that was current when
each note was recorded.

## Current counts

| Local status | Issue records | Count | Meaning |
| --- | --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | Issue register below | 77 | Source, regression, and host/build checks pass; real validation remains. |
| Resolved locally; no runtime gate | [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | 1 | Pure Dart serialization is covered by a focused regression test; no device/provider behavior is involved. |
| Closed by source review | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | 1 | No plugin-owned security sink was found; no package runtime test is required. |
| Host/platform-specific boundary | [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680), [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727), [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753), [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796), [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | 15 | Strong evidence points to Apple/WebKit Simulator or callback limitations, Android framework/provider/dependency, host app/site/Firebase configuration, and Flutter engine/platform-view behavior; no Forge-owned control point is available. |
| Open implementation or reproduction | [open work plan](open-work-plan.md) | 31 | No complete local implementation boundary has been established. |
| **Issue export total** | 125 | **125** | Historical export count; upstream `OPEN` state is unchanged. |

Eight PR-only records also have local implementations but remain outside the
125-issue count: [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243),
[#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771),
[#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871),
[#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474),
[#2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823),
[#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853), and
[#2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743), and
[#2825](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2825).

PR [#2825](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2825)
is source-fixed in Android 1.0.52, iOS 2.1.29, macOS 1.1.8, Windows 1.0.12,
Linux 1.0.7, platform-interface 1.1.13, and root 2.1.66 for the
Android/iOS/desktop container API slice.
`ContainerController` manages named containers; AndroidX WebKit profiles are
bound before WebView state setup and scoped cookie calls resolve the profile
cookie store through the WebView controller id; iOS 17+ binds UUID identifiers
to `WKWebsiteDataStore` and routes controller-scoped cookie calls to that
data store; iOS 17+ also applies `proxySettings` to the selected data store;
Android `CookieManager.flush` fans out to all container profiles, and
`ContainerController.clearContainerData` clears supported container data
without deleting the profile.
The Android source suite, `compileDebugKotlin`, and Xcode iOS example build
pass. A physical Android provider with WebView 110+
must still verify two same-origin WebViews, cookie/local-storage separation,
profile deletion after disposal, and fallback behavior without `MULTI_PROFILE`;
physical iOS 17+ must verify the same data-store lifecycle. The desktop
adapters are source-complete. macOS and Linux cookie operations now resolve
the selected WebView store/session, and macOS 14+, Linux, and Windows accept
per-WebView proxy settings. Windows maps the first/default proxy rule and
bypass list to WebView2 environment arguments; an explicitly supplied
`WebViewEnvironment` cannot be reconfigured after creation. Target-OS
builds/runtime validation remain pending.

### Android/iOS lifecycle ownership and settings diff validation

The Android 1.0.53 and iOS 2.1.31 implementation wave is source-complete for
the scoped lifecycle boundary. Manager maps remove retained/headless
instances before disposal, duplicate IDs dispose the previous owner, and
headless disposal is idempotent. Both native packages now have an internal
lifecycle coordinator; post-dispose callbacks are rejected, and tracked
async JavaScript callbacks complete at most once. Android skips unchanged
content-blocker and asset-loader work; iOS skips unchanged content-blocker
compilation and preserves omitted values in partial settings updates.
Android and iOS pull-to-refresh delegates reject callbacks from a disposing
WebView and reset the native refresh indicator. Native user/plugin script
registration also skips active duplicates while retaining retry behavior for
registrations that previously failed.
Android JavaScript bridge work is rejected before queueing and again before a
queued response is evaluated after disposal begins. iOS evaluateJavascript
completion callbacks are tracked as lifecycle operations and drained once on
navigation or disposal; the MethodChannel result contract is unchanged.
Android and iOS native MethodChannel callback results, including default
decisions, now pass through exactly-once completion gates, preventing a late
result from repeating a callback or fallback after teardown. The gate also
rejects a later fallback after a handled result while preserving the native
default invoked by the active completion handler.
Android JavaScript UI and bridge error callbacks claim the same boundary
before native cancel/reject fallback actions.
Delayed Android IME, scroll-stop, and context-menu callbacks now also check the
same lifecycle state before touching native UI. iOS delayed keyboard, gesture,
scroll, content-size, and context-menu callbacks use weak ownership and the
same lifecycle gate. Focused source tests cover these teardown races; target
IME/keyboard runtime validation remains pending.
The follow-up audit also gates Android floating-menu repositioning and runtime
plugin-script callbacks, plus iOS delayed focus/image-reference lookups. The
iOS incremental settings path now applies `isPagingEnabled` to the matching
scroll-view property; source coverage is present and device validation remains
pending.
Android web-archive and iOS screenshot/PDF/web-archive native completions are
also lifecycle-tracked and are drained once with their existing null-result
shape when disposal wins the race. Source and host-build coverage is present;
target runtime validation remains pending.
The iOS popup window initialization and fullscreen-container main-queue
callbacks also re-check lifecycle admission before mutating native UI state.
Android screenshot work and initial platform-view loading now also stop when
the lifecycle begins disposal; the source regression covers both posted paths.
Android print-job and Custom Tabs managers, plus the iOS print-job,
authentication-session, and in-app-browser managers, now snapshot and clear
their non-null ownership maps before disposing children; child cleanup removes
only its own already-detached entry. Source and host validation pass, while
target runtime validation remains pending.
Android asynchronous JavaScript operations now also complete once when script
preparation throws or the WebView evaluation post cannot be queued. iOS
screenshot compression options use safe defaults for malformed channel values;
source tests and host builds pass, with provider/runtime validation still
pending.
The Android and iOS lifecycle coordinators now serialize state transitions and
debug-trace access, closing concurrent-dispose/renderer callback races without
changing the public API or channel contract.
The iOS KVO registrations are tracked per observed object/key path, so teardown
removes only observers that were registered during partial or complete setup.
The headless-to-normal factory handoff now restores active manager ownership
after the old headless entry is detached. Source and host validation cover the
ownership invariant; device/provider runtime validation remains pending.
The iOS WebKit delegate now completes stale permission, navigation,
authentication, dialog, and popup callbacks with native defaults after
disposal. The behavior remains source-validated pending the physical iOS
keyboard/scene/popup/provider matrix.
Focused package tests, Android example Kotlin compilation, SwiftPM manifest
validation, and the iOS example device build pass. Example-wide Dart analysis
still reports pre-existing example-only diagnostics and is not used as the
platform-native lifecycle gate.

The iOS simulator passed a fresh 100-cycle create/dispose/recreate run on
2026-08-13; all 100 pending JavaScript calls reached the safe terminal result,
and the test exited successfully without a crash, ANR, or Dart failure. The
separate 50 keep-alive reattachment plus 50 headless-to-normal transfer
diagnostic also remains passed. The connected physical iOS device previously
passed the same 100-cycle disposal/recreate diagnostic with only
`WebView disposed` or `WebView navigation started` terminal outcomes, plus 50
keep-alive and 50 headless-to-normal transfer cycles, before the final iOS
headless deferred cleanup path was added. All physical runs used
`--no-uninstall`; the final physical-device matrix remains pending.
On the same host, `xcrun devicectl` reported the paired physical iPhone as
available, but Flutter's device discovery did not expose that identifier, so
no physical iOS install or test was attempted and the app/profile was not
removed.
After the guaranteed Android `finally` and iOS/macOS `defer` cleanup paths were
added, the iOS 26.2 Simulator reran the 100-cycle disposal diagnostic and the
50 keep-alive plus 50 headless-transfer diagnostic successfully, again without
uninstalling the app.
On 2026-08-13, before the final Android headless guaranteed-cleanup path was
added, the connected Android API 36 device passed the 100-cycle
disposal/recreate diagnostic with 100/100 `WebView disposed` outcomes and the
50 keep-alive plus 50 headless-to-normal transfer diagnostic. Both runs used
`--no-uninstall`; no app removal or profile reset was performed. The final
Android code then reran on the `Medium_Phone` API 35 emulator on 2026-08-13:
100/100 disposal/recreate outcomes were `WebView disposed`, and the 50
keep-alive plus 50 headless-to-normal transfer cycles passed. This final run
also used `--no-uninstall`; no app removal or profile reset was performed.
Physical API 36/OEM/provider validation remains required. The
transfer diagnostic now polls a page marker instead of requiring optional
`onLoadStop` delivery and records phase-specific timeouts. The desktop
and Web ownership slice is source-complete: Web tests and the example web
build pass; macOS source tests and SwiftPM manifest validation pass; Windows
and Linux source tests pass.
After the exactly-once callback gate was tightened, the Android API 35
`Medium_Phone` emulator passed a fresh 100-cycle disposal/recreate diagnostic
with 100/100 `WebView disposed` outcomes, followed by 50 KeepAlive and 50
headless-to-normal ownership transfers. These runs used `--no-uninstall`; the
existing package remained installed and no profile reset was performed. The
host's Flutter command normally selects Gradle 8.13, which is incompatible
with the installed Java 24 runtime, so this validation used the already
available Gradle 9.2.1 distribution through a temporary wrapper override; the
wrapper was restored to Gradle 8.13 afterward. Post-test logs contain no app
fatal, ANR, signal, or OOM signature. Physical API 36/OEM/provider coverage
remains required. The iOS simulator service was unavailable on the host and
the Xcode beta installation no longer exposed `Simulator.app`, so no new
simulator installation or removal was attempted. Target-runtime validation
remains pending, with
the macOS example build blocked by the host Xcode beta's 12.0 deployment-target
floor, Windows native build unavailable on macOS, and Linux native build
blocked by missing WPE/pkg-config tooling. Still required: physical Android
renderer-loss/fullscreen/IME/provider coverage, physical iOS
keyboard/scene/popup/provider coverage, and target-runtime desktop/Web
validation. The available Android AVDs also cannot start with the installed
emulator binary because its Qt build requires unsupported `neon` processor
features; an ADB-connected Android target is still required. The diagnostic
commands are in
`flutter_inappwebview_forge/example/integration_test/`.

The Android and iOS headless-to-normal transfer path also removes the
transferred WebView from its old active ownership map before the headless
wrapper is disposed, so one native WebView cannot remain indexed under both
identities. Android and iOS source regression tests and the Android Kotlin/iOS
example builds cover this ownership boundary. Android, iOS, and macOS manager
teardown remains map-first, and the Android/iOS factories now remove the
headless entry before attempting the native handoff. Entries without a native
view are disposed instead of being silently lost, and identity checks prevent
late cleanup from removing a newer owner. Duplicate headless IDs also dispose
an active owner in the shared native ID namespace. This follow-up is
source-validated only; target provider and device validation remains pending.
teardown also clears active and retained ownership before disposing every
remaining native WebView; package source tests cover the new cleanup ordering.
The Android `finally` and iOS/macOS `defer` paths also force every accepted
dispose call to reach the terminal lifecycle state.

The currently installed Flutter toolchain does not expose a
`flutter drive --no-uninstall` option, but the integration diagnostics run
successfully through `flutter test --no-uninstall`. Its wireless physical-iOS
diagnostic still requires `--publish-port`, which `flutter test` does not
accept. No installed app was removed during these lifecycle runs.

### Desktop and Web ownership hardening

The macOS 1.1.9, Windows 1.0.14, Linux 1.0.8, and Web 1.0.3 source wave now
removes nullable ownership placeholders, replaces duplicate IDs explicitly,
and makes disposal/removal ordering deterministic. Web headless-to-regular
transfer retains the iframe and JavaScript bridge, updates the JavaScript view
identity, and rebinds the regular WebView MethodChannel. Linux enables
`is_disposing_` before any destructor cleanup can trigger WPE callbacks.
Linux and Windows retained ownership now use internal lifecycle coordinators
for detach/reattach and disposal admission.
Web create, retained-transfer, reattach, and disposal share one internal
lifecycle coordinator; callbacks are rejected after teardown while the
MethodChannel contract remains unchanged. Web scroll notifications are
coalesced to one channel dispatch per animation frame; a queued frame is
harmless after manager ownership is removed. Linux WebKit/WPE settings now use
a previous snapshot to skip unchanged native setters and duplicate content
blocker compilation.
The iOS and macOS delegates also gate outgoing callbacks through lifecycle
state, including WebMessage and FindInteraction sub-delegates; pending
MethodChannel results are drained exactly once during teardown. macOS completes
pending native and legacy async JavaScript callbacks exactly once during
disposal. iOS/macOS source suites and the iOS example build pass, while the
macOS example and target runtime matrices remain pending.
Android channel events and decision callbacks are lifecycle-gated with native
fallback completion, and the headless wrapper shares the coordinator. Android
source tests, Kotlin compilation, and the example `:app:assembleDebug` build
through Gradle 9.2.1 pass; physical Android validation remains pending by
request, with no device or simulator run in this validation pass.
Focused package/source tests pass. Real Web browser same-origin/cross-origin
and headless transfer tests, macOS consuming-app/physical WebKit tests,
Windows WebView2 tests, and Linux WPE backend tests remain required.
The Web adapter also caches its last settings snapshot so unchanged updates do
not cross the JavaScript interop boundary. Its outgoing load, popup, window,
fullscreen, bridge, and injected-script callbacks now re-check lifecycle state
after asynchronous channel work; duplicate async completions are ignored by
operation ID. The Web package tests and example Web build pass. Browser
same-origin/cross-origin, retained-transfer, and disposal runtime validation
remain pending; no device or browser runtime was used for this source/host
validation pass.

### Local input accessory and cross-platform autocorrection validation

The iOS input responder refresh and cross-platform
`disableAutocorrection` document-start setting are source-complete in root
2.1.70, iOS 2.1.31, Android 1.0.53, macOS 1.1.9, Windows 1.0.14, Linux 1.0.8,
Web 1.0.3, and platform-interface 1.1.17. This local feature is not part of
the 125-record upstream issue count. Validate on physical iOS 15+ with
repeated focus changes between HTML inputs and accessory enabled/disabled.
Validate the setting on each target platform with input, textarea,
contenteditable, and dynamically-created fields. Confirm that the
page-level autocorrection/spellcheck hints do not alter unrelated WebViews.

Android PR [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243)
is source-fixed in Android 1.0.41: the file chooser now canonicalizes and
rejects private-sandbox `/data/` `file://` results across single, multi-select,
and legacy callbacks. `content://` selections and FileProvider capture URIs
remain allowed. The Android package suite passes 48/48 tests, `compileDebugKotlin`,
and the `assembleDebug` AAR task. The Flutter APK wrapper is blocked by the
existing Gradle 8.13/JDK `OutgoingVariantsReportTask` compatibility failure;
an adversarial external-picker/provider matrix across API levels also remains
pending. This PR-only record does not change the 74-issue count.

### 2026-08-12 Android 16/API 36 validation note

The connected physical Android 16/API 36 device with WebView 151.0.7922.83
passed the IME lifecycle (#2555), fullscreen keyboard (#2878), disposal
lifecycle (#2654), renderer/fullscreen (#2819), screen-lock redraw (#2837),
cold-start/headless bridge (#2843/#2849), Bundle codec/activity handoff
(#2536), WebView-to-Flutter transition (#2688), rapid interception/navigation
(#2580), and cookie mutation/explicit flush (#2718) diagnostics. Four
headless document-start cycles also passed. These results narrow the remaining
gates but do not remove Android 10/11, OEM/provider, release, or exact
renderer-loss requirements from the register. The #2721 display-size override
was restored to the physical size, but the Activity/VM service restarted during
the override before the geometry assertion; it remains pending. The counts are
unchanged.

Android issue [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660)
is source-fixed in Android 1.0.46 and root 2.1.54: the nullable
`paymentRequestEnabled` setting is serialized through platform-interface 1.1.6,
applied only when `WebViewFeature.PAYMENT_REQUEST` is supported, and reported
back by `getRealSettings`. The Android library manifest declares the Chromium
Payment Request intent queries required by Google Pay. Platform-interface and
Android tests, `compileDebugKotlin`, and the debug AAR build pass. The
2026-08-12 physical Android diagnostic reports `PAYMENT_REQUEST=true` and
effective `paymentRequestEnabled=true` through `getSettings()`, using
`--no-uninstall`. Validation remains pending on Android 12-16/OEM WebView
providers with Google Pay's
`IS_READY_TO_PAY`, success/cancel flows, host app publication and merchant
configuration, and custom-user-agent requirements. This issue remains outside
the active queue and increases the runtime-pending issue count to 71.

Android issue [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846)
is source-fixed in Android 1.0.48 and root 2.1.56: the Android library and
both Forge example application modules no longer force-apply the Kotlin
Gradle plugin from the `plugins` block. They apply it only for AGP major
versions below 9 and configure the Kotlin compiler through
`KotlinAndroidProjectExtension`, allowing AGP 9 built-in Kotlin to own the
plugin path. The root example no longer forces `android.builtInKotlin=false`
or `android.newDsl=false`. The Android static migration regression passes;
Flutter >=3.47/AGP 9/Gradle 9/JDK 17 built-in-Kotlin validation and the legacy
AGP 8 consuming-app matrix remain pending. This issue remains outside the
active queue; it was the 73rd runtime-pending issue before #2793 was added.

Issue [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793)
is source-fixed in platform-interface 1.1.8 and root 2.1.57: the additive
`JavaScriptBridgeEvents` helper installs event-style `on`, `off`,
`hasListener`, and `emit` methods on the runtime-configured JavaScript bridge,
routes page events through the existing JavaScript handler contract, and adds
typed JSON/serialized handler codecs. No native channel or existing handler
contract changes. Platform-interface tests pass 7/7 and changed-file analysis
reports no issues. The opt-in Android physical-device diagnostic passed on
2026-08-12 for JavaScript-to-Dart events, Dart-to-JavaScript dispatch, and an
asynchronous typed handler response; it used `--no-uninstall` and preserved the
existing app installation. Broader Android provider coverage and iOS, Web,
Windows, macOS, and Linux example/runtime validation remain pending.
This issue remains outside the active queue and increases the runtime-pending
issue count to 74.

Android issue [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834)
is source-fixed in Android 1.0.47, platform-interface 1.1.7, and root 2.1.55:
the Android-only `userAgentMetadata` setting is serialized, feature-gated by
`WebViewFeature.USER_AGENT_METADATA`, and applied through
`WebSettingsCompat.setUserAgentMetadata` with malformed brand entries ignored.
The setting customizes metadata but cannot guarantee suppression of every
Chromium Client Hints header. Platform-interface and Android source tests pass.
The opt-in physical Android diagnostic passed on 2026-08-12: configured
platform, platform version, model, mobile state, and full version list were
returned by `navigator.userAgentData.getHighEntropyValues`, using
`--no-uninstall`. Android provider/device request-header validation remains
pending. This issue
remains outside the active queue; it was the 72nd runtime-pending issue before
#2846 was added.

Android PR [#2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743)
is source-fixed in Android 1.0.45 and root 2.1.53: the nullable
`WebAuthenticationSupport` setting is serialized through the platform
interface, applied with `WebSettingsCompat.setWebAuthenticationSupport` only
when `WebViewFeature.WEB_AUTHENTICATION` is supported, and reported back by
`getRealSettings`. Platform-interface and Android tests plus the native
Kotlin/AAR build pass. The 2026-08-12 physical Android diagnostic reports
`WEB_AUTHENTICATION=true` and effective `FOR_APP=1` through `getSettings()`,
using `--no-uninstall`. Physical Android WebView-provider validation for
`NONE`, `FOR_APP`, and `FOR_BROWSER`, including Digital Asset Links and
WebAuthn flows, remains pending. This PR-only record does not change the
74-issue count.

Android PR [#2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823)
is source-fixed in Android 1.0.44: `audio/*` file chooser requests now detect
audio capture, launch the recorder directly for capture-only inputs when a
provider resolves the intent, and add the recorder as a chooser option without
coupling it to camera permission. The Android source regression suite and
native build remain the local gates; recorder-provider, permission, cancel,
and returned-URI validation on physical Android devices remains pending. This
PR-only record does not change the 74-issue count.

iOS PR [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853)
is source-fixed in iOS 2.1.25: `requestFocus()` now traverses the WebView
subtree and makes the first focusable native content view first responder,
then falls back to the WebView. The existing channel and public Dart contract
are unchanged. iOS source tests and SwiftPM manifest validation pass; physical
iOS platform-view, `document.hasFocus()`, focus-event, and tab/reattachment
validation remain pending. This PR-only record does not change the 74-issue
count.

### Count by exported category

| Category | Export | Runtime pending | Source-validated; no runtime gate | Source-review closed | Host/platform boundary | Still open | Technical open after showcase |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Bugs | 98 | 57 | 1 | 1 | 15 | 24 | 24 |
| Enhancements | 16 | 12 | 0 | 0 | 0 | 4 | 4 |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | 0 | 0 |
| Showcase | 3 | 0 | 0 | 0 | 0 | 3 | 0 |
| **Total** | **125** | **77** | **1** | **1** | **15** | **31** | **28** |

Android [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
now validates nullable and non-string optional callback fields before dispatch,
including permission-request and cancellation maps plus the resources container;
the remaining gate is the Android API/provider matrix listed in
[`known-issues.md`](known-issues.md). The count remains 71.

Android [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641)
and [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685)
are implemented in Android 1.0.40. Legacy API 19/20 and provider compatibility
paths remain SDK-gated, while the native compatibility files isolate their
deprecation diagnostics. The 47-test Android package suite,
`compileDebugKotlin`, and the debug APK build pass without package-owned
Java/Android deprecation warnings. The direct release compile still encounters
the generated dev-only `integration_test` registrant, and the normal Flutter
release path uses a stale configured Android Studio JDK location in this
environment; clean JDK 17/21, AAB, provider, device, and publish validation
remain required. The records therefore stay in this register and the count is
now 68.

Android [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843)
and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849)
now include a bounded provider-startup fallback in Android 1.0.38 and an opt-in
profile/AOT cold-start diagnostic. Four clean API 35/WebView 124 installs pass
`onWebViewCreated`, `onLoadStop`, and the JavaScript bridge/document-start checks.
The opt-in [`android_headless_cold_start_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_headless_cold_start_diagnostic_test.dart)
also passes four headless create/load/dispose cycles with an
`AT_DOCUMENT_START` bridge marker, and the general HeadlessInAppWebView suite
passes 6/6 on the same API 35 AVD. No app `AndroidRuntime`, ANR, or native fatal
appears; explicit headless disposal emits Chromium renderer exit code `-1`,
which is the known teardown signature tracked separately under external #2491.
On 2026-08-11, the same cold-start and four-cycle headless checks also pass on
the Samsung A16 (`SM-A165F`, Android 16/API 36, MediaTek MT6789,
WebView 150.0.7871.181), with no app `AndroidRuntime`, ANR, or native fatal in
the filtered log. Physical release/R8 and broader provider coverage remains
required, so the records stay in this register and the count remains 68.

Android [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)
now has Android 35 AVD happy-path evidence for nested InAppBrowser and Chrome
Custom Tabs activity extras. The package test suite and opt-in diagnostic pass,
including open/load/close callbacks. On 2026-08-11, the Samsung A16
(`SM-A165F`, Android 16/API 36) diagnostic also passes both nested InAppBrowser
and Custom Tabs handoffs with the expected history URL and open/load/close
callbacks. Samsung's filtered log reports an `ActivityManager` IntentRedirect
Hardening warning for the Custom Tabs intent, but no app `AndroidRuntime`, fatal,
or ANR. Restore/rotation, malformed external extras, and physical/provider
coverage remain release gates, so the record stays in this register and the
count remains 68.

Pub.dev analysis issue [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757)
and upstream [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758)
are fixed locally by using boolean `false` for disabled `linter.rules`
overrides across the federated packages. Pana 0.23.3 reproduces the old
string-value crash and passes the corrected form in an isolated package. The
full package publish analysis remains pending because the Forge package names
are not yet available on pub.dev.

Android release-gate issue [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687)
is mitigated in the example release path. The Gradle build directory now
resolves from the project directory to the Flutter-expected `example/build`
path. After a normal release tooling regeneration (without `--no-pub`), the
JDK 21 release build produces `build/app/outputs/flutter-apk/app-release.apk`,
the Android plugin `syncReleaseLibJars` task succeeds, and the APK installs and
launches on the API 35 `emulator-5554` with `MainActivity` resumed and no fatal
crash in the smoke log. Clean JDK 17/provider/AAB/publish validation remains
required.

iOS/macOS [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)
now isolates the authentication presentation provider behind the iOS 13/macOS
10.15 availability boundaries. Source tests, Swift Package manifest checks,
and the Xcode 27 iOS example build pass; exact Xcode 26.4.1 and macOS
consuming-app validation remain required.

Android [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)
now prioritizes `shouldInterceptRequest` and Service Worker interception on the
main looper, removes timed-out queued dispatches, and ignores late callback
results. During the fresh 2026-08-10 API 35 rapid-navigation diagnostic, a separate Kotlin
overload recursion in `injectDeferredObject` was also confirmed as the direct
source of the observed `OutOfMemoryError`; Android 1.0.34 now calls the
platform `WebView.evaluateJavascript` overload. Android source tests and the
API 35/WebView 124 diagnostic pass (`finalLoaded=true`, final marker `final`,
31 interception callbacks, and no app fatal crash, ANR, or OOM in the log). On
2026-08-11, the opt-in diagnostic also passes 24 rapid navigations on the
Samsung A16 (`SM-A165F`, Android 16/API 36, WebView 150.0.7871.181), with
`finalLoaded=true`, the `final` DOM marker, 31 interception callbacks, and no
app fatal, ANR, or OOM; only Chromium tile-memory warnings were emitted.
Physical Android 10/11 OEM/provider and broader back/forward validation remain
required, so the record stays in this register and the count remains 68.

Android [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718)
is source-fixed in Android 1.0.43. API 21+ `setCookie`, `deleteCookie`, and
`deleteCookies` mutations no longer call the synchronous `CookieManager.flush()`
after queuing their asynchronous updates; the explicit `flush` API is preserved
for callers that require it and now completes its MethodChannel result. The Android package suite passes 48/48 tests,
`compileDebugKotlin`, and `assembleDebug`. Android 10/provider and Play Console
cookie-clear validation remain required. The existing remote-URL Cookie Manager
integration test built and installed on the API 35 AVD but timed out after 60
seconds before its assertions, with no fatal AndroidRuntime or ANR log captured.
A fresh isolated `flutter drive` attempt on 2026-08-10 installed the same test
but Flutter 3.44.8 failed in VM-service setup with
`registerService: (-32000) Service connection disposed`; the AVD log again had
no app `AndroidRuntime`, fatal, or ANR. The new local diagnostic does not depend
on that remote page: on 2026-08-11 it completes 10/10 mutation and explicit-
flush cycles on the Samsung A16 (`SM-A165F`, Android 16/API 36, MediaTek
MT6789, WebView 150.0.7871.181), with durations from 21 to 279 ms and an empty
final cookie list. The filtered log contains only Chromium tile-memory
warnings. Android 10/provider and Play Console validation remain required, so
the record stays in this register and the count remains 68.

Android [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878)
now has an opt-in fullscreen → exit → separate Flutter `TextField` diagnostic
at
[`flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart).
The existing API 35/WebView 124 pass uses the documented
`SystemChannels.textInput.show` workaround, so it does not independently prove
the native fullscreen restoration path. On 2026-08-11, the workaround-free
diagnostic passes on the Samsung A16 (`SM-A165F`, Android 16/API 36,
WebView 150.0.7871.181): `insetBeforeFocus=0.0`,
`insetAfterFocus=346.31`, and the Flutter focus node remains active. No
AndroidRuntime, fatal, or ANR appears; the record stays in this register for
Android 10/OEM and broader physical-device validation, and the count remains
68.

Android [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)
now has an opt-in display-size recovery diagnostic at
[`android_display_size_recovery_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_display_size_recovery_diagnostic_test.dart).
The API 35 AVD builds and starts the diagnostic, but both host `wm size`
change/reset attempts temporarily put `emulator-5554` offline before the test
could complete its geometry assertion. On 2026-08-11 and again on 2026-08-12,
the same reversible override on the Samsung A16 restarted the example
activity/VM service before the geometry assertion; the Activity remained up,
no app crash or ANR was recorded, but neither run produced a geometry result.
The display-size and OEM-provider gate therefore remains pending.

Android [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555)
now has an opt-in IME lifecycle diagnostic at
[`android_ime_lifecycle_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_ime_lifecycle_diagnostic_test.dart).
On 2026-08-10, a clean API 35 AVD run passed both virtual-display and hybrid
composition cycles: each focused the HTML input, cleared and disposed the
WebView, then reopened the Flutter keyboard with
`keyboardInsetAfterDispose=24.0` and an active Flutter focus node. On
2026-08-11, the same two cycles pass on the Samsung A16
(`SM-A165F`, Android 16/API 36, WebView 150.0.7871.181), each with
`keyboardInsetAfterDispose=358.4` and an active Flutter focus node. No
AndroidRuntime, fatal, or IME NPE appeared; Android 10 and OEM validation
remain required, so this record stays in the register and the count remains
68.

iOS [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711)
now has a targeted Dart regression test that reproduces the missing native
channel and passes after `goBack()` treats only `MissingPluginException` as a
teardown no-op. The iOS package tests (2/2), SwiftPM manifest validation, and
Simulator build pass. A four-cycle iPhone 17 Pro iOS 26.2 disposal diagnostic
completes with `WebView navigation started` outcomes after the harness's
navigate-away race; the test accepts that safe terminal result and records no
missing-plugin failure or app crash. Physical/device scene reattachment and
stale-controller validation remain required, so #2711 stays in this register.

iOS [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710)
now has an opt-in seek/fullscreen diagnostic at
[`ios_fullscreen_video_seek_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_fullscreen_video_seek_diagnostic_test.dart).
On 2026-08-11, the iPhone 17 Pro iOS 26.2 Simulator passed three cycles using a
bundled H.264/AAC video: play, seek, native-container fullscreen entry,
runtime opt-out dismissal, and re-entry all produced the expected state. The
test exited 0, the iOS package tests passed 2/2, and the SwiftPM manifest
validated with the documented module-cache workaround. The 2026-08-12 physical
iOS run returned `request=null` after seek and did not receive
`onEnterFullscreen` before the diagnostic timeout, failing the first cycle.
Physical iOS 26/GPU, HLS/iframe, orientation, media-control, and consuming-app
validation remain required, so #2710 stays in this register and the count
remains 68.

iOS/Android [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
now has disposal lifecycle diagnostics at
[`ios_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_disposal_lifecycle_diagnostic_test.dart)
and
[`android_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_disposal_lifecycle_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator previously completed four cycles with each
pending async JavaScript call reaching the safe `WebView navigation started`
terminal error after the harness begins navigation; the diagnostic now accepts
both that result and `WebView disposed`. A clean iPhone 17 Pro iOS 27 Simulator
run also completed the previous four-cycle run with outcomes `[WebView
navigation started, WebView disposed, WebView navigation started, WebView
navigation started]`. On 2026-08-13, the connected iPhone 17 Pro Simulator
completed the expanded 100-cycle run with all outcomes `WebView navigation
started` and exit code 0. The API 35 `emulator-5554` did the same across
virtual-display and hybrid composition. A fresh 2026-08-10 `flutter drive` run
completed all four cycles with exit code 0;
explicit disposal logs Chromium renderer exit code `-1`, but no app
`AndroidRuntime`, fatal, ANR, or Dart test failure appears. This matches the
renderer-teardown signature reported by external [#2491](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2491),
which is outside the supplied 125-issue export; the exact back-button and
affected-OEM path remains unvalidated. On 2026-08-11, the Samsung A16
diagnostic completes all four cycles with `WebView disposed` outcomes across
virtual-display and hybrid composition; the filtered log contains only
Chromium tile-memory warnings and no app `AndroidRuntime`, fatal, or ANR.
The connected physical iOS device also installed and launched the signed
example, and two `ios_disposal_lifecycle_diagnostic_test.dart` runs passed
after provisioning approval; the rerun completed four cycles with safe
`WebView disposed`/`WebView navigation started` outcomes. Repeated physical
100-cycle runs, iOS 15-26 coverage,
and Android API 33+/OEM/provider validation remain required, so #2654 stays in
this register and the count remains 68.

iOS [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)
now has an opt-in multi-window navigation diagnostic at
[`ios_multi_window_navigation_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_multi_window_navigation_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator passes three popup
attach/evaluate/navigate/dispose cycles, including page and custom-world
JavaScript, `shouldOverrideUrlLoading`, and an async call raced with
`about:blank` navigation. A fresh 2026-08-10 `flutter drive` run exits 0 with
`popupActions=3` and the same navigation sequence; no `EXC_BAD_ACCESS`,
`SIGSEGV`, `SIGABRT`, or fatal Simulator log is present. iOS 2.1.23 completes
pending native and legacy async callbacks with `WebView navigation started`
before the new provisional navigation and ignores late completions. Physical
iOS 15–26, Xcode 16/26, and symbolicated-crash validation remain required, so
#2867 also passes three popup attach/evaluate/navigate/dispose cycles on the
connected physical iOS device with `--no-uninstall`; the app remains installed.
Broader iOS 15-26/Xcode coverage and symbolicated-crash comparison remain
required, so #2867 stays in this register and the count remains 68.

Android [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)
now restores fullscreen state in both the pre-destroy fallback and the
`onRenderProcessGone` path before forwarding renderer-loss events. The Android
package suite passes all 49 tests on 2026-08-10, including the renderer-loss
fullscreen regression. The normal fullscreen/exit path passes on the 2026-08-11
Samsung A16 (`SM-A165F`, Android 16/API 36, MediaTek MT6789, WebView
150.0.7871.181), but the upstream Vimeo overlay/offline reproducer and forced
MediaTek gralloc/surface failure were not reproduced. On 2026-08-12, the
opt-in [`android_renderer_fullscreen_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_renderer_fullscreen_diagnostic_test.dart)
enters the IFramely-generated direct Vimeo iframe in hybrid composition; after
Wi-Fi is disabled during fullscreen, a black/loading surface is observed, but
`onExitFullscreen` is delivered, `onRenderProcessGone` is not delivered,
`fullscreenState=false`, and the test exits without an app crash or ANR. The
API 35 AVD and this normal A16 path cannot stand in for that GPU/provider
matrix; a physical MediaTek test using `https://iframely.com/domains/vimeo`,
network loss, banner/popup presentation, and renderer teardown remains
required, so the count stays 68.

Android [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680)
is tracked as a host/provider boundary rather than runtime-pending implementation
work: the reported Cloudflare `206 Partial Content` failure is not on Forge's
default request path, and the upstream record was stale-closed on 2026-08-07.

iOS [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)
is now tracked as a host/platform boundary rather than runtime-pending
implementation work. The installed WebKit SDK declares the public geolocation
decision delegate at iOS 27.0. The fresh 2026-08-10 iOS 27 Simulator deny-path
diagnostic receives `https://example.com` in Dart and returns `error:1`; the iPhone 17 Pro
iOS 26.2 run leaves `callbackOrigin=null` on the same secure HTTPS page. The
iOS 26 prompt remains owned by WebKit because no public Forge decision hook is
available; private WebKit APIs are out of scope.

iOS [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)
now has successful opt-in diagnostics on iOS 26.0, 26.2, and 27.0 Simulators,
plus one physical iOS device run with `--no-uninstall`:
`window.open` sends `https://example.com/popup` to `onCreateWindow`, the callback
returns `false`, and the caller remains at `https://example.com/`. The record
remains in this register until repeated physical iOS 15-26 popup attachment,
navigation, disposal, and scene-transition coverage is completed.

Android [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)
now has an opt-in screen-lock redraw diagnostic at
[`android_screen_lock_redraw_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_screen_lock_redraw_diagnostic_test.dart).
On the API 35 `emulator-5554` hybrid-composition run, a real ADB lock/unlock
checkpoint preserved the `ANDROID_SCREEN_LOCK_MARKER` DOM content and the
WebView URL. On 2026-08-11, the Samsung A16 (`SM-A165F`, Android 16/API 36)
passes the same real lock/unlock checkpoint in both hybrid and virtual-display
composition; the marker and URL remain intact and both integration tests exit
successfully. No app `AndroidRuntime`, fatal, or renderer crash appears; the
hybrid run has one system `ActivityManager` freeze warning. Android 10 and
affected OEM/provider lock/unlock validation remain required and the count
remains 68.

iOS [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)
is source-fixed in iOS 2.1.20. The previously recorded iPhone 17 Pro iOS 26.2
Simulator pass measured `visualViewport.height` as `778px -> 435.44px ->
778px`, with `visualViewport.scale` returning from `0.939` to `1.0`. A fresh
default-DDS run on 2026-08-10 reproduces the same transition, including an
active HTML input and zero page offset after dismissal. Earlier clean DDS
reruns on the current host were inconclusive: iOS 26.2 reported zero WebKit
viewport metrics after loading, while iOS 27 reached the initial `778px`
viewport but did not expose a software-keyboard transition (`keyboardDelta=0`).
CoreSimulatorService connection failures were also observed. The fix retains
the pre-keyboard `UIScrollView` zoom/offset and refreshes the final frame/layout
after dismissal. The physical iOS device run passed with `839px -> 487.8125px
-> 839px` and zero final offset. Custom page-zoom, native `WKWebView`
comparison, and broader physical-device validation remain required, so the
count remains 68.

### #2690 - iOS 18 Writing Tools behavior

Issue [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690)
is implemented in platform-interface 1.1.15, iOS 2.1.30, and root 2.1.68.
The additive `IOSWritingToolsBehavior` enum and
`InAppWebViewSettings.writingToolsBehavior` setting serialize the native raw
values for `none`, `default`, `complete`, and `limited`. iOS applies the value
only while creating `WKWebViewConfiguration`, behind an iOS 18.0 availability
guard; iOS 15-17 and unsupported devices retain WebKit's default behavior.
Platform-interface serialization/capability tests and iOS native source
contract tests pass. Physical iOS 18+ validation remains required for the
Writing Tools UI, device capability fallback, and `getSettings()` readback.
Apple Intelligence availability is controlled by the OS, device, language,
and region; this setting configures WebKit's Writing Tools behavior but does
not guarantee that Apple Intelligence is available.

## Issue register

The following 77 issue records have moved out of the active implementation
queue. They remain release gates until the required real validation is
recorded:

`#2536`, `#2555`, `#2568`, `#2580`, `#2594`, `#2600`, `#2619`, `#2641`,
`#2654`, `#2673`, `#2685`, `#2687`, `#2697`, `#2700`, `#2703`, `#2707`, `#2710`, `#2711`,
`#2717`, `#2718`, `#2720`, `#2721`, `#2725`, `#2728`, `#2733`, `#2736`, `#2737`,
`#2741`, `#2757`, `#2760`, `#2762`, `#2763`, `#2778`, `#2780`, `#2782`, `#2783`, `#2787`, `#2789`,
`#2791`, `#2797`, `#2805`, `#2812`, `#2813`, `#2819`, `#2826`, `#2830`,
`#2793`, `#2834`, `#2835`, `#2837`, `#2840`, `#2841`, `#2842`, `#2843`, `#2846`, `#2848`, `#2849`,
`#2850`, `#2852`, `#2855`, `#2856`, `#2859`, `#2861`, `#2862`, `#2863`,
`#2660`, `#2690`, `#2752`, `#2814`, `#2839`, `#2867`, `#2868`, `#2872`, `#2873`, `#2875`, `#2878`, `#2880`.

## Validation tracks

| Track | Required evidence |
| --- | --- |
| Android | Physical API/provider coverage, activity restore and rotation, cold-start/AOT cycles, malformed extras, IME/fullscreen behavior, and final APK/AAB checks where applicable. |
| iOS/macOS | Physical-device WebKit/AppKit coverage across supported OS versions, UIScene activation, popup/presentation, keyboard, authentication, geolocation grant/deny, and SPM/CocoaPods consuming-app validation. |
| Windows | Native WebView2 create/resize/dispose/recreate flows, affected runtime versions, minimized/focus behavior, and debug/release builds on Windows. |
| Linux | WPE/WebKit build matrix plus Fedora/X11/Intel runtime frames, GL-disabled fallback, backend diagnostics, and required `pkg-config` configurations. |
| Web | Browser integration coverage for same-origin navigation/history and cross-origin privacy behavior. |

The per-issue required evidence is maintained in the detailed findings in
[known-issues.md](known-issues.md). A source test, static assertion, host
build, or manifest check is recorded as supporting evidence, not as a
replacement for the target runtime test.

## Status transitions

1. A complete local implementation leaves `open-work-plan.md` and enters this
   register with its source, regression, and host validation evidence.
2. If real validation fails, move the issue back to the active work plan with
   the failing environment and native evidence.
3. If all required real validation passes, remove the issue from this
   register and mark it fully locally validated in `known-issues.md` and the
   resolution log.
4. Host/platform-specific boundaries are neither runtime-pending fixes nor
   upstream closures; keep their evidence and limitations in
   `known-issues.md` and the resolution log.
5. Do not change or comment on the upstream GitHub issue state as part of
   these local transitions.
