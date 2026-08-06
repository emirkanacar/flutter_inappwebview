package com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js

import com.emirkanacar.flutter_inappwebview_forge_android.types.PluginScript
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScriptInjectionTime

open class PrintJS {
    companion object {
        @JvmField
        val PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_PRINT_JS_PLUGIN_SCRIPT"

        @JvmStatic
        fun PRINT_JS_PLUGIN_SCRIPT(
            allowedOriginRules: MutableSet<String>?,
            forMainFrameOnly: Boolean
        ): PluginScript = PluginScript(
            PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            PRINT_JS_SOURCE(),
            UserScriptInjectionTime.AT_DOCUMENT_START,
            null,
            false,
            allowedOriginRules,
            forMainFrameOnly
        )

        @JvmStatic
        fun PRINT_JS_SOURCE(): String =
            "window.print = function() {" +
                "  if (window.top == null || window.top === window) {" +
                "     window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                ".callHandler('onPrintRequest', window.location.href);" +
                "  } else {" +
                "     window.top.print();" +
                "  }" +
                "};"
    }
}
