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
            var state = window.__flutterInAppWebViewDisableAutocorrection || {
                observer: null,
                elements: new Map(),
                trackedElements: new Set()
            };
            if (state.observer) {
                state.observer.disconnect();
            }

            var applyToEditableElements = function(root) {
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
                    if (!state.trackedElements.has(element)) {
                        state.elements.set(element, {
                            autocorrect: element.getAttribute('autocorrect'),
                            spellcheck: element.getAttribute('spellcheck')
                        });
                        state.trackedElements.add(element);
                    }
                    element.setAttribute('autocorrect', 'off');
                    element.setAttribute('spellcheck', 'false');
                });
            };

            window.__flutterInAppWebViewDisableAutocorrection = state;
            applyToEditableElements(document);

            if (window.MutationObserver) {
                state.observer = new MutationObserver(function(mutations) {
                    mutations.forEach(function(mutation) {
                        Array.prototype.forEach.call(mutation.addedNodes, applyToEditableElements);
                    });
                });
                state.observer.observe(document, { childList: true, subtree: true });
            }
        })();
        """
    }

    public static func ENABLE_AUTOCORRECTION_JS_SOURCE() -> String {
        return """
        (function() {
            var state = window.__flutterInAppWebViewDisableAutocorrection;
            if (!state) {
                return;
            }
            if (state.observer) {
                state.observer.disconnect();
            }
            state.elements.forEach(function(previous, element) {
                if (previous.autocorrect === null) {
                    element.removeAttribute('autocorrect');
                } else {
                    element.setAttribute('autocorrect', previous.autocorrect);
                }
                if (previous.spellcheck === null) {
                    element.removeAttribute('spellcheck');
                } else {
                    element.setAttribute('spellcheck', previous.spellcheck);
                }
            });
            delete window.__flutterInAppWebViewDisableAutocorrection;
        })();
        """
    }
}
