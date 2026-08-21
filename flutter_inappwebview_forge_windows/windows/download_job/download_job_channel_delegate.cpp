#include "download_job_channel_delegate.h"

#include "download_job_controller.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{
  DownloadJobChannelDelegate::DownloadJobChannelDelegate(
    DownloadJobController* downloadJobController,
    flutter::BinaryMessenger* messenger, const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
    downloadJobController_(downloadJobController)
  {}

  void DownloadJobChannelDelegate::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (disposed_ || !downloadJobController_) {
      result->Success(make_fl_value());
      return;
    }

    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "cancel")) {
      downloadJobController_->cancel();
      result->Success(make_fl_value(true));
    }
    else if (string_equals(methodName, "getInfo")) {
      result->Success(make_fl_value(downloadJobController_->getInfo()));
    }
    else if (string_equals(methodName, "dispose")) {
      downloadJobController_->dispose();
      result->Success(make_fl_value(true));
    }
    else {
      result->NotImplemented();
    }
  }

  void DownloadJobChannelDelegate::onProgressChanged(const double progress) const
  {
    if (disposed_ || !channel) {
      return;
    }

    auto arguments = flutter::EncodableMap{};
    arguments.insert({ make_fl_value("progress"), make_fl_value(progress) });
    channel->InvokeMethod("onProgressChanged", std::make_unique<flutter::EncodableValue>(arguments));
  }

  void DownloadJobChannelDelegate::onComplete(const bool completed, const std::optional<std::string>& error) const
  {
    if (disposed_ || !channel) {
      return;
    }

    auto arguments = flutter::EncodableMap{};
    arguments.insert({ make_fl_value("completed"), make_fl_value(completed) });
    arguments.insert({ make_fl_value("error"), make_fl_value(error) });
    channel->InvokeMethod("onComplete", std::make_unique<flutter::EncodableValue>(arguments));
  }

  void DownloadJobChannelDelegate::dispose()
  {
    if (disposed_) {
      return;
    }
    disposed_ = true;

    UnregisterMethodCallHandler();
    downloadJobController_ = nullptr;
  }

  DownloadJobChannelDelegate::~DownloadJobChannelDelegate()
  {
    debugLog("dealloc DownloadJobChannelDelegate");
    downloadJobController_ = nullptr;
  }
}
