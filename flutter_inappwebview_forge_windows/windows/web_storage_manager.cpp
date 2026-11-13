#include "web_storage_manager.h"

#include <WebView2.h>
#include <wil/com.h>
#include <wrl.h>

#include "utils/flutter.h"
#include "utils/log.h"
#include "utils/string.h"
#include "utils/timer.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  WebStorageManager::WebStorageManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), WebStorageManager::METHOD_CHANNEL_NAME)
  {}

  void WebStorageManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto& methodName = method_call.method_name();

    if (!string_equals(methodName, "deleteBrowsingData")) {
      result->NotImplemented();
      return;
    }

    if (!plugin || !plugin->webViewEnvironmentManager) {
      result->Success(false);
      return;
    }

    auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
    plugin->webViewEnvironmentManager->createOrGetDefaultWebViewEnvironment([this, result_](WebViewEnvironment* webViewEnvironment)
      {
        if (!webViewEnvironment) {
          result_->Success(false);
          return;
        }
        deleteBrowsingData(webViewEnvironment, [result_](const bool& cleared)
          {
            result_->Success(cleared);
          });
      });
  }

  void WebStorageManager::deleteBrowsingData(WebViewEnvironment* webViewEnvironment, std::function<void(const bool&)> completionHandler) const
  {
    // The completion handler must run exactly once on every path.
    auto complete = [completionHandler](const bool& cleared)
      {
        if (completionHandler) {
          completionHandler(cleared);
        }
      };

    // Closing the temp WebView inside a WebView2 callback can crash
    // ICoreWebView2 (see CookieManager), so close it after a short delay.
    auto closeLater = [](wil::com_ptr<ICoreWebView2Controller> webViewController)
      {
        if (!webViewController) {
          return;
        }
        Timer::setTimeout([webViewController]()
          {
            if (webViewController) {
              webViewController->Close();
            }
          }, 1000);
      };

    webViewEnvironment->useTempWebView([complete, closeLater](wil::com_ptr<ICoreWebView2Controller> webViewController, wil::com_ptr<ICoreWebView2> webView)
      {
        wil::com_ptr<ICoreWebView2Profile2> profile2;
        if (webView) {
          if (auto webView13 = webView.try_query<ICoreWebView2_13>()) {
            wil::com_ptr<ICoreWebView2Profile> profile;
            if (succeededOrLog(webView13->get_Profile(&profile)) && profile) {
              profile2 = profile.try_query<ICoreWebView2Profile2>();
            }
          }
        }

        if (!profile2) {
          complete(false);
          closeLater(webViewController);
          return;
        }

        auto hr = profile2->ClearBrowsingDataAll(Callback<ICoreWebView2ClearBrowsingDataCompletedHandler>(
          [complete, closeLater, webViewController](HRESULT errorCode) -> HRESULT
          {
            complete(succeededOrLog(errorCode));
            closeLater(webViewController);
            return S_OK;
          }
        ).Get());

        if (failedAndLog(hr)) {
          complete(false);
          closeLater(webViewController);
        }
      });
  }

  WebStorageManager::~WebStorageManager()
  {
    debugLog("dealloc WebStorageManager");
    plugin = nullptr;
  }
}
