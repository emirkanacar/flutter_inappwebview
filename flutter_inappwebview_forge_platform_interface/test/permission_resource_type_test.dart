import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  test('unknown native permission resources do not abort request parsing', () {
    final request = PermissionRequest.fromMap({
      'origin': 'https://example.test',
      'resources': [PermissionResourceType.CAMERA.toNativeValue(), 13],
    });

    expect(request, isNotNull);
    expect(request?.resources, [PermissionResourceType.CAMERA]);
  });
}
