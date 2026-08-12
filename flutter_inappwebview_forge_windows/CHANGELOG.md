## 1.0.13 - 2026-08-13

- Add opt-in pull-to-refresh for WebView2 pages without a vertical scrollbar
  through `PullToRefreshSettings.allowWithNoScrollbar`. The gesture verifies
  the document is at the top edge and uses the existing `onRefresh` callback
  ([#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760)).
  Windows native build and runtime validation remain pending.

## 1.0.12 - 2026-08-13

- Apply per-WebView proxy server and bypass settings to newly created WebView2
  environments. Existing explicit `WebViewEnvironment` instances retain their
  configured proxy options.

## 1.0.11 - 2026-08-12

- Add persistent WebView2 user-data containers through
  `ContainerController` and `InAppWebViewSettings.containerId`.

## 1.0.10 - 2026-08-12

- Serialize WebView2 controller resize, position, visibility, and teardown
  calls and reject late callbacks after disposal, preventing a native crash
  when `put_Bounds` or `put_RasterizationScale` races with `Close()`
  ([#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752)).
  Windows runtime validation remains pending.

## 1.0.9 - 2026-08-12

- Update the Windows WIL package and apply MSVC `/FS` and experimental
  coroutine compatibility settings for Visual Studio 2026 / MSVC 14.5x
  builds ([#2839](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2839), [#2869](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2869)).
  Windows native build and runtime validation on the affected toolchain
  remain pending.

## 1.0.8 - 2026-08-12

- Dispose the Windows `FindInteractionController` before stopping or closing
  WebView2, preventing child-window teardown from removing find event handlers
  from an invalid controller state ([#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814)).
  Windows 11/WebView2 multi-window runtime validation remains pending.

## 1.0.7 - 2026-08-08

- Guard headless WebView size callbacks after the WebView2 controller has been released during startup or renderer teardown ([#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778)).

## 1.0.6 - 2026-08-08

- Guard the InAppBrowser resize callback when the WebView2 controller has already been released during window teardown ([#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736)).

## 1.0.5 - 2026-08-06

- Add regression coverage confirming `getTitle()` uses the WebView2 document title ([#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725)).
- Apply `InAppWebViewSettings.pageZoom` through WebView2 `ICoreWebView2Controller.ZoomFactor` and report the effective zoom factor in real settings.

## 1.0.4 - 2026-08-06

- Load Flutter assets through WebView2's restricted virtual HTTPS origin so relative local resources work without an opaque `file:` origin.
- Validate relative asset paths, reject `..` traversal, and percent-encode the virtual asset URL.
- Keep a diagnostic legacy file-navigation fallback for WebView2 runtimes without `ICoreWebView2_3`.
- Add static regression coverage and update the issue triage documentation for [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872).

## 1.0.3 - 2026-08-06

- Hide the WebView2 child window when the Flutter window is minimized so it cannot block desktop mouse input in the former application area.
- Emit native minimize/restore events and restore WebView2 visibility and screen position after the window is restored.
- Keep the Windows example's local federated dependency overrides aligned with the repository packages.
- Add regression coverage for the minimize/restore visibility path.

## 1.0.2 - 2026-08-06

- Prevent static WinRT/Composition COM resources from being released during DLL unload; shared resources now use explicit last-instance shutdown and process-lifetime raw pointers.
- Guard `CustomPlatformView` callbacks against disposed widgets and detached render boxes during asynchronous initialization and position reporting.
- Keep the Windows native lifetime fix and lifecycle guards documented for native create/destroy/recreate validation on Windows.

## 1.0.1 - 2026-08-06

- Prevent forward-incompatible WebView2 permission resource values from crashing permission request decoding; known resources remain available to applications.

## 1.0.0

- First `flutter_inappwebview_forge_windows` release as part of the Forge federated plugin.
- Reset the Windows implementation version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
