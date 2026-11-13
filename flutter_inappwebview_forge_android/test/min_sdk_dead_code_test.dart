import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory _sourceDir(String relativePath) {
  final candidates = [
    Directory(relativePath),
    Directory('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((dir) => dir.existsSync());
}

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

/// API levels at or below the declared `minSdk 24`. A runtime check against
/// one of these is always true (or always false), so its fallback branch is
/// unreachable.
const _belowOrAtMinSdk = [
  'BASE',
  'BASE_1_1',
  'CUPCAKE',
  'DONUT',
  'ECLAIR',
  'ECLAIR_0_1',
  'ECLAIR_MR1',
  'FROYO',
  'GINGERBREAD',
  'GINGERBREAD_MR1',
  'HONEYCOMB',
  'HONEYCOMB_MR1',
  'HONEYCOMB_MR2',
  'ICE_CREAM_SANDWICH',
  'ICE_CREAM_SANDWICH_MR1',
  'JELLY_BEAN',
  'JELLY_BEAN_MR1',
  'JELLY_BEAN_MR2',
  'KITKAT',
  'KITKAT_WATCH',
  'LOLLIPOP',
  'LOLLIPOP_MR1',
  'M',
  'N',
];

void main() {
  test('Android declares minSdk 24', () {
    final gradle = _sourceFile('android/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('minSdk = 24'));
  });

  test('Android sources have no SDK checks or API annotations at or below '
      'minSdk 24', () {
    final codes = _belowOrAtMinSdk.join('|');
    final sdkCheck = RegExp(
      r'SDK_INT\s*[<>=!]=?\s*(?:Build\.)?VERSION_CODES\.(' + codes + r')\b',
    );
    final numericCheck = RegExp(r'SDK_INT\s*[<>=!]=?\s*(\d+)\b');
    final apiAnnotation = RegExp(
      r'@(?:RequiresApi|TargetApi)\(\s*(?:api\s*=\s*)?'
              r'(?:Build\.)?VERSION_CODES\.(' +
          codes +
          r')\s*\)',
    );

    final offenders = <String>[];
    final root = _sourceDir('android/src/main');
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File ||
          !(entity.path.endsWith('.kt') || entity.path.endsWith('.java'))) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final numeric = numericCheck.firstMatch(line);
        if (sdkCheck.hasMatch(line) ||
            apiAnnotation.hasMatch(line) ||
            (numeric != null && int.parse(numeric.group(1)!) <= 24)) {
          offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
