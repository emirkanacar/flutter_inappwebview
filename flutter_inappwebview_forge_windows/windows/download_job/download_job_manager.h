#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_MANAGER_H_

#include <WebView2.h>
#include <flutter/binary_messenger.h>
#include <wil/com.h>

#include <map>
#include <memory>
#include <string>

namespace flutter_inappwebview_plugin
{
  class FlutterInappwebviewWindowsPlugin;
  class DownloadJobController;

  class DownloadJobManager
  {
  public:
    explicit DownloadJobManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~DownloadJobManager();

    std::shared_ptr<DownloadJobController> create(
      const std::string& id,
      wil::com_ptr<ICoreWebView2DownloadOperation> downloadOperation,
      const std::string& url,
      const std::string& resultFilePath);
    std::shared_ptr<DownloadJobController> get(const std::string& id) const;
    void erase(const std::string& id);
    void dispose();

    std::map<std::string, std::shared_ptr<DownloadJobController>> jobs;

  private:
    const FlutterInappwebviewWindowsPlugin* plugin_ = nullptr;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_JOB_MANAGER_H_
