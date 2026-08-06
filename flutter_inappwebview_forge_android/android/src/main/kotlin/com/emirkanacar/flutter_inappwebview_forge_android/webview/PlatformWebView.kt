package com.emirkanacar.flutter_inappwebview_forge_android.webview

import io.flutter.plugin.platform.PlatformView
import java.util.HashMap

interface PlatformWebView : PlatformView {
    fun makeInitialLoad(params: HashMap<String, Any?>)
}
