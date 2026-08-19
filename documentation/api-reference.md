# API reference

The API reference is generated from the public Dart package with `dart doc`.
It is intentionally kept separate from the hand-written guides so source
comments and public signatures remain the single source of truth.

## Generate locally

From the repository root:

```sh
npm run docs:api:site
```

This writes the generated HTML reference to `documentation/public/api/`.
The generated directory is ignored by Git and should not be edited manually.
The generator uses the repository FVM Dart binary when present, then falls
back to the `dart` executable on `PATH`. Set `DART_BIN` to override it. When
using a Flutter SDK outside FVM, set `FLUTTER_ROOT` to that SDK directory.

## Open the generated reference

After generation and while the documentation site is running, open
the generated [/api/](/api/) route. The trailing slash lets static hosts such
as Cloudflare Pages resolve the generated `api/index.html` directory entry.

The complete site build runs both the API generator and the VitePress build:

```sh
npm run docs:site:build
```

## Cloudflare Pages deployment

Build the site first and upload the VitePress output, not the `documentation/`
source directory and not only `documentation/public/api/`:

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

Open the API using the directory URL:

```text
/api/
```

The `_redirects` file also normalizes `/api` and the older `/api/index.html`
link to that route for static hosting.
