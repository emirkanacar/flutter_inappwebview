package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import io.flutter.embedding.android.FlutterActivity

open class NoHistoryCustomTabsActivityCallbacks(
    @JvmField var plugin: InAppWebViewFlutterPlugin?
) : Disposable {
    @JvmField
    val noHistoryBrowserIDs: MutableMap<String, String?> = HashMap()

    @JvmField
    val activityLifecycleCallbacks: Application.ActivityLifecycleCallbacks =
        object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit

            override fun onActivityStarted(activity: Activity) = Unit

            override fun onActivityResumed(activity: Activity) {
                val manager = plugin?.chromeSafariBrowserManager
                if (activity is FlutterActivity && manager != null) {
                    for (browserId in noHistoryBrowserIDs.values) {
                        if (browserId != null) {
                            noHistoryBrowserIDs[browserId] = null
                            manager.browsers[browserId]?.let { browser ->
                                browser.close()
                                browser.dispose()
                            }
                        }
                    }
                }
            }

            override fun onActivityPaused(activity: Activity) = Unit

            override fun onActivityStopped(activity: Activity) = Unit

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

            override fun onActivityDestroyed(activity: Activity) = Unit
        }

    override fun dispose() {
        noHistoryBrowserIDs.clear()
        plugin = null
    }
}
