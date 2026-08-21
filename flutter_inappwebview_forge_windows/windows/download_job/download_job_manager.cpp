#include "download_job_manager.h"

#include "download_job_controller.h"
#include "../flutter_inappwebview_windows_plugin.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin
{
  DownloadJobManager::DownloadJobManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin_(plugin)
  {}

  std::shared_ptr<DownloadJobController> DownloadJobManager::create(
    const std::string& id,
    wil::com_ptr<ICoreWebView2DownloadOperation> downloadOperation,
    const std::string& url,
    const std::string& resultFilePath)
  {
    if (id.empty() || !plugin_ || !plugin_->registrar || !downloadOperation) {
      return nullptr;
    }

    auto controller = std::make_shared<DownloadJobController>(
      id,
      plugin_->registrar->messenger(),
      this,
      std::move(downloadOperation),
      url,
      resultFilePath);
    jobs[id] = controller;
    controller->start();
    return controller;
  }

  std::shared_ptr<DownloadJobController> DownloadJobManager::get(const std::string& id) const
  {
    auto it = jobs.find(id);
    return it != jobs.end() ? it->second : nullptr;
  }

  void DownloadJobManager::erase(const std::string& id)
  {
    jobs.erase(id);
  }

  void DownloadJobManager::dispose()
  {
    auto ownedJobs = jobs;
    jobs.clear();
    for (auto& pair : ownedJobs) {
      if (pair.second) {
        pair.second->dispose();
      }
    }
    plugin_ = nullptr;
  }

  DownloadJobManager::~DownloadJobManager()
  {
    debugLog("dealloc DownloadJobManager");
    dispose();
  }
}
