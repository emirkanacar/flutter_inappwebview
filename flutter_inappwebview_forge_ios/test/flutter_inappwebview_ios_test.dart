import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _assert(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

void main() {
  final source = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/InAppWebView.swift',
  ).readAsStringSync();

  _assert(
    source.contains('keyboardDidHideNotification'),
    'keyboardDidHideNotification is not registered',
  );
  _assert(
    source.contains('func keyboardDidHide'),
    'keyboardDidHide restoration is missing',
  );
  _assert(
    source.contains('name: UIResponder.keyboardDidHideNotification'),
    'keyboardDidHide observer is missing',
  );

  final willHide = RegExp(
    r'@objc func keyboardWillHide\(notification: NSNotification\) \{'
    r'([\s\S]*?)\n    \}\n\n    @objc func keyboardDidHide',
  ).firstMatch(source)?.group(1);
  _assert(willHide != null, 'keyboardWillHide function could not be parsed');
  _assert(
    !willHide!.contains('resetScrollViewContentInset'),
    'keyboardWillHide restores the inset before UIKit finishes its layout pass',
  );

  final windowSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/UIApplication/VisibleViewController.swift',
  ).readAsStringSync();
  final pluginSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebViewFlutterPlugin.swift',
  ).readAsStringSync();

  _assert(
    windowSource.contains('activeKeyWindow'),
    'active window helper is missing',
  );
  _assert(
    windowSource.contains('UIWindowScene'),
    'scene-aware window lookup is missing',
  );
  _assert(
    pluginSource.contains('registrar.addSceneDelegate(instance)'),
    'Flutter scene delegate registration is missing',
  );
  _assert(
    !windowSource.contains('UIApplication.shared.delegate?.window'),
    'legacy AppDelegate window lookup is still present',
  );

  _assert(
    source.contains('guard windowCreated else { return }'),
    'popup JavaScript is evaluated before the Flutter platform view is attached',
  );
  _assert(
    source.contains('if #unavailable(iOS 18.0), windowId != nil'),
    'popup content-world compatibility guard is missing',
  );
  _assert(
    source.contains('super.evaluateJavaScript(javaScript) { result, error in'),
    'popup JavaScript does not use the page-world fallback',
  );
  _assert(
    source.contains(
      'in: WKContentWorld.page, completionHandler: completionHandler',
    ),
    'popup async JavaScript does not use the page content world fallback',
  );
}
