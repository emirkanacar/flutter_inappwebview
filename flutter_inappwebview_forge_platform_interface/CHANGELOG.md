## 1.1.1 - 2026-08-06

- Add `WebAuthenticationSessionSettings.additionalHeaderFields` for iOS 17.4+ and macOS 14.4+.
- Mark `InAppWebViewSettings.pageZoom` as supported by Windows WebView2 through `ICoreWebView2Controller.ZoomFactor`.
- Add Android-only `PlatformInAppWebViewController.setBackgroundColor` capability metadata and regenerate the controller method support checks.
- Add the iOS-only `InAppWebViewSettings.useNativeFullscreenContainer` setting, enabled by default for the iOS 26+ seek-to-fullscreen WebKit workaround.
- Regenerate settings serialization, capability checks, and API documentation for the new setting.

## 1.0.4 - 2026-08-06

- Clarify that Web iframe load callbacks and `getUrl()` report the current same-origin URL, while an inaccessible cross-origin URL is `null` after the document loads instead of the iframe's requested `src`.
- Regenerate the Web navigation callback and controller capability documentation for the same-origin limitation.

## 1.0.3 - 2026-08-06

- Document that Android Forge preserves the original HTTP/HTTPS main-frame navigation when `shouldOverrideUrlLoading` returns `ALLOW`, while non-HTTP(S) URLs retain the asynchronous reload behavior.
- Regenerate the platform WebView and in-app browser navigation callback documentation.

## 1.0.2 - 2026-08-06

- Document that the Android Forge implementation ignores `allowUniversalAccessFromFileURLs=true` to preserve file-origin isolation and recommends `WebViewAssetLoader` or a controlled HTTPS origin.
- Regenerate the settings API documentation after the Android security behavior was clarified.

## 1.0.1 - 2026-08-06

- Prevent unknown native exchangeable-enum values from reaching generated non-null assertions when decoding collection fields.
- Add regression coverage for unknown native WebView2 permission resources in `PermissionRequest` payloads.

## 1.0.0

- First `flutter_inappwebview_forge_platform_interface` release as part of the Forge federated plugin.
- Reset the platform interface version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
