#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_

#include <filesystem>
#include <optional>
#include <string>
#include <vector>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {
class FlutterInappwebviewWindowsPlugin;

class ContainerManager : public ChannelDelegate {
 public:
  static inline const std::string METHOD_CHANNEL_NAME =
      "com.emirkanacar/flutter_inappwebview_containercontroller";

  explicit ContainerManager(const FlutterInappwebviewWindowsPlugin* plugin);
  ~ContainerManager() override;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

  static std::optional<std::filesystem::path> userDataFolderFor(
      const std::string& containerId);

 private:
  const FlutterInappwebviewWindowsPlugin* plugin_;
  static bool isSafeContainerId(const std::string& containerId);
  static std::filesystem::path rootFolder();
  static std::vector<std::string> allContainerNames();
};
}

#endif
