import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory _sourcesDirectory() {
  const relativePath =
      'ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios';
  final candidates = [
    Directory(relativePath),
    Directory('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((directory) => directory.existsSync());
}

Iterable<File> _swiftSources() => _sourcesDirectory()
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.swift'));

void main() {
  test('method-channel arguments are never force-unwrapped or force-cast', () {
    final offenders = <String>[];
    final forceUnwrap = RegExp(r'arguments!\[');
    for (final file in _swiftSources()) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (forceUnwrap.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('missing or mistyped arguments complete with invalid_arguments', () {
    final helper = _swiftSources().firstWhere(
      (file) => file.path.endsWith('ChannelArguments.swift'),
    );
    final source = helper.readAsStringSync();
    expect(source, contains('func requiredArgument<T>('));
    expect(source, contains('code: "invalid_arguments"'));

    final handlers = _swiftSources().where(
      (file) => file.readAsStringSync().contains('try requiredArgument('),
    );
    expect(handlers, isNotEmpty);
    for (final file in handlers) {
      final handlerSource = file.readAsStringSync();
      expect(
        handlerSource,
        contains('invalidArgumentsError(error, method: call.method)'),
        reason: '${file.path} must report argument errors to the caller',
      );
    }
  });
}
