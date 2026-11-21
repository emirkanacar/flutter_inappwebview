#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPTS_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPTS_UTIL_H_

#include <string>

#include <memory>
#include <optional>
#include <vector>

#include "../types/plugin_script.h"

namespace flutter_inappwebview_plugin
{
  const std::string VAR_PLACEHOLDER_VALUE = "$IN_APP_WEBVIEW_PLACEHOLDER_VALUE";
  const std::string VAR_FUNCTION_ARGUMENT_NAMES = "$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_NAMES";
  const std::string VAR_FUNCTION_ARGUMENT_VALUES = "$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_VALUES";
  const std::string VAR_FUNCTION_BODY = "$IN_APP_WEBVIEW_FUNCTION_BODY";

  inline const std::string DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT";

  inline std::string DISABLE_AUTOCORRECTION_JS_SOURCE() {
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

  inline std::shared_ptr<PluginScript> DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_shared<PluginScript>(
        DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME,
        DISABLE_AUTOCORRECTION_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,
        true);
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPTS_UTIL_H_
