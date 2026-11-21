import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation-parameter key read by the native `ChannelEventFilter`.
const String skippedChannelEventsKey = 'skippedEvents';

/// Fire-and-forget events that have no listener in [params], so native code
/// does not need to encode and send them.
///
/// Must stay in sync with the controller handlers: each event listed here is
/// dropped by the Dart controller when its callback is `null` and no
/// InAppBrowser handler exists. InAppBrowser does not use this list.
List<String> skippedChannelEvents(PlatformWebViewCreationParams params) {
  return [
    if (params.onConsoleMessage == null) 'onConsoleMessage',
    if (params.onScrollChanged == null) 'onScrollChanged',
    if (params.onProgressChanged == null) 'onProgressChanged',
    if (params.onTitleChanged == null) 'onTitleChanged',
    if (params.onOverScrolled == null) 'onOverScrolled',
    if (params.onZoomScaleChanged == null &&
        // ignore: deprecated_member_use_from_same_package, deprecated_member_use
        params.androidOnScaleChanged == null)
      'onZoomScaleChanged',
  ];
}
