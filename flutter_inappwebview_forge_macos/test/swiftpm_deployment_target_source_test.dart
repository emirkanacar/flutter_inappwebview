import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('10.15-only protocol conformance builds with the 10.14 package minimum '
      '(#2891)', () {
    // Upstream #2891: a type conforming to
    // ASWebAuthenticationPresentationContextProviding must be available from
    // the package's own minimum. Forge keeps the conformance on a separate
    // macOS 10.15 type, so SwiftPM builds with `.macOS("10.14")` compile.
    final manifest = _sourceFile(
      'macos/flutter_inappwebview_forge_macos/Package.swift',
    ).readAsStringSync();
    expect(manifest, contains('.macOS("10.14")'));

    final source = _sourceFile(
      'macos/flutter_inappwebview_forge_macos/Sources/'
      'flutter_inappwebview_forge_macos/WebAuthenticationSession/'
      'WebAuthenticationSession.swift',
    ).readAsStringSync();
    final conformance = source.indexOf(
      'ASWebAuthenticationPresentationContextProviding {',
    );
    expect(conformance, isNonNegative);
    final declarationStart = source.lastIndexOf('\n', conformance);
    final previousLine = source.substring(
      source.lastIndexOf('\n', declarationStart - 1) + 1,
      declarationStart,
    );
    expect(previousLine.trim(), '@available(macOS 10.15, *)');
    expect(
      'ASWebAuthenticationPresentationContextProviding'
          .allMatches(source)
          .length,
      1,
    );
  });
}
