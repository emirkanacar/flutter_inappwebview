package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.annotation.SuppressLint
import android.text.TextUtils
import android.util.Log
import android.webkit.WebView
import androidx.webkit.ScriptHandler
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.PluginScriptsUtil
import org.json.JSONObject
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedHashSet

@SuppressLint("RestrictedApi")
open class UserContentController(initialWebView: WebView?) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG = "UserContentController"

        @JvmStatic
        fun escapeCode(code: String): String = JSONObject.quote(code)

        @JvmStatic
        fun escapeContentWorldName(name: String): String = name.replace("'", "\\'")

        private fun userScriptsAtDocumentStart(): String =
            "if (window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentStartLoaded == null || !window._" +
                JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentStartLoaded) {" +
                "  window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentStartLoaded = true;" +
                "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
                "}"

        private fun userScriptsAtDocumentEnd(): String =
            "if (window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentEndLoaded == null || !window._" +
                JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentEndLoaded) {" +
                "  window._" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_userScriptsAtDocumentEndLoaded = true;" +
                "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
                "}"

        private fun contentWorldsGenerator(): String =
            "(function() {" +
                "  var interval = setInterval(function() {" +
                "    if (document.body == null) {return;}" +
                "    var contentWorldNames = [" +
                PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY + "];" +
                "    for (var contentWorldName of contentWorldNames) {" +
                "      var iframeId = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_' + contentWorldName;" +
                "      var iframe = document.getElementById(iframeId);" +
                "      if (iframe == null) {" +
                "        iframe = document.createElement('iframe');" +
                "        iframe.id = iframeId;" +
                "        iframe.style = 'display: none; z-index: 0; position: absolute; width: 0px; height: 0px';" +
                "        document.body.append(iframe);" +
                "      }" +
                "      if (iframe.contentWindow.document.getElementById('" +
                JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_plugin_scripts') == null) {" +
                "        var script = iframe.contentWindow.document.createElement('script');" +
                "        script.id = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_plugin_scripts';" +
                "        script.innerHTML = " + PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED + ";" +
                "        iframe.contentWindow.document.body.append(script);" +
                "      }" +
                "    }" +
                "    clearInterval(interval);" +
                "  });" +
                "})();"

        private fun contentWorldWrapper(): String =
            "(function() {" +
                "  var interval = setInterval(function() {" +
                "    if (document.body == null) {return;}" +
                "    var iframeId = '" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_" + PluginScriptsUtil.VAR_CONTENT_WORLD_NAME + "';" +
                "    var iframe = document.getElementById(iframeId);" +
                "    if (iframe == null) {" +
                "      iframe = document.createElement('iframe');" +
                "      iframe.id = iframeId;" +
                "      iframe.style = 'display: none; z-index: 0; position: absolute; width: 0px; height: 0px';" +
                "      document.body.append(iframe);" +
                "    }" +
                "    if (iframe.contentWindow.document.querySelector('#" +
                JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                "_plugin_scripts') == null) {" +
                "      return;" +
                "    }" +
                "    var script = iframe.contentWindow.document.createElement('script');" +
                "    script.innerHTML = " + PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED + ";" +
                "    iframe.contentWindow.document.body.append(script);" +
                "    clearInterval(interval);" +
                "  });" +
                "})();"

        private val DOCUMENT_READY_WRAPPER_JS_SOURCE =
            "if (document.readyState === 'interactive' || document.readyState === 'complete') { " +
                "  " + PluginScriptsUtil.VAR_PLACEHOLDER_VALUE +
                "}"
    }

    @JvmField
    var webView: WebView? = initialWebView

    private val contentWorlds: MutableSet<ContentWorld> = hashSetOf(ContentWorld.PAGE)
    private val scriptHandlerMap: MutableMap<UserScript, ScriptHandler> = HashMap()
    private var contentWorldsCreatorScript: ScriptHandler? = null
    private val pendingUserOnlyScriptRegistrations: MutableSet<UserScript> = LinkedHashSet()
    private val pendingPluginScriptRegistrations: MutableSet<PluginScript> = LinkedHashSet()
    private var contentWorldsCreatorScriptPending = false

    private val userOnlyScripts: MutableMap<UserScriptInjectionTime, LinkedHashSet<UserScript>> =
        hashMapOf(
            UserScriptInjectionTime.AT_DOCUMENT_START to LinkedHashSet(),
            UserScriptInjectionTime.AT_DOCUMENT_END to LinkedHashSet()
        )

    private val pluginScripts: MutableMap<UserScriptInjectionTime, LinkedHashSet<PluginScript>> =
        hashMapOf(
            UserScriptInjectionTime.AT_DOCUMENT_START to LinkedHashSet(),
            UserScriptInjectionTime.AT_DOCUMENT_END to LinkedHashSet()
        )

    fun generateWrappedCodeForDocumentStart(): String =
        Util.replaceAll(
            DOCUMENT_READY_WRAPPER_JS_SOURCE,
            PluginScriptsUtil.VAR_PLACEHOLDER_VALUE,
            generateCodeForDocumentStart()
        )

    fun generateWrappedCodeForDocumentEnd(): String {
        val injectionTime = UserScriptInjectionTime.AT_DOCUMENT_END
        var js = ""
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            js += generateCodeForDocumentStart()
        }
        js += generatePluginScriptsCodeAt(injectionTime)
        js += generateUserOnlyScriptsCodeAt(injectionTime)
        return userScriptsAtDocumentEnd().replace(
            PluginScriptsUtil.VAR_PLACEHOLDER_VALUE,
            js
        )
    }

    fun generateCodeForDocumentStart(): String {
        val injectionTime = UserScriptInjectionTime.AT_DOCUMENT_START
        var js = ""
        js += generatePluginScriptsCodeAt(injectionTime)
        js += generateContentWorldsCreatorCode()
        js += generateUserOnlyScriptsCodeAt(injectionTime)
        return userScriptsAtDocumentStart().replace(
            PluginScriptsUtil.VAR_PLACEHOLDER_VALUE,
            js
        )
    }

    fun generateContentWorldsCreatorCode(): String {
        if (contentWorlds.size == 1) {
            return ""
        }

        val source = StringBuilder()
        getPluginScriptsRequiredInAllContentWorlds().forEach { script ->
            source.append(script.source)
        }
        val contentWorldNames = contentWorlds
            .filter { it != ContentWorld.PAGE }
            .map { "'${escapeContentWorldName(it.name)}'" }

        return contentWorldsGenerator()
            .replace(
                PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY,
                TextUtils.join(", ", contentWorldNames)
            )
            .replace(
                PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED,
                escapeCode(source.toString())
            )
    }

    fun generatePluginScriptsCodeAt(injectionTime: UserScriptInjectionTime): String {
        val js = StringBuilder()
        getPluginScriptsAt(injectionTime).forEach { script ->
            var source = ";${script.source}"
            source = wrapSourceCodeInContentWorld(script.getContentWorld(), source)
            source = wrapSourceCodeAddChecks(source, script)
            js.append(source)
        }
        return js.toString()
    }

    fun generateUserOnlyScriptsCodeAt(injectionTime: UserScriptInjectionTime): String {
        val js = StringBuilder()
        getUserOnlyScriptsAt(injectionTime).forEach { script ->
            var source = ";${script.source}"
            source = wrapSourceCodeInContentWorld(script.getContentWorld(), source)
            source = wrapSourceCodeAddChecks(source, script)
            js.append(source)
        }
        return js.toString()
    }

    fun generateCodeForScriptEvaluation(source: String, contentWorld: ContentWorld?): String {
        if (contentWorld != null && contentWorld != ContentWorld.PAGE) {
            val sourceWrapped = StringBuilder()
            if (!contentWorlds.contains(contentWorld)) {
                contentWorlds.add(contentWorld)
                val pluginScriptsSource = StringBuilder()
                getPluginScriptsRequiredInAllContentWorlds().forEach { script ->
                    pluginScriptsSource.append(script.source)
                }
                val contentWorldCreatorCode = contentWorldsGenerator()
                    .replace(
                        PluginScriptsUtil.VAR_CONTENT_WORLD_NAME_ARRAY,
                        "'${escapeContentWorldName(contentWorld.name)}'"
                    )
                    .replace(
                        PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED,
                        escapeCode(pluginScriptsSource.toString())
                    )
                sourceWrapped.append(contentWorldCreatorCode).append(";")
            }
            return sourceWrapped
                .append(wrapSourceCodeInContentWorld(contentWorld, source))
                .toString()
        }
        return source
    }

    fun wrapSourceCodeInContentWorld(contentWorld: ContentWorld?, source: String): String {
        if (contentWorld == null || contentWorld == ContentWorld.PAGE) {
            return source
        }
        return contentWorldWrapper()
            .replace(
                PluginScriptsUtil.VAR_CONTENT_WORLD_NAME,
                escapeContentWorldName(contentWorld.name)
            )
            .replace(
                PluginScriptsUtil.VAR_JSON_SOURCE_ENCODED,
                escapeCode(source)
            )
    }

    fun getUserOnlyScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<UserScript> =
        LinkedHashSet(userScriptsAt(injectionTime))

    private fun updateContentWorldsCreatorScript() {
        val source = generateContentWorldsCreatorCode()
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            contentWorldsCreatorScript?.remove()
            contentWorldsCreatorScript = null
            contentWorldsCreatorScriptPending = false
            val currentWebView = webView
            if (source.isNotEmpty() && currentWebView != null) {
                contentWorldsCreatorScript = addDocumentStartJavaScript(source, setOf("*"))
                contentWorldsCreatorScriptPending = contentWorldsCreatorScript == null
            }
        }
    }

    private fun addDocumentStartJavaScript(
        source: String,
        allowedOriginRules: Set<String>
    ): ScriptHandler? {
        val currentWebView = webView ?: return null
        return try {
            WebViewCompat.addDocumentStartJavaScript(currentWebView, source, allowedOriginRules)
        } catch (e: RuntimeException) {
            Log.e(LOG_TAG, "Unable to register document-start JavaScript", e)
            null
        }
    }

    fun addUserOnlyScript(userOnlyScript: UserScript): Boolean {
        contentWorlds.add(userOnlyScript.getContentWorld())
        updateContentWorldsCreatorScript()
        val currentWebView = webView
        if (currentWebView != null &&
            WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
        ) {
            var source = userOnlyScript.source
            if (userOnlyScript.injectionTime == UserScriptInjectionTime.AT_DOCUMENT_END) {
                source = "if (document.readyState === 'complete') { $source} else { window.addEventListener('load', function() { $source }); }"
            }
            source = wrapSourceCodeAddChecks(source, userOnlyScript)
            val scriptHandler = addDocumentStartJavaScript(
                wrapSourceCodeInContentWorld(userOnlyScript.getContentWorld(), source),
                userOnlyScript.getAllowedOriginRules()
            )
            if (scriptHandler != null) {
                scriptHandlerMap[userOnlyScript] = scriptHandler
                pendingUserOnlyScriptRegistrations.remove(userOnlyScript)
            } else {
                pendingUserOnlyScriptRegistrations.add(userOnlyScript)
            }
        }
        return userScriptsAt(userOnlyScript.injectionTime).add(userOnlyScript)
    }

    fun addUserOnlyScripts(userOnlyScripts: List<UserScript>) {
        userOnlyScripts.forEach { addUserOnlyScript(it) }
    }

    fun removeUserOnlyScript(userOnlyScript: UserScript): Boolean {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            scriptHandlerMap.remove(userOnlyScript)?.remove()
            pendingUserOnlyScriptRegistrations.remove(userOnlyScript)
            updateContentWorldsCreatorScript()
        }
        return userScriptsAt(userOnlyScript.injectionTime).remove(userOnlyScript)
    }

    fun removeUserOnlyScriptAt(index: Int, injectionTime: UserScriptInjectionTime): Boolean {
        val userOnlyScript = ArrayList(userScriptsAt(injectionTime))[index]
        return removeUserOnlyScript(userOnlyScript)
    }

    fun removeAllUserOnlyScripts() {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            userScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START).forEach {
                scriptHandlerMap.remove(it)?.remove()
            }
            userScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_END).forEach {
                scriptHandlerMap.remove(it)?.remove()
            }
        }
        pendingUserOnlyScriptRegistrations.clear()
        userScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START).clear()
        userScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_END).clear()
    }

    fun getPluginScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<PluginScript> =
        LinkedHashSet(pluginScriptsAt(injectionTime))

    fun getPluginScriptsRequiredInAllContentWorlds(): LinkedHashSet<PluginScript> =
        getPluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START)
            .filter { it.isRequiredInAllContentWorlds }
            .toCollection(LinkedHashSet())

    fun addPluginScript(pluginScript: PluginScript): Boolean {
        contentWorlds.add(pluginScript.getContentWorld())
        updateContentWorldsCreatorScript()
        val currentWebView = webView
        if (currentWebView != null &&
            WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
        ) {
            var source = pluginScript.source
            if (pluginScript.injectionTime == UserScriptInjectionTime.AT_DOCUMENT_END) {
                source = "if (document.readyState === 'complete') { $source} else { window.addEventListener('load', function() { $source }); }"
            }
            source = wrapSourceCodeAddChecks(source, pluginScript)
            val scriptHandler = addDocumentStartJavaScript(
                wrapSourceCodeInContentWorld(pluginScript.getContentWorld(), source),
                pluginScript.getAllowedOriginRules()
            )
            if (scriptHandler != null) {
                scriptHandlerMap[pluginScript] = scriptHandler
                pendingPluginScriptRegistrations.remove(pluginScript)
            } else {
                pendingPluginScriptRegistrations.add(pluginScript)
            }
        }
        return pluginScriptsAt(pluginScript.injectionTime).add(pluginScript)
    }

    fun addPluginScripts(pluginScripts: List<PluginScript>) {
        pluginScripts.forEach { addPluginScript(it) }
    }

    fun removePluginScript(pluginScript: PluginScript): Boolean {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            scriptHandlerMap.remove(pluginScript)?.remove()
            pendingPluginScriptRegistrations.remove(pluginScript)
            updateContentWorldsCreatorScript()
        }
        return pluginScriptsAt(pluginScript.injectionTime).remove(pluginScript)
    }

    fun removeAllPluginScripts() {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            pluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START).forEach {
                scriptHandlerMap.remove(it)?.remove()
            }
            pluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_END).forEach {
                scriptHandlerMap.remove(it)?.remove()
            }
        }
        pendingPluginScriptRegistrations.clear()
        pluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_START).clear()
        pluginScriptsAt(UserScriptInjectionTime.AT_DOCUMENT_END).clear()
    }

    fun getUserOnlyScriptAsList(): LinkedHashSet<UserScript> =
        userOnlyScripts.values
            .flatMapTo(LinkedHashSet()) { it }

    fun getPluginScriptAsList(): LinkedHashSet<PluginScript> =
        pluginScripts.values
            .flatMapTo(LinkedHashSet()) { it }

    fun resetContentWorlds() {
        contentWorlds.clear()
        contentWorlds.add(ContentWorld.PAGE)
        getPluginScriptAsList().forEach { contentWorlds.add(it.getContentWorld()) }
        getUserOnlyScriptAsList().forEach { contentWorlds.add(it.getContentWorld()) }
    }

    fun containsPluginScript(pluginScript: PluginScript): Boolean =
        getPluginScriptAsList().contains(pluginScript)

    fun containsPluginScriptByGroupName(groupName: String?): Boolean =
        getPluginScriptAsList().any { Util.objEquals(groupName, it.groupName) }

    fun containsUserOnlyScript(userOnlyScript: UserScript): Boolean =
        getUserOnlyScriptAsList().contains(userOnlyScript)

    fun containsUserOnlyScriptByGroupName(groupName: String?): Boolean =
        getUserOnlyScriptAsList().any { Util.objEquals(groupName, it.groupName) }

    fun removePluginScriptsByGroupName(groupName: String?) {
        getPluginScriptAsList()
            .filter { Util.objEquals(groupName, it.groupName) }
            .forEach { removePluginScript(it) }
    }

    fun removeUserOnlyScriptsByGroupName(groupName: String?) {
        getUserOnlyScriptAsList()
            .filter { Util.objEquals(groupName, it.groupName) }
            .forEach { removeUserOnlyScript(it) }
    }

    fun hasPendingScriptRegistrations(): Boolean =
        contentWorldsCreatorScriptPending ||
            pendingUserOnlyScriptRegistrations.isNotEmpty() ||
            pendingPluginScriptRegistrations.isNotEmpty()

    fun retryPendingScriptRegistrations() {
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            return
        }

        if (contentWorldsCreatorScriptPending) {
            updateContentWorldsCreatorScript()
        }
        pendingUserOnlyScriptRegistrations.toList().forEach { addUserOnlyScript(it) }
        pendingPluginScriptRegistrations.toList().forEach { addPluginScript(it) }
    }

    fun getContentWorlds(): LinkedHashSet<ContentWorld> = LinkedHashSet(contentWorlds)

    private fun wrapSourceCodeAddChecks(source: String, userScript: UserScript): String {
        val ifStatement = StringBuilder("if (")
        val allowedOriginRules = userScript.getAllowedOriginRules()
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT) &&
            !allowedOriginRules.contains("*")
        ) {
            if (allowedOriginRules.isEmpty()) {
                return ""
            }
            val jsRegExpArray = StringBuilder("[")
            allowedOriginRules.forEach { allowedOriginRule ->
                if (jsRegExpArray.length > 1) {
                    jsRegExpArray.append(", ")
                }
                jsRegExpArray.append("new RegExp(")
                    .append(escapeCode(allowedOriginRule))
                    .append(")")
            }
            if (jsRegExpArray.length > 1) {
                jsRegExpArray.append("]")
                ifStatement.append(jsRegExpArray)
                    .append(".some(function(rx) { return rx.test(window.location.origin); })")
            }
        }
        if (userScript.isForMainFrameOnly) {
            if (ifStatement.length > 4) {
                ifStatement.append(" && ")
            }
            ifStatement.append("window === window.top")
        }
        return ifStatement
            .takeIf { it.length > 4 }
            ?.append(") {")
            ?.append(source)
            ?.append("}")
            ?.toString()
            ?: source
    }

    private fun userScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<UserScript> =
        userOnlyScripts.getValue(injectionTime)

    private fun pluginScriptsAt(injectionTime: UserScriptInjectionTime): LinkedHashSet<PluginScript> =
        pluginScripts.getValue(injectionTime)

    override fun dispose() {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
            contentWorldsCreatorScript?.remove()
        }
        contentWorldsCreatorScript = null
        contentWorldsCreatorScriptPending = false
        removeAllUserOnlyScripts()
        removeAllPluginScripts()
        webView = null
    }
}
