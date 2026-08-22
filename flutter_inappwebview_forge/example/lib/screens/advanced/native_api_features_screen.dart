import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:flutter_inappwebview_forge_example/widgets/common/app_drawer.dart';
import 'package:path_provider/path_provider.dart';

/// Interactive demos for 2.1.76 / 2.1.77 native WebView API gap features.
class NativeApiFeaturesScreen extends StatefulWidget {
  const NativeApiFeaturesScreen({super.key});

  @override
  State<NativeApiFeaturesScreen> createState() =>
      _NativeApiFeaturesScreenState();
}

class _NativeApiFeaturesScreenState extends State<NativeApiFeaturesScreen> {
  static const _profileId = 'forge-demo-profile';
  static const _startUrl = 'https://flutter.dev';

  InAppWebViewController? _controller;
  DownloadJobController? _downloadJob;
  Uint8List? _savedState;
  final List<String> _log = <String>[];
  bool _muted = false;
  bool _bfCacheEnabled = true;
  bool _useWebViewBuilder = false;
  bool _downloadHandled = false;
  int? _visualStateRequestId;
  String _status = 'Load a page, then try the actions below.';

  InAppWebViewSettings get _settings => InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
        backForwardCacheEnabled: _bfCacheEnabled,
        backForwardCacheTimeoutSeconds: 30,
        backForwardCacheMaxPagesInCache: 3,
        useWebViewBuilder: _useWebViewBuilder,
        webViewBuilderOriginAllowList: _useWebViewBuilder
            ? <String>{'https://flutter.dev', 'https://*.flutter.dev'}
            : null,
        containerId: defaultTargetPlatform == TargetPlatform.android
            ? _profileId
            : null,
        conversationContext: defaultTargetPlatform == TargetPlatform.iOS
            ? <String, dynamic>{
                'type': 'message',
                'threadIdentifier': 'forge-demo-thread',
                'selfIdentifiers': <String>['me'],
                'responsePrimaryRecipientIdentifiers': <String>['them'],
                'entries': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'text': 'Hello from the Forge example',
                    'senderIdentifier': 'them',
                    'entryIdentifier': 'e1',
                  },
                ],
              }
            : null,
      );

  void _append(String message) {
    setState(() {
      _status = message;
      _log.insert(0, '${DateTime.now().toIso8601String().substring(11, 19)}  $message');
      if (_log.length > 40) {
        _log.removeRange(40, _log.length);
      }
    });
  }

  Future<void> _runGuarded(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      _append('$label failed: $error');
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Mute', () async {
      final next = !_muted;
      if (InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.setAudioMuted,
      )) {
        await controller.setAudioMuted(muted: next);
      } else {
        await controller.setMuted(muted: next);
      }
      var effective = next;
      if (InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.isAudioMuted,
      )) {
        effective = await controller.isAudioMuted();
      } else if (InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.isMuted,
      )) {
        effective = await controller.isMuted();
      }
      setState(() => _muted = effective);
      _append('Audio muted=$_muted');
    });
  }

  Future<void> _navigateWithParams({required bool replaceHistory}) async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Navigate', () async {
      if (!InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.navigate,
      )) {
        await controller.loadUrl(
          urlRequest: URLRequest(url: WebUri('https://docs.flutter.dev')),
        );
        _append('navigate() unsupported; used loadUrl fallback');
        return;
      }
      await controller.navigate(
        url: WebUri('https://docs.flutter.dev'),
        replaceHistory: replaceHistory,
        headers: <String, String>{'X-Forge-Demo': 'native-api-gaps'},
      );
      _append(
        'navigate(replaceHistory=$replaceHistory, headers={X-Forge-Demo})',
      );
    });
  }

  Future<void> _prerender() async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Prerender', () async {
      if (!InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.prerenderUrl,
      )) {
        _append('prerenderUrl unsupported on this platform/provider');
        return;
      }
      await controller.prerenderUrl(url: WebUri('https://docs.flutter.dev'));
      _append('prerenderUrl(https://docs.flutter.dev)');
    });
  }

  Future<void> _requestVisualState() async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Visual state', () async {
      if (!InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.postVisualStateCallback,
      )) {
        _append('postVisualStateCallback unsupported');
        return;
      }
      final requestId = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
      setState(() => _visualStateRequestId = requestId);
      await controller.postVisualStateCallback(requestId: requestId);
      _append('postVisualStateCallback($requestId) posted');
    });
  }

  Future<void> _saveState({required bool withOptions}) async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Save state', () async {
      final Uint8List? bytes;
      if (withOptions &&
          InAppWebViewController.isMethodSupported(
            PlatformInAppWebViewControllerMethod.saveStateWithOptions,
          )) {
        bytes = await controller.saveStateWithOptions(
          maxSizeBytes: 512 * 1024,
          includeForwardHistory: false,
        );
        _append(
          'saveStateWithOptions(maxSize=512KiB, includeForward=false) '
          '-> ${bytes?.length ?? 0} bytes',
        );
      } else {
        bytes = await controller.saveState();
        _append('saveState() -> ${bytes?.length ?? 0} bytes');
      }
      setState(() => _savedState = bytes);
    });
  }

  Future<void> _restoreState() async {
    final controller = _controller;
    final state = _savedState;
    if (controller == null || state == null) {
      _append('No saved state yet');
      return;
    }
    await _runGuarded('Restore state', () async {
      final ok = await controller.restoreState(state);
      _append('restoreState() -> $ok');
    });
  }

  Future<void> _profileWarmup() async {
    await _runGuarded('Profile warmup', () async {
      final containers = ContainerController.instance();
      if (!ContainerController.isMethodSupported(
            PlatformContainerControllerMethod.preconnect,
          ) &&
          !ContainerController.isMethodSupported(
            PlatformContainerControllerMethod.prefetchUrl,
          )) {
        _append('Profile preconnect/prefetch unsupported');
        return;
      }
      if (ContainerController.isMethodSupported(
        PlatformContainerControllerMethod.addCustomHeader,
      )) {
        final added = await containers.addCustomHeader(
          containerId: _profileId,
          headerName: 'X-Forge-Profile',
          headerValue: 'demo',
          originRules: <String>{'https://*.flutter.dev'},
        );
        _append('addCustomHeader -> $added');
      }
      if (ContainerController.isMethodSupported(
        PlatformContainerControllerMethod.preconnect,
      )) {
        final ok = await containers.preconnect(
          containerId: _profileId,
          url: _startUrl,
        );
        _append('preconnect($_startUrl) -> $ok');
      }
      if (ContainerController.isMethodSupported(
        PlatformContainerControllerMethod.prefetchUrl,
      )) {
        final ok = await containers.prefetchUrl(
          containerId: _profileId,
          url: _startUrl,
        );
        _append('prefetchUrl($_startUrl) -> $ok');
      }
    });
  }

  Future<void> _reloadWithCurrentSettings() async {
    final controller = _controller;
    if (controller == null) return;
    await _runGuarded('Apply settings', () async {
      await controller.setSettings(settings: _settings);
      await controller.reload();
      _append(
        'Applied BFCache=$_bfCacheEnabled, useWebViewBuilder=$_useWebViewBuilder',
      );
    });
  }

  Widget _chipButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }

  @override
  void dispose() {
    _downloadJob?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native API Features')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: InAppWebView(
              key: ValueKey<String>(
                'native-api-${_bfCacheEnabled}_$_useWebViewBuilder',
              ),
              initialUrlRequest: URLRequest(url: WebUri(_startUrl)),
              initialSettings: _settings,
              onWebViewCreated: (controller) {
                _controller = controller;
                _append('WebView created');
              },
              onLoadStop: (controller, url) {
                _append('onLoadStop: $url');
              },
              onVisualStateReady: (controller, requestId) {
                _append('onVisualStateReady($requestId)');
              },
              onDownloadStarting: (controller, request) async {
                _append(
                  'onDownloadStarting: ${request.url} '
                  '(id=${request.downloadId})',
                );
                if (!_downloadHandled) {
                  _append('Returning null (notify-only download)');
                  return null;
                }
                final dir = await getTemporaryDirectory();
                final fileName =
                    request.suggestedFilename ?? 'forge-download.bin';
                final path = '${dir.path}/$fileName';
                final downloadId = request.downloadId;
                if (downloadId != null &&
                    DownloadJobController.isClassSupported()) {
                  _downloadJob?.dispose();
                  _downloadJob = DownloadJobController(id: downloadId)
                    ..onProgressChanged = (progress) async {
                      _append('download progress=${progress.toStringAsFixed(2)}');
                    }
                    ..onComplete = (completed, error) async {
                      _append(
                        completed
                            ? 'download complete: $path'
                            : 'download failed: $error',
                      );
                    };
                }
                return DownloadStartResponse(
                  handled: true,
                  action: DownloadStartResponseAction.DOWNLOAD,
                  resultFilePath: path,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(_status, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Text('Audio / navigation', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  children: [
                    _chipButton(
                      label: _muted ? 'Unmute' : 'Mute',
                      onPressed: _toggleMute,
                    ),
                    _chipButton(
                      label: 'Navigate (push)',
                      onPressed: () =>
                          _navigateWithParams(replaceHistory: false),
                    ),
                    _chipButton(
                      label: 'Navigate (replace)',
                      onPressed: () =>
                          _navigateWithParams(replaceHistory: true),
                    ),
                    _chipButton(label: 'Prerender', onPressed: _prerender),
                    _chipButton(
                      label: 'Visual state',
                      onPressed: _requestVisualState,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('State / profile', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  children: [
                    _chipButton(
                      label: 'Save state',
                      onPressed: () => _saveState(withOptions: false),
                    ),
                    _chipButton(
                      label: 'Save with options',
                      onPressed: () => _saveState(withOptions: true),
                    ),
                    _chipButton(
                      label: 'Restore state',
                      onPressed: _savedState == null ? null : _restoreState,
                    ),
                    _chipButton(
                      label: 'Profile preconnect/prefetch',
                      onPressed: _profileWarmup,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Back/Forward Cache'),
                  subtitle: const Text(
                    'backForwardCacheEnabled + timeout/max pages',
                  ),
                  value: _bfCacheEnabled,
                  onChanged: (value) {
                    setState(() => _bfCacheEnabled = value);
                    _reloadWithCurrentSettings();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use WebViewBuilder'),
                  subtitle: const Text(
                    'Android opt-in immutable builder / origin allowlist',
                  ),
                  value: _useWebViewBuilder,
                  onChanged: (value) {
                    setState(() => _useWebViewBuilder = value);
                    _reloadWithCurrentSettings();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Handle downloads natively'),
                  subtitle: const Text(
                    'Off = notify-only null response; on = DownloadJobController',
                  ),
                  value: _downloadHandled,
                  onChanged: (value) {
                    setState(() => _downloadHandled = value);
                    _append(
                      value
                          ? 'Downloads will return handled + resultFilePath'
                          : 'Downloads return null (notify-only)',
                    );
                  },
                ),
                if (_visualStateRequestId != null)
                  Text(
                    'Last visual-state request id: $_visualStateRequestId',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                Text(
                  'iOS 26 conversationContext is applied when supported. '
                  'Android minSdk is 24 + WebKit 1.16 in 2.1.77.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(),
                Text('Event log', style: Theme.of(context).textTheme.titleMedium),
                ..._log.map(
                  (line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(line, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
