package com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js

import com.emirkanacar.flutter_inappwebview_forge_android.types.PluginScript
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScriptInjectionTime

open class OnWindowBlurEventJS {
    companion object {
        @JvmField
        val ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME =
            "IN_APP_WEBVIEW_ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT"

        @JvmStatic
        fun ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT(
            allowedOriginRules: MutableSet<String>?
        ): PluginScript = PluginScript(
            ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT_GROUP_NAME,
            ON_WINDOW_BLUR_EVENT_JS_SOURCE(),
            UserScriptInjectionTime.AT_DOCUMENT_START,
            null,
            false,
            allowedOriginRules,
            true
        )

        @JvmStatic
        fun ON_WINDOW_BLUR_EVENT_JS_SOURCE(): String =
            "(function(){" +
                "  window.addEventListener('blur', function(e) {" +
                "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                ".callHandler('onWindowBlur');" +
                "  });" +
                "})();"
    }
}
