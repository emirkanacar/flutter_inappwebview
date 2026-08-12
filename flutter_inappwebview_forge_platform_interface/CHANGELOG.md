## 1.1.14 - 2026-08-13

- Add Windows pull-to-refresh capability metadata and the
  `PullToRefreshSettings.allowWithNoScrollbar` opt-in for WebView2 platform
  views ([#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760)).

## 1.1.13 - 2026-08-13

- Advertise desktop per-WebView proxy settings and scoped cookie behavior in
  the platform capability metadata.

## 1.1.12 - 2026-08-12

- Extend persistent container API support to macOS, Windows, and Linux.

## 1.1.11 - 2026-08-12

- Add `PlatformContainerController.clearContainerData` for clearing a named
  container without deleting it.

## 1.1.10 - 2026-08-12

- Add `InAppWebViewSettings.proxySettings` for iOS 17+ per-WebView proxy
  configuration through `WKWebsiteDataStore.proxyConfigurations`.

## 1.1.9 - 2026-08-12

- Add the `PlatformContainerController` API and
  `InAppWebViewSettings.containerId` serialization for persistent WebView
  storage profiles on Android and iOS. Android WebView 110+ with
  `MULTI_PROFILE` and iOS 17+ with UUID identifiers are required; unsupported
  platforms and versions retain their default profile behavior.

## 1.1.8 - 2026-08-12

- Add the additive `JavaScriptBridgeEvents` helper for event-style bridge
  communication and typed JSON/serialized JavaScript handler codecs
  ([#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793)).
  The helper reuses the existing JavaScript handler and bridge-name contracts;
  no native channel or security model changes are introduced.

## 1.1.7 - 2026-08-12

- Add Android-only `userAgentMetadata` settings and
  `USER_AGENT_METADATA` capability metadata for customizing User-Agent Client
  Hints ([#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834)).
  Chromium and the installed WebView remain responsible for final header
  generation; suppression of every Client Hints header is not guaranteed.

## 1.1.6 - 2026-08-12

- Add Android `paymentRequestEnabled` settings and `PAYMENT_REQUEST`
  capability metadata for Payment Request / Google Pay integrations
  ([#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660)).
  The setting remains nullable and feature-gated; device/provider validation
  remains pending.

## 1.1.5 - 2026-08-12

- Add Android `WebAuthenticationSupport` settings and `WEB_AUTHENTICATION`
  capability metadata for WebAuthn support ([PR #2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743)).

## 1.1.4 - 2026-08-10

- Correct the iOS availability metadata for `onGeolocationPermissionsShowPrompt` to iOS 27+, matching the public WebKit SDK declaration ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).

## 1.1.3 - 2026-08-08

- Clear the default localhost server's stale `HttpServer` reference when its request stream closes or errors, so `isRunning()` reflects externally terminated servers on iOS and Android ([#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720)).
- Add regression coverage for localhost-server listener cleanup and normal lifecycle reporting.

## 1.1.2 - 2026-08-08

- Mark `onGeolocationPermissionsShowPrompt` as supported by iOS 26+ and regenerate the platform capability metadata ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).

## 1.1.1 - 2026-08-06

- Mark `ContextMenu` and `PlatformInAppWebViewController.setContextMenu` as supported on macOS.
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
## 1.1.15 - 2026-08-13

- Add the iOS 18+ `IOSWritingToolsBehavior` enum and
  `InAppWebViewSettings.writingToolsBehavior` capability metadata for
  configuring Writing Tools when an iOS WebView is created ([#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690)).
