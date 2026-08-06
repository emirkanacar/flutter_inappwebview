package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.text.TextUtils
import android.util.Log
import androidx.browser.customtabs.CustomTabsService
import java.util.ArrayList

open class CustomTabsHelper private constructor() {
    companion object {
        @JvmField
        protected val TAG = "CustomTabsHelper"

        @JvmField
        val STABLE_PACKAGE = "com.android.chrome"

        @JvmField
        val BETA_PACKAGE = "com.chrome.beta"

        @JvmField
        val DEV_PACKAGE = "com.chrome.dev"

        @JvmField
        val LOCAL_PACKAGE = "com.google.android.apps.chrome"

        @JvmField
        val EXTRA_CUSTOM_TABS_KEEP_ALIVE =
            "android.support.customtabs.extra.KEEP_ALIVE"

        private var sPackageNameToUse: String? = null

        @JvmStatic
        fun addKeepAliveExtra(context: Context, intent: Intent) {
            val keepAliveIntent = Intent().setClassName(
                context.packageName,
                KeepAliveService::class.java.canonicalName ?: KeepAliveService::class.java.name
            )
            intent.putExtra(EXTRA_CUSTOM_TABS_KEEP_ALIVE, keepAliveIntent)
        }

        @JvmStatic
        fun getPackageNameToUse(context: Context): String? {
            sPackageNameToUse?.let { return it }

            val packageManager = context.packageManager
            val activityIntent = Intent(Intent.ACTION_VIEW, Uri.parse("http://www.example.com"))
                .addCategory(Intent.CATEGORY_BROWSABLE)
            val defaultViewHandlerInfo = packageManager.resolveActivity(activityIntent, 0)
            val defaultViewHandlerPackageName =
                defaultViewHandlerInfo?.activityInfo?.packageName

            var flags = 0
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                flags = flags or PackageManager.MATCH_ALL
            }
            val resolvedActivityList = packageManager.queryIntentActivities(activityIntent, flags)
            val packagesSupportingCustomTabs = ArrayList<String>()
            for (info in resolvedActivityList) {
                val serviceIntent = Intent().apply {
                    action = CustomTabsService.ACTION_CUSTOM_TABS_CONNECTION
                    setPackage(info.activityInfo.packageName)
                }
                if (packageManager.resolveService(serviceIntent, 0) != null) {
                    packagesSupportingCustomTabs.add(info.activityInfo.packageName)
                }
            }

            sPackageNameToUse = when {
                packagesSupportingCustomTabs.isEmpty() -> null
                packagesSupportingCustomTabs.size == 1 -> packagesSupportingCustomTabs[0]
                !TextUtils.isEmpty(defaultViewHandlerPackageName) &&
                    !hasSpecializedHandlerIntents(context, activityIntent) &&
                    packagesSupportingCustomTabs.contains(defaultViewHandlerPackageName) ->
                    defaultViewHandlerPackageName
                packagesSupportingCustomTabs.contains(STABLE_PACKAGE) -> STABLE_PACKAGE
                packagesSupportingCustomTabs.contains(BETA_PACKAGE) -> BETA_PACKAGE
                packagesSupportingCustomTabs.contains(DEV_PACKAGE) -> DEV_PACKAGE
                packagesSupportingCustomTabs.contains(LOCAL_PACKAGE) -> LOCAL_PACKAGE
                else -> null
            }
            return sPackageNameToUse
        }

        private fun hasSpecializedHandlerIntents(context: Context, intent: Intent): Boolean {
            return try {
                val handlers = context.packageManager.queryIntentActivities(
                    intent,
                    PackageManager.GET_RESOLVED_FILTER
                )
                for (resolveInfo in handlers) {
                    val filter: IntentFilter = resolveInfo.filter ?: continue
                    if (filter.countDataAuthorities() == 0 || filter.countDataPaths() == 0) continue
                    if (resolveInfo.activityInfo == null) continue
                    return true
                }
                false
            } catch (error: RuntimeException) {
                Log.e(TAG, "Runtime exception while getting specialized handlers")
                false
            }
        }

        @JvmStatic
        fun getPackages(): Array<String> =
            arrayOf("", STABLE_PACKAGE, BETA_PACKAGE, DEV_PACKAGE, LOCAL_PACKAGE)
    }
}
