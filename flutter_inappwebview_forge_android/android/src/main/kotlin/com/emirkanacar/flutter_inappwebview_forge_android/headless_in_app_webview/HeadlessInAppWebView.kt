package com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.Size2D
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodChannel

open class HeadlessInAppWebView(
    initialPlugin: InAppWebViewFlutterPlugin,
    @JvmField val id: String,
    @JvmField var flutterWebView: FlutterWebView?
) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG = "HeadlessInAppWebView"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_headless_inappwebview_"
    }

    @JvmField
    var channelDelegate: HeadlessWebViewChannelDelegate? = null

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    init {
        val channel = MethodChannel(
            initialPlugin.requireMessenger(),
            METHOD_CHANNEL_NAME_PREFIX + id
        )
        channelDelegate = HeadlessWebViewChannelDelegate(this, channel)
    }

    fun onWebViewCreated() {
        channelDelegate?.onWebViewCreated()
    }

    @Suppress("UNCHECKED_CAST")
    fun prepare(params: Map<String, Any?>) {
        flutterWebView?.let { currentFlutterWebView ->
            currentFlutterWebView.getView()?.let { view ->
                val initialSize = params["initialSize"] as? MutableMap<String, Any?>
                val size = Size2D.fromMap(initialSize) ?: Size2D(-1.0, -1.0)
                setSize(size)
                view.visibility = View.INVISIBLE
            }
        }

        val currentPlugin = plugin ?: return
        val activity = currentPlugin.activity ?: return

        // Add the headless WebView to the view hierarchy.
        // This way is also possible to take screenshots.
        val contentView = activity.findViewById<ViewGroup>(android.R.id.content)
        val mainView = contentView?.getChildAt(0) as? ViewGroup
        if (mainView != null) {
            flutterWebView?.getView()?.let { view ->
                mainView.addView(view, 0)
            }
        }
    }

    fun setSize(size: Size2D) {
        val currentFlutterWebView = flutterWebView ?: return
        if (currentFlutterWebView.webView == null) return
        val view = currentFlutterWebView.getView() ?: return

        val scale = Util.getPixelDensity(view.context).toDouble()
        val fullscreenSize = Util.getFullscreenSize(view.context)
        val width = if (size.width == -1.0) {
            fullscreenSize.width
        } else {
            size.width * scale
        }
        val height = if (size.width == -1.0) {
            fullscreenSize.height
        } else {
            size.height * scale
        }
        view.layoutParams = FrameLayout.LayoutParams(width.toInt(), height.toInt())
    }

    fun getSize(): Size2D? {
        val currentFlutterWebView = flutterWebView ?: return null
        if (currentFlutterWebView.webView == null) return null
        val view = currentFlutterWebView.getView() ?: return null

        val scale = Util.getPixelDensity(view.context).toDouble()
        val fullscreenSize = Util.getFullscreenSize(view.context)
        val layoutParams = view.layoutParams
        return Size2D(
            if (fullscreenSize.width == layoutParams.width.toDouble()) {
                layoutParams.width.toDouble()
            } else {
                layoutParams.width / scale
            },
            if (fullscreenSize.height == layoutParams.height.toDouble()) {
                layoutParams.height.toDouble()
            } else {
                layoutParams.height / scale
            }
        )
    }

    fun disposeAndGetFlutterWebView(): FlutterWebView? {
        val newFlutterWebView = flutterWebView
        val currentFlutterWebView = flutterWebView
        if (currentFlutterWebView != null) {
            currentFlutterWebView.getView()?.let { view ->
                // Restore WebView layout params and visibility.
                view.layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
                view.visibility = View.VISIBLE

                // Remove from parent.
                (view.parent as? ViewGroup)?.removeView(view)
            }
            // Set to null to avoid being disposed before calling dispose().
            flutterWebView = null
            dispose()
        }
        return newFlutterWebView
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null

        plugin?.let { currentPlugin ->
            currentPlugin.headlessInAppWebViewManager?.let { manager ->
                if (manager.webViews.containsKey(id)) {
                    manager.webViews[id] = null
                }
            }

            currentPlugin.activity?.let { activity: Activity ->
                val contentView = activity.findViewById<ViewGroup>(android.R.id.content)
                val mainView = contentView?.getChildAt(0) as? ViewGroup
                if (mainView != null) {
                    flutterWebView?.getView()?.let(mainView::removeView)
                }
            }
        }

        flutterWebView?.dispose()
        flutterWebView = null
        plugin = null
    }
}
