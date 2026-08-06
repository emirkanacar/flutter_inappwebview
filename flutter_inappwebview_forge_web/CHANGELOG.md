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
