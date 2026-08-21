import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'webview_data_type.g.dart';

///iOS/macOS `WKWebViewDataType` values for session data fetch/restore.
@ExchangeableEnum(bitwiseOrOperator: true)
class WebViewDataType_ {
  // ignore: unused_field
  final int _value;
  const WebViewDataType_._internal(this._value);

  ///Session Storage data.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(available: '26.0', value: 1),
      EnumMacOSPlatform(available: '26.0', value: 1),
    ],
  )
  static const SESSION_STORAGE = const WebViewDataType_._internal(1);
}
