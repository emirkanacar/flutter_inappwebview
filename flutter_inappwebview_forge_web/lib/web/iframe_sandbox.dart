import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Whether [sandbox] is the [Sandbox.ALLOW_ALL] value.
///
/// [Sandbox.ALLOW_ALL] is a `List`, while `iframeSandbox` is a `Set`, so the
/// two never compare equal with `==`. Its only entry has a `null` native value,
/// so match on that instead.
bool isIframeSandboxAllowAll(Set<Sandbox>? sandbox) =>
    sandbox != null &&
    sandbox.isNotEmpty &&
    sandbox.every((value) => value.toNativeValue() == null);
