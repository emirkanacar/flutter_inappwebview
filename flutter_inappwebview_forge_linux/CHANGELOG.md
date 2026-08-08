## 1.0.3 - 2026-08-08

- Add `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` to force the software/pixel-buffer rendering path for GPU/DMA-BUF issues ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).

## 1.0.2 - 2026-08-06

- Improve WPE WebKit CMake errors with all supported `pkg-config` candidates, backend alternatives, diagnostic commands, and an absolute link to `WPE_BACKEND.md`.
- Add Linux README prerequisite guidance for WPEPlatform and the legacy FDO backend across distro package layouts.
- Add static regression coverage for the dependency diagnostics and update the issue triage documentation for [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862).

## 1.0.1 - 2026-08-06

- Guard `webkit_web_view_get_theme_color` with `WEBKIT_CHECK_VERSION(2, 50, 0)` so Linux builds using older WPE WebKit headers and libraries no longer fail with an undefined reference.
- Preserve the existing theme-color behavior on WebKit 2.50 and newer while returning no theme color on older versions.
- Add a standalone source regression check for the WebKit version guard.
- Keep the Linux example's local federated dependency overrides aligned with the repository packages.
- Align the Linux implementation dependency on the federated platform interface with the current `1.0.3` contract.

## 1.0.0

- First `flutter_inappwebview_forge_linux` release as part of the Forge federated plugin.
- Reset the Linux implementation version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
