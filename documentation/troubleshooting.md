# Troubleshooting

## The WebView is slow when opening a route

Check that the WebView is not recreated in `build()` and that a new
`InAppWebViewKeepAlive` is not created for every build. For a known URL, use
[Preload and reuse](preload-and-reuse.md). Measure the result on the target
device before keeping a preloader permanently.

## The page loses scroll position or JavaScript state

The native WebView was probably destroyed and recreated. Keep the same
`InAppWebViewKeepAlive` instance across widget replacement, or transfer the
same `InAppWebViewPreloader` into the new route.

## iOS says the executable is not codesigned

The application needs a valid Apple development certificate and provisioning
profile for the selected device. Trusting the developer profile on the device
is separate from the Flutter plugin. Do not delete an already-installed test
application unless reinstalling is necessary; deleting it can require profile
approval again.

## Android crashes or behaves differently on one device

Record the Android version, WebView provider/version, device manufacturer, and
composition mode. Renderer, provider, text-selection, IME, and fullscreen
issues may belong to the system WebView or Android framework rather than the
plugin. First reproduce with the same provider and a clean lifecycle cycle.

## Keyboard or autocorrection behavior is unexpected

`disableAutocorrection` applies to editable HTML elements through the
cross-platform WebView setting. It does not remove the operating system's
emoji key or guarantee a particular keyboard layout. For a native Flutter
text field, use Flutter's text input configuration instead.

## A permission prompt never appears

Check both sides:

1. the page requested the capability through the correct Web API;
2. the host application declared the native permission and handles the
   plugin callback.

The plugin cannot add a missing Android manifest permission or an iOS usage
description to an application at runtime.

## A WebView command returns null

Some values are unavailable before page navigation completes, after a renderer
or WebKit process failure, or for cross-origin iframe content on Web. Treat
nullable results as expected and check controller/WebView lifecycle state
before issuing follow-up commands.

## Where to look next

- [Known issues](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/known-issues.md)
  for repository-specific findings.
- [Runtime validation pending](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/runtime-validation-pending.md)
  for behavior that is source-implemented but still needs a target runtime.
- [Development guide](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/development.md)
  for build and test commands.
