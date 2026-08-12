import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'writing_tools_behavior.g.dart';

///Configures the Writing Tools experience for an iOS WebView.
///
///Writing Tools support is available on iOS 18.0 and later. The system can
///still provide a more limited experience when the requested capabilities are
///not available on the device.
@ExchangeableEnum()
class IOSWritingToolsBehavior_ {
  // ignore: unused_field
  final int _value;
  const IOSWritingToolsBehavior_._internal(this._value);

  ///Prevents Writing Tools from modifying text in the WebView.
  static const NONE = const IOSWritingToolsBehavior_._internal(-1);

  ///Lets the system choose the most appropriate Writing Tools experience.
  static const DEFAULT = const IOSWritingToolsBehavior_._internal(0);

  ///Requests the complete inline-editing Writing Tools experience.
  static const COMPLETE = const IOSWritingToolsBehavior_._internal(1);

  ///Requests the limited overlay-panel Writing Tools experience.
  static const LIMITED = const IOSWritingToolsBehavior_._internal(2);
}
