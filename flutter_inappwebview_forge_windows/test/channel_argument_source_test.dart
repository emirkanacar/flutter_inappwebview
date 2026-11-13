import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('channel handler exceptions complete the call instead of crashing', () {
    final source = _sourceFile(
      'windows/types/channel_delegate.cpp',
    ).readAsStringSync();

    // get_fl_map_value throws std::out_of_range / std::bad_variant_access on a
    // missing or mistyped argument; the shared handler must catch it.
    expect(source, contains('catch (const std::exception& e)'));
    expect(source, contains('catch (...)'));
    expect(source, contains('"invalid_arguments"'));
    // The caller is completed at most once: only when the handler had not
    // already replied before throwing.
    expect(source, contains('if (!*completed)'));
  });
}
