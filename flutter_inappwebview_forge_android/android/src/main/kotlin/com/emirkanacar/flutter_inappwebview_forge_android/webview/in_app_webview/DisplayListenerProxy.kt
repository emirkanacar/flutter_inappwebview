package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.annotation.TargetApi
import android.hardware.display.DisplayManager
import android.os.Build
import android.util.Log
import java.lang.reflect.Field
import java.util.ArrayList

private const val TAG = "DisplayListenerProxy"

/** Works around an Android WebView bug by filtering some DisplayListener invocations. */
@TargetApi(Build.VERSION_CODES.KITKAT)
open class DisplayListenerProxy {
    private var listenersBeforeWebView: ArrayList<DisplayManager.DisplayListener> = arrayListOf()

    /** Should be called prior to the webview's initialization. */
    open fun onPreWebViewInitialization(displayManager: DisplayManager) {
        listenersBeforeWebView = yoinkDisplayListeners(displayManager)
    }

    /** Should be called after the webview's initialization. */
    open fun onPostWebViewInitialization(displayManager: DisplayManager) {
        val webViewListeners = yoinkDisplayListeners(displayManager)
        webViewListeners.removeAll(listenersBeforeWebView)
        if (webViewListeners.isEmpty()) return

        for (webViewListener in webViewListeners) {
            displayManager.unregisterDisplayListener(webViewListener)
            displayManager.registerDisplayListener(
                object : DisplayManager.DisplayListener {
                    override fun onDisplayAdded(displayId: Int) {
                        for (listener in webViewListeners) listener.onDisplayAdded(displayId)
                    }

                    override fun onDisplayRemoved(displayId: Int) {
                        for (listener in webViewListeners) listener.onDisplayRemoved(displayId)
                    }

                    override fun onDisplayChanged(displayId: Int) {
                        if (displayManager.getDisplay(displayId) == null) return
                        for (listener in webViewListeners) listener.onDisplayChanged(displayId)
                    }
                },
                null
            )
        }
    }

    @Suppress("UNCHECKED_CAST", "PrivateApi")
    private fun yoinkDisplayListeners(displayManager: DisplayManager): ArrayList<DisplayManager.DisplayListener> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) return arrayListOf()
        return try {
            val displayManagerGlobalField = DisplayManager::class.java.getDeclaredField("mGlobal")
            displayManagerGlobalField.isAccessible = true
            val displayManagerGlobal = displayManagerGlobalField.get(displayManager)
            val displayListenersField = displayManagerGlobal.javaClass.getDeclaredField("mDisplayListeners")
            displayListenersField.isAccessible = true
            val delegates = displayListenersField.get(displayManagerGlobal) as? ArrayList<Any?>
                ?: return arrayListOf()

            var listenerField: Field? = null
            val listeners = ArrayList<DisplayManager.DisplayListener>()
            for (delegate in delegates) {
                if (delegate == null) continue
                if (listenerField == null) {
                    listenerField = delegate.javaClass.getField("mListener")
                    listenerField.isAccessible = true
                }
                val listener = listenerField?.get(delegate) as? DisplayManager.DisplayListener
                if (listener != null) listeners.add(listener)
            }
            listeners
        } catch (e: ReflectiveOperationException) {
            Log.w(TAG, "Could not extract WebView's display listeners. $e")
            arrayListOf()
        }
    }
}
