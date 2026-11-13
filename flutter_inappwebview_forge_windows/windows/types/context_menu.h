#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_

#include <flutter/standard_method_codec.h>
#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin
{
  // Mirrors the Dart ContextMenuItem map ("id", "title"). The id is kept as
  // the original EncodableValue (int32, int64, or string) so it can be sent
  // back unchanged in onContextMenuActionItemClicked.
  struct ContextMenuItem
  {
    flutter::EncodableValue id;
    std::string title;
  };

  // Mirrors the Dart ContextMenu map ("menuItems", "settings").
  class ContextMenu
  {
  public:
    std::vector<ContextMenuItem> menuItems;
    bool hideDefaultSystemContextMenuItems = false;

    ContextMenu(const flutter::EncodableMap& map);
    ~ContextMenu();

    // Returns nullptr for a missing or empty map: the Dart side sends {} when
    // no ContextMenu was supplied.
    static std::shared_ptr<ContextMenu> fromOptionalMap(const std::optional<flutter::EncodableMap>& map);
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_H_
