package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.webkit.WebView
import android.widget.ListPopupWindow

open class InputAwareWebView : WebView {
    companion object {
        private const val INPUT_METHOD_SERVICE = Context.INPUT_METHOD_SERVICE
        private const val LOG_TAG = "InputAwareWebView"
    }

    @JvmField
    var containerView: View? = null

    private var threadedInputConnectionProxyView: View? = null
    private var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null
    private var useHybridComposition = false

    constructor(
        context: Context,
        containerView: View?,
        useHybridComposition: Boolean?
    ) : super(context) {
        this.containerView = containerView
        this.useHybridComposition = useHybridComposition == true
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet?, defaultStyle: Int) :
        super(context, attrs, defaultStyle)

    fun setContainerView(containerView: View?) {
        this.containerView = containerView

        val currentProxyAdapterView = proxyAdapterView ?: return
        Log.w(LOG_TAG, "The containerView has changed while the proxyAdapterView exists.")
        if (containerView != null &&
            isViewReady(containerView) &&
            isViewReady(currentProxyAdapterView)
        ) {
            setInputConnectionTarget(currentProxyAdapterView)
        }
    }

    /** Restores Flutter's input target after Android removes a fullscreen custom view. */
    fun restoreInputConnectionAfterFullscreen() {
        val currentContainerView = containerView ?: return
        if (!isViewReady(currentContainerView)) {
            return
        }
        currentContainerView.post {
            if (containerView !== currentContainerView || !isViewReady(currentContainerView)) {
                return@post
            }

            currentContainerView.requestFocus()
            if (!useHybridComposition) {
                resetInputConnection()
            }

            val inputMethodManager =
                getContext().getSystemService(INPUT_METHOD_SERVICE) as? InputMethodManager
            try {
                inputMethodManager?.restartInput(currentContainerView)
            } catch (error: RuntimeException) {
                Log.w(LOG_TAG, "Unable to restore the Flutter input connection after fullscreen.", error)
            }
        }
    }

    /** Sets the proxy adapter view to use its cached input connection. */
    fun lockInputConnection() {
        proxyAdapterView?.setLocked(true)
    }

    /** Sets the proxy adapter view back to its default behavior. */
    fun unlockInputConnection() {
        proxyAdapterView?.setLocked(false)
    }

    /** Restores the original InputConnection, if needed. */
    open fun dispose() {
        if (useHybridComposition) return
        resetInputConnection()
    }

    /**
     * Creates an InputConnection from the IME thread when needed.
     *
     * This mirrors the WebView implementation on Android versions below N.
     */
    override fun checkInputConnectionProxy(view: View): Boolean {
        if (useHybridComposition) {
            return super.checkInputConnectionProxy(view)
        }

        val previousProxy = threadedInputConnectionProxyView
        threadedInputConnectionProxyView = view
        if (previousProxy === view) {
            return super.checkInputConnectionProxy(view)
        }

        val currentContainerView = containerView
        if (currentContainerView == null ||
            !isViewReady(currentContainerView) ||
            !isViewReady(view)
        ) {
            Log.e(
                LOG_TAG,
                "Can't create a proxy view because there's no container view. " +
                    "Text input may not work."
            )
            return super.checkInputConnectionProxy(view)
        }

        val imeHandler = view.handler
        if (imeHandler == null) {
            Log.e(LOG_TAG, "Can't create a proxy view because the target has no handler.")
            return super.checkInputConnectionProxy(view)
        }

        val newProxyAdapterView = ThreadedInputConnectionProxyAdapterView(
            currentContainerView,
            view,
            imeHandler
        )
        proxyAdapterView = newProxyAdapterView
        setInputConnectionTarget(newProxyAdapterView)
        return super.checkInputConnectionProxy(view)
    }

    /** Ensures that input creation returns to the container view after focus is cleared. */
    override fun clearFocus() {
        super.clearFocus()
        if (!useHybridComposition) {
            resetInputConnection()
        }
    }

    /** Ensures that input creation returns to the container view. */
    private fun resetInputConnection() {
        if (proxyAdapterView == null) {
            return
        }
        val currentContainerView = containerView
        if (currentContainerView == null) {
            Log.e(
                LOG_TAG,
                "Can't reset the input connection to the container view because there is none."
            )
            return
        }
        if (!isViewReady(currentContainerView)) {
            return
        }
        setInputConnectionTarget(currentContainerView)
    }

    /**
     * Routes InputConnection creation to the handler thread of the target view on pre-N Android.
     */
    private fun setInputConnectionTarget(targetView: View) {
        val currentContainerView = containerView
        if (currentContainerView == null) {
            Log.e(
                LOG_TAG,
                "Can't set the input connection target because there is no containerView " +
                    "to use as a handler."
            )
            return
        }
        if (!isViewReady(currentContainerView) || !isViewReady(targetView)) {
            return
        }

        targetView.requestFocus()
        currentContainerView.post {
            val postedContainerView = containerView
            if (postedContainerView == null ||
                !isViewReady(postedContainerView) ||
                !isViewReady(targetView)
            ) {
                Log.e(
                    LOG_TAG,
                    "Can't set the input connection target because there is no containerView " +
                        "to use as a handler."
                )
                return@post
            }

            val inputMethodManager =
                getContext().getSystemService(INPUT_METHOD_SERVICE) as? InputMethodManager
            // Make InputMethodManager believe that the target view now has focus. This causes
            // it to create the input connection on targetView.getHandler().
            targetView.onWindowFocusChanged(true)

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                inputMethodManager?.isActive(postedContainerView)
            }
        }
    }

    private fun isViewReady(view: View): Boolean =
        view.isAttachedToWindow && view.windowToken != null

    override fun onFocusChanged(
        focused: Boolean,
        direction: Int,
        previouslyFocusedRect: Rect?
    ) {
        if (useHybridComposition) {
            super.onFocusChanged(focused, direction, previouslyFocusedRect)
            return
        }

        // Older Chromium versions could crash when a select popup synchronously changed focus.
        if (
            Build.VERSION.SDK_INT < Build.VERSION_CODES.P &&
            isCalledFromListPopupWindowShow() &&
            !focused
        ) {
            return
        }
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
    }

    private fun isCalledFromListPopupWindowShow(): Boolean {
        val listPopupWindowClassName = ListPopupWindow::class.java.name
        return Thread.currentThread().stackTrace.any { stackTraceElement ->
            stackTraceElement.className == listPopupWindowClassName &&
                stackTraceElement.methodName == "show"
        }
    }
}
