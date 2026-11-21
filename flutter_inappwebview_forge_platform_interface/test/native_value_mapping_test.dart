import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('WebResourceError.fromMap falls back to UNKNOWN for unmapped types', () {
    // Upstream PR #2900: an unmapped native error code threw a null check
    // error from the generated fromMap instead of producing an error object.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final error = WebResourceError.fromMap({
      'type': -987654,
      'description': 'net::ERR_SOMETHING_NEW',
    })!;

    expect(error.type, WebResourceErrorType.UNKNOWN);
    expect(error.description, 'net::ERR_SOMETHING_NEW');
    expect(
      WebResourceError.fromMap({'type': null, 'description': ''})!.type,
      WebResourceErrorType.UNKNOWN,
    );
  });

  test('Linux HTTP auth actions have native values', () {
    // Upstream PR #2898: without Linux values, PROCEED was sent as null and
    // the Linux plugin treated every HTTP auth response as CANCEL.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    expect(HttpAuthResponseAction.CANCEL.toNativeValue(), 0);
    expect(HttpAuthResponseAction.PROCEED.toNativeValue(), 1);
    expect(
      HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS.toNativeValue(),
      2,
    );
  });

  test('Linux SSL error codes decode from GTlsCertificateFlags', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    expect(SslErrorType.fromNativeValue(1), SslErrorType.UNTRUSTED);
    expect(SslErrorType.fromNativeValue(2), SslErrorType.IDMISMATCH);
    expect(SslErrorType.fromNativeValue(4), SslErrorType.NOT_YET_VALID);
    expect(SslErrorType.fromNativeValue(8), SslErrorType.EXPIRED);
    expect(SslErrorType.fromNativeValue(16), SslErrorType.REVOKED);
    expect(SslErrorType.fromNativeValue(64), SslErrorType.INVALID);
  });

  test('Linux HTTP auth challenge decodes an integer failure count', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final challenge = HttpAuthenticationChallenge.fromMap({
      'previousFailureCount': 0,
      'protectionSpace': {
        'host': '127.0.0.1',
        'port': 8081,
        'protocol': null,
        'realm': 'Node',
        'authenticationMethod': null,
      },
      'proposedCredential': null,
      'failureResponse': null,
      'error': null,
    });

    expect(challenge?.previousFailureCount, 0);
  });
}
