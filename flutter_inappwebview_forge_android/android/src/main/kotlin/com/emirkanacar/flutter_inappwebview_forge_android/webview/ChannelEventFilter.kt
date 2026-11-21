package com.emirkanacar.flutter_inappwebview_forge_android.webview

/**
 * Fire-and-forget WebView channel events that Dart reported as having no
 * listener, so they are not encoded or sent over the platform channel.
 *
 * Dart sends the list in the `skippedEvents` creation parameter of every
 * platform-view creation (new, KeepAlive reuse, and headless transfer), so
 * the filter always matches the callbacks of the widget that currently owns
 * the WebView. A missing or malformed value clears the filter and every event
 * is sent, which is the pre-filter behavior.
 *
 * Only notifications whose Dart handler is a no-op without a listener are
 * accepted. Callbacks that wait for a Dart result are never filtered.
 */
class ChannelEventFilter {
  companion object {
    const val CREATION_PARAM = "skippedEvents"

    @JvmField
    val SKIPPABLE_EVENTS: Set<String> = setOf(
      "onConsoleMessage",
      "onScrollChanged",
      "onProgressChanged",
      "onTitleChanged",
      "onOverScrolled",
      "onZoomScaleChanged"
    )
  }

  @Volatile
  private var skipped: Set<String> = emptySet()

  fun update(raw: Any?) {
    val names = raw as? List<*>
    skipped = names
      ?.filterIsInstance<String>()
      ?.filterTo(HashSet()) { it in SKIPPABLE_EVENTS }
      ?: emptySet()
  }

  fun isSkipped(method: String): Boolean = method in skipped
}
