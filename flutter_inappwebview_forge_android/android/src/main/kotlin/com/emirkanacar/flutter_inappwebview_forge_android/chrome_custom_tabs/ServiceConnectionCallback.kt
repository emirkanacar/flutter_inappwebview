package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import androidx.browser.customtabs.CustomTabsClient

/** Callback for events when connecting and disconnecting from Custom Tabs Service. */
interface ServiceConnectionCallback {
    fun onServiceConnected(client: CustomTabsClient)

    fun onServiceDisconnected()
}
