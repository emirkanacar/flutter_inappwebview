# WebView
-keepattributes *JavascriptInterface*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.webView, jav.lang.String);
}
-keepclassmembers class com.emirkanacar.flutter_inappwebview_forge_android.webview.JavaScriptBridgeInterface {
     <fields>;
     <methods>;
     public *;
     private *;
}
-keep class com.emirkanacar.flutter_inappwebview_forge_android.** { *; }

-dontwarn android.window.BackEvent
