import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_inappwebview_forge_web/web/iframe_sandbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sandbox.ALLOW_ALL passed as a Set is recognized', () {
    expect(isIframeSandboxAllowAll(Sandbox.ALLOW_ALL.toSet()), isTrue);
    expect(isIframeSandboxAllowAll({...Sandbox.ALLOW_ALL}), isTrue);
  });

  test('Other sandbox sets are not treated as allow-all', () {
    expect(isIframeSandboxAllowAll(null), isFalse);
    expect(isIframeSandboxAllowAll(<Sandbox>{}), isFalse);
    expect(isIframeSandboxAllowAll(Sandbox.ALLOW_NONE.toSet()), isFalse);
    expect(isIframeSandboxAllowAll({Sandbox.ALLOW_SCRIPTS}), isFalse);
    expect(
      isIframeSandboxAllowAll({...Sandbox.ALLOW_ALL, Sandbox.ALLOW_SCRIPTS}),
      isFalse,
    );
  });
}
