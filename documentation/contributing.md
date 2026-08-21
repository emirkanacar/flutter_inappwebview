# Contributing

## Repository layout

- `flutter_inappwebview_forge/` owns the public Dart API and example app.
- `flutter_inappwebview_forge_platform_interface/` owns shared contracts,
  types, serializers, and capability metadata.
- Platform packages own native lifecycle, rendering, permissions, and
  platform-specific behavior.
- `documentation/` contains user-facing guides.
- `docs/` contains engineering plans, triage records, and validation notes.

## Making a behavior change

1. Confirm the correct federated layer.
2. Preserve public Dart APIs and MethodChannel names unless a breaking change
   is intentional.
3. Trace both Dart and native sides of the callback and lifecycle path.
4. Add a focused regression test before changing a workaround or lifecycle
   rule.
5. Run the affected package tests, formatting, and native build checks.
6. Update the package changelog and the relevant engineering record.
7. Mark device/provider validation separately from source validation.

Generated files must be regenerated rather than edited by hand. Native
callbacks and channel inputs are nullable and may arrive after renderer,
window, or process failure; cleanup paths must remain idempotent.

## Documentation changes

Use `documentation/` when the change affects application developers:

- add a short example;
- explain platform limitations;
- describe lifecycle and ownership rules;
- include the failure mode and the safe fallback;
- map deprecated Options, prefixed callbacks, and type aliases to current names.
- name deprecated symbols in the affected package changelog when they are
  documented, redirected, or later removed.

Use `docs/` when the change records implementation evidence, issue triage,
performance measurements, migration decisions, or release validation.

## Documentation site

Install the site dependency once:

```sh
npm install --prefix documentation
```

Start the local VitePress site. The first run generates the Dart API
reference when `documentation/public/api/` is missing:

```sh
npm run docs:site:dev
```

Generate the Dart API reference and build the complete static site. The
documentation package runs the API generator before VitePress automatically:

```sh
npm run docs:site:build
```

The API output under `documentation/public/api/` is generated content. Do not
edit or commit it; update the Dart `///` comments and regenerate instead.

## Checks

From the repository root:

```sh
fvm flutter analyze --no-pub
fvm flutter test --no-pub
git diff --check
```

Choose native and device checks according to the affected platform. Do not
claim a physical-device or provider result from a Dart-only test.
