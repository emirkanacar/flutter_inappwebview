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
