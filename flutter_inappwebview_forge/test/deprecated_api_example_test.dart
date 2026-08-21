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
  test('example screens use current error and settings APIs', () {
    final storageScreen = _sourceFile(
      'example/lib/screens/storage/web_storage_screen.dart',
    ).readAsStringSync();

    expect(storageScreen, contains('onReceivedError:'));
    expect(storageScreen, contains('initialSettings:'));
    expect(storageScreen, isNot(contains('onLoadError:')));
    expect(storageScreen, isNot(contains('initialOptions:')));
  });
}
