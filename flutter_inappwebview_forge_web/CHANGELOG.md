## 1.0.3 - 2026-08-13

- Add `InAppWebViewSettings.disableAutocorrection` support for editable
  content in Web iframe views.
- Preserve the underlying iframe and JavaScript bridge during headless to
  regular WebView transfer, rebind the MethodChannel to the new view ID, and
  make WebView/headless ownership disposal idempotent.
- Coalesce iframe scroll callbacks to one native channel dispatch per
  animation frame and drop the queued dispatch when the WebView is disposed.
- Route Web create, prepare, retained-transfer, reattach, and disposal paths
  through one internal lifecycle coordinator so callbacks are rejected after
  teardown without changing the Web MethodChannel contract.
- Track Web async callback operation IDs so duplicate completions are ignored
  and pending work is drained exactly once when disposal begins.
- Cache the last Web settings snapshot so unchanged `setSettings` calls do not
  cross the JavaScript interop boundary.

## 1.0.2 - 2026-08-08

- Reinforce same-origin current-URL reporting and the cross-origin `null` fallback for iframe navigation and `getUrl()` ([#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737)).

## 1.0.1 - 2026-08-06

- Report the current same-origin iframe URL for load, history, and `getUrl()` paths instead of repeating the iframe's initial `src` after navigation.
- Return `null` for cross-origin iframe URLs that the browser's same-origin policy makes inaccessible, avoiding a misleading stale URL.
- Make Web URL event decoding nullable, add regression coverage, and document the browser limitation described in [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737).
- Keep the Web example's platform-interface dependency on the local federated package so offline lockfile resolution remains reproducible.
- Refresh the Web example lockfile for implementation 1.0.1 and platform interface 1.0.4.

## 1.0.0

- First `flutter_inappwebview_forge_web` release as part of the Forge federated plugin.
- Reset the Web implementation version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
