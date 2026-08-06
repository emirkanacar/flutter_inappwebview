package com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js

class WebMessageListenerJS private constructor() {
  companion object {
    private const val IS_ORIGIN_ALLOWED_FUNCTION_NAME =
      "FlutterInAppWebViewWebMessageListenerIsOriginAllowed"

    @JvmStatic
    fun IS_ORIGIN_ALLOWED_JS_SOURCE(): String =
      "function $IS_ORIGIN_ALLOWED_FUNCTION_NAME(allowedOriginRules, scheme, host, port) {" +
        "  for (var i = 0; i < allowedOriginRules.length; i++) {" +
        "    var rule = allowedOriginRules[i];" +
        "    if (rule === '*') { return true; }" +
        "    if (rule == null || scheme == null || scheme === '') { continue; }" +
        "    var rulePort = rule.port == null ? (rule.scheme === 'https' ? 443 : 80) : rule.port;" +
        "    var currentPort = port == null || port === '' ? (scheme === 'https' ? 443 : 80) : parseInt(port, 10);" +
        "    var hostAllowed = rule.host == null || rule.host === '' || rule.host === host ||" +
        "      (rule.host.indexOf('*') === 0 && host != null && host.indexOf(rule.host.substring(1)) >= 0);" +
        "    if (rule.scheme === scheme && hostAllowed && rulePort === currentPort) { return true; }" +
        "  }" +
        "  return false;" +
        "}"

    @JvmStatic
    fun WEB_MESSAGE_LISTENER_JS_SOURCE(): String =
      "function FlutterInAppWebViewWebMessageListener(jsObjectName) {" +
        "  this.jsObjectName = jsObjectName;" +
        "  this.listeners = [];" +
        "  this.onmessage = null;" +
        "}" +
        "FlutterInAppWebViewWebMessageListener.prototype.postMessage = function(data) {" +
        "  var message = {" +
        "    'data': window.ArrayBuffer != null && data instanceof ArrayBuffer ? Array.from(new Uint8Array(data)) : (data != null ? data.toString() : null)," +
        "    'type': window.ArrayBuffer != null && data instanceof ArrayBuffer ? 1 : 0" +
        "  };" +
        "  window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
        ".callHandler('onWebMessageListenerPostMessageReceived', {jsObjectName: this.jsObjectName, message: message});" +
        "};" +
        "FlutterInAppWebViewWebMessageListener.prototype.addEventListener = function(type, listener) {" +
        "  if (listener == null) { return; }" +
        "  this.listeners.push(listener);" +
        "};" +
        "FlutterInAppWebViewWebMessageListener.prototype.removeEventListener = function(type, listener) {" +
        "  if (listener == null) { return; }" +
        "  var index = this.listeners.indexOf(listener);" +
        "  if (index >= 0) { this.listeners.splice(index, 1); }" +
        "};"
  }
}
