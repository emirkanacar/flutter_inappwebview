#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DISABLE_AUTOCORRECTION_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DISABLE_AUTOCORRECTION_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"

namespace flutter_inappwebview_plugin {

class DisableAutocorrectionJS {
 public:
  inline static const std::string DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT";

  static std::string DISABLE_AUTOCORRECTION_JS_SOURCE() {
    return R"JS(
(function() {
  var apply = function(root) {
    var elements = [];
    if (root && root.nodeType === 1 &&
        (root.matches('input, textarea, [contenteditable]') || root.isContentEditable)) {
      elements.push(root);
    }
    if (root && root.querySelectorAll) {
      elements = elements.concat(Array.prototype.slice.call(
        root.querySelectorAll('input, textarea, [contenteditable]')));
    }
    elements.forEach(function(element) {
      element.setAttribute('autocorrect', 'off');
      element.setAttribute('spellcheck', 'false');
    });
  };
  apply(document);
  if (window.MutationObserver) {
    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        Array.prototype.forEach.call(mutation.addedNodes, apply);
      });
    });
    observer.observe(document, { childList: true, subtree: true });
  }
})();
)JS";
  }

  static std::unique_ptr<PluginScript> DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME,
        DISABLE_AUTOCORRECTION_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules);
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_DISABLE_AUTOCORRECTION_JS_H_
