package com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh

import android.graphics.Color
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class PullToRefreshChannelDelegate(
    private var pullToRefreshView: PullToRefreshLayout?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEnabled" -> {
                val view = pullToRefreshView
                val enabled = call.argument<Boolean>("enabled")
                if (view == null) {
                    result.success(false)
                } else if (enabled == null) {
                    result.error("invalid_arguments", "enabled is required.", null)
                } else {
                    view.settings.enabled = enabled
                    view.isEnabled = enabled
                    result.success(true)
                }
            }
            "isEnabled" -> result.success(pullToRefreshView?.isEnabled ?: false)
            "setRefreshing" -> {
                val view = pullToRefreshView
                val refreshing = call.argument<Boolean>("refreshing")
                if (view == null) {
                    result.success(false)
                } else if (refreshing == null) {
                    result.error("invalid_arguments", "refreshing is required.", null)
                } else {
                    view.isRefreshing = refreshing
                    result.success(true)
                }
            }
            "isRefreshing" -> result.success(pullToRefreshView?.isRefreshing ?: false)
            "setColor" -> {
                val view = pullToRefreshView
                val color = call.argument<String>("color")
                if (view == null) {
                    result.success(false)
                } else if (color == null) {
                    result.error("invalid_arguments", "color is required.", null)
                } else {
                    view.setColorSchemeColors(Color.parseColor(color))
                    result.success(true)
                }
            }
            "setBackgroundColor" -> {
                val view = pullToRefreshView
                val color = call.argument<String>("color")
                if (view == null) {
                    result.success(false)
                } else if (color == null) {
                    result.error("invalid_arguments", "color is required.", null)
                } else {
                    view.setProgressBackgroundColorSchemeColor(Color.parseColor(color))
                    result.success(true)
                }
            }
            "setDistanceToTriggerSync" -> {
                val view = pullToRefreshView
                val distance = call.argument<Int>("distanceToTriggerSync")
                if (view == null) {
                    result.success(false)
                } else if (distance == null) {
                    result.error("invalid_arguments", "distanceToTriggerSync is required.", null)
                } else {
                    view.setDistanceToTriggerSync(distance)
                    result.success(true)
                }
            }
            "setSlingshotDistance" -> {
                val view = pullToRefreshView
                val distance = call.argument<Int>("slingshotDistance")
                if (view == null) {
                    result.success(false)
                } else if (distance == null) {
                    result.error("invalid_arguments", "slingshotDistance is required.", null)
                } else {
                    view.setSlingshotDistance(distance)
                    result.success(true)
                }
            }
            "getDefaultSlingshotDistance" -> result.success(SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE)
            "setSize" -> {
                val view = pullToRefreshView
                val size = call.argument<Int>("size")
                if (view == null) {
                    result.success(false)
                } else if (size == null) {
                    result.error("invalid_arguments", "size is required.", null)
                } else {
                    view.setSize(size)
                    result.success(true)
                }
            }
            else -> result.notImplemented()
        }
    }

    fun onRefresh() {
        if (!canDispatchCallbacks()) {
            pullToRefreshView?.isRefreshing = false
            return
        }
        val channel = getChannel() ?: return
        channel.invokeMethod("onRefresh", HashMap<String, Any?>())
    }

    private fun canDispatchCallbacks(): Boolean {
        val view = pullToRefreshView ?: return false
        val child = if (view.childCount > 0) view.getChildAt(0) else null
        return getChannel() != null &&
            (child !is InAppWebView || child.acceptsCallbacks())
    }

    override fun dispose() {
        super.dispose()
        pullToRefreshView = null
    }
}
