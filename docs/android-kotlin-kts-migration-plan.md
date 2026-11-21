# Android Kotlin/KTS and Native Package Migration Plan

Last reviewed: 2026-11-21\
Status: Conditional AGP 9 compatibility is implemented; Flutter/AGP runtime validation and API/performance validation remain\
Scope: `flutter_inappwebview_forge_android` and the Android example applications

## Objective

Move the Android platform package to current Flutter plugin conventions:

- Migrate Android native sources from Java to Kotlin.
- Convert Groovy Gradle files to Kotlin DSL (`.gradle.kts`).
- Adopt the AGP 9+ built-in Kotlin model and remove the separate `kotlin-android`/KGP application.
- Replace the legacy native namespace with the Forge namespace.
- Preserve the Dart API, MethodChannel/EventChannel names, payload contracts, and WebView behavior.
- Document every implementation step in the Android changelog.

Current Flutter documentation presents Kotlin as the default language for Android in new plugins. Flutter’s built-in Kotlin guide for plugin authors also recommends removing KGP with AGP 9+ and using the `kotlin.compilerOptions` DSL:

- [Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- [Flutter: Built-in Kotlin migration for plugin authors](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
- [Android: Migrating from Groovy to Kotlin DSL](https://developer.android.com/build/migrate-to-kotlin-dsl)
- [Android: Built-in Kotlin migration](https://developer.android.com/build/migrate-to-built-in-kotlin)

## Current state and target

| Area | Current state | Target |
| --- | --- | --- |
| Native language | Done: 157 Kotlin files, no Java | Kotlin only |
| Gradle | `build.gradle.kts` and `settings.gradle.kts` using the transition plugin model | `build.gradle.kts`, `plugins {}` DSL, and the supported built-in Kotlin model |
| Kotlin build model | Android 1.0.48 applies KGP only for AGP <9 and configures JVM 17 through the Kotlin extension | AGP 9+ built-in Kotlin with no forced KGP application |
| Native namespace | Done: `com.emirkanacar.flutter_inappwebview_forge_android` | Same |
| Flutter baseline | Flutter `3.44.8`, Dart `3.12.2` | Flutter `>=3.47.0`, Dart `^3.12.0` for built-in Kotlin |
| Java/Kotlin bytecode | Java 17 target | Java/Kotlin JVM 17 target |
| Android build | AGP `8.13.2` with the transitional KTS toolchain | Flutter-template-compatible AGP 9.x and matching Gradle |

## Built-in Kotlin compatibility checkpoint — 2026-08-12

The Android library and both Forge example application modules now use the
Flutter plugin-author migration shape: `org.jetbrains.kotlin.android` is not
declared in the `plugins` block, is applied conditionally only when the AGP
major version is below 9, and the JVM 17 target is configured through
`KotlinAndroidProjectExtension`. The root example no longer forces
`android.builtInKotlin=false` or `android.newDsl=false`.

This keeps the current Flutter 3.44.8/AGP 8.13.2 development path working while
allowing a Flutter >=3.47/AGP 9 consumer to use built-in Kotlin. The Android
static migration regression passes. The target Flutter >=3.47, AGP 9, Gradle
9, JDK 17, built-in-Kotlin, release/AAB, and consuming-app validation remains a
runtime/toolchain gate.

## Implementation checkpoint — 2026-08-06

Complete at this checkpoint (details are in git history and the Android
changelog):

- The plugin and both example apps use `.gradle.kts`.
- All plugin native sources are Kotlin (157 files, no Java); the example
  `MainActivity` classes are Kotlin. Migrated files use neither `!!` nor
  `@JvmSuppressWildcards`.
- The migration preserved Java-visible fields, getters, static factories,
  overloads, `Map<String, Object>` channel contracts, API-level guards, and
  JavaScript plugin payloads. Required channel arguments return explicit
  errors.
- The namespace is `com.emirkanacar.flutter_inappwebview_forge_android`. The
  FileProvider authority suffix (`flutter_inappwebview_android.fileprovider`)
  is unchanged for URI compatibility.
- `compileDebugKotlin`, both example `assembleDebug` builds, and the
  FileProvider path test passed on Flutter 3.44.8.

Open: Phase 4 device/performance validation and the AGP 9 built-in Kotlin
validation on Flutter `>=3.47.0` (verify the exact versions from the stable
template before starting).

## Package and authority decision

### Canonical native package

The proposed new namespace is:

```text
com.emirkanacar.flutter_inappwebview_forge_android
```

These values are updated together:

- `flutter_inappwebview_forge_android/pubspec.yaml` → `flutter.plugin.platforms.android.package`.
- Android `namespace`.
- Kotlin directory structure and all `package`/`import` statements.
- Activity/receiver classes in the plugin manifest.
- Fully qualified custom view names in layout XML files.
- ProGuard/consumer-rule references.
- `namespace`, `applicationId`, `MainActivity` paths, and manifest references in both Android examples.

The `InAppWebViewFlutterPlugin` class name remains unchanged; only the namespace and source language change. This preserves Flutter’s `pluginClass` contract.

### FileProvider authority

The provider authority is a compatibility surface used by application manifests and is independent of the Java package name. The recommended default is therefore:

- Change the native class package.
- Preserve the `flutter_inappwebview_android.fileprovider` authority suffix in the first Forge release.
- Treat a new authority as a separate breaking decision; update example manifests, migration documentation, and capture/file-upload tests together if it is introduced.

This separation prevents existing applications from silently losing `FileProvider` URIs because of a namespace migration.

## Implementation phases

### Phase 0 — Contract and toolchain lock

- Pin the Flutter stable version, Dart SDK, AGP, Gradle, Android Studio, and JDK versions in CI.
- Use JDK 17 as the baseline build environment; run JDK 21/24 only as additional compatibility checks.
- Take the AGP 9.x and matching Gradle version from the selected Flutter template.
- Preserve the current `minSdk 24`, AndroidX WebKit `1.16.0`, and Browser `1.10.0` contracts independently of this migration (the original checkpoint was minSdk 19 / WebKit 1.14.0).
- Record MethodChannel/EventChannel names, method names, payload maps, the WebView platform-view ID, and the JavaScript bridge name in baseline tests.
- Finalize the FileProvider authority decision before implementation begins.

Exit criterion: the toolchain and backward-compatibility contract are documented, reproducible, and working in CI.

### Phase 1 — KTS build infrastructure

Move the build files before changing native source code:

- `flutter_inappwebview_forge_android/android/build.gradle` → `build.gradle.kts`.
- `flutter_inappwebview_forge_android/android/settings.gradle` → `settings.gradle.kts`.
- Root example `example/android/settings.gradle`, `build.gradle`, and `app/build.gradle` → `.kts`.
- Apply the same standard to the platform package’s example Android host files.
- Remove `buildscript`/`classpath`/`apply plugin` usage and use the `plugins {}` DSL.
- Express `compileSdk`, `minSdk`, `consumerProguardFiles`, build types, and AndroidX dependencies with the type-safe KTS DSL.
- Preserve Java 17 compile options and add `kotlin.compilerOptions { jvmTarget = JvmTarget.JVM_17 }` once Kotlin sources are present.
- Do not use `org.jetbrains.kotlin.android` or `kotlin-android` for the AGP 9 built-in Kotlin model.
- In the example host, use `dev.flutter.flutter-plugin-loader` only in `settings.gradle.kts` and `dev.flutter.flutter-gradle-plugin` in the module build file.
- Use `android.builtInKotlin`/`android.newDsl` in the form recommended by the selected Flutter template; do not leave a temporary opt-out.

Exit criterion: while Java sources are still present, the plugin AAR and both example applications build in debug/release through KTS.

### Phase 2 — Controlled Java-to-Kotlin migration

The 157 files were not converted in one step; each group was compiled after migration:

1. Plugin entry point, `InAppWebViewFileProvider`, core utility/type classes, and low-risk settings models.
2. Channel delegates, callback results, and credential/database classes.
3. WebView, platform-view factory, Headless WebView, and WebView managers.
4. In-app browser, Custom Tabs, Trusted Web Activity, print, proxy, tracing, and process-global configuration.
5. Content blocker, service worker, pull-to-refresh, JavaScript/plugin scripts, and remaining type classes.

Migration rules:

- Preserve public class and method names.
- When moving Java `static` APIs to Kotlin companion/top-level APIs, use `@JvmStatic` and `@JvmField` where required.
- Transfer `@NonNull`/`@Nullable` information to Kotlin nullability correctly; do not assume Java platform types are non-null in platform callbacks.
- Preserve `Parcelable`, WebView callback, `ActivityAware`, and Flutter plugin interface overrides explicitly.
- Test `R` resource access, reflection-based classes, and Android manifest entry points.
- Do not leave duplicate copies of a class during the Java/Kotlin transition; remove the old `.java` file at the end of each group.
- Kotlin migration must not change Dart channel names or payload contracts.

Exit criterion: no source remains under `android/src/main/java`, all native sources are `.kt`, and every migration group passes compile/lint tests. The Java/Kotlin migration part of this criterion is complete; API-matrix and performance measurements continue in Phase 4.

### Phase 3 — Namespace and source-path migration

- Move `src/main/java/com/pichillilorenzo/...` to `src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/...`.
- Align the manifest’s legacy `package` attribute with the modern `namespace`; remove the legacy attribute where possible.
- Update activity, receiver, custom-view, layout `tools:context`, and provider references to the new namespace.
- Move the `MainActivity` classes in the root and platform examples to Kotlin and update example application identities to the Forge name.
- Update the Android package value in `pubspec.yaml`.
- Do not edit generated plugin registrants by hand; regenerate them with `flutter pub get`/build and verify the diff.
- Allow old native package strings only in historical migration notes/changelogs.
- Apply the FileProvider authority decision from Phase 0; if the authority changes, add an explicit migration note for the old authority.

Exit criterion: merged Android manifests resolve the new classes, no component uses the old namespace, and capture/file-upload flows work.

### Phase 4 — Native tests and performance validation

Test layers to add:

- Kotlin/JUnit unit tests for lifecycle, nullability, type conversion, and authority/path decisions.
- Android instrumentation tests for plugin attach/detach/reattach, platform-view creation, Headless WebView, FileProvider, camera/video picker, and Activity result flows.
- Dart channel compatibility tests for static channels, per-WebView channels, event callbacks, method names, and payload types.
- Integration tests for the bridge, JavaScript handlers, Custom Tabs, popup/window creation, KeepAlive, cookies, permissions, downloads, fullscreen/keyboard, and dispose/recreate.
- Build smoke tests for debug APK, release APK, AAB, lint, unit tests, instrumentation tests, and dependency resolution.

The Android performance plan uses the API 24/29/35/36 matrix for the current `minSdk 24` line; API 19/21/23 coverage applies only to the 2.1.76 / Android 1.0.55 compatibility line. Release/profile builds must demonstrate that the Kotlin migration does not change startup, bridge readiness, channel pressure, or disposal measurements.

Required static checks:

```text
rg --files flutter_inappwebview_forge_android/android/src/main/java   # must be empty
rg --files flutter_inappwebview_forge_android/android/src/main/kotlin  # all native sources must be here
rg 'build.gradle|settings.gradle' android example/android             # only .kts files should remain
rg 'com.pichillilorenzo.flutter_inappwebview_android'                # only historical migration text may match
```

### Phase 5 — Release, migration notes, and changelog

- At the end of every phase, record the changes in the `Unreleased` section of `flutter_inappwebview_forge_android/CHANGELOG.md`.
- Announce minimum Flutter/Dart, AGP/Gradle/JDK, and native-package changes in the root package changelog as well.
- If a native-package or minimum-SDK change happens after a published release, plan a semver-breaking release. Since Forge `1.0.0` has not been published, the migration can be completed under `Unreleased` and included in the first release.
- Update Android manifest, FileProvider authority, and minimum-toolchain examples in the README/installation documentation.
- Publish an explicit migration checklist for applications using the old package/authority.

## Risks and rollback plan

| Risk | Mitigation | Rollback |
| --- | --- | --- |
| Kotlin nullability changes behavior | Group-based compile plus callback/instrumentation tests | Revert the latest migrated group |
| AGP 9/KTS breaks consuming applications | Run the JDK/Flutter/AGP matrix in CI | Enable built-in Kotlin only on a supported toolchain |
| Native namespace does not resolve in the manifest | APK/AAB merged-manifest and component smoke tests | Revert the namespace change while preserving channel contracts |
| FileProvider authority change breaks capture | Keep the default authority fixed and add real-device tests | Retain a compatibility shim for the old authority |
| KTS configuration increases build time | Measure Gradle configuration cache and build scans | Remove unnecessary script logic from KTS |
| Java-to-Kotlin migration causes startup/performance regression | Compare profile baselines and crash/ANR rates before and after | Revert the affected class group to the last working commit |

## Completion criteria

The full plan is complete only when all of the following are true:

- All Android native sources are Kotlin and all build files are KTS.
- The AGP 9+ built-in Kotlin model produces no `kotlin-android`/KGP warnings.
- The new namespace and the Flutter `pubspec` Android package value match.
- Dart API, channel names, payloads, and bridge behavior pass compatibility tests.
- Root and platform examples build as debug/release/AAB.
- The API 24–36 Android matrix (API 19–23 only for the 1.0.55 compatibility line) and WebView capture/FileProvider scenarios are verified.
- Every implementation change is recorded in the Android changelog and the migration documentation is current.
