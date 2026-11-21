//
//  ConsoleLogJS.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class ConsoleLogJS {
    
    public static let CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT"
    
    // This plugin is only for main frame.
    // Using it also on non-main frames could cause issues
    // such as https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738
    public static func CONSOLE_LOG_JS_PLUGIN_SCRIPT(allowedOriginRules: [String]?) -> PluginScript {
        return PluginScript(
            groupName: CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
            source: CONSOLE_LOG_JS_SOURCE(),
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            allowedOriginRules: allowedOriginRules,
            requiredInAllContentWorlds: true,
            messageHandlerNames: [])
    }
    
    // Sets the per-document switch read by CONSOLE_LOG_JS_SOURCE. When it is
    // false the console methods still run but nothing is stringified or sent
    // over the bridge, which is the no-listener fast path.
    public static func SET_CONSOLE_MESSAGES_ENABLED_JS_SOURCE(_ enabled: Bool) -> String {
        return "if (window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME()) != null) { window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._consoleMessagesEnabled = \(enabled); }"
    }

    // the message needs to be concatenated with '' in order to have the same behavior like on Android
    public static func CONSOLE_LOG_JS_SOURCE() -> String {
        return """
        (function(console) {
            var _bridge = window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME());
            if (_bridge != null) {
                // Hook once per document and content world, so a runtime
                // re-injection cannot report the same message twice.
                if (_bridge._consoleLogHooked === true) { return; }
                _bridge._consoleLogHooked = true;
            }
        
            function _callHandler(logLevel, args) {
                var bridge = window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME());
                if (bridge == null || bridge._consoleMessagesEnabled === false) { return; }
                var message = '';
                for (var i in args) {
                    try {
                        message += message === '' ? args[i] : ' ' + args[i];
                    } catch(_) {}
                }
                try {
                    bridge.callHandler('onConsoleMessage', {'level': logLevel, 'message': message})
                } catch(_) {}
            }
        
            var oldLogs = {
                'consoleLog': console.log,
                'consoleDebug': console.debug,
                'consoleError': console.error,
                'consoleInfo': console.info,
                'consoleWarn': console.warn
            };
        
            for (var k in oldLogs) {
                (function(oldLog) {
                    var logLevel = oldLog.replace('console', '').toLowerCase();
                    console[logLevel] = function() {
                        oldLogs[oldLog].apply(null, arguments);
                        _callHandler(logLevel, arguments);
                    }
                })(k);
            }
        })(window.console);
        """
    }
}
