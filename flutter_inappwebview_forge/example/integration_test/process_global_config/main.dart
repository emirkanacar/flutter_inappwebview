import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:path_provider/path_provider.dart';
import '../util.dart';

part 'apply.dart';

void main() {
  final shouldSkip = !ProcessGlobalConfig.isClassSupported();

  skippableGroup('Process Global Config', () {
    apply();
  }, skip: shouldSkip);
}
