import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

import '../web_uri.dart';
import 'download_job_state.dart';
import '../types/enum_method.dart';

part 'download_job_info.g.dart';

///Snapshot of a native WebView download job.
@ExchangeableObject()
class DownloadJobInfo_ {
  ///Download job ID.
  String id;

  ///Source URL.
  WebUri? url;

  ///Absolute destination path when native download is handled by the plugin.
  String? resultFilePath;

  ///Progress in the range 0.0-1.0, or `null` when unknown.
  double? progress;

  ///Current job state.
  DownloadJobState_? state;

  ///Failure message when [state] is [DownloadJobState_.FAILED].
  String? error;

  ///Resume data from a failed or canceled iOS/macOS `WKDownload`.
  String? resumeDataBase64;

  DownloadJobInfo_({
    required this.id,
    this.url,
    this.resultFilePath,
    this.progress,
    this.state,
    this.error,
    this.resumeDataBase64,
  });
}
