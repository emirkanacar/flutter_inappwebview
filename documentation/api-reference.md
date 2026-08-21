# API reference

The generated Dart API reference is a standalone `dart doc` site served at
[/api/](/api/index.html). Use a full page load for that route; it is not a
VitePress markdown page.

Published packages also have the same generated reference on
[pub.dev](https://pub.dev/documentation/flutter_inappwebview_forge/latest/).

## Open the generated reference

After the documentation site is running, open [/api/](/api/index.html). The
trailing directory URL and `/api/index.html` both serve `index.html`.

The complete site build generates the API first, then builds VitePress:

```sh
npm run docs:site:build
```

`npm run docs:site:dev` generates the API the first time it is missing, then
starts the local preview.

## Generate only the API

From the repository root:

```sh
npm run docs:api:site
```

This writes HTML to `documentation/public/api/`. The generated directory is
ignored by Git and should not be edited manually. The generator uses the
repository FVM Dart binary when present, then falls back to the `dart`
executable on `PATH`. Set `DART_BIN` to override it. When using a Flutter SDK
outside FVM, set `FLUTTER_ROOT` to that SDK directory.

## Cloudflare Pages deployment

Build the site first and upload the VitePress output, not the `documentation/`
source directory and not only `documentation/public/api/`. The build image
must provide a Dart SDK; Node-only Cloudflare builds cannot run `dart doc`.

```sh
npm run docs:site:build
npx wrangler pages deploy documentation/.vitepress/dist \
  --project-name=YOUR_PAGES_PROJECT
```

The build must contain both of these files before upload:

```text
documentation/.vitepress/dist/index.html
documentation/.vitepress/dist/api/index.html
```

GitHub Actions publishes the same output to GitHub Pages from `master`.
