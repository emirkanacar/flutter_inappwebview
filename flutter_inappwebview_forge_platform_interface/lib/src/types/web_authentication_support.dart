import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'web_authentication_support.g.dart';

///Configures the WebAuthn support level for an Android WebView.
@ExchangeableEnum()
class WebAuthenticationSupport_ {
  // ignore: unused_field
  final int _value;
  const WebAuthenticationSupport_._internal(this._value);

  ///Disable WebAuthn requests from the WebView.
  static const NONE = const WebAuthenticationSupport_._internal(0);

  ///Allow WebAuthn requests for the app in which the WebView is embedded.
  static const FOR_APP = const WebAuthenticationSupport_._internal(1);

  ///Allow WebAuthn requests for any website. This requires the app to have the
  ///privileges and Digital Asset Links needed by the Android WebView.
  static const FOR_BROWSER = const WebAuthenticationSupport_._internal(2);
}
