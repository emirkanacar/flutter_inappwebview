//
//  DisableAutocorrectionJS.swift
//  flutter_inappwebview_forge
//

import Foundation

public class DisableAutocorrectionJS {
    public static let DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME =
        "IN_APP_WEBVIEW_DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT"

    public static func DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?,
                                                               forMainFrameOnly: Bool) -> PluginScript {
        return PluginScript(
            groupName: DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: DISABLE_AUTOCORRECTION_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: forMainFrameOnly,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: false,
            messageHandlerNames: [])
    }

    public static func DISABLE_AUTOCORRECTION_JS_SOURCE() -> String {
        return """
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
        """
    }
}
