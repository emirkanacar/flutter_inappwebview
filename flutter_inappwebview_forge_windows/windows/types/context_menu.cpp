#include "context_menu.h"

namespace flutter_inappwebview_plugin
{
  namespace
  {
    const flutter::EncodableValue* findValue(const flutter::EncodableMap& map, const char* key)
    {
      auto it = map.find(flutter::EncodableValue(key));
      if (it == map.end() || it->second.IsNull()) {
        return nullptr;
      }
      return &it->second;
    }

    bool isValidItemId(const flutter::EncodableValue& value)
    {
      return std::holds_alternative<std::string>(value) ||
        std::holds_alternative<int32_t>(value) ||
        std::holds_alternative<int64_t>(value);
    }
  }

  ContextMenu::ContextMenu(const flutter::EncodableMap& map)
  {
    if (auto items = findValue(map, "menuItems")) {
      if (auto list = std::get_if<flutter::EncodableList>(items)) {
        for (const auto& entry : *list) {
          auto itemMap = std::get_if<flutter::EncodableMap>(&entry);
          if (!itemMap) {
            continue;
          }
          auto id = findValue(*itemMap, "id");
          auto title = findValue(*itemMap, "title");
          if (!id || !isValidItemId(*id) || !title || !std::holds_alternative<std::string>(*title)) {
            continue;
          }
          menuItems.push_back(ContextMenuItem{ *id, std::get<std::string>(*title) });
        }
      }
    }

    if (auto settings = findValue(map, "settings")) {
      if (auto settingsMap = std::get_if<flutter::EncodableMap>(settings)) {
        if (auto hide = findValue(*settingsMap, "hideDefaultSystemContextMenuItems")) {
          if (auto hideValue = std::get_if<bool>(hide)) {
            hideDefaultSystemContextMenuItems = *hideValue;
          }
        }
      }
    }
  }

  ContextMenu::~ContextMenu()
  {}

  std::shared_ptr<ContextMenu> ContextMenu::fromOptionalMap(const std::optional<flutter::EncodableMap>& map)
  {
    if (!map.has_value() || map.value().empty()) {
      return nullptr;
    }
    return std::make_shared<ContextMenu>(map.value());
  }
}
