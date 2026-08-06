package com.emirkanacar.flutter_inappwebview_forge_android.webview

import android.net.Uri
import android.os.Build
import android.webkit.ValueCallback
import android.webkit.WebView

import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature

import com.emirkanacar.flutter_inappwebview_forge_android.Util;
import com.emirkanacar.flutter_inappwebview_forge_android.find_interaction.FindInteractionChannelDelegate;
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserActivity;
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserSettings;
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.PrintJobSettings;
import com.emirkanacar.flutter_inappwebview_forge_android.types.BaseCallbackResultImpl;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ClientCertChallenge;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ClientCertResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ContentWorld;
import com.emirkanacar.flutter_inappwebview_forge_android.types.CreateWindowAction;
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomSchemeResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.DownloadStartRequest;
import com.emirkanacar.flutter_inappwebview_forge_android.types.GeolocationPermissionShowPromptResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult;
import com.emirkanacar.flutter_inappwebview_forge_android.types.HttpAuthResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.HttpAuthenticationChallenge;
import com.emirkanacar.flutter_inappwebview_forge_android.types.InAppWebViewRect;
import com.emirkanacar.flutter_inappwebview_forge_android.types.JavaScriptHandlerFunctionData;
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsAlertResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsBeforeUnloadResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsConfirmResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsPromptResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.NavigationAction;
import com.emirkanacar.flutter_inappwebview_forge_android.types.NavigationActionPolicy;
import com.emirkanacar.flutter_inappwebview_forge_android.types.PermissionResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.SafeBrowsingResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ServerTrustAuthResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ServerTrustChallenge;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ShowFileChooserRequest;
import com.emirkanacar.flutter_inappwebview_forge_android.types.ShowFileChooserResponse;
import com.emirkanacar.flutter_inappwebview_forge_android.types.SslCertificateExt;
import com.emirkanacar.flutter_inappwebview_forge_android.types.SyncBaseCallbackResultImpl;
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest;
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScript;
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessageCompatExt;
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessagePortCompatExt;
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceErrorExt;
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt;
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceResponseExt;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebViewSettings;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageChannel;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageListener;

import java.io.IOException
import java.util.ArrayList
import java.util.HashMap
import java.util.concurrent.TimeUnit

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

private fun mutableMapArgument(call: MethodCall, key: String): MutableMap<String, Any?>? {
  return mutableMapValue(call.argument<Any?>(key))
}

private fun mutableMapValue(value: Any?): MutableMap<String, Any?>? {
  val source = value as? Map<*, *> ?: return null
  val map = mutableMapOf<String, Any?>()
  for (entry in source.entries) {
    val stringKey = entry.key as? String ?: return null
    map[stringKey] = entry.value
  }
  return map
}

