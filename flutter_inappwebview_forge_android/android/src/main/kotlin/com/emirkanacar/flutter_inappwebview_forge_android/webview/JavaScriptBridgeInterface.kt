package com.emirkanacar.flutter_inappwebview_forge_android.webview

import android.os.Build
import android.os.Handler
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.ValueCallback
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.PrintJobController
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.PrintJobSettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.JavaScriptHandlerFunctionData
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.regex.Pattern

class JavaScriptBridgeInterface(
    initialInAppWebView: InAppWebView,
    private val expectedBridgeSecret: String
) {
    companion object {
        private const val LOG_TAG = "JSBridgeInterface"
    }

    private var inAppWebView: InAppWebView? = initialInAppWebView

    @JavascriptInterface
    fun _hideContextMenu() {
        val webView = inAppWebView ?: return
        val handler = Handler(webView.getWebViewLooper())
        handler.post {
            val currentWebView = inAppWebView ?: return@post
            if (currentWebView.floatingContextMenu != null) {
                currentWebView.hideContextMenu()
            }
        }
    }

    @JavascriptInterface
    fun _callHandler(jsonStringifiedData: String) {
        val webView = inAppWebView ?: return

        val data = try {
            JSONObject(jsonStringifiedData)
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e(
                LOG_TAG,
                "Cannot convert jsonStringifiedData parameter of _callHandler method to a valid JSONObject"
            )
            return
        }

        if (!data.has("handlerName") || data.isNull("handlerName")) {
            Log.d(LOG_TAG, "handlerName is null or undefined")
            return
        }

        val handlerName = data.optString("handlerName")
        val bridgeSecret = data.optString("_bridgeSecret")
        val callHandlerId = data.optInt("_callHandlerID")
        val origin = data.optString("origin")
        val requestUrl = data.optString("requestUrl")
        val isMainFrame = data.optBoolean("isMainFrame")
        val args = data.optString("args")

        if (expectedBridgeSecret != bridgeSecret) {
            Log.e(
                LOG_TAG,
                "Bridge access attempt with wrong secret token, possibly from malicious code from origin: $origin"
            )
            return
        }

        val allowedOrigins = webView.customSettings.javaScriptHandlersOriginAllowList
        val isOriginAllowed = if (allowedOrigins != null) {
            allowedOrigins.any { allowedOrigin: Pattern ->
                allowedOrigin.matcher(origin).matches()
            }
        } else {
            true
        }
        if (!isOriginAllowed) {
            Log.e(LOG_TAG, "Bridge access attempt from an origin not allowed: $origin")
            return
        }

        if (webView.customSettings.javaScriptHandlersForMainFrameOnly == true && !isMainFrame) {
            Log.e(LOG_TAG, "Bridge access attempt from a sub-frame origin: $origin")
            return
        }

        val handler = Handler(webView.getWebViewLooper())
        handler.post {
            val currentWebView = inAppWebView ?: return@post
            var isInternalHandler = true

            when (handlerName) {
                "onPrintRequest" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        val settings = PrintJobSettings()
                        settings.handledByClient = true
                        val printJobId = currentWebView.printCurrentPage(settings)
                        val channelDelegate = currentWebView.channelDelegate
                        if (channelDelegate != null) {
                            channelDelegate.onPrintRequest(
                                currentWebView.url,
                                printJobId,
                                object : WebViewChannelDelegate.PrintRequestCallback() {
                                    override fun nonNullSuccess(handledByClient: Boolean): Boolean =
                                        !handledByClient

                                    override fun defaultBehaviour(handledByClient: Boolean?) {
                                        val plugin = inAppWebView?.plugin
                                        val printJobManager = plugin?.printJobManager
                                        val printJobController: PrintJobController? =
                                            printJobManager?.jobs?.get(printJobId)
                                        printJobController?.disposeNoCancel()
                                    }

                                    override fun error(
                                        errorCode: String,
                                        errorMessage: String?,
                                        errorDetails: Any?
                                    ) {
                                        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
                                        defaultBehaviour(null)
                                    }
                                }
                            )
                        }
                    }
                }

                "callAsyncJavaScript" -> {
                    try {
                        val arguments = JSONArray(args)
                        val jsonObject = arguments.getJSONObject(0)
                        val resultUuid = jsonObject.getString("resultUuid")
                        val callback: ValueCallback<String>? =
                            currentWebView.callAsyncJavaScriptCallbacks[resultUuid]
                        if (callback != null) {
                            callback.onReceiveValue(jsonObject.toString())
                            currentWebView.callAsyncJavaScriptCallbacks.remove(resultUuid)
                        }
                    } catch (e: JSONException) {
                        Log.e(LOG_TAG, "", e)
                    }
                }

                "evaluateJavaScriptWithContentWorld" -> {
                    try {
                        val arguments = JSONArray(args)
                        val jsonObject = arguments.getJSONObject(0)
                        val resultUuid = jsonObject.getString("resultUuid")
                        val callback: ValueCallback<String>? =
                            currentWebView.evaluateJavaScriptContentWorldCallbacks[resultUuid]
                        if (callback != null) {
                            val value = if (jsonObject.has("value")) {
                                jsonObject.get("value").toString()
                            } else {
                                "null"
                            }
                            callback.onReceiveValue(value)
                            currentWebView.evaluateJavaScriptContentWorldCallbacks.remove(resultUuid)
                        }
                    } catch (e: JSONException) {
                        Log.e(LOG_TAG, "", e)
                    }
                }

                else -> isInternalHandler = false
            }

            if (isInternalHandler) {
                val sourceCode = "if (window." +
                    JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                    "[" + callHandlerId + "] != null) { " +
                    "window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                    "[" + callHandlerId + "].resolve(); " +
                    "delete window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                    "[" + callHandlerId + "]; " +
                    "}"
                currentWebView.evaluateJavascript(sourceCode, null)
                return@post
            }

            val channelDelegate = currentWebView.channelDelegate ?: return@post
            val data = JavaScriptHandlerFunctionData(origin, requestUrl, isMainFrame, args)
            channelDelegate.onCallJsHandler(
                handlerName,
                data,
                object : WebViewChannelDelegate.CallJsHandlerCallback() {
                    override fun defaultBehaviour(json: Any?) {
                        val callbackWebView = inAppWebView ?: return
                        val sourceCode = "if (window." +
                            JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "] != null) { " +
                            "window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "].resolve(" + json + "); " +
                            "delete window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "]; " +
                            "}"
                        callbackWebView.evaluateJavascript(sourceCode, null)
                    }

                    override fun error(
                        errorCode: String,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                        val message = errorCode + (errorMessage?.let { ", $it" } ?: "")
                        Log.e(LOG_TAG, message)

                        val callbackWebView = inAppWebView ?: return
                        val sourceCode = "if (window." +
                            JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "] != null) { " +
                            "window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "].reject(new Error(" +
                            JSONObject.quote(message) + ")); " +
                            "delete window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                            "[" + callHandlerId + "]; " +
                            "}"
                        callbackWebView.evaluateJavascript(sourceCode, null)
                    }
                }
            )
        }
    }

    fun dispose() {
        inAppWebView = null
    }
}
