package com.emirkanacar.flutter_inappwebview_forge_example

import android.content.Context
import android.graphics.Color
import android.view.View
import android.webkit.WebView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

private const val ANDROID_2688_NATIVE_WEBVIEW_TYPE =
    "com.emirkanacar.flutter_inappwebview_forge_example/android_2688_native_webview"

private const val ANDROID_2688_NATIVE_WEBVIEW_HTML = """
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; height: 100%; background: #0d47a1; }
    body { display: grid; place-items: center; font-family: sans-serif; }
    #webview-surface-marker { color: white; font-size: 28px; font-weight: 700; }
  </style>
</head>
<body>
  <div id="webview-surface-marker">NATIVE_WEBVIEW_SURFACE</div>
</body>
</html>
"""

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            ANDROID_2688_NATIVE_WEBVIEW_TYPE,
            Android2688NativeWebViewFactory(),
        )
    }
}

private class Android2688NativeWebViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return Android2688NativeWebView(context)
    }
}

private class Android2688NativeWebView(context: Context) : PlatformView {
    private val webView = WebView(context).apply {
        setBackgroundColor(Color.rgb(13, 71, 161))
        settings.javaScriptEnabled = true
        loadDataWithBaseURL(
            "https://example.com/",
            ANDROID_2688_NATIVE_WEBVIEW_HTML,
            "text/html",
            "UTF-8",
            null,
        )
    }

    override fun getView(): View = webView

    override fun dispose() {
        webView.stopLoading()
        webView.removeAllViews()
        webView.destroy()
    }
}
