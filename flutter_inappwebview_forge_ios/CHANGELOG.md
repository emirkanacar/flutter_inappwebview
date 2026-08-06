## 2.0.0 - 2026-08-06

- Add UIScene-compatible Flutter plugin registration for both application and scene lifecycle forwarding.
- Replace AppDelegate/global window lookups with an active `UIWindowScene` key-window helper for iOS 15+.
- Raise the minimum iOS deployment target to 15.0 and remove the pre-scene window and legacy authentication-session paths.
- Complete the iOS Swift Package Manager manifest with FlutterFramework, Swift Collections, and processed resources while retaining CocoaPods support.
- Update the Swift Collections SPM lock to `1.6.0` for current Xcode package-trait resolution.
- Update the iOS example application to use Flutter's implicit engine and SceneDelegate lifecycle model.
- Add a minimal iOS example test so the example test harness can load successfully.
- Raise the Flutter baseline to `>=3.38.0` for the UIScene registration APIs.

- Breaking: raise the iOS implementation version to `2.0.0` because iOS 12 support has been removed.

## 1.0.0

- First `flutter_inappwebview_forge_ios` release as part of the Forge federated plugin.
- Reset the iOS implementation version to `1.0.0`.
- Includes the iOS keyboard, scroll callback, disposal, and dependency baseline improvements prepared for the Forge release.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
