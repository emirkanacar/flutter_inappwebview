import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile() {
  final candidates = [
    File('lib/src/in_app_localhost_server_io.dart'),
    File(
      'flutter_inappwebview_forge_platform_interface/lib/src/'
      'in_app_localhost_server_io.dart',
    ),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

File _barrelFile() {
  final candidates = [
    File('lib/src/in_app_localhost_server.dart'),
    File(
      'flutter_inappwebview_forge_platform_interface/lib/src/'
      'in_app_localhost_server.dart',
    ),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

File _platformFile() {
  final candidates = [
    File('lib/src/platform_in_app_localhost_server.dart'),
    File(
      'flutter_inappwebview_forge_platform_interface/lib/src/'
      'platform_in_app_localhost_server.dart',
    ),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

File _httpRequestBarrelFile() {
  final candidates = [
    File('lib/src/in_app_localhost_http_request.dart'),
    File(
      'flutter_inappwebview_forge_platform_interface/lib/src/'
      'in_app_localhost_http_request.dart',
    ),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('localhost dart:io imports stay behind dart.library.io', () {
    final barrel = _barrelFile().readAsStringSync();
    final platform = _platformFile().readAsStringSync();
    final httpRequestBarrel = _httpRequestBarrelFile().readAsStringSync();

    expect(barrel, contains("if (dart.library.io)"));
    expect(barrel, isNot(contains("dart.library.html")));
    expect(barrel, isNot(contains("import 'dart:io'")));
    expect(httpRequestBarrel, contains("if (dart.library.io)"));
    expect(httpRequestBarrel, isNot(contains("dart.library.html")));
    expect(platform, isNot(contains("import 'dart:io'")));
    expect(platform, contains('InAppLocalhostHttpRequest'));
  });

  test('localhost server clears stale references when HttpServer ends', () {
    final source = _sourceFile().readAsStringSync();

    expect(source, contains('subscription.onDone'));
    expect(source, contains('subscription.onError'));
    expect(source, contains('identical(this._server, server)'));
    expect(source, contains('_clearServerReference'));
  });

  test('localhost server reports its normal lifecycle', () async {
    final server = DefaultInAppLocalhostServer(
      const PlatformInAppLocalhostServerCreationParams(port: 0),
    );

    await server.start();
    expect(server.isRunning(), isTrue);

    await server.close();
    expect(server.isRunning(), isFalse);
  });

  test('localhost server can restart after a controlled close', () async {
    final server = DefaultInAppLocalhostServer(
      const PlatformInAppLocalhostServerCreationParams(port: 0),
    );

    await server.start();
    expect(server.isRunning(), isTrue);
    await server.close();
    expect(server.isRunning(), isFalse);

    await server.start();
    expect(server.isRunning(), isTrue);
    await server.close();
    expect(server.isRunning(), isFalse);
  });

  test('closing one localhost server does not clear another', () async {
    final first = DefaultInAppLocalhostServer(
      const PlatformInAppLocalhostServerCreationParams(port: 0),
    );
    final second = DefaultInAppLocalhostServer(
      const PlatformInAppLocalhostServerCreationParams(port: 0),
    );

    await first.start();
    await second.start();
    try {
      await first.close();
      expect(first.isRunning(), isFalse);
      expect(second.isRunning(), isTrue);
    } finally {
      await second.close();
    }
  });
}
