#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_

#include <flutter_linux/flutter_linux.h>

#include <filesystem>
#include <optional>
#include <string>
#include <vector>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

class ContainerManager : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.emirkanacar/flutter_inappwebview_containercontroller";

  explicit ContainerManager(PluginInstance* plugin);
  ~ContainerManager() override = default;

  void HandleMethodCall(FlMethodCall* method_call) override;

  static std::optional<std::filesystem::path> dataDirectoryFor(
      const std::string& container_id);

 private:
  static bool isSafeContainerId(const std::string& container_id);
  static std::filesystem::path rootDirectory();
  static std::vector<std::string> allContainerNames();
};

}  // namespace flutter_inappwebview_plugin

#endif
