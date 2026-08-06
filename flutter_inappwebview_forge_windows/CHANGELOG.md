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
