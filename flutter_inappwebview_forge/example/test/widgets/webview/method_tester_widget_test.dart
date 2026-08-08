import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_example/widgets/webview/method_tester_widget.dart';

import '../../test_helpers/mock_inappwebview_platform.dart';

void main() {
  setUpAll(() {
    MockInAppWebViewPlatform.initialize();
  });

  group('MethodTesterWidget', () {
    testWidgets('renders search input and warning when controller is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MethodTesterWidget(controller: null)),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      final searchField = tester.widget<TextField>(find.byType(TextField));
      expect(searchField.decoration?.hintText, startsWith('Search '));
      expect(searchField.decoration?.hintText, endsWith(' methods...'));
      expect(
        find.textContaining('WebView controller not available'),
        findsOneWidget,
      );
    });
  });
}
