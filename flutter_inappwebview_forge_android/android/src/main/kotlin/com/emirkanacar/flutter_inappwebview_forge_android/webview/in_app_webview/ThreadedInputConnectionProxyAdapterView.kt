package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.os.Handler
import android.os.IBinder
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection

class ThreadedInputConnectionProxyAdapterView(
    containerView: View,
    private val targetView: View,
    private val imeHandler: Handler
) : View(containerView.context) {
    private val windowTokenValue: IBinder? = containerView.windowToken
    private val rootViewValue: View = containerView.rootView

    private var triggerDelayed = true
    private var locked = false
    private var cachedConnection: InputConnection? = null

    init {
        isFocusable = true
        isFocusableInTouchMode = true
        visibility = VISIBLE
    }

    /** Returns whether or not this is currently asynchronously acquiring an input connection. */
    fun isTriggerDelayed(): Boolean = triggerDelayed

    /** Sets whether or not this should use its previously cached input connection. */
    fun setLocked(locked: Boolean) {
        this.locked = locked
    }

    /**
     * This is expected to be called on the IME thread. It delegates to the target WebView
     * to obtain its input connection.
     */
    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
        triggerDelayed = false
        val inputConnection = if (locked) {
            cachedConnection
        } else {
            targetView.onCreateInputConnection(outAttrs)
        }
        triggerDelayed = true
        cachedConnection = inputConnection
        return inputConnection
    }

    override fun checkInputConnectionProxy(view: View): Boolean = true

    override fun hasWindowFocus(): Boolean = true

    override fun getRootView(): View = rootViewValue

    override fun onCheckIsTextEditor(): Boolean = true

    override fun isFocused(): Boolean = true

    override fun getWindowToken(): IBinder? = windowTokenValue

    override fun getHandler(): Handler? = imeHandler
}
