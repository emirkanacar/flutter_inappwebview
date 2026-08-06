# flutter_inappwebview_forge_android

The Android WebView implementation of [`flutter_inappwebview_forge`](https://pub.dev/packages/flutter_inappwebview_forge).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview_forge`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Android 16 KB page-size validation

The Forge Android implementation contains Kotlin/Java code only; it does not
build or package a plugin-owned JNI/NDK library. The final application can
still contain native libraries from the Flutter engine or transitive SDKs, so
16 KB support must be checked on the release APK/AAB rather than inferred
from this package's Kotlin compilation.

From the repository root, run the release-artifact check after building:

```bash
tool/check_android_16k_alignment.sh build/app/outputs/bundle/release/app-release.aab
```

The check validates ELF `PT_LOAD` alignment for every bundled `.so`, checks
APK ZIP alignment with `zipalign` when given an APK, and checks an AAB's
`PAGE_ALIGNMENT_16K` bundle configuration through `bundletool`. See the
[Android 16 KB page-size guidance](https://developer.android.com/guide/practices/page-sizes)
for the host application's AGP, NDK, and device-test requirements.
