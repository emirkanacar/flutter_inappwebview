package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.webkit.JsPromptResult
import android.webkit.JsResult
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Answers a WebView JavaScript dialog result at most once.
 *
 * Page JavaScript stays blocked in alert(), confirm(), prompt(), or the
 * before-unload prompt until the [JsResult] is answered, and the answer can
 * come from several racing places: the Dart reply, the native dialog buttons,
 * a channel error, a missing activity, or dispose. The first answer wins and
 * the rest are ignored, so every path may answer without checking the others.
 */
class JsDialogResult(
  private val result: JsResult,
  private val onAnswered: (JsDialogResult) -> Unit
) {
  private val answered = AtomicBoolean(false)

  val isAnswered: Boolean
    get() = answered.get()

  fun confirm() {
    if (!begin()) return
    result.confirm()
  }

  /** Confirms a prompt with [value]; other dialogs ignore the value. */
  fun confirm(value: String?) {
    if (!begin()) return
    val promptResult = result as? JsPromptResult
    if (promptResult != null) {
      promptResult.confirm(value)
    } else {
      result.confirm()
    }
  }

  fun cancel() {
    if (!begin()) return
    result.cancel()
  }

  private fun begin(): Boolean {
    if (!answered.compareAndSet(false, true)) return false
    onAnswered(this)
    return true
  }
}
