import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

List<int> _version(String value) =>
    value.split('.').map(int.parse).toList(growable: false);

void main() {
  test('SwiftPM FlutterFramework dependency matches the Flutter minimum', () {
    // Upstream #2951: Flutter creates the FlutterFramework Swift package from
    // 3.41.0. A lower minimum lets SwiftPM builds on 3.38-3.40 fail to
    // resolve ../FlutterFramework.
    final manifest = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Package.swift',
    ).readAsStringSync();
    expect(manifest, contains('.package(name: "FlutterFramework"'));

    final pubspec = _sourceFile('pubspec.yaml').readAsStringSync();
    final minimum = RegExp(
      r'^\s+flutter:\s*">=([0-9.]+)"',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1)!;
    final version = _version(minimum);
    expect(
      version[0] > 3 || (version[0] == 3 && version[1] >= 41),
      isTrue,
      reason: 'pubspec allows Flutter $minimum without FlutterFramework',
    );
  });
}
