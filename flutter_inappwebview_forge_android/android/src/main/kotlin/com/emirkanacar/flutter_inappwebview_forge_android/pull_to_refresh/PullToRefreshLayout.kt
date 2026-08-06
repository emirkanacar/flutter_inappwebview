package com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.view.View
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodChannel

open class PullToRefreshLayout : SwipeRefreshLayout, Disposable {
    companion object {
        @JvmField
        val LOG_TAG = "PullToRefreshLayout"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX =
            "com.emirkanacar/flutter_inappwebview_pull_to_refresh_"
    }

    @JvmField
    var channelDelegate: PullToRefreshChannelDelegate? = null

    @JvmField
    var settings: PullToRefreshSettings = PullToRefreshSettings()

    constructor(
        context: Context,
        plugin: InAppWebViewFlutterPlugin,
        id: Any,
        settings: PullToRefreshSettings
    ) : super(context) {
        this.settings = settings
        val channel = MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME_PREFIX + id)
        channelDelegate = PullToRefreshChannelDelegate(this, channel)
    }

    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

    fun prepare() {
        isFocusable = true

        setEnabled(settings.enabled)
        setOnChildScrollUpCallback(object : OnChildScrollUpCallback {
            override fun canChildScrollUp(parent: SwipeRefreshLayout, child: View?): Boolean {
                if (child is InAppWebView) {
                    return (child.canScrollVertically() && child.scrollY > 0) ||
                        (!child.canScrollVertically() && child.scrollY == 0)
                }
                return true
            }
        })
        setOnRefreshListener {
            val delegate = channelDelegate
            if (delegate == null) {
                isRefreshing = false
            } else {
                delegate.onRefresh()
            }
        }
        settings.color?.let { setColorSchemeColors(Color.parseColor(it)) }
        settings.backgroundColor?.let { setProgressBackgroundColorSchemeColor(Color.parseColor(it)) }
        settings.distanceToTriggerSync?.let { setDistanceToTriggerSync(it) }
        settings.slingshotDistance?.let { setSlingshotDistance(it) }
        settings.size?.let { setSize(it) }
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        removeAllViews()
    }
}
