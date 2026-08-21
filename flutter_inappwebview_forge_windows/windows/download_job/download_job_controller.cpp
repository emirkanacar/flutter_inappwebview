#include "download_job_controller.h"

#include "download_job_channel_delegate.h"
#include "download_job_manager.h"
#include "../utils/flutter.h"
#include "../utils/log.h"

#include <wrl.h>

using namespace Microsoft::WRL;

namespace flutter_inappwebview_plugin
{
  namespace
  {
    constexpr int kStateRunning = 1;
    constexpr int kStateCompleted = 2;
    constexpr int kStateFailed = 3;
    constexpr int kStateCanceled = 4;
  }

  DownloadJobController::DownloadJobController(
    const std::string& id,
    flutter::BinaryMessenger* messenger,
    DownloadJobManager* manager,
    wil::com_ptr<ICoreWebView2DownloadOperation> downloadOperation,
    const std::string& url,
    const std::string& resultFilePath)
    : id(id),
    manager_(manager),
    downloadOperation_(std::move(downloadOperation)),
    url_(url),
    resultFilePath_(resultFilePath),
    state_(kStateRunning)
  {
    channelDelegate = std::make_unique<DownloadJobChannelDelegate>(
      this, messenger, METHOD_CHANNEL_NAME_PREFIX + id);
  }

  void DownloadJobController::start()
  {
    attachHandlers();
    updateProgressFromOperation();
    handleStateChanged();
  }

  void DownloadJobController::attachHandlers()
  {
    if (handlersAttached_ || !downloadOperation_) {
      return;
    }

    // Keep the COM pointer alive inside the handlers so WebView2 can deliver events.
    auto download = downloadOperation_;
    auto weakSelf = weak_from_this();

    failedLog(download->add_BytesReceivedChanged(
      Callback<ICoreWebView2BytesReceivedChangedEventHandler>(
        [weakSelf, download](ICoreWebView2DownloadOperation* sender, IUnknown* args) -> HRESULT
        {
          if (auto self = weakSelf.lock()) {
            self->updateProgressFromOperation();
          }
          return S_OK;
        }).Get(),
      &bytesReceivedToken_));

    failedLog(download->add_StateChanged(
      Callback<ICoreWebView2StateChangedEventHandler>(
        [weakSelf, download](ICoreWebView2DownloadOperation* sender, IUnknown* args) -> HRESULT
        {
          if (auto self = weakSelf.lock()) {
            self->handleStateChanged();
          }
          return S_OK;
        }).Get(),
      &stateChangedToken_));

    handlersAttached_ = true;
  }

  void DownloadJobController::detachHandlers()
  {
    if (!handlersAttached_ || !downloadOperation_) {
      handlersAttached_ = false;
      return;
    }

    failedLog(downloadOperation_->remove_BytesReceivedChanged(bytesReceivedToken_));
    failedLog(downloadOperation_->remove_StateChanged(stateChangedToken_));
    bytesReceivedToken_ = {};
    stateChangedToken_ = {};
    handlersAttached_ = false;
  }

  void DownloadJobController::updateProgressFromOperation()
  {
    if (!downloadOperation_ || disposed_) {
      return;
    }

    INT64 bytesReceived = 0;
    INT64 totalBytes = 0;
    failedLog(downloadOperation_->get_BytesReceived(&bytesReceived));
    failedLog(downloadOperation_->get_TotalBytesToReceive(&totalBytes));

    if (totalBytes > 0) {
      progress_ = static_cast<double>(bytesReceived) / static_cast<double>(totalBytes);
      if (channelDelegate) {
        channelDelegate->onProgressChanged(progress_);
      }
    }
  }

  void DownloadJobController::handleStateChanged()
  {
    if (!downloadOperation_ || disposed_ || completedEmitted_) {
      return;
    }

    COREWEBVIEW2_DOWNLOAD_STATE state =
      COREWEBVIEW2_DOWNLOAD_STATE_IN_PROGRESS;
    if (FAILED(downloadOperation_->get_State(&state))) {
      return;
    }

    switch (state) {
    case COREWEBVIEW2_DOWNLOAD_STATE_IN_PROGRESS:
      state_ = kStateRunning;
      updateProgressFromOperation();
      break;
    case COREWEBVIEW2_DOWNLOAD_STATE_COMPLETED:
      state_ = kStateCompleted;
      progress_ = 1.0;
      if (channelDelegate) {
        channelDelegate->onProgressChanged(1.0);
      }
      emitComplete(true, std::nullopt);
      break;
    case COREWEBVIEW2_DOWNLOAD_STATE_INTERRUPTED: {
      COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON reason =
        COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_NONE;
      failedLog(downloadOperation_->get_InterruptReason(&reason));
      if (reason == COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_USER_CANCELED) {
        state_ = kStateCanceled;
        emitComplete(false, std::string("canceled"));
      }
      else {
        state_ = kStateFailed;
        emitComplete(false, std::string("interrupted:") + std::to_string(static_cast<int>(reason)));
      }
      break;
    }
    }
  }

  void DownloadJobController::emitComplete(const bool completed, const std::optional<std::string>& error)
  {
    if (completedEmitted_) {
      return;
    }
    completedEmitted_ = true;
    error_ = error;
    if (channelDelegate) {
      channelDelegate->onComplete(completed, error);
    }
  }

  void DownloadJobController::cancel()
  {
    if (disposed_ || completedEmitted_) {
      return;
    }

    if (downloadOperation_) {
      failedLog(downloadOperation_->Cancel());
    }
    state_ = kStateCanceled;
    emitComplete(false, std::string("canceled"));
  }

  flutter::EncodableMap DownloadJobController::getInfo() const
  {
    return flutter::EncodableMap{
      {"id", make_fl_value(id)},
      {"url", make_fl_value(url_)},
      {"resultFilePath", make_fl_value(resultFilePath_)},
      {"progress", make_fl_value(progress_)},
      {"state", make_fl_value(static_cast<int64_t>(state_))},
      {"error", make_fl_value(error_)}
    };
  }

  void DownloadJobController::dispose()
  {
    if (disposed_) {
      return;
    }
    disposed_ = true;

    detachHandlers();
    downloadOperation_.reset();

    if (channelDelegate) {
      channelDelegate->dispose();
      channelDelegate.reset();
    }

    // Erase last so manager ownership cannot destroy this mid-cleanup.
    auto* manager = manager_;
    manager_ = nullptr;
    if (manager) {
      manager->erase(id);
    }
  }

  DownloadJobController::~DownloadJobController()
  {
    debugLog("dealloc DownloadJobController");
    if (disposed_) {
      return;
    }
    disposed_ = true;
    detachHandlers();
    downloadOperation_.reset();
    if (channelDelegate) {
      channelDelegate->dispose();
      channelDelegate.reset();
    }
    manager_ = nullptr;
  }
}
