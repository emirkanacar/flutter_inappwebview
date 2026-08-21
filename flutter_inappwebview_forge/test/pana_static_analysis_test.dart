import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('public API satisfies lints_core identifiers and return types', () {
    final chromeSafari = _sourceFile(
      'lib/src/chrome_safari_browser/chrome_safari_browser.dart',
    ).readAsStringSync();
    final serviceWorker = _sourceFile(
      'lib/src/service_worker_controller.dart',
    ).readAsStringSync();

    expect(chromeSafari, contains('prewarmConnections(List<WebUri> urls)'));
    expect(chromeSafari, isNot(contains('List<WebUri> URLs')));
    expect(
      serviceWorker,
      contains(
        'Future<void> setServiceWorkerClient(ServiceWorkerClient? value)',
      ),
    );
    expect(
      serviceWorker,
      contains(
        'Future<void> setServiceWorkerClient(AndroidServiceWorkerClient? value)',
      ),
    );
  });
}
