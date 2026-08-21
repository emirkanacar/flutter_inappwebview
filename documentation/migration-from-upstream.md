# Migration and upstream relationship

`flutter_inappwebview_forge` is a maintained, actively developed fork of the
original [Flutter InAppWebView project](https://github.com/pichillilorenzo/flutter_inappwebview),
created and maintained by Lorenzo Pichilli with contributions from the open
source community.

The Forge packages continue that foundation and add project-specific fixes,
platform work, lifecycle hardening, performance changes, and new features.
The fork is not presented as the upstream package; its package names,
repository, release process, and native ownership are maintained here.

## Package mapping

| Upstream package | Forge package |
| --- | --- |
| `flutter_inappwebview` | `flutter_inappwebview_forge` |
| `flutter_inappwebview_platform_interface` | `flutter_inappwebview_forge_platform_interface` |
| `flutter_inappwebview_android` | `flutter_inappwebview_forge_android` |
| `flutter_inappwebview_ios` | `flutter_inappwebview_forge_ios` |
| `flutter_inappwebview_macos` | `flutter_inappwebview_forge_macos` |
| `flutter_inappwebview_windows` | `flutter_inappwebview_forge_windows` |
| `flutter_inappwebview_linux` | `flutter_inappwebview_forge_linux` |
| `flutter_inappwebview_web` | `flutter_inappwebview_forge_web` |

The Android implementation uses the Forge namespace
`com.emirkanacar.flutter_inappwebview_forge_android`.

## What remains compatible

- The main Dart widget/controller model remains `InAppWebView` and
  `InAppWebViewController`.
- Existing settings, callbacks, nullable results, and deprecated compatibility
  adapters are retained unless a release note says otherwise.
- MethodChannel names, method names, event payload keys, platform-view IDs,
  and JavaScript bridge names are compatibility surfaces.
- Platform-specific features continue to use runtime support checks and safe
  fallbacks when the host WebView does not provide them.

Compatibility does not mean every upstream behavior is identical. The Forge
implementation may fix a lifecycle race, reject a stale callback, or add a
new setting while preserving the public contract.

## Migration steps

1. Replace the dependency and imports:

   ```yaml
   dependencies:
     flutter_inappwebview_forge: ^2.1.74
   ```

   ```dart
   import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
   ```

2. Run `flutter pub get` and check that the endorsed Forge platform packages
   resolve from the same release line.
3. Keep the existing WebView lifecycle ownership stable. If the app used a
   controller or keep-alive object from the old package, transfer the same
   ownership pattern rather than creating a second WebView during migration.
4. Run the focused platform tests and validate Android/iOS provider behavior
   on the target runtime before shipping.
5. Read the [Changelog](changelog.md) for additive features and compatibility
   notes introduced after the upstream baseline.

Do not add both the upstream and Forge implementations to the same app unless
you have a deliberate platform-registration plan. Duplicate platform
registrations can hide which native implementation owns a WebView.

## How Forge development is tracked

Upstream issues and pull requests are preserved as historical references when
they motivate a Forge change. Local implementation status, source coverage,
device validation, and remaining provider limitations are tracked separately
in the repository's engineering records. An upstream ticket being closed does
not automatically mean the Forge runtime gate is complete.

## Attribution and license

The original project and its contributors are credited in the repository's
license and attribution records. The Forge packages retain the Apache License
2.0 notices and link back to the upstream project for historical context.
