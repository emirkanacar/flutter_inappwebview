#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_STORAGE_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_STORAGE_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <functional>

#include "flutter_inappwebview_windows_plugin.h"
#include "types/channel_delegate.h"
#include "webview_environment/webview_environment_manager.h"

namespace flutter_inappwebview_plugin
{
  // Only deleteBrowsingData is implemented on Windows. Other
  // WebStorageManager methods reply NotImplemented, matching the capability
  // metadata, which does not list Windows for them.
  class WebStorageManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_webstoragemanager";

    const FlutterInappwebviewWindowsPlugin* plugin;

    WebStorageManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~WebStorageManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    // Clears every browsing data kind of the default profile through
    // ICoreWebView2Profile2::ClearBrowsingDataAll. Completes with false when
    // the WebView2 runtime does not expose the interface.
    void deleteBrowsingData(WebViewEnvironment* webViewEnvironment, std::function<void(const bool&)> completionHandler) const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_STORAGE_MANAGER_H_
