# Apple UIScene and Swift Package Manager Migration Plan

Last reviewed: 2026-08-06  
Status: Phase 1 implementation complete; device/release validation pending  
Scope: iOS UIScene support, plus SPM manifests for the iOS and macOS implementations

## Context

Issue [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880) identifies a lifecycle problem in the upstream implementation: scene-based applications do not reliably expose their UI window through `UIApplicationDelegate.window`. Flutter's UIScene migration guidance requires plugins to support both application and scene lifecycle delegates while applications transition to the scene-based model.

Flutter 3.44 enables Swift Package Manager as the default native dependency path for new iOS and macOS applications. The UIScene plugin registration APIs are available from Flutter 3.38. Both Apple implementations must therefore keep CocoaPods compatibility while providing a valid `Package.swift` that depends on Flutter's generated `FlutterFramework` package.

## Goals

- Remove all plugin reliance on `UIApplication.shared.delegate?.window` and global `UIApplication.shared.windows` lookups.
- Register the plugin with both `FlutterPluginRegistrar.addApplicationDelegate` and `addSceneDelegate`.
- Resolve the active key window from the foreground `UIWindowScene` on iOS 15 and newer.
- Set iOS 15.0 as the minimum deployment target across Swift Package Manager, CocoaPods, and the example applications.
- Make the iOS package consumable through Swift Package Manager without removing the existing podspec.
- Make the macOS package consumable through Swift Package Manager without removing its existing podspec.
- Keep resource loading correct for both managers: `Bundle.module` for SPM and `Bundle(for:)` for CocoaPods.
- Update both example applications so they exercise the current Flutter `SceneDelegate` and implicit-engine registration model.

## Implementation status

### Completed in Phase 1

- Added `FlutterSceneLifeCycleDelegate` conformance to `InAppWebViewFlutterPlugin`.
- Registered the same plugin instance with the application delegate and scene delegate.
- Added the scene-aware `UIApplication.activeKeyWindow` helper.
- Removed the pre-scene window fallback and the legacy `SFAuthenticationSession` path now that iOS 15 is the minimum.
- Migrated headless WebView insertion, Web Authentication presentation, and in-app browser restoration away from AppDelegate window access.
- Added the `FlutterFramework` local package dependency and target dependency to the iOS `Package.swift`.
- Preserved the existing `swift-collections` package dependency and processed `Resources` through SPM.
- Added the same `FlutterFramework` and processed-resource SPM dependencies to the macOS manifest.
- Migrated both iOS examples to `FlutterImplicitEngineDelegate`, added `SceneDelegate.swift`, and added the `UIApplicationSceneManifest` configuration.
- Corrected the iOS example unit test so it references the Forge plugin type.
- Raised the iOS deployment target to 15.0 in both podspecs, Podfiles, Xcode projects, and package metadata.

### Validation completed locally

- `flutter pub get --offline`, `flutter analyze --no-pub`, and `flutter test --no-pub` pass for the iOS example.
- `swift package dump-package` resolves the iOS package at iOS 15.0 and the macOS package at macOS 10.14.
- `pod ipc spec` resolves both iOS podspec platform entries at iOS 15.0.
- `flutter build ios --debug --no-codesign --no-pub` passes with Xcode's iOS 15+ deployment-target range.
- The root and iOS packages are versioned at `2.0.0`; the macOS SPM update is versioned at `1.1.0`.

### Remaining validation

- Validate the published CocoaPods source from a tagged repository release; the local podspec intentionally uses a path source for Flutter plugin integration.
- Run the iOS example on iOS 15 and newer scene-based devices/simulators.
- Exercise headless WebView rendering, Web Authentication, and InAppBrowser presentation/dismissal while the application moves between active and inactive scenes.

The package baseline is now Flutter `>=3.38.0` and iOS `>=15.0`. Flutter 3.38–3.43 hosts can use the migration with Swift Package Manager explicitly enabled; Flutter 3.44 and newer hosts use the current default SPM workflow.

## Package-management design

The iOS implementation supports both dependency managers during the transition:

| Concern | Swift Package Manager | CocoaPods |
| --- | --- | --- |
| Manifest | `ios/flutter_inappwebview_forge_ios/Package.swift` | `ios/flutter_inappwebview_forge_ios.podspec` |
| Flutter dependency | Local `FlutterFramework` package | `Flutter` pod | 
| Source path | `Sources/flutter_inappwebview_forge_ios` | Same source path | 
| Resources | `.process("Resources")` and `Bundle.module` | `s.resources` / resource bundle and `Bundle(for:)` |
| Third-party dependency | SwiftPM `swift-collections` 1.6.0 | CocoaPods `swift-collections` (`~>1.3.0` permits the 1.x line) |

The macOS manifest follows the same FlutterFramework and resource rules. Its CocoaPods integration intentionally keeps the existing `OrderedSet` dependency because the podspec uses that module when `SWIFT_PACKAGE` is not defined.

The package product remains hyphenated (`flutter-inappwebview-forge-ios`) because Swift Package Manager products must not use the plugin's underscore-based Dart/module identity as a bundle identifier.

## UIScene design

The plugin does not own application-level scene transitions, so it registers for the Flutter lifecycle forwarding path without adding redundant scene callbacks. This keeps lifecycle ownership in the host application while allowing Flutter to forward future scene events to the plugin.

UI presentation and headless rendering use the active scene's windows:

1. Select foreground-active or foreground-inactive `UIWindowScene` instances.
2. Prefer the scene's key window.
3. Fall back to the first window in that scene.

All supported iOS versions use the scene-aware path, preventing `AppDelegate.window == nil` from breaking Web Authentication, InAppBrowser restoration, or headless WebView rendering.

## Acceptance criteria

- No iOS plugin source references `UIApplication.shared.delegate?.window` or uses `UIApplication.shared.windows` to choose a presentation window.
- The iOS and macOS implementations build through both native dependency managers.
- SPM resolves `FlutterFramework`, `swift-collections`, and the processed resource directory.
- CocoaPods continues to resolve the same Swift sources and privacy/storyboard resources.
- A scene-based host can present and dismiss an InAppBrowser and start Web Authentication without a missing-window failure.
- An iOS 15+ host resolves presentation windows through its active scene.
- The migration is documented in the package and root changelogs before release.

## Verification commands

Use the Flutter version selected by the repository owner:

```sh
flutter config --enable-swift-package-manager --enable-uiscene-migration
flutter pub get
flutter build ios --debug --no-codesign
pod lib lint flutter_inappwebview_forge_ios.podspec --allow-warnings
```

The final verification must be performed on a machine with full Xcode, because the Command Line Tools package cannot build iOS targets or run the simulator.

## References

- [Flutter UIScene adoption guide](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)
- [Flutter Swift Package Manager guide for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
- [Flutter Swift Package Manager guide for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
- [Upstream issue #2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880)
