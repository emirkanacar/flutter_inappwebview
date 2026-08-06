package com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js

import com.emirkanacar.flutter_inappwebview_forge_android.types.PluginScript
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScriptInjectionTime

open class OnLoadResourceJS {
    companion object {
        @JvmField
        val ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME =
            "IN_APP_WEBVIEW_ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT"

        @JvmStatic
        fun FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE(): String =
            JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + "._useOnLoadResource"

        @JvmStatic
        fun ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
            allowedOriginRules: MutableSet<String>?,
            forMainFrameOnly: Boolean
        ): PluginScript = PluginScript(
            ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME,
            ON_LOAD_RESOURCE_JS_SOURCE(),
            UserScriptInjectionTime.AT_DOCUMENT_START,
            null,
            false,
            allowedOriginRules,
            forMainFrameOnly
        )

        @JvmStatic
        fun ON_LOAD_RESOURCE_JS_SOURCE(): String =
            "window." + FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE() + " = true;" +
                "(function() {" +
                "   var observer = new PerformanceObserver(function(list) {" +
                "       list.getEntries().forEach(function(entry) {" +
                "         if (" + FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE() + " == null || " +
                FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE() + " == true) {" +
                "           var resource = {" +
                "             'url': entry.name," +
                "             'initiatorType': entry.initiatorType," +
                "             'startTime': entry.startTime," +
                "             'duration': entry.duration" +
                "           };" +
                "           window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                ".callHandler('onLoadResource', resource);" +
                "         }" +
                "       });" +
                "   });" +
                "   observer.observe({entryTypes: ['resource']});" +
                "})();"
    }
}
