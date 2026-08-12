#include "container_manager.h"

#include <glib.h>

#include "plugin_instance.h"
#include "utils/flutter.h"

namespace flutter_inappwebview_plugin {

ContainerManager::ContainerManager(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME) {}

bool ContainerManager::isSafeContainerId(const std::string& container_id) {
  if (container_id.empty() || container_id == "." || container_id == "..") return false;
  for (const char character : container_id) {
    if (!((character >= 'a' && character <= 'z') ||
          (character >= 'A' && character <= 'Z') ||
          (character >= '0' && character <= '9') || character == '-' || character == '_' ||
          character == '.')) {
      return false;
    }
  }
  return true;
}

std::filesystem::path ContainerManager::rootDirectory() {
  return std::filesystem::path(g_get_user_data_dir()) / "flutter_inappwebview_forge" /
         "containers";
}

std::optional<std::filesystem::path> ContainerManager::dataDirectoryFor(
    const std::string& container_id) {
  if (!isSafeContainerId(container_id)) return std::nullopt;
  return rootDirectory() / container_id / "data";
}

std::vector<std::string> ContainerManager::allContainerNames() {
  std::vector<std::string> result;
  std::error_code error;
  const auto root = rootDirectory();
  if (!std::filesystem::is_directory(root, error)) return result;
  for (const auto& entry : std::filesystem::directory_iterator(root, error)) {
    if (error || !entry.is_directory(error)) continue;
    const auto name = entry.path().filename().string();
    if (isSafeContainerId(name)) result.push_back(name);
  }
  return result;
}

void ContainerManager::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  if (g_strcmp0(method, "getAllContainerNames") == 0) {
    g_autoptr(FlValue) names = fl_value_new_list();
    for (const auto& name : allContainerNames()) {
      fl_value_append_take(names, fl_value_new_string(name.c_str()));
    }
    fl_method_call_respond_success(method_call, names, nullptr);
    return;
  }

  const auto container_id = get_optional_fl_map_value<std::string>(args, "containerId");
  const auto directory = container_id.has_value() ? dataDirectoryFor(container_id.value())
                                                   : std::nullopt;
  if (!directory.has_value()) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(FALSE), nullptr);
    return;
  }

  std::error_code error;
  if (g_strcmp0(method, "hasContainer") == 0) {
    fl_method_call_respond_success(
        method_call, fl_value_new_bool(std::filesystem::is_directory(directory.value(), error)),
        nullptr);
  } else if (g_strcmp0(method, "deleteContainer") == 0) {
    const bool existed = std::filesystem::is_directory(directory.value(), error);
    if (existed) std::filesystem::remove_all(directory.value().parent_path(), error);
    fl_method_call_respond_success(method_call, fl_value_new_bool(existed && !error), nullptr);
  } else if (g_strcmp0(method, "clearContainerData") == 0) {
    if (!std::filesystem::is_directory(directory.value(), error)) {
      fl_method_call_respond_success(method_call, fl_value_new_bool(FALSE), nullptr);
      return;
    }
    for (const auto& entry : std::filesystem::directory_iterator(directory.value(), error)) {
      if (error) break;
      std::filesystem::remove_all(entry.path(), error);
    }
    fl_method_call_respond_success(method_call, fl_value_new_bool(!error), nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

}  // namespace flutter_inappwebview_plugin
