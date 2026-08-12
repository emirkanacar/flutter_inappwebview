@file:Suppress("DEPRECATION")

package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.Manifest
import android.annotation.TargetApi
import android.app.Activity
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Message
import android.os.Parcelable
import android.provider.MediaStore
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.webkit.ConsoleMessage
import android.webkit.GeolocationPermissions
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.MimeTypeMap
import android.webkit.PermissionRequest
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout

import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider

import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFileProvider
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.ActivityResultListener
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.types.CreateWindowAction
import com.emirkanacar.flutter_inappwebview_forge_android.types.GeolocationPermissionShowPromptResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsAlertResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsBeforeUnloadResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsConfirmResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.JsPromptResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.PermissionResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.ShowFileChooserRequest
import com.emirkanacar.flutter_inappwebview_forge_android.types.ShowFileChooserResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate

import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.util.HashMap

import io.flutter.plugin.common.PluginRegistry

open class InAppWebViewChromeClient(
  @JvmField var plugin: InAppWebViewFlutterPlugin?,
  @JvmField var inAppWebView: InAppWebView?,
  private var inAppBrowserDelegate: InAppBrowserDelegate?
) : WebChromeClient(), PluginRegistry.ActivityResultListener, ActivityResultListener {

  companion object {
    @JvmField
    protected val LOG_TAG = "IABWebChromeClient"

    private const val PICKER = 1
    private const val PICKER_LEGACY = 3
    private const val CAPTURE_DIRECTORY = "Captures"

    @JvmField
    protected val FULLSCREEN_LAYOUT_PARAMS = FrameLayout.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT,
      Gravity.CENTER
    )

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    @JvmField
    protected val FULLSCREEN_SYSTEM_UI_VISIBILITY_KITKAT =
      View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
        View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
        View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
        View.SYSTEM_UI_FLAG_FULLSCREEN or
        View.SYSTEM_UI_FLAG_IMMERSIVE or
        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY

    @JvmField
    protected val FULLSCREEN_SYSTEM_UI_VISIBILITY =
      View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
        View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
        View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
        View.SYSTEM_UI_FLAG_FULLSCREEN
  }

  val DEFAULT_MIME_TYPES = "*/*"
  @JvmField
  val dialogs: MutableMap<DialogInterface, JsResult> = HashMap()

  private var mCustomView: View? = null
  private var mCustomViewCallback: WebChromeClient.CustomViewCallback? = null
  private var mOriginalOrientation = 0
  private var mOriginalSystemUiVisibility = 0

  private var filePathCallbackLegacy: ValueCallback<Uri>? = null
  private var filePathCallback: ValueCallback<Array<Uri>>? = null
  private var videoOutputFileUri: Uri? = null
  private var imageOutputFileUri: Uri? = null
  private var lastProgress: Int? = null

  init {
    inAppBrowserDelegate?.getActivityResultListeners()?.add(this)
    plugin?.activityPluginBinding?.addActivityResultListener(this)
  }

  override fun getDefaultVideoPoster(): Bitmap? {
    val data = inAppWebView?.customSettings?.defaultVideoPoster
    if (data != null) {
      val bitmapOptions = BitmapFactory.Options().apply {
        inMutable = true
      }
      return BitmapFactory.decodeByteArray(data, 0, data.size, bitmapOptions)
    }
    return Bitmap.createBitmap(50, 50, Bitmap.Config.ARGB_8888)
  }

  override fun onHideCustomView() {
    val activity = getActivity() ?: return
    val decorView = getRootView() ?: return
    mCustomView?.let { (decorView as FrameLayout).removeView(it) }
    mCustomView = null
    decorView.systemUiVisibility = mOriginalSystemUiVisibility
    activity.requestedOrientation = mOriginalOrientation
    mCustomViewCallback?.onCustomViewHidden()
    mCustomViewCallback = null
    activity.window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)

    inAppWebView?.let { webView ->
      webView.channelDelegate?.onExitFullscreen()
      webView.setInFullscreen(false)
      webView.restoreInputConnectionAfterFullscreen()
    }
  }

  override fun onShowCustomView(paramView: View, paramCustomViewCallback: CustomViewCallback) {
    if (mCustomView != null) {
      onHideCustomView()
      return
    }

    val activity = getActivity() ?: return
    val decorView = getRootView() ?: return
    mCustomView = paramView
    mOriginalSystemUiVisibility = decorView.systemUiVisibility
    mOriginalOrientation = activity.requestedOrientation
    mCustomViewCallback = paramCustomViewCallback
    paramView.setBackgroundColor(Color.BLACK)

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      decorView.systemUiVisibility = FULLSCREEN_SYSTEM_UI_VISIBILITY_KITKAT
    } else {
      decorView.systemUiVisibility = FULLSCREEN_SYSTEM_UI_VISIBILITY
    }
    activity.window.setFlags(
      WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
      WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
    )
    (decorView as FrameLayout).addView(paramView, FULLSCREEN_LAYOUT_PARAMS)

    inAppWebView?.let { webView ->
      webView.channelDelegate?.onEnterFullscreen()
      webView.setInFullscreen(true)
    }
  }

  override fun onJsAlert(view: WebView, url: String, message: String, result: JsResult): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false
    channelDelegate.onJsAlert(url, message, null, object : WebViewChannelDelegate.JsAlertCallback() {
      override fun nonNullSuccess(response: JsAlertResponse): Boolean {
        if (response.isHandledByClient) {
          when (response.action ?: 1) {
            0 -> result.confirm()
            else -> result.cancel()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(response: JsAlertResponse?) {
        createAlertDialog(
          message,
          result,
          response?.message,
          response?.confirmButtonTitle
        )
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        result.cancel()
      }
    })
    return true
  }

  fun createAlertDialog(
    message: String,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?
  ) {
    val alertMessage = responseMessage.takeUnless { it.isNullOrEmpty() } ?: message
    val activity = getActivity() ?: return
    val clickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val alertDialogBuilder = AlertDialog.Builder(
      activity,
      androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert
    ).apply {
      setMessage(alertMessage)
      setPositiveButton(
        confirmButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.ok),
        clickListener
      )
      setOnCancelListener { dialog ->
        result.cancel()
        dialog.dismiss()
        dialogs.remove(dialog)
      }
    }
    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsConfirm(view: WebView, url: String, message: String, result: JsResult): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false
    channelDelegate.onJsConfirm(url, message, null, object : WebViewChannelDelegate.JsConfirmCallback() {
      override fun nonNullSuccess(response: JsConfirmResponse): Boolean {
        if (response.isHandledByClient) {
          when (response.action ?: 1) {
            0 -> result.confirm()
            else -> result.cancel()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(response: JsConfirmResponse?) {
        createConfirmDialog(
          message,
          result,
          response?.message,
          response?.confirmButtonTitle,
          response?.cancelButtonTitle
        )
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        result.cancel()
      }
    })
    return true
  }

  fun createConfirmDialog(
    message: String,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?,
    cancelButtonTitle: String?
  ) {
    val alertMessage = responseMessage.takeUnless { it.isNullOrEmpty() } ?: message
    val activity = getActivity() ?: return
    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val alertDialogBuilder = AlertDialog.Builder(
      activity,
      androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert
    ).apply {
      setMessage(alertMessage)
      setPositiveButton(
        confirmButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.ok),
        confirmClickListener
      )
      setNegativeButton(
        cancelButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.cancel),
        cancelClickListener
      )
      setOnCancelListener { dialog ->
        result.cancel()
        dialog.dismiss()
        dialogs.remove(dialog)
      }
    }
    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsPrompt(
    view: WebView,
    url: String,
    message: String,
    defaultValue: String,
    result: JsPromptResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false
    channelDelegate.onJsPrompt(
      url,
      message,
      defaultValue,
      null,
      object : WebViewChannelDelegate.JsPromptCallback() {
        override fun nonNullSuccess(response: JsPromptResponse): Boolean {
          if (response.isHandledByClient) {
            when (response.action ?: 1) {
              0 -> result.confirm(response.value)
              else -> result.cancel()
            }
            return false
          }
          return true
        }

        override fun defaultBehaviour(response: JsPromptResponse?) {
          createPromptDialog(
            view,
            message,
            defaultValue,
            result,
            response?.message,
            response?.defaultValue,
            response?.value,
            response?.cancelButtonTitle,
            response?.confirmButtonTitle
          )
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
          result.cancel()
        }
      }
    )
    return true
  }

  fun createPromptDialog(
    view: WebView,
    message: String,
    defaultValue: String,
    result: JsPromptResult,
    responseMessage: String?,
    responseDefaultValue: String?,
    value: String?,
    cancelButtonTitle: String?,
    confirmButtonTitle: String?
  ) {
    val layout = FrameLayout(view.context)
    val input = EditText(view.context).apply {
      maxLines = 1
      setText(responseDefaultValue.takeUnless { it.isNullOrEmpty() } ?: defaultValue)
      layoutParams = LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.MATCH_PARENT,
        LinearLayout.LayoutParams.MATCH_PARENT
      )
    }
    layout.setPaddingRelative(45, 15, 45, 0)
    layout.addView(input)

    val alertMessage = responseMessage.takeUnless { it.isNullOrEmpty() } ?: message
    val activity = getActivity() ?: return
    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm(value ?: input.text.toString())
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val alertDialogBuilder = AlertDialog.Builder(
      activity,
      androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert
    ).apply {
      setMessage(alertMessage)
      setPositiveButton(
        confirmButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.ok),
        confirmClickListener
      )
      setNegativeButton(
        cancelButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.cancel),
        cancelClickListener
      )
      setOnCancelListener { dialog ->
        result.cancel()
        dialog.dismiss()
        dialogs.remove(dialog)
      }
    }
    val alertDialog = alertDialogBuilder.create()
    alertDialog.setView(layout)
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onJsBeforeUnload(
    view: WebView,
    url: String,
    message: String,
    result: JsResult
  ): Boolean {
    val channelDelegate = inAppWebView?.channelDelegate ?: return false
    channelDelegate.onJsBeforeUnload(url, message, object : WebViewChannelDelegate.JsBeforeUnloadCallback() {
      override fun nonNullSuccess(response: JsBeforeUnloadResponse): Boolean {
        if (response.isHandledByClient) {
          when (response.action ?: 1) {
            0 -> result.confirm()
            else -> result.cancel()
          }
          return false
        }
        return true
      }

      override fun defaultBehaviour(response: JsBeforeUnloadResponse?) {
        createBeforeUnloadDialog(
          message,
          result,
          response?.message,
          response?.confirmButtonTitle,
          response?.cancelButtonTitle
        )
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        result.cancel()
      }
    })
    return true
  }

  fun createBeforeUnloadDialog(
    message: String,
    result: JsResult,
    responseMessage: String?,
    confirmButtonTitle: String?,
    cancelButtonTitle: String?
  ) {
    val alertMessage = responseMessage.takeUnless { it.isNullOrEmpty() } ?: message
    val activity = getActivity() ?: return
    val confirmClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.confirm()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val cancelClickListener = DialogInterface.OnClickListener { dialog, _ ->
      result.cancel()
      dialog.dismiss()
      dialogs.remove(dialog)
    }
    val alertDialogBuilder = AlertDialog.Builder(
      activity,
      androidx.appcompat.R.style.Theme_AppCompat_Dialog_Alert
    ).apply {
      setMessage(alertMessage)
      setPositiveButton(
        confirmButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.ok),
        confirmClickListener
      )
      setNegativeButton(
        cancelButtonTitle.takeUnless { it.isNullOrEmpty() } ?: activity.getString(android.R.string.cancel),
        cancelClickListener
      )
      setOnCancelListener { dialog ->
        result.cancel()
        dialog.dismiss()
        dialogs.remove(dialog)
      }
    }
    val alertDialog = alertDialogBuilder.create()
    dialogs[alertDialog] = result
    alertDialog.show()
  }

  override fun onCreateWindow(
    view: WebView,
    isDialog: Boolean,
    isUserGesture: Boolean,
    resultMsg: Message
  ): Boolean {
    val manager = plugin?.inAppWebViewManager
    if (manager == null) {
      return false
    }
    manager.windowAutoincrementId++
    val windowId = manager.windowAutoincrementId

    val result = view.hitTestResult
    var url = result.extra

    // Ensure that images with hyperlink return the correct URL, not the image source
    if (result.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE) {
      val href = view.handler.obtainMessage()
      view.requestFocusNodeHref(href)
      href.data?.getString("url")?.takeUnless { it.isEmpty() }?.let { imageUrl ->
        url = imageUrl
      }
    }

    val createWindowAction = CreateWindowAction(
      URLRequest(url, "GET", null, null),
      true,
      isUserGesture,
      false,
      windowId,
      isDialog
    )

    manager.windowWebViewMessages?.set(windowId, resultMsg)

    val channelDelegate = inAppWebView?.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onCreateWindow(createWindowAction, object : WebViewChannelDelegate.CreateWindowCallback() {
        override fun nonNullSuccess(handledByClient: Boolean): Boolean = !handledByClient

        override fun defaultBehaviour(handledByClient: Boolean?) {
          manager.windowWebViewMessages?.remove(windowId)
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
          defaultBehaviour(null)
        }
      })
      return true
    }

    return false
  }

  override fun onCloseWindow(window: WebView) {
    inAppWebView?.channelDelegate?.onCloseWindow()
    super.onCloseWindow(window)
  }

  override fun onGeolocationPermissionsShowPrompt(
    origin: String,
    callback: GeolocationPermissions.Callback
  ) {
    val resultCallback = object : WebViewChannelDelegate.GeolocationPermissionsShowPromptCallback() {
      override fun nonNullSuccess(response: GeolocationPermissionShowPromptResponse): Boolean {
        callback.invoke(response.origin, response.isAllow, response.isRetain)
        return false
      }

      override fun defaultBehaviour(response: GeolocationPermissionShowPromptResponse?) {
        callback.invoke(origin, false, false)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = inAppWebView?.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onGeolocationPermissionsShowPrompt(origin, resultCallback)
    } else {
      resultCallback.defaultBehaviour(null)
    }
  }

  override fun onGeolocationPermissionsHidePrompt() {
    inAppWebView?.channelDelegate?.onGeolocationPermissionsHidePrompt()
  }

  override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
    inAppWebView?.channelDelegate?.onConsoleMessage(
      consoleMessage.message(),
      consoleMessage.messageLevel().ordinal
    )
    return super.onConsoleMessage(consoleMessage)
  }

  override fun onProgressChanged(view: WebView, progress: Int) {
    super.onProgressChanged(view, progress)
    val webView = view as? InAppWebView ?: return
    if (lastProgress == progress) {
      return
    }
    lastProgress = progress
    inAppBrowserDelegate?.didChangeProgress(progress)
    webView.channelDelegate?.onProgressChanged(progress)
  }

  override fun onReceivedTitle(view: WebView, title: String) {
    super.onReceivedTitle(view, title)
    inAppBrowserDelegate?.didChangeTitle(title)
    (view as? InAppWebView)?.channelDelegate?.onTitleChanged(title)
  }

  override fun onReceivedIcon(view: WebView, icon: Bitmap) {
    super.onReceivedIcon(view, icon)
    val byteArrayOutputStream = ByteArrayOutputStream()
    icon.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
    try {
      byteArrayOutputStream.close()
    } catch (e: IOException) {
      Log.e(LOG_TAG, "", e)
    }
    icon.recycle()
    (view as? InAppWebView)?.channelDelegate?.onReceivedIcon(byteArrayOutputStream.toByteArray())
  }

  override fun onReceivedTouchIconUrl(view: WebView, url: String, precomposed: Boolean) {
    super.onReceivedTouchIconUrl(view, url, precomposed)
    (view as? InAppWebView)?.channelDelegate?.onReceivedTouchIconUrl(url, precomposed)
  }

  protected fun getRootView(): ViewGroup? {
    return getActivity()?.findViewById(android.R.id.content)
  }

  private fun onShowFileChooser(
    request: ShowFileChooserRequest,
    filePathsCallback: ValueCallback<*>
  ): Boolean {
    val callback = object : WebViewChannelDelegate.ShowFileChooserCallback() {
      override fun nonNullSuccess(response: ShowFileChooserResponse): Boolean {
        if (response.isHandledByClient) {
          val uriArray = response.filePaths?.map(Uri::parse)?.toTypedArray()
          @Suppress("UNCHECKED_CAST")
          (filePathsCallback as? ValueCallback<Array<Uri>>)?.onReceiveValue(uriArray)
          return false
        }
        return true
      }

      override fun defaultBehaviour(response: ShowFileChooserResponse?) {
        val acceptTypes = request.acceptTypes.toTypedArray()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          val allowMultiple = request.mode == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE
          startPickerIntent(
            filePathsCallback as? ValueCallback<Array<Uri>> ?: return,
            acceptTypes,
            allowMultiple,
            request.isCaptureEnabled
          )
        } else {
          startPickerIntent(
            filePathsCallback as? ValueCallback<Uri> ?: return,
            acceptTypes.firstOrNull() ?: "",
            request.isCaptureEnabled
          )
        }
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val webView = inAppWebView
    val channelDelegate = webView?.channelDelegate
    if (channelDelegate != null && webView.customSettings.useOnShowFileChooser == true) {
      channelDelegate.onShowFileChooser(request, callback)
    } else {
      callback.defaultBehaviour(null)
    }

    return true
  }

  protected fun openFileChooser(filePathCallback: ValueCallback<Uri>, acceptType: String) {
    onShowFileChooser(
      ShowFileChooserRequest(0, mutableListOf(acceptType), false, null, null),
      filePathCallback
    )
  }

  protected fun openFileChooser(filePathCallback: ValueCallback<Uri>) {
    onShowFileChooser(
      ShowFileChooserRequest(0, mutableListOf(""), false, null, null),
      filePathCallback
    )
  }

  protected fun openFileChooser(
    filePathCallback: ValueCallback<Uri>,
    acceptType: String,
    capture: String
  ) {
    onShowFileChooser(
      ShowFileChooserRequest(0, mutableListOf(acceptType), true, null, null),
      filePathCallback
    )
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onShowFileChooser(
    webView: WebView,
    filePathCallback: ValueCallback<Array<Uri>>,
    fileChooserParams: FileChooserParams
  ): Boolean {
    return onShowFileChooser(
      ShowFileChooserRequest.fromFileChooserParams(fileChooserParams),
      filePathCallback
    )
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (filePathCallback == null && filePathCallbackLegacy == null) {
      // Do not consume results owned by another Flutter plugin.
      return false
    }

    if (requestCode != PICKER && requestCode != PICKER_LEGACY) {
      // Keep a pending file chooser alive while another activity result is routed.
      return false
    }

    // Use the captured output URI when the camera activity does not return a filename.
    when (requestCode) {
      PICKER -> {
        val results = if (resultCode == Activity.RESULT_OK) {
          getSelectedFiles(data, resultCode)
        } else {
          null
        }
        filePathCallback?.onReceiveValue(results)
      }
      PICKER_LEGACY -> {
        val result = if (resultCode == Activity.RESULT_OK) {
          val candidate = data?.data ?: getCapturedMediaFile()
          if (isPrivateSandboxFileUri(candidate)) null else candidate
        } else {
          null
        }
        filePathCallbackLegacy?.onReceiveValue(result)
      }
    }

    filePathCallback = null
    filePathCallbackLegacy = null
    imageOutputFileUri = null
    videoOutputFileUri = null

    return true
  }

  private fun getSelectedFiles(data: Intent?, resultCode: Int): Array<Uri>? {
    // we have one file selected
    if (data?.data != null) {
      if (resultCode == Activity.RESULT_OK && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        return filterSandboxFileUris(
          WebChromeClient.FileChooserParams.parseResult(resultCode, data)
        )
      } else {
        return null
      }
    }

    // we have multiple files selected
    data?.clipData?.let { clipData ->
      return filterSandboxFileUris(
        Array(clipData.itemCount) { index -> clipData.getItemAt(index).uri }
      )
    }

    // we have a captured image or video file
    return getCapturedMediaFile()?.let { arrayOf(it) }
  }

  private fun isPrivateSandboxFileUri(uri: Uri?): Boolean {
    if (uri == null || !uri.scheme.orEmpty().equals("file", ignoreCase = true)) {
      return false
    }

    val path = uri.path ?: return false
    val normalizedPath = canonicalizePath(path) ?: return true
    val dataDir = getActivity()?.applicationInfo?.dataDir
    val normalizedDataDir = dataDir?.let(::canonicalizePath)

    if (normalizedDataDir != null &&
      (normalizedPath == normalizedDataDir || normalizedPath.startsWith("$normalizedDataDir/"))
    ) {
      return true
    }

    // Defense in depth for alternate app-private data-dir representations such
    // as /data/data and /data/user/0 paths on older Android releases.
    return normalizedPath == "/data" || normalizedPath.startsWith("/data/")
  }

  private fun canonicalizePath(path: String): String? {
    return try {
      File(path).canonicalPath
    } catch (e: IOException) {
      Log.w(LOG_TAG, "Unable to canonicalize file chooser URI path.", e)
      null
    }
  }

  private fun filterSandboxFileUris(uris: Array<Uri>?): Array<Uri>? {
    if (uris == null) return null

    val safeUris = uris.filterNot(::isPrivateSandboxFileUri)
    return when {
      safeUris.size == uris.size -> uris
      safeUris.isEmpty() -> null
      else -> safeUris.toTypedArray()
    }
  }

  private fun isFileNotEmpty(uri: Uri): Boolean {
    val activity = getActivity() ?: return false
    try {
      val descriptor = activity.contentResolver.openAssetFileDescriptor(uri, "r") ?: return false
      val length = descriptor.length
      descriptor.close()
      return length > 0
    } catch (e: IOException) {
      return false
    }
  }

  private fun getCapturedMediaFile(): Uri? {
    imageOutputFileUri?.takeIf(::isFileNotEmpty)?.let { return it }
    videoOutputFileUri?.takeIf(::isFileNotEmpty)?.let { return it }
    return null
  }

  fun startPickerIntent(
    filePathCallback: ValueCallback<Uri>,
    acceptType: String,
    captureEnabled: Boolean
  ) {
    filePathCallbackLegacy = filePathCallback
    val images = acceptsImages(acceptType)
    val video = acceptsVideo(acceptType)
    val audio = acceptsAudio(acceptType)
    var pickerIntent: Intent? = null

    if (captureEnabled) {
      pickerIntent = when {
        images && !needsCameraPermission() -> getPhotoIntent()
        video && !needsCameraPermission() -> getVideoIntent()
        audio && !images && !video -> getAudioIntent().takeIf(::canResolveIntent)
        else -> null
      }
    }
    if (pickerIntent == null) {
      pickerIntent = Intent.createChooser(getFileChooserIntent(acceptType), "")
      val extraIntents = ArrayList<Parcelable>()
      if (!needsCameraPermission()) {
        if (images) extraIntents.add(getPhotoIntent())
        if (video) extraIntents.add(getVideoIntent())
      }
      getAudioIntent().takeIf { audio && canResolveIntent(it) }?.let(extraIntents::add)
      pickerIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents.toTypedArray())
    }

    val activity = getActivity()
    if (activity != null && pickerIntent.resolveActivity(activity.packageManager) != null) {
      activity.startActivityForResult(pickerIntent, PICKER_LEGACY)
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent")
    }
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  fun startPickerIntent(
    callback: ValueCallback<Array<Uri>>,
    acceptTypes: Array<String>,
    allowMultiple: Boolean,
    captureEnabled: Boolean
  ): Boolean {
    filePathCallback = callback
    val images = acceptsImages(acceptTypes)
    val video = acceptsVideo(acceptTypes)
    val audio = acceptsAudio(acceptTypes)
    var pickerIntent: Intent? = null

    if (captureEnabled) {
      pickerIntent = when {
        images && !needsCameraPermission() -> getPhotoIntent()
        video && !needsCameraPermission() -> getVideoIntent()
        audio && !images && !video -> getAudioIntent().takeIf(::canResolveIntent)
        else -> null
      }
    }
    if (pickerIntent == null) {
      val extraIntents = ArrayList<Parcelable>()
      if (!needsCameraPermission()) {
        if (images) extraIntents.add(getPhotoIntent())
        if (video) extraIntents.add(getVideoIntent())
      }
      getAudioIntent().takeIf { audio && canResolveIntent(it) }?.let(extraIntents::add)
      val fileSelectionIntent = getFileChooserIntent(acceptTypes, allowMultiple)
      pickerIntent = Intent(Intent.ACTION_CHOOSER).apply {
        putExtra(Intent.EXTRA_INTENT, fileSelectionIntent)
        putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents.toTypedArray())
      }
    }

    val activity = getActivity()
    if (activity != null && pickerIntent.resolveActivity(activity.packageManager) != null) {
      activity.startActivityForResult(pickerIntent, PICKER)
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent")
    }

    return true
  }

  protected fun needsCameraPermission(): Boolean {
    val activity = getActivity() ?: return true
    return try {
      val requestedPermissions = activity.packageManager.getPackageInfo(
        activity.applicationContext.packageName,
        PackageManager.GET_PERMISSIONS
      ).requestedPermissions
      requestedPermissions?.contains(Manifest.permission.CAMERA) == true &&
        ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) !=
        PackageManager.PERMISSION_GRANTED
    } catch (e: PackageManager.NameNotFoundException) {
      true
    }
  }

  private fun getPhotoIntent(): Intent {
    val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
    imageOutputFileUri = getOutputUri(MediaStore.ACTION_IMAGE_CAPTURE)
    intent.putExtra(MediaStore.EXTRA_OUTPUT, imageOutputFileUri)
    return intent
  }

  private fun getVideoIntent(): Intent {
    val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
    videoOutputFileUri = getOutputUri(MediaStore.ACTION_VIDEO_CAPTURE)
    intent.putExtra(MediaStore.EXTRA_OUTPUT, videoOutputFileUri)
    return intent
  }

  private fun getAudioIntent(): Intent {
    return Intent(MediaStore.Audio.Media.RECORD_SOUND_ACTION)
  }

  private fun canResolveIntent(intent: Intent): Boolean {
    val activity = getActivity() ?: return false
    return intent.resolveActivity(activity.packageManager) != null
  }

  private fun getFileChooserIntent(acceptTypes: String): Intent {
    var acceptedType = acceptTypes
    if (acceptedType.isEmpty()) {
      acceptedType = DEFAULT_MIME_TYPES
    }
    if (Regex("\\.\\w+").matches(acceptedType)) {
      acceptedType = getMimeTypeFromExtension(acceptedType.replace(".", "")) ?: DEFAULT_MIME_TYPES
    }
    return Intent(Intent.ACTION_GET_CONTENT).apply {
      addCategory(Intent.CATEGORY_OPENABLE)
      type = acceptedType
    }
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  private fun getFileChooserIntent(acceptTypes: Array<String>, allowMultiple: Boolean): Intent {
    return Intent(Intent.ACTION_GET_CONTENT).apply {
      addCategory(Intent.CATEGORY_OPENABLE)
      type = DEFAULT_MIME_TYPES
      putExtra(Intent.EXTRA_MIME_TYPES, getAcceptedMimeType(acceptTypes))
      putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiple)
    }
  }

  private fun acceptsAny(types: Array<String>): Boolean {
    if (isArrayEmpty(types)) {
      return true
    }

    for (type in types) {
      if (type.equals("*/*")) {
        return true
      }
    }

    return false
  }

  private fun acceptsImages(types: String): Boolean {
    var mimeType = types
    if (Regex("\\.\\w+").matches(types)) {
      mimeType = getMimeTypeFromExtension(types.replace(".", "")) ?: ""
    }
    return mimeType.isEmpty() || mimeType.lowercase().contains("image")
  }

  private fun acceptsImages(types: Array<String>): Boolean {
    val mimeTypes = getAcceptedMimeType(types)
    return acceptsAny(types) || arrayContainsString(mimeTypes, "image")
  }

  private fun acceptsVideo(types: String): Boolean {
    var mimeType = types
    if (Regex("\\.\\w+").matches(types)) {
      mimeType = getMimeTypeFromExtension(types.replace(".", "")) ?: ""
    }
    return mimeType.isEmpty() || mimeType.lowercase().contains("video")
  }

  private fun acceptsVideo(types: Array<String>): Boolean {
    val mimeTypes = getAcceptedMimeType(types)
    return acceptsAny(types) || arrayContainsString(mimeTypes, "video")
  }

  private fun acceptsAudio(types: String): Boolean {
    var mimeType = types
    if (Regex("\\.\\w+").matches(types)) {
      mimeType = getMimeTypeFromExtension(types.replace(".", "")) ?: ""
    }
    return mimeType.isEmpty() || mimeType.lowercase().contains("audio")
  }

  private fun acceptsAudio(types: Array<String>): Boolean {
    val mimeTypes = getAcceptedMimeType(types)
    return acceptsAny(types) || arrayContainsString(mimeTypes, "audio")
  }

  private fun arrayContainsString(array: Array<String?>, pattern: String): Boolean {
    for (content in array) {
      if (content?.contains(pattern) == true) {
        return true
      }
    }
    return false
  }

  private fun getAcceptedMimeType(types: Array<String>): Array<String?> {
    if (isArrayEmpty(types)) {
      return arrayOf(DEFAULT_MIME_TYPES)
    }
    return Array(types.size) { index ->
      val type = types[index]
      // convert file extensions to mime types
      if (Regex("\\.\\w+").matches(type)) {
        getMimeTypeFromExtension(type.replace(".", ""))
      } else {
        type
      }
    }
  }

  private fun getMimeTypeFromExtension(extension: String?): String? {
    return extension?.let { MimeTypeMap.getSingleton().getMimeTypeFromExtension(it) }
  }

  private fun getOutputUri(intentType: String): Uri? {
    val capturedFile = try {
      getCapturedFile(intentType)
    } catch (e: IOException) {
      Log.e(LOG_TAG, "Error occurred while creating the File", e)
      null
    } ?: return null

    // For versions below 6.0 (23), use the old File creation and permissions model.
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return Uri.fromFile(capturedFile)
    }

    val activity = getActivity() ?: return null
    val fileProviderAuthority = "${activity.applicationContext.packageName}." +
      InAppWebViewFileProvider.fileProviderAuthorityExtension
    try {
      // For versions 6.0+ (23), use the FileProvider to avoid runtime permissions.
      return FileProvider.getUriForFile(activity.applicationContext, fileProviderAuthority, capturedFile)
    } catch (e: Exception) {
      Log.e(LOG_TAG, "", e)
    }
    return null
  }

  @Throws(IOException::class)
  private fun getCapturedFile(intentType: String): File? {
    var prefix = ""
    var suffix = ""
    var dir = ""

    if (intentType == MediaStore.ACTION_IMAGE_CAPTURE) {
      prefix = "image"
      suffix = ".jpg"
      dir = Environment.DIRECTORY_PICTURES
    } else if (intentType == MediaStore.ACTION_VIDEO_CAPTURE) {
      prefix = "video"
      suffix = ".mp4"
      dir = Environment.DIRECTORY_MOVIES
    }

    // For versions below 6.0 (23), use the old File creation and permissions model.
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      val storageDir = Environment.getExternalStoragePublicDirectory(dir)
      val filename = String.format("%s-%d%s", prefix, System.currentTimeMillis(), suffix)
      return File(storageDir, filename)
    }

    val activity = getActivity() ?: return null
    val externalFilesDir = activity.applicationContext.getExternalFilesDir(null) ?: return null
    val storageDir = File(externalFilesDir, CAPTURE_DIRECTORY)
    if (!storageDir.exists() && !storageDir.mkdirs()) return null
    return File.createTempFile(prefix, suffix, storageDir)
  }

  private fun isArrayEmpty(arr: Array<String>): Boolean {
    // when our array returned from getAcceptTypes() has no values set from the webview
    // i.e. <input type="file" />, without any "accept" attr
    // will be an array with one empty string element, afaik
    return arr.isEmpty() || (arr.size == 1 && arr[0].isEmpty())
  }

  override fun onPermissionRequest(request: PermissionRequest) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      val callback = object : WebViewChannelDelegate.PermissionRequestCallback() {
        override fun nonNullSuccess(response: PermissionResponse): Boolean {
          when (response.action) {
            1 -> request.grant(response.resources.toTypedArray())
            else -> request.deny()
          }
          return false
        }

        override fun defaultBehaviour(response: PermissionResponse?) {
          request.deny()
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
          defaultBehaviour(null)
        }
      }

      val channelDelegate = inAppWebView?.channelDelegate
      if (channelDelegate != null) {
        channelDelegate.onPermissionRequest(
          request.origin.toString(),
          request.resources.toList().map { it },
          null,
          callback
        )
      } else {
        callback.defaultBehaviour(null)
      }
    }
  }

  override fun onRequestFocus(view: WebView) {
    inAppWebView?.channelDelegate?.onRequestFocus()
  }

  override fun onPermissionRequestCanceled(request: PermissionRequest) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      inAppWebView?.channelDelegate?.onPermissionRequestCanceled(
        request.origin.toString(),
        request.resources.toList().map { it }
      )
    }
  }

  private fun getActivity(): Activity? {
    return inAppBrowserDelegate?.getActivity() ?: plugin?.activity
  }

  fun dispose() {
    for ((dialog, result) in dialogs) {
      result.cancel()
      dialog.dismiss()
    }
    dialogs.clear()
    plugin?.activityPluginBinding?.removeActivityResultListener(this)
    inAppBrowserDelegate?.let { delegate ->
      delegate.getActivityResultListeners().clear()
      inAppBrowserDelegate = null
    }
    filePathCallbackLegacy = null
    filePathCallback = null
    videoOutputFileUri = null
    imageOutputFileUri = null
    inAppWebView = null
    plugin = null
  }
}
