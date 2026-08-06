package com.emirkanacar.flutter_inappwebview_forge_android

import android.app.Activity
import android.content.Context
import android.os.Build

import com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs.ChromeSafariBrowserManager
import com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs.NoHistoryCustomTabsActivityCallbacks
import com.emirkanacar.flutter_inappwebview_forge_android.credential_database.CredentialDatabaseHandler
import com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview.HeadlessInAppWebViewManager
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserManager
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.PrintJobManager
import com.emirkanacar.flutter_inappwebview_forge_android.process_global_config.ProcessGlobalConfigManager
import com.emirkanacar.flutter_inappwebview_forge_android.proxy.ProxyManager
import com.emirkanacar.flutter_inappwebview_forge_android.service_worker.ServiceWorkerManager
import com.emirkanacar.flutter_inappwebview_forge_android.tracing.TracingControllerManager
import com.emirkanacar.flutter_inappwebview_forge_android.webview.FlutterWebViewFactory
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewManager

import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry

class InAppWebViewFlutterPlugin : FlutterPlugin, ActivityAware {
    companion object {
        @JvmField
        protected val LOG_TAG = "InAppWebViewFlutterPL"
    }

    @JvmField
    var platformUtil: PlatformUtil? = null

    @JvmField
    var inAppBrowserManager: InAppBrowserManager? = null

    @JvmField
    var headlessInAppWebViewManager: HeadlessInAppWebViewManager? = null

    @JvmField
    var chromeSafariBrowserManager: ChromeSafariBrowserManager? = null

    @JvmField
    var noHistoryCustomTabsActivityCallbacks: NoHistoryCustomTabsActivityCallbacks? = null

    @JvmField
    var inAppWebViewManager: InAppWebViewManager? = null

    @JvmField
    var myCookieManager: MyCookieManager? = null

    @JvmField
    var credentialDatabaseHandler: CredentialDatabaseHandler? = null

    @JvmField
    var myWebStorage: MyWebStorage? = null

    @JvmField
    var serviceWorkerManager: ServiceWorkerManager? = null

    @JvmField
    var webViewFeatureManager: WebViewFeatureManager? = null

    @JvmField
    var proxyManager: ProxyManager? = null

    @JvmField
    var printJobManager: PrintJobManager? = null

    @JvmField
    var tracingControllerManager: TracingControllerManager? = null

    @JvmField
    var processGlobalConfigManager: ProcessGlobalConfigManager? = null

    @JvmField
    var flutterWebViewFactory: FlutterWebViewFactory? = null

    @JvmField
    var applicationContext: Context? = null

    @JvmField
    var messenger: BinaryMessenger? = null

    @JvmField
    var flutterAssets: FlutterPlugin.FlutterAssets? = null

    @JvmField
    var activityPluginBinding: ActivityPluginBinding? = null

    @JvmField
    var activity: Activity? = null

    @JvmField
    var flutterView: FlutterView? = null

    fun requireMessenger(): BinaryMessenger {
        return messenger ?: error("Flutter messenger is not available outside the engine lifecycle.")
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterAssets = binding.flutterAssets

        // Shared.activity could be null or not. It depends on who is called first
        // between onAttachedToEngine and onAttachedToActivity.
        // See https://github.com/pichillilorenzo/flutter_inappwebview/issues/390#issuecomment-647039084
        onAttachedToEngine(
            binding.applicationContext,
            binding.binaryMessenger,
            activity,
            binding.platformViewRegistry,
            null,
        )
    }

    private fun onAttachedToEngine(
        applicationContext: Context,
        messenger: BinaryMessenger,
        activity: Activity?,
        platformViewRegistry: PlatformViewRegistry,
        flutterView: FlutterView?,
    ) {
        this.applicationContext = applicationContext
        this.activity = activity
        this.messenger = messenger
        this.flutterView = flutterView

        inAppBrowserManager = InAppBrowserManager(this)
        headlessInAppWebViewManager = HeadlessInAppWebViewManager(this)
        chromeSafariBrowserManager = ChromeSafariBrowserManager(this)
        noHistoryCustomTabsActivityCallbacks = NoHistoryCustomTabsActivityCallbacks(this)

        val webViewFactory = FlutterWebViewFactory(this)
        flutterWebViewFactory = webViewFactory
        platformViewRegistry.registerViewFactory(FlutterWebViewFactory.VIEW_TYPE_ID, webViewFactory)

        platformUtil = PlatformUtil(this)
        inAppWebViewManager = InAppWebViewManager(this)
        myCookieManager = MyCookieManager(this)
        myWebStorage = MyWebStorage(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            serviceWorkerManager = ServiceWorkerManager(this)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            credentialDatabaseHandler = CredentialDatabaseHandler(this)
        }
        webViewFeatureManager = WebViewFeatureManager(this)
        proxyManager = ProxyManager(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            printJobManager = PrintJobManager(this)
        }
        tracingControllerManager = TracingControllerManager(this)
        processGlobalConfigManager = ProcessGlobalConfigManager(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        platformUtil?.dispose()
        platformUtil = null
        inAppBrowserManager?.dispose()
        inAppBrowserManager = null
        headlessInAppWebViewManager?.dispose()
        headlessInAppWebViewManager = null
        chromeSafariBrowserManager?.dispose()
        chromeSafariBrowserManager = null
        noHistoryCustomTabsActivityCallbacks?.dispose()
        noHistoryCustomTabsActivityCallbacks = null
        myCookieManager?.dispose()
        myCookieManager = null
        myWebStorage?.dispose()
        myWebStorage = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            credentialDatabaseHandler?.dispose()
            credentialDatabaseHandler = null
        }
        inAppWebViewManager?.dispose()
        inAppWebViewManager = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            serviceWorkerManager?.dispose()
            serviceWorkerManager = null
        }
        webViewFeatureManager?.dispose()
        webViewFeatureManager = null
        proxyManager?.dispose()
        proxyManager = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            printJobManager?.dispose()
            printJobManager = null
        }
        tracingControllerManager?.dispose()
        tracingControllerManager = null
        processGlobalConfigManager?.dispose()
        processGlobalConfigManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activity = binding.activity
        registerActivityLifecycleCallbacks(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterActivityLifecycleCallbacks(activity)
        activityPluginBinding = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activity = binding.activity
        registerActivityLifecycleCallbacks(binding.activity)
    }

    override fun onDetachedFromActivity() {
        unregisterActivityLifecycleCallbacks(activity)
        activityPluginBinding = null
        activity = null
    }

    private fun registerActivityLifecycleCallbacks(activity: Activity) {
        noHistoryCustomTabsActivityCallbacks?.let { callbacks ->
            activity.application.registerActivityLifecycleCallbacks(callbacks.activityLifecycleCallbacks)
        }
    }

    private fun unregisterActivityLifecycleCallbacks(activity: Activity?) {
        if (activity == null) {
            return
        }
        noHistoryCustomTabsActivityCallbacks?.let { callbacks ->
            activity.application.unregisterActivityLifecycleCallbacks(callbacks.activityLifecycleCallbacks)
        }
    }
}
