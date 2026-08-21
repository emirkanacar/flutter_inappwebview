#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_CONTROLLER_H_

#include <WebView2.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <wil/com.h>

#include <memory>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  class DownloadJobChannelDelegate;
  class DownloadJobManager;

  class DownloadJobController : public std::enable_shared_from_this<DownloadJobController>
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX =
      "com.emirkanacar/flutter_inappwebview_downloadjobcontroller_";

    const std::string id;
    std::unique_ptr<DownloadJobChannelDelegate> channelDelegate;

    DownloadJobController(
      const std::string& id,
      flutter::BinaryMessenger* messenger,
      DownloadJobManager* manager,
      wil::com_ptr<ICoreWebView2DownloadOperation> downloadOperation,
      const std::string& url,
      const std::string& resultFilePath);
    ~DownloadJobController();

    void start();
    void cancel();
    flutter::EncodableMap getInfo() const;
    void dispose();

  private:
    DownloadJobManager* manager_ = nullptr;
    wil::com_ptr<ICoreWebView2DownloadOperation> downloadOperation_;
    std::string url_;
    std::string resultFilePath_;
    int state_ = 1; // RUNNING
    double progress_ = 0.0;
    std::optional<std::string> error_;
    EventRegistrationToken bytesReceivedToken_ = {};
    EventRegistrationToken stateChangedToken_ = {};
    bool handlersAttached_ = false;
    bool completedEmitted_ = false;
    bool disposed_ = false;

    void attachHandlers();
    void detachHandlers();
    void updateProgressFromOperation();
    void handleStateChanged();
    void emitComplete(const bool completed, const std::optional<std::string>& error);
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_CONTROLLER_H_
