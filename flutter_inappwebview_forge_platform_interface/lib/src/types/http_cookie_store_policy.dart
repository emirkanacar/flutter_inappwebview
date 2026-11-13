import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'http_cookie_store_policy.g.dart';

///Class that represents whether a WebView cookie store accepts cookies.
///Used by `CookieManager.setCookiePolicy` and `CookieManager.getCookiePolicy`.
@ExchangeableEnum()
class HTTPCookieStorePolicy_ {
  // ignore: unused_field
  final String _value;
  const HTTPCookieStorePolicy_._internal(this._value);

  ///The cookie store accepts and sends cookies. This is the default.
  static const ALLOW = HTTPCookieStorePolicy_._internal("allow");

  ///The cookie store neither stores new cookies nor sends existing ones.
  static const DISALLOW = HTTPCookieStorePolicy_._internal("disallow");
}
