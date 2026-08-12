#include "container_manager.h"

#include <cstdlib>
#include <fstream>

#include "flutter_inappwebview_windows_plugin.h"
#include "utils/flutter.h"

namespace flutter_inappwebview_plugin {

ContainerManager::ContainerManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : ChannelDelegate(plugin->registrar->messenger(), METHOD_CHANNEL_NAME), plugin_(plugin) {}

ContainerManager::~ContainerManager() { plugin_ = nullptr; }

bool ContainerManager::isSafeContainerId(const std::string& containerId) {
  if (containerId.empty() || containerId == "." || containerId == "..") return false;
  for (const char character : containerId) {
    if (!((character >= 'a' && character <= 'z') ||
          (character >= 'A' && character <= 'Z') ||
          (character >= '0' && character <= '9') || character == '-' || character == '_' ||
          character == '.')) {
      return false;
    }
  }
  return true;
}

std::filesystem::path ContainerManager::rootFolder() {
  const char* localAppData = std::getenv("LOCALAPPDATA");
  const auto base = localAppData != nullptr ? std::filesystem::path(localAppData)
                                            : std::filesystem::temp_directory_path();
  return base / "flutter_inappwebview_forge" / "containers";
}

std::optional<std::filesystem::path> ContainerManager::userDataFolderFor(
    const std::string& containerId) {
  if (!isSafeContainerId(containerId)) return std::nullopt;
  return rootFolder() / containerId;
}

std::vector<std::string> ContainerManager::allContainerNames() {
  std::vector<std::string> result;
  std::error_code error;
  const auto root = rootFolder();
  if (!std::filesystem::is_directory(root, error)) return result;
  for (const auto& entry : std::filesystem::directory_iterator(root, error)) {
    if (error || !entry.is_directory(error)) continue;
    const auto name = entry.path().filename().string();
    if (isSafeContainerId(name)) result.push_back(name);
  }
  return result;
}

void ContainerManager::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "getAllContainerNames") {
    flutter::EncodableList names;
    for (const auto& name : allContainerNames()) names.emplace_back(name);
    result->Success(names);
    return;
  }

  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  const auto containerId = arguments == nullptr
                               ? std::optional<std::string>{}
                               : get_optional_fl_map_value<std::string>(*arguments, "containerId");
  const auto folder = containerId.has_value() ? userDataFolderFor(containerId.value())
                                              : std::nullopt;
  if (!folder.has_value()) {
    result->Success(false);
    return;
  }

  std::error_code error;
  if (method_call.method_name() == "hasContainer") {
    result->Success(std::filesystem::is_directory(folder.value(), error));
  } else if (method_call.method_name() == "deleteContainer") {
    const bool existed = std::filesystem::is_directory(folder.value(), error);
    if (existed) std::filesystem::remove_all(folder.value(), error);
    result->Success(existed && !error);
  } else if (method_call.method_name() == "clearContainerData") {
    if (!std::filesystem::is_directory(folder.value(), error)) {
      result->Success(false);
      return;
    }
    for (const auto& entry : std::filesystem::directory_iterator(folder.value(), error)) {
      if (error) break;
      std::filesystem::remove_all(entry.path(), error);
    }
    result->Success(!error);
  } else {
    result->NotImplemented();
  }
}
}
