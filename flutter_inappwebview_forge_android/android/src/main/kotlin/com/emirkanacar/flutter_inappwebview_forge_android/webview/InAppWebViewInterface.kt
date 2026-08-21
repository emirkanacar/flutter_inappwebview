package com.emirkanacar.flutter_inappwebview_forge_android.webview

import android.content.Context
import android.net.Uri
import android.net.http.SslCertificate
import android.os.Looper
import android.webkit.ValueCallback
import android.webkit.WebMessage as AndroidWebMessage
import android.webkit.WebView
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.types.ContentWorld
import com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.PrintJobSettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserContentController
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessage
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebViewSettings
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageChannel
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageListener
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.HashMap

interface InAppWebViewInterface {
    fun getContext(): Context
    fun getUrl(): String?
    fun getTitle(): String?
    fun getProgress(): Int
    fun loadUrl(urlRequest: URLRequest)
    fun postUrl(url: String, postData: ByteArray)
    fun loadDataWithBaseURL(baseUrl: String?, data: String, mimeType: String?, encoding: String?, historyUrl: String?)

    @Throws(IOException::class)
    fun loadFile(assetFilePath: String)

    fun evaluateJavascript(source: String, contentWorld: ContentWorld?, resultCallback: ValueCallback<String>)
    fun injectJavascriptFileFromUrl(urlFile: String, scriptHtmlTagAttributes: MutableMap<String, Any?>)
    fun injectCSSCode(source: String)
    fun injectCSSFileFromUrl(urlFile: String, cssLinkHtmlTagAttributes: MutableMap<String, Any?>)
    fun reload()
    fun goBack()
    fun canGoBack(): Boolean
    fun goForward()
    fun canGoForward(): Boolean
    fun goBackOrForward(steps: Int)
    fun canGoBackOrForward(steps: Int): Boolean
    fun stopLoading()
    fun isLoading(): Boolean
    fun takeScreenshot(screenshotConfiguration: MutableMap<String, Any?>, result: MethodChannel.Result)
    fun setSettings(newSettings: InAppWebViewSettings, newSettingsMap: HashMap<String, Any?>)
    fun getCustomSettings(): InAppWebViewSettings
    fun getCustomSettingsMap(): MutableMap<String, Any?>
    fun getCopyBackForwardList(): HashMap<String, Any?>
    fun clearAllCache()
    fun clearSslPreferences()
    fun findAllAsync(find: String)
    fun findNext(forward: Boolean)
    fun clearMatches()
    fun scrollTo(x: Int?, y: Int?, animated: Boolean?)
    fun scrollBy(x: Int?, y: Int?, animated: Boolean?)
    fun onPause()
    fun onResume()
    fun pauseTimers()
    fun resumeTimers()
    fun printCurrentPage(settings: PrintJobSettings?): String?
    fun getContentHeight(): Int
    fun getContentHeight(callback: ValueCallback<Int>)
    fun getContentWidth(callback: ValueCallback<Int>)
    fun zoomBy(zoomFactor: Float)
    fun getOriginalUrl(): String?
    fun getSelectedText(callback: ValueCallback<String>)
    fun getHitTestResult(): WebView.HitTestResult
    fun getHitTestResult(callback: ValueCallback<HitTestResult>)
    fun pageDown(bottom: Boolean): Boolean
    fun pageUp(top: Boolean): Boolean
    fun saveWebArchive(basename: String, autoname: Boolean, callback: ValueCallback<String?>?)
    fun zoomIn(): Boolean
    fun zoomOut(): Boolean
    fun clearFocus()
    fun requestFocusNodeHref(): MutableMap<String, Any?>
    fun requestImageRef(): MutableMap<String, Any?>
    fun getScrollX(): Int
    fun getScrollY(): Int
    fun getCertificate(): SslCertificate?

    fun clearHistory()
    fun callAsyncJavaScript(
        functionBody: String,
        arguments: MutableMap<String, Any?>,
        contentWorld: ContentWorld?,
        resultCallback: ValueCallback<String>
    )

    fun isSecureContext(resultCallback: ValueCallback<Boolean>)
    fun createCompatWebMessageChannel(): WebMessageChannel
    fun createWebMessageChannel(callback: ValueCallback<WebMessageChannel>): WebMessageChannel
    fun postWebMessage(message: AndroidWebMessage, targetOrigin: Uri)

    @Throws(Exception::class)
    fun postWebMessage(message: WebMessage, targetOrigin: Uri, callback: ValueCallback<String>)

    @Throws(Exception::class)
    fun addWebMessageListener(webMessageListener: WebMessageListener)

    fun canScrollVertically(): Boolean
    fun canScrollHorizontally(): Boolean
    fun getZoomScale(): Float
    fun getZoomScale(callback: ValueCallback<Float>)
    fun getContextMenu(): MutableMap<String, Any?>?
    fun setContextMenu(contextMenu: MutableMap<String, Any?>?)
    fun getPlugin(): InAppWebViewFlutterPlugin
    fun setPlugin(plugin: InAppWebViewFlutterPlugin)
    fun getInAppBrowserDelegate(): InAppBrowserDelegate?
    fun setInAppBrowserDelegate(inAppBrowserDelegate: InAppBrowserDelegate?)
    fun getUserContentController(): UserContentController
    fun setUserContentController(userContentController: UserContentController)
    fun getWebMessageChannels(): MutableMap<String, WebMessageChannel>
    fun setWebMessageChannels(webMessageChannels: MutableMap<String, WebMessageChannel>)
    fun disposeWebMessageChannels()
    fun disposeWebMessageListeners()
    fun getWebViewLooper(): Looper
    fun isInFullscreen(): Boolean
    fun setInFullscreen(inFullscreen: Boolean)
    fun getChannelDelegate(): com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate?
    fun setChannelDelegate(eventWebViewChannelDelegate: com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate?)
    fun showInputMethod()
    fun hideInputMethod()
    fun saveState(): ByteArray?
    fun saveState(maxSizeBytes: Int?, includeForwardHistory: Boolean): ByteArray?
    fun restoreState(state: ByteArray): Boolean
}