open class WebViewChannelDelegate(
  @JvmField var webView: InAppWebView?,
  channel: MethodChannel
) : ChannelDelegateImpl(channel) {
  companion object {
    @JvmField val LOG_TAG = "WebViewChannelDelegate"
    private const val SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS = 250L
  }

  @Suppress("UNCHECKED_CAST")
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val method = try {
      WebViewChannelDelegateMethods.valueOf(call.method)
    } catch (_: IllegalArgumentException) {
      result.notImplemented()
      return
    }

    when (method) {
      WebViewChannelDelegateMethods.getUrl -> result.success(webView?.url)
      WebViewChannelDelegateMethods.getTitle -> result.success(webView?.title)
      WebViewChannelDelegateMethods.getProgress -> result.success(webView?.progress)

      WebViewChannelDelegateMethods.loadUrl -> {
        webView?.let { view ->
          URLRequest.fromMap(mutableMapArgument(call, "urlRequest"))?.let(view::loadUrl)
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.postUrl -> {
        webView?.postUrl(
          call.argument<String>("url") ?: "",
          call.argument<ByteArray>("postData") ?: ByteArray(0)
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.loadData -> {
        webView?.loadDataWithBaseURL(
          call.argument<String>("baseUrl") ?: "",
          call.argument<String>("data") ?: "",
          call.argument<String>("mimeType") ?: "text/html",
          call.argument<String>("encoding") ?: "utf-8",
          call.argument<String>("historyUrl")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.loadFile -> {
        try {
          webView?.loadFile(call.argument<String>("assetFilePath") ?: "")
          result.success(true)
        } catch (e: IOException) {
          e.printStackTrace()
          result.error(LOG_TAG, e.message, null)
        }
      }

      WebViewChannelDelegateMethods.evaluateJavascript -> {
        val view = webView
        if (view == null) {
          result.success(null)
        } else {
          view.evaluateJavascript(
            call.argument<String>("source") ?: "",
            ContentWorld.fromMap(mutableMapArgument(call, "contentWorld")),
            ValueCallback { value -> result.success(value) }
          )
        }
      }

      WebViewChannelDelegateMethods.injectJavascriptFileFromUrl -> {
        webView?.injectJavascriptFileFromUrl(
          call.argument<String>("urlFile") ?: "",
          mutableMapArgument(call, "scriptHtmlTagAttributes") ?: mutableMapOf()
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.injectCSSCode -> {
        webView?.injectCSSCode(call.argument<String>("source") ?: "")
        result.success(true)
      }

      WebViewChannelDelegateMethods.injectCSSFileFromUrl -> {
        webView?.injectCSSFileFromUrl(
          call.argument<String>("urlFile") ?: "",
          mutableMapArgument(call, "cssLinkHtmlTagAttributes") ?: mutableMapOf()
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.reload -> {
        webView?.reload()
        result.success(true)
      }

      WebViewChannelDelegateMethods.goBack -> {
        webView?.goBack()
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoBack -> result.success(webView?.canGoBack() ?: false)

      WebViewChannelDelegateMethods.goForward -> {
        webView?.goForward()
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoForward -> {
        result.success(webView?.canGoForward() ?: false)
      }

      WebViewChannelDelegateMethods.goBackOrForward -> {
        webView?.goBackOrForward(call.argument<Int>("steps") ?: 0)
        result.success(true)
      }

      WebViewChannelDelegateMethods.canGoBackOrForward -> {
        result.success(webView?.canGoBackOrForward(call.argument<Int>("steps") ?: 0) ?: false)
      }

      WebViewChannelDelegateMethods.stopLoading -> {
        webView?.stopLoading()
        result.success(true)
      }

      WebViewChannelDelegateMethods.isLoading -> {
        result.success(webView?.isLoading ?: false)
      }

      WebViewChannelDelegateMethods.takeScreenshot -> {
        webView?.takeScreenshot(
          mutableMapArgument(call, "screenshotConfiguration") ?: mutableMapOf(),
          result
        ) ?: result.success(null)
      }

      WebViewChannelDelegateMethods.setSettings -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          val activity = view.getInAppBrowserDelegate() as InAppBrowserActivity
          val settingsMap = mutableMapArgument(call, "settings") ?: mutableMapOf()
          val settings = InAppBrowserSettings()
          settings.parse(settingsMap)
          activity.setSettings(settings, HashMap(settingsMap))
        } else if (view != null) {
          val settingsMap = mutableMapArgument(call, "settings") ?: mutableMapOf()
          val settings = InAppWebViewSettings()
          settings.parse(settingsMap)
          view.setSettings(settings, HashMap(settingsMap))
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.getSettings -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          result.success((view.getInAppBrowserDelegate() as InAppBrowserActivity).getCustomSettingsMap())
        } else {
          result.success(view?.getCustomSettingsMap())
        }
      }

      WebViewChannelDelegateMethods.close -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          (view.getInAppBrowserDelegate() as InAppBrowserActivity).close(result)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.show -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          (view.getInAppBrowserDelegate() as InAppBrowserActivity).show()
          result.success(true)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.hide -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          (view.getInAppBrowserDelegate() as InAppBrowserActivity).hide()
          result.success(true)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.isHidden -> {
        val view = webView
        if (view != null && view.getInAppBrowserDelegate() is InAppBrowserActivity) {
          result.success((view.getInAppBrowserDelegate() as InAppBrowserActivity).isHidden)
        } else {
          result.notImplemented()
        }
      }

      WebViewChannelDelegateMethods.getCopyBackForwardList -> {
        result.success(webView?.getCopyBackForwardList())
      }

      WebViewChannelDelegateMethods.startSafeBrowsing -> {
        val view = webView
        if (view != null && WebViewFeature.isFeatureSupported(WebViewFeature.START_SAFE_BROWSING)) {
          WebViewCompat.startSafeBrowsing(view.context, ValueCallback { success ->
            result.success(success)
          })
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.clearCache -> {
        webView?.clearAllCache()
        result.success(true)
      }

      WebViewChannelDelegateMethods.clearSslPreferences -> {
        webView?.clearSslPreferences()
        result.success(true)
      }

      WebViewChannelDelegateMethods.findAll -> {
        webView?.findAllAsync(call.argument<String>("find") ?: "")
        result.success(true)
      }

      WebViewChannelDelegateMethods.findNext -> {
        webView?.findNext(call.argument<Boolean>("forward") ?: false)
        result.success(true)
      }

      WebViewChannelDelegateMethods.clearMatches -> {
        webView?.clearMatches()
        result.success(true)
      }

      WebViewChannelDelegateMethods.scrollTo -> {
        webView?.scrollTo(
          call.argument<Int>("x"),
          call.argument<Int>("y"),
          call.argument<Boolean>("animated")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.scrollBy -> {
        webView?.scrollBy(
          call.argument<Int>("x"),
          call.argument<Int>("y"),
          call.argument<Boolean>("animated")
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.pause -> {
        webView?.onPause()
        result.success(true)
      }

      WebViewChannelDelegateMethods.resume -> {
        webView?.onResume()
        result.success(true)
      }

      WebViewChannelDelegateMethods.pauseTimers -> {
        webView?.pauseTimers()
        result.success(true)
      }

      WebViewChannelDelegateMethods.resumeTimers -> {
        webView?.resumeTimers()
        result.success(true)
      }

      WebViewChannelDelegateMethods.printCurrentPage -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          result.success(webView?.printCurrentPage(
            PrintJobSettings().apply {
              mutableMapArgument(call, "settings")?.let(::parse)
            }
          ))
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.getContentHeight -> {
        result.success(webView?.getContentHeight())
      }

      WebViewChannelDelegateMethods.getContentWidth -> {
        webView?.getContentWidth(ValueCallback { width -> result.success(width) })
          ?: result.success(null)
      }

      WebViewChannelDelegateMethods.zoomBy -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView?.zoomBy(call.argument<Number>("zoomFactor")?.toFloat() ?: 0f)
        }
        result.success(true)
      }

      WebViewChannelDelegateMethods.getOriginalUrl -> result.success(webView?.originalUrl)

      WebViewChannelDelegateMethods.getZoomScale -> {
        result.success(webView?.getZoomScale())
      }

      WebViewChannelDelegateMethods.getSelectedText -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          webView?.getSelectedText(ValueCallback { value -> result.success(value) })
            ?: result.success(null)
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.getHitTestResult -> {
        result.success(webView?.getHitTestResult()?.let(HitTestResult::fromWebViewHitTestResult)?.toMap())
      }

      WebViewChannelDelegateMethods.pageDown -> {
        result.success(webView?.pageDown(call.argument<Boolean>("bottom") ?: false) ?: false)
      }

      WebViewChannelDelegateMethods.pageUp -> {
        result.success(webView?.pageUp(call.argument<Boolean>("top") ?: false) ?: false)
      }

      WebViewChannelDelegateMethods.saveWebArchive -> {
        val view = webView
        if (view == null) {
          result.success(null)
        } else {
          view.saveWebArchive(
            call.argument<String>("filePath") ?: "",
            call.argument<Boolean>("autoname") ?: false,
            ValueCallback { value -> result.success(value) }
          )
        }
      }

      WebViewChannelDelegateMethods.zoomIn -> result.success(webView?.zoomIn() ?: false)
      WebViewChannelDelegateMethods.zoomOut -> result.success(webView?.zoomOut() ?: false)

      WebViewChannelDelegateMethods.clearFocus -> {
        webView?.clearFocus()
        result.success(true)
      }

      WebViewChannelDelegateMethods.requestFocus -> {
        val view = webView
        if (view == null) {
          result.success(false)
        } else {
          val direction = call.argument<Int>("direction")
          val rect = InAppWebViewRect.fromMap(mutableMapArgument(call, "previouslyFocusedRect"))
          val focused = when {
            direction != null && rect != null -> view.requestFocus(direction, rect.toRect())
            direction != null -> view.requestFocus(direction)
            else -> view.requestFocus()
          }
          result.success(focused)
        }
      }

      WebViewChannelDelegateMethods.setContextMenu -> {
        webView?.setContextMenu(mutableMapArgument(call, "contextMenu") ?: mutableMapOf())
        result.success(true)
      }

      WebViewChannelDelegateMethods.requestFocusNodeHref -> {
        result.success(webView?.requestFocusNodeHref())
      }

      WebViewChannelDelegateMethods.requestImageRef -> {
        result.success(webView?.requestImageRef())
      }

      WebViewChannelDelegateMethods.getScrollX -> result.success(webView?.scrollX)
      WebViewChannelDelegateMethods.getScrollY -> result.success(webView?.scrollY)

      WebViewChannelDelegateMethods.getCertificate -> {
        result.success(webView?.certificate?.let(SslCertificateExt::toMap))
      }

      WebViewChannelDelegateMethods.clearHistory -> {
        webView?.clearHistory()
        result.success(true)
      }

      WebViewChannelDelegateMethods.addUserScript -> {
        val controller = webView?.getUserContentController()
        val userScript = UserScript.fromMap(mutableMapArgument(call, "userScript"))
        result.success(if (controller != null && userScript != null) {
          controller.addUserOnlyScript(userScript)
        } else {
          false
        })
      }

      WebViewChannelDelegateMethods.removeUserScript -> {
        val controller = webView?.getUserContentController()
        val userScript = UserScript.fromMap(mutableMapArgument(call, "userScript"))
        val index = call.argument<Int>("index")
        result.success(if (controller != null && userScript != null && index != null) {
          controller.removeUserOnlyScriptAt(index, userScript.injectionTime)
        } else {
          false
        })
      }

      WebViewChannelDelegateMethods.removeUserScriptsByGroupName -> {
        webView?.getUserContentController()?.removeUserOnlyScriptsByGroupName(
          call.argument<String>("groupName") ?: ""
        )
        result.success(true)
      }

      WebViewChannelDelegateMethods.removeAllUserScripts -> {
        webView?.getUserContentController()?.removeAllUserOnlyScripts()
        result.success(true)
      }

      WebViewChannelDelegateMethods.callAsyncJavaScript -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView?.callAsyncJavaScript(
            call.argument<String>("functionBody") ?: "",
            mutableMapArgument(call, "arguments") ?: mutableMapOf(),
            ContentWorld.fromMap(mutableMapArgument(call, "contentWorld")),
            ValueCallback { value -> result.success(value) }
          ) ?: result.success(null)
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.isSecureContext -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          webView?.isSecureContext(ValueCallback { value -> result.success(value) })
            ?: result.success(false)
        } else {
          result.success(false)
        }
      }

      WebViewChannelDelegateMethods.createWebMessageChannel -> {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
          result.success(webView?.createCompatWebMessageChannel()?.toMap())
        } else {
          result.success(null)
        }
      }

      WebViewChannelDelegateMethods.postWebMessage -> {
        val view = webView
        val message = WebMessageCompatExt.fromMap(mutableMapArgument(call, "message"))
        if (view == null || message == null ||
          !WebViewFeature.isFeatureSupported(WebViewFeature.POST_WEB_MESSAGE)
        ) {
          result.success(true)
        } else {
          val compatPorts = ArrayList<WebMessagePortCompat>()
          message.ports?.forEach { portExt ->
            view.getWebMessageChannels()[portExt.webMessageChannelId]
              ?.compatPorts?.getOrNull(portExt.index)
              ?.let(compatPorts::add)
          }
          val data = message.data
          try {
            val ports = compatPorts.toTypedArray()
            val targetOrigin = Uri.parse(call.argument<String>("targetOrigin") ?: "")
            if (
              WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
              data is ByteArray &&
              message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
            ) {
              WebViewCompat.postWebMessage(view, WebMessageCompat(data, ports), targetOrigin)
            } else {
              WebViewCompat.postWebMessage(
                view,
                WebMessageCompat(data?.toString(), ports),
                targetOrigin
              )
            }
            result.success(true)
          } catch (e: Exception) {
            result.error(LOG_TAG, e.message, null)
          }
        }
      }

      WebViewChannelDelegateMethods.addWebMessageListener -> {
        val view = webView
        val listener = if (view != null) {
          WebMessageListener.fromMap(
            view,
            view.getPlugin().requireMessenger(),
            mutableMapArgument(call, "webMessageListener")
          )
        } else {
          null
        }
        if (view == null || listener == null ||
          !WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)
        ) {
          result.success(true)
        } else {
          try {
            view.addWebMessageListener(listener)
            result.success(true)
          } catch (e: Exception) {
            result.error(LOG_TAG, e.message, null)
          }
        }
      }

      WebViewChannelDelegateMethods.canScrollVertically ->
        result.success(webView?.canScrollVertically() ?: false)

      WebViewChannelDelegateMethods.canScrollHorizontally ->
        result.success(webView?.canScrollHorizontally() ?: false)

      WebViewChannelDelegateMethods.isInFullscreen ->
        result.success(webView?.isInFullscreen() ?: false)

      WebViewChannelDelegateMethods.clearFormData -> {
        webView?.clearFormData()
        result.success(true)
      }

      WebViewChannelDelegateMethods.hideInputMethod -> {
        webView?.hideInputMethod()
        result.success(webView != null)
      }

      WebViewChannelDelegateMethods.showInputMethod -> {
        webView?.showInputMethod()
        result.success(webView != null)
      }

      WebViewChannelDelegateMethods.saveState -> result.success(webView?.saveState())

      WebViewChannelDelegateMethods.restoreState -> {
        result.success(webView?.restoreState(call.argument<ByteArray>("state") ?: ByteArray(0)) ?: false)
      }
    }
  }

  private fun invokeEvent(method: String, arguments: Any? = HashMap<String, Any?>()) {
    getChannel()?.invokeMethod(method, arguments)
  }

  /**
   * @deprecated Use [FindInteractionChannelDelegate.onFindResultReceived] instead.
   */
  @Deprecated("Use FindInteractionChannelDelegate.onFindResultReceived instead.")
  open fun onFindResultReceived(
    activeMatchOrdinal: Int,
    numberOfMatches: Int,
    isDoneCounting: Boolean
  ) {
    invokeEvent(
      "onFindResultReceived",
      HashMap<String, Any?>().apply {
        put("activeMatchOrdinal", activeMatchOrdinal)
        put("numberOfMatches", numberOfMatches)
        put("isDoneCounting", isDoneCounting)
      }
    )
  }

  open fun onLongPressHitTestResult(hitTestResult: HitTestResult) {
    invokeEvent("onLongPressHitTestResult", hitTestResult.toMap())
  }

  open fun onScrollChanged(x: Int, y: Int) {
    invokeEvent("onScrollChanged", HashMap<String, Any?>().apply {
      put("x", x)
      put("y", y)
    })
  }

  open fun onDownloadStarting(downloadStartRequest: DownloadStartRequest) {
    invokeEvent("onDownloadStarting", downloadStartRequest.toMap())
  }

  open fun onCreateContextMenu(hitTestResult: HitTestResult) {
    invokeEvent("onCreateContextMenu", hitTestResult.toMap())
  }

  open fun onOverScrolled(scrollX: Int, scrollY: Int, clampedX: Boolean, clampedY: Boolean) {
    invokeEvent("onOverScrolled", HashMap<String, Any?>().apply {
      put("x", scrollX)
      put("y", scrollY)
      put("clampedX", clampedX)
      put("clampedY", clampedY)
    })
  }

  open fun onContextMenuActionItemClicked(itemId: Int, itemTitle: String?) {
    invokeEvent("onContextMenuActionItemClicked", HashMap<String, Any?>().apply {
      put("id", itemId)
      put("androidId", itemId)
      put("iosId", null)
      put("title", itemTitle)
    })
  }

  open fun onHideContextMenu() {
    invokeEvent("onHideContextMenu")
  }

  open fun onEnterFullscreen() {
    invokeEvent("onEnterFullscreen")
  }

  open fun onExitFullscreen() {
    invokeEvent("onExitFullscreen")
  }

  open class JsAlertCallback : BaseCallbackResultImpl<JsAlertResponse>() {
    override fun decodeResult(obj: Any?): JsAlertResponse? =
      JsAlertResponse.fromMap(mutableMapValue(obj))
  }

  open fun onJsAlert(
    url: String?,
    message: String?,
    isMainFrame: Boolean?,
    callback: JsAlertCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onJsAlert", HashMap<String, Any?>().apply {
      put("url", url)
      put("message", message)
      put("isMainFrame", isMainFrame)
    }, callback)
  }

  open class JsConfirmCallback : BaseCallbackResultImpl<JsConfirmResponse>() {
    override fun decodeResult(obj: Any?): JsConfirmResponse? =
      JsConfirmResponse.fromMap(mutableMapValue(obj))
  }

  open fun onJsConfirm(
    url: String?,
    message: String?,
    isMainFrame: Boolean?,
    callback: JsConfirmCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onJsConfirm", HashMap<String, Any?>().apply {
      put("url", url)
      put("message", message)
      put("isMainFrame", isMainFrame)
    }, callback)
  }

  open class JsPromptCallback : BaseCallbackResultImpl<JsPromptResponse>() {
    override fun decodeResult(obj: Any?): JsPromptResponse? =
      JsPromptResponse.fromMap(mutableMapValue(obj))
  }

  open fun onJsPrompt(
    url: String?,
    message: String?,
    defaultValue: String?,
    isMainFrame: Boolean?,
    callback: JsPromptCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onJsPrompt", HashMap<String, Any?>().apply {
      put("url", url)
      put("message", message)
      put("defaultValue", defaultValue)
      put("isMainFrame", isMainFrame)
    }, callback)
  }

  open class JsBeforeUnloadCallback : BaseCallbackResultImpl<JsBeforeUnloadResponse>() {
    override fun decodeResult(obj: Any?): JsBeforeUnloadResponse? =
      JsBeforeUnloadResponse.fromMap(mutableMapValue(obj))
  }

  open fun onJsBeforeUnload(url: String?, message: String?, callback: JsBeforeUnloadCallback) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onJsBeforeUnload", HashMap<String, Any?>().apply {
      put("url", url)
      put("message", message)
    }, callback)
  }

  open class CreateWindowCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean? = obj as? Boolean
  }

  open fun onCreateWindow(createWindowAction: CreateWindowAction, callback: CreateWindowCallback) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onCreateWindow", createWindowAction.toMap(), callback)
  }

  open fun onCloseWindow() {
    invokeEvent("onCloseWindow")
  }

  open class GeolocationPermissionsShowPromptCallback :
    BaseCallbackResultImpl<GeolocationPermissionShowPromptResponse>() {
    override fun decodeResult(obj: Any?): GeolocationPermissionShowPromptResponse? =
      GeolocationPermissionShowPromptResponse.fromMap(mutableMapValue(obj))
  }

  open fun onGeolocationPermissionsShowPrompt(
    origin: String?,
    callback: GeolocationPermissionsShowPromptCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onGeolocationPermissionsShowPrompt", HashMap<String, Any?>().apply {
      put("origin", origin)
    }, callback)
  }

  open fun onGeolocationPermissionsHidePrompt() {
    invokeEvent("onGeolocationPermissionsHidePrompt")
  }

  open fun onConsoleMessage(message: String?, messageLevel: Int) {
    invokeEvent("onConsoleMessage", HashMap<String, Any?>().apply {
      put("message", message)
      put("messageLevel", messageLevel)
    })
  }

  open fun onProgressChanged(progress: Int) {
    invokeEvent("onProgressChanged", HashMap<String, Any?>().apply {
      put("progress", progress)
    })
  }

  open fun onTitleChanged(title: String?) {
    invokeEvent("onTitleChanged", HashMap<String, Any?>().apply {
      put("title", title)
    })
  }

  open fun onReceivedIcon(icon: ByteArray?) {
    invokeEvent("onReceivedIcon", HashMap<String, Any?>().apply {
      put("icon", icon)
    })
  }

  open fun onReceivedTouchIconUrl(url: String?, precomposed: Boolean) {
    invokeEvent("onReceivedTouchIconUrl", HashMap<String, Any?>().apply {
      put("url", url)
      put("precomposed", precomposed)
    })
  }

  open class PermissionRequestCallback : BaseCallbackResultImpl<PermissionResponse>() {
    override fun decodeResult(obj: Any?): PermissionResponse? =
      PermissionResponse.fromMap(mutableMapValue(obj))
  }

  open fun onPermissionRequest(
    origin: String?,
    resources: List<String>?,
    frame: Any?,
    callback: PermissionRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onPermissionRequest", HashMap<String, Any?>().apply {
      put("origin", origin)
      put("resources", resources)
      put("frame", frame)
    }, callback)
  }

  open fun onPermissionRequestCanceled(origin: String?, resources: List<String>?) {
    invokeEvent("onPermissionRequestCanceled", HashMap<String, Any?>().apply {
      put("origin", origin)
      put("resources", resources)
    })
  }

  open class ShouldOverrideUrlLoadingCallback :
    BaseCallbackResultImpl<NavigationActionPolicy>() {
    override fun decodeResult(obj: Any?): NavigationActionPolicy {
      val action = (obj as? Number)?.toInt() ?: NavigationActionPolicy.CANCEL.rawValue()
      return NavigationActionPolicy.fromValue(action)
    }
  }

  open fun shouldOverrideUrlLoading(
    navigationAction: NavigationAction,
    callback: ShouldOverrideUrlLoadingCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("shouldOverrideUrlLoading", navigationAction.toMap(), callback)
  }

  open fun onLoadStart(url: String?) {
    invokeEvent("onLoadStart", HashMap<String, Any?>().apply { put("url", url) })
  }

  open fun onLoadStop(url: String?) {
    invokeEvent("onLoadStop", HashMap<String, Any?>().apply { put("url", url) })
  }

  open fun onUpdateVisitedHistory(url: String?, isReload: Boolean) {
    invokeEvent("onUpdateVisitedHistory", HashMap<String, Any?>().apply {
      put("url", url)
      put("isReload", isReload)
    })
  }

  open fun onReceivedError(request: WebResourceRequestExt, error: WebResourceErrorExt) {
    invokeEvent("onReceivedError", HashMap<String, Any?>().apply {
      put("request", request.toMap())
      put("error", error.toMap())
    })
  }

  open fun onReceivedHttpError(
    request: WebResourceRequestExt,
    errorResponse: WebResourceResponseExt
  ) {
    invokeEvent("onReceivedHttpError", HashMap<String, Any?>().apply {
      put("request", request.toMap())
      put("errorResponse", errorResponse.toMap())
    })
  }

  open class ReceivedHttpAuthRequestCallback :
    BaseCallbackResultImpl<HttpAuthResponse>() {
    override fun decodeResult(obj: Any?): HttpAuthResponse? =
      HttpAuthResponse.fromMap(mutableMapValue(obj))
  }

  open fun onReceivedHttpAuthRequest(
    challenge: HttpAuthenticationChallenge,
    callback: ReceivedHttpAuthRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedHttpAuthRequest", challenge.toMap(), callback)
  }

  open class ReceivedServerTrustAuthRequestCallback :
    BaseCallbackResultImpl<ServerTrustAuthResponse>() {
    override fun decodeResult(obj: Any?): ServerTrustAuthResponse? =
      ServerTrustAuthResponse.fromMap(mutableMapValue(obj))
  }

  open fun onReceivedServerTrustAuthRequest(
    challenge: ServerTrustChallenge,
    callback: ReceivedServerTrustAuthRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedServerTrustAuthRequest", challenge.toMap(), callback)
  }

  open class ReceivedClientCertRequestCallback :
    BaseCallbackResultImpl<ClientCertResponse>() {
    override fun decodeResult(obj: Any?): ClientCertResponse? =
      ClientCertResponse.fromMap(mutableMapValue(obj))
  }

  open fun onReceivedClientCertRequest(
    challenge: ClientCertChallenge,
    callback: ReceivedClientCertRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onReceivedClientCertRequest", challenge.toMap(), callback)
  }

  open fun onZoomScaleChanged(oldScale: Float, newScale: Float) {
    invokeEvent("onZoomScaleChanged", HashMap<String, Any?>().apply {
      put("oldScale", oldScale)
      put("newScale", newScale)
    })
  }

  open class SafeBrowsingHitCallback :
    BaseCallbackResultImpl<SafeBrowsingResponse>() {
    override fun decodeResult(obj: Any?): SafeBrowsingResponse? =
      SafeBrowsingResponse.fromMap(mutableMapValue(obj))
  }

  open fun onSafeBrowsingHit(
    url: String?,
    threatType: Int,
    callback: SafeBrowsingHitCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onSafeBrowsingHit", HashMap<String, Any?>().apply {
      put("url", url)
      put("threatType", threatType)
    }, callback)
  }

  open class FormResubmissionCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = (obj as? Number)?.toInt()
  }

  open fun onFormResubmission(url: String?, callback: FormResubmissionCallback) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onFormResubmission", HashMap<String, Any?>().apply {
      put("url", url)
    }, callback)
  }

  open fun onPageCommitVisible(url: String?) {
    invokeEvent("onPageCommitVisible", HashMap<String, Any?>().apply { put("url", url) })
  }

  open fun onRenderProcessGone(didCrash: Boolean, rendererPriorityAtExit: Int) {
    invokeEvent("onRenderProcessGone", HashMap<String, Any?>().apply {
      put("didCrash", didCrash)
      put("rendererPriorityAtExit", rendererPriorityAtExit)
    })
  }

  open fun onReceivedLoginRequest(realm: String?, account: String?, args: String?) {
    invokeEvent("onReceivedLoginRequest", HashMap<String, Any?>().apply {
      put("realm", realm)
      put("account", account)
      put("args", args)
    })
  }

  open class LoadResourceWithCustomSchemeCallback :
    BaseCallbackResultImpl<CustomSchemeResponse>() {
    override fun decodeResult(obj: Any?): CustomSchemeResponse? =
      CustomSchemeResponse.fromMap(mutableMapValue(obj))
  }

  open fun onLoadResourceWithCustomScheme(
    request: WebResourceRequestExt,
    callback: LoadResourceWithCustomSchemeCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onLoadResourceWithCustomScheme", HashMap<String, Any?>().apply {
      put("request", request.toMap())
    }, callback)
  }

  open class SyncLoadResourceWithCustomSchemeCallback :
    SyncBaseCallbackResultImpl<CustomSchemeResponse>() {
    override fun decodeResult(obj: Any?): CustomSchemeResponse? =
      LoadResourceWithCustomSchemeCallback().decodeResult(obj)
  }

  @Throws(InterruptedException::class)
  open fun onLoadResourceWithCustomScheme(
    request: WebResourceRequestExt
  ): CustomSchemeResponse? {
    val channel = getChannel() ?: return null
    val callback = SyncLoadResourceWithCustomSchemeCallback()
    return Util.invokeMethodAndWaitResult(
      channel,
      "onLoadResourceWithCustomScheme",
      HashMap<String, Any?>().apply { put("request", request.toMap()) },
      callback
    )
  }

  open class ShouldInterceptRequestCallback :
    BaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      WebResourceResponseExt.fromMap(mutableMapValue(obj))
  }

  open fun shouldInterceptRequest(
    request: WebResourceRequestExt,
    callback: ShouldInterceptRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("shouldInterceptRequest", request.toMap(), callback)
  }

  open class SyncShouldInterceptRequestCallback :
    SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
    override fun decodeResult(obj: Any?): WebResourceResponseExt? =
      ShouldInterceptRequestCallback().decodeResult(obj)
  }

  @Throws(InterruptedException::class)
  open fun shouldInterceptRequest(
    request: WebResourceRequestExt
  ): WebResourceResponseExt? {
    val channel = getChannel() ?: return null
    val callback = SyncShouldInterceptRequestCallback()
    return Util.invokeMethodAndWaitResult(
      channel,
      "shouldInterceptRequest",
      request.toMap(),
      callback,
      SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS
    )
  }

  open class RenderProcessUnresponsiveCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = (obj as? Number)?.toInt()
  }

  open fun onRenderProcessUnresponsive(
    url: String?,
    callback: RenderProcessUnresponsiveCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onRenderProcessUnresponsive", HashMap<String, Any?>().apply {
      put("url", url)
    }, callback)
  }

  open class RenderProcessResponsiveCallback : BaseCallbackResultImpl<Int>() {
    override fun decodeResult(obj: Any?): Int? = (obj as? Number)?.toInt()
  }

  open fun onRenderProcessResponsive(url: String?, callback: RenderProcessResponsiveCallback) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onRenderProcessResponsive", HashMap<String, Any?>().apply {
      put("url", url)
    }, callback)
  }

  open class CallJsHandlerCallback : BaseCallbackResultImpl<Any?>() {
    override fun decodeResult(obj: Any?): Any? = obj
  }

  open fun onCallJsHandler(
    handlerName: String?,
    data: JavaScriptHandlerFunctionData,
    callback: CallJsHandlerCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onCallJsHandler", HashMap<String, Any?>().apply {
      put("handlerName", handlerName)
      put("data", data.toMap())
    }, callback)
  }

  open class PrintRequestCallback : BaseCallbackResultImpl<Boolean>() {
    override fun decodeResult(obj: Any?): Boolean? = obj as? Boolean
  }

  open fun onPrintRequest(
    url: String?,
    printJobId: String?,
    callback: PrintRequestCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onPrintRequest", HashMap<String, Any?>().apply {
      put("url", url)
      put("printJobId", printJobId)
    }, callback)
  }

  open fun onRequestFocus() {
    invokeEvent("onRequestFocus")
  }

  open class ShowFileChooserCallback :
    BaseCallbackResultImpl<ShowFileChooserResponse>() {
    override fun decodeResult(obj: Any?): ShowFileChooserResponse? =
      ShowFileChooserResponse.fromMap(mutableMapValue(obj))
  }

  open fun onShowFileChooser(
    request: ShowFileChooserRequest,
    callback: ShowFileChooserCallback
  ) {
    val channel = getChannel()
    if (channel == null) {
      callback.defaultBehaviour(null)
      return
    }
    channel.invokeMethod("onShowFileChooser", request.toMap(), callback)
  }

  override fun dispose() {
    super.dispose()
    webView = null
  }
}
