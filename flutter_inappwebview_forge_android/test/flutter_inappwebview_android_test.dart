import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FileProvider paths expose only capture and legacy media directories', () {
    final providerPaths =
        [
          File('android/src/main/res/xml/provider_paths.xml'),
          File(
            'flutter_inappwebview_forge_android/android/src/main/res/xml/provider_paths.xml',
          ),
        ].firstWhere(
          (file) => file.existsSync(),
          orElse: () => File('android/src/main/res/xml/provider_paths.xml'),
        );

    expect(providerPaths.existsSync(), isTrue);
    final content = providerPaths.readAsStringSync();

    expect(
      content,
      contains('<external-files-path name="app_captures" path="Captures/"/>'),
    );
    expect(
      content,
      contains('<external-path name="pictures" path="Pictures/"/>'),
    );
    expect(content, contains('<external-path name="movies" path="Movies/"/>'));
    expect(
      RegExp(r'<external-path\b[^>]*path="\."\s*/>').hasMatch(content),
      isFalse,
    );
  });
}
