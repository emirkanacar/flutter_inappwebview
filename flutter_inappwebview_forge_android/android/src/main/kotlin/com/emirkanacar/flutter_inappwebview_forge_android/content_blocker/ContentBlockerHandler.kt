package com.emirkanacar.flutter_inappwebview_forge_android.content_blocker

import android.os.Build
import android.os.Handler
import android.text.TextUtils
import android.util.Log
import android.webkit.WebResourceResponse
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.MalformedURLException
import java.net.URI
import java.net.URISyntaxException
import java.net.URL
import java.util.HashMap
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.CountDownLatch
import javax.net.ssl.SSLHandshakeException

open class ContentBlockerHandler {
    companion object {
        @JvmField
        protected val LOG_TAG = "ContentBlockerHandler"
    }

    @JvmField
    protected var ruleList: MutableList<ContentBlocker> = mutableListOf()

    constructor()

    constructor(ruleList: MutableList<ContentBlocker>) {
        this.ruleList = ruleList
    }

    fun getRuleList(): MutableList<ContentBlocker> = ruleList

    fun setRuleList(newRuleList: MutableList<ContentBlocker>) {
        ruleList = newRuleList
    }

    @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
    fun checkUrl(
        webView: InAppWebView,
        request: WebResourceRequestExt,
        responseResourceType: ContentBlockerTriggerResourceType
    ): WebResourceResponse? {
        if (webView.customSettings.contentBlockers == null) {
            return null
        }

        val url = request.url

        val uri = try {
            URI(url)
        } catch (_: URISyntaxException) {
            val urlSplit = url.split(":")
            val scheme = urlSplit.firstOrNull().orEmpty()
            val tempUrl = URL(url.replace(scheme, "https"))
            URI(
                scheme,
                tempUrl.userInfo,
                tempUrl.host,
                tempUrl.port,
                tempUrl.path,
                tempUrl.query,
                tempUrl.ref
            )
        }
        val host = uri.host
        val port = uri.port
        val scheme = uri.scheme
        val ruleListCopy = CopyOnWriteArrayList(ruleList)

        for (contentBlocker in ruleListCopy) {
            val trigger = contentBlocker.trigger
            val resourceTypes = trigger.resourceType
            if (resourceTypes.contains(ContentBlockerTriggerResourceType.IMAGE) &&
                !resourceTypes.contains(ContentBlockerTriggerResourceType.SVG_DOCUMENT)
            ) {
                resourceTypes.add(ContentBlockerTriggerResourceType.SVG_DOCUMENT)
            }

            val action = contentBlocker.action
            val matcher = trigger.urlFilterPatternCompiled.matcher(url)
            if (!matcher.matches()) {
                continue
            }

            if (resourceTypes.isNotEmpty() && !resourceTypes.contains(responseResourceType)) {
                return null
            }
            if (trigger.ifDomain.isNotEmpty()) {
                val matchFound = trigger.ifDomain.any { domain ->
                    (domain.startsWith("*") && host?.endsWith(domain.replace("*", "")) == true) ||
                        domain == host
                }
                if (!matchFound) {
                    return null
                }
            }
            if (trigger.unlessDomain.isNotEmpty()) {
                val matchFound = trigger.unlessDomain.any { domain ->
                    (domain.startsWith("*") && host?.endsWith(domain.replace("*", "")) == true) ||
                        domain == host
                }
                if (matchFound) {
                    return null
                }
            }

            var webViewUrl: String? = null
            if (trigger.loadType.isNotEmpty() ||
                trigger.ifTopUrl.isNotEmpty() ||
                trigger.unlessTopUrl.isNotEmpty()
            ) {
                val latch = CountDownLatch(1)
                val handler = Handler(webView.getWebViewLooper())
                handler.post {
                    webViewUrl = webView.url
                    latch.countDown()
                }
                latch.await()
            }

            webViewUrl?.let { currentUrl ->
                if (trigger.loadType.isNotEmpty()) {
                    val currentUri = URI(currentUrl)
                    val currentHost = currentUri.host
                    val currentPort = currentUri.port
                    val currentScheme = currentUri.scheme

                    if ((trigger.loadType.contains("first-party") &&
                            currentHost != null &&
                            !(currentScheme == scheme && currentHost == host && currentPort == port)) ||
                        (trigger.loadType.contains("third-party") &&
                            currentHost != null && currentHost == host)
                    ) {
                        return null
                    }
                }
                if (trigger.ifTopUrl.isNotEmpty()) {
                    if (trigger.ifTopUrl.none { topUrl -> currentUrl.startsWith(topUrl) }) {
                        return null
                    }
                }
                if (trigger.unlessTopUrl.isNotEmpty()) {
                    if (trigger.unlessTopUrl.any { topUrl -> currentUrl.startsWith(topUrl) }) {
                        return null
                    }
                }
            }

            when (action.type) {
                ContentBlockerActionType.BLOCK -> {
                    return WebResourceResponse("", "", null)
                }

                ContentBlockerActionType.CSS_DISPLAY_NONE -> {
                    val cssSelector = action.selector
                    val jsScript = "(function(d) { " +
                        "   function hide () { " +
                        "       if (d.body != null && !d.getElementById('" +
                        JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                        "-css-display-none-style')) { " +
                        "           var c = d.createElement('style'); " +
                        "           c.id = '" +
                        JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                        "-css-display-none-style'; " +
                        "           c.innerHTML = '" + cssSelector +
                        " { display: none !important; }'; " +
                        "           d.body.appendChild(c); " +
                        "       }" +
                        "       d.querySelectorAll('" + cssSelector +
                        "').forEach(function (item, index) { " +
                        "           item.setAttribute('style', 'display: none !important;'); " +
                        "       }); " +
                        "   }; " +
                        "   hide(); " +
                        "   d.addEventListener('DOMContentLoaded', function(event) { hide(); }); " +
                        "})(document);"

                    val handler = Handler(webView.getWebViewLooper())
                    handler.postDelayed({
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            webView.evaluateJavascript(jsScript, null)
                        } else {
                            webView.loadUrl("javascript:$jsScript")
                        }
                    }, 800)
                }

                ContentBlockerActionType.MAKE_HTTPS -> {
                    if (scheme == "http" && (port == -1 || port == 80)) {
                        val urlHttps = url.replace("http://", "https://")
                        val urlConnection = Util.makeHttpRequest(
                            urlHttps,
                            request.method ?: "GET",
                            request.headers
                        )
                        if (urlConnection != null) {
                            try {
                                val dataBytes = Util.readAllBytes(urlConnection.inputStream)
                                    ?: return null
                                val dataStream: InputStream = ByteArrayInputStream(dataBytes)

                                var encoding = urlConnection.contentEncoding
                                var contentType = urlConnection.contentType
                                if (contentType == null) {
                                    contentType = "text/plain"
                                } else {
                                    val contentTypeSplit = contentType.split(";")
                                    contentType = contentTypeSplit[0].trim()
                                    if (encoding == null) {
                                        encoding = if (contentTypeSplit.size > 1 &&
                                            contentTypeSplit[1].contains("charset=")
                                        ) {
                                            contentTypeSplit[1].replace("charset=", "").trim()
                                        } else {
                                            "utf-8"
                                        }
                                    }
                                }

                                val reasonPhrase = urlConnection.responseMessage
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
                                    reasonPhrase != null
                                ) {
                                    val responseHeaders = HashMap<String, String>()
                                    for (responseHeader in urlConnection.headerFields) {
                                        responseHeaders[responseHeader.key] =
                                            TextUtils.join(",", responseHeader.value)
                                    }
                                    return WebResourceResponse(
                                        contentType,
                                        encoding,
                                        urlConnection.responseCode,
                                        reasonPhrase,
                                        responseHeaders,
                                        dataStream
                                    )
                                }
                                return WebResourceResponse(contentType, encoding, dataStream)
                            } catch (e: Exception) {
                                if (e !is SSLHandshakeException) {
                                    Log.e(LOG_TAG, "", e)
                                }
                            } finally {
                                urlConnection.disconnect()
                            }
                        }
                    }
                }
            }
        }
        return null
    }

    @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
    fun checkUrl(webView: InAppWebView, request: WebResourceRequestExt): WebResourceResponse? {
        val responseResourceType = getResourceTypeFromUrl(request)
        return checkUrl(webView, request, responseResourceType)
    }

    @Throws(URISyntaxException::class, InterruptedException::class, MalformedURLException::class)
    fun checkUrl(
        webView: InAppWebView,
        request: WebResourceRequestExt,
        contentType: String
    ): WebResourceResponse? {
        val responseResourceType = getResourceTypeFromContentType(contentType)
        return checkUrl(webView, request, responseResourceType)
    }

    fun getResourceTypeFromUrl(request: WebResourceRequestExt): ContentBlockerTriggerResourceType {
        var responseResourceType = ContentBlockerTriggerResourceType.RAW
        val url = request.url

        if (url.startsWith("http://") || url.startsWith("https://")) {
            val urlConnection = Util.makeHttpRequest(url, "HEAD", request.headers)
            if (urlConnection != null) {
                try {
                    var contentType = urlConnection.contentType
                    if (contentType != null) {
                        val contentTypeSplit = contentType.split(";")
                        contentType = contentTypeSplit[0].trim()
                        responseResourceType = getResourceTypeFromContentType(contentType)
                    }
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "", e)
                } finally {
                    urlConnection.disconnect()
                }
            }
        }
        return responseResourceType
    }

    fun getResourceTypeFromContentType(contentType: String): ContentBlockerTriggerResourceType {
        var responseResourceType = ContentBlockerTriggerResourceType.RAW

        if (contentType == "text/css") {
            responseResourceType = ContentBlockerTriggerResourceType.STYLE_SHEET
        } else if (contentType == "image/svg+xml") {
            responseResourceType = ContentBlockerTriggerResourceType.SVG_DOCUMENT
        } else if (contentType.startsWith("image/")) {
            responseResourceType = ContentBlockerTriggerResourceType.IMAGE
        } else if (contentType.startsWith("font/")) {
            responseResourceType = ContentBlockerTriggerResourceType.FONT
        } else if (contentType.startsWith("audio/") ||
            contentType.startsWith("video/") ||
            contentType == "application/ogg"
        ) {
            responseResourceType = ContentBlockerTriggerResourceType.MEDIA
        } else if (contentType.endsWith("javascript")) {
            responseResourceType = ContentBlockerTriggerResourceType.SCRIPT
        } else if (contentType.startsWith("text/")) {
            responseResourceType = ContentBlockerTriggerResourceType.DOCUMENT
        }

        return responseResourceType
    }
}
