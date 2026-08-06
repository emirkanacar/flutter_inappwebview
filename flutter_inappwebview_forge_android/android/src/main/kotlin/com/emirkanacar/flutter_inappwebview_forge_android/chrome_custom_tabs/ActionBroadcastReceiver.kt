package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.browser.customtabs.CustomTabsIntent

open class ActionBroadcastReceiver : BroadcastReceiver() {
    companion object {
        @JvmField
        protected val LOG_TAG: String = "ActionBroadcastReceiver"

        @JvmField
        val KEY_ACTION_ID: String =
            "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_ID"

        @JvmField
        val KEY_ACTION_VIEW_ID: String =
            "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_VIEW_ID"

        @JvmField
        val KEY_ACTION_MANAGER_ID: String =
            "com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs.ACTION_MANAGER_ID"

        @JvmField
        val KEY_URL_TITLE: String = "android.intent.extra.SUBJECT"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val clickedId = intent.getIntExtra(CustomTabsIntent.EXTRA_REMOTEVIEWS_CLICKED_ID, -1)
        val url = intent.getDataString() ?: return
        val bundle = intent.extras ?: return
        val viewId = bundle.getString(KEY_ACTION_VIEW_ID)
        val managerId = bundle.getString(KEY_ACTION_MANAGER_ID)
        val manager = managerId?.let { ChromeSafariBrowserManager.shared[it] } ?: return

        if (clickedId == -1) {
            val id = bundle.getInt(KEY_ACTION_ID)
            val title = bundle.getString(KEY_URL_TITLE)
            val browser = viewId?.let { manager.browsers[it] }
            browser?.channelDelegate?.onItemActionPerform(id, url, title)
        } else {
            val browser = viewId?.let { manager.browsers[it] }
            browser?.channelDelegate?.onSecondaryItemActionPerform(
                browser.resources.getResourceName(clickedId),
                url
            )
        }
    }
}
