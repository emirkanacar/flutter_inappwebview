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
