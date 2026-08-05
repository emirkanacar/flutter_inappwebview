import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:flutter_test/flutter_test.dart';
import '../util.dart';

part 'find_interactions.dart';

void main() {
  final shouldSkip = !FindInteractionController.isClassSupported();

  skippableGroup('FindInteractionController', () {
    findInteractions();
  }, skip: shouldSkip);
}
