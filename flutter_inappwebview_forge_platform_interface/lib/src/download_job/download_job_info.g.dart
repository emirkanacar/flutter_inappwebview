// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_job_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Snapshot of a native WebView download job.
class DownloadJobInfo {
  ///Failure message when [state] is [DownloadJobState_.FAILED].
  String? error;

  ///Download job ID.
  String id;

  ///Progress in the range 0.0-1.0, or `null` when unknown.
  double? progress;

  ///Absolute destination path when native download is handled by the plugin.
  String? resultFilePath;

  ///Resume data from a failed or canceled iOS/macOS `WKDownload`.
  String? resumeDataBase64;

  ///Current job state.
  DownloadJobState? state;

  ///Source URL.
  WebUri? url;
  DownloadJobInfo({
    this.error,
    required this.id,
    this.progress,
    this.resultFilePath,
    this.resumeDataBase64,
    this.state,
    this.url,
  });

  ///Gets a possible [DownloadJobInfo] instance from a [Map] value.
  static DownloadJobInfo? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = DownloadJobInfo(
      error: map['error'],
      id: map['id'],
      progress: map['progress'],
      resultFilePath: map['resultFilePath'],
      resumeDataBase64: map['resumeDataBase64'],
      state: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => DownloadJobState.fromNativeValue(
          map['state'],
        ),
        EnumMethod.value => DownloadJobState.fromValue(map['state']),
        EnumMethod.name => DownloadJobState.byName(map['state']),
      },
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "error": error,
      "id": id,
      "progress": progress,
      "resultFilePath": resultFilePath,
      "resumeDataBase64": resumeDataBase64,
      "state": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => state?.toNativeValue(),
        EnumMethod.value => state?.toValue(),
        EnumMethod.name => state?.name(),
      },
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadJobInfo{error: $error, id: $id, progress: $progress, resultFilePath: $resultFilePath, resumeDataBase64: $resumeDataBase64, state: $state, url: $url}';
  }
}
