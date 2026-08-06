package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.content.ComponentName
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsServiceConnection
import java.lang.ref.WeakReference

/**
 * Implementation for the CustomTabsServiceConnection that avoids leaking the
 * ServiceConnectionCallback.
 */
open class ServiceConnection(
    connectionCallback: ServiceConnectionCallback
) : CustomTabsServiceConnection() {
    private val connectionCallback = WeakReference(connectionCallback)

    override fun onCustomTabsServiceConnected(name: ComponentName, client: CustomTabsClient) {
        connectionCallback.get()?.onServiceConnected(client)
    }

    override fun onServiceDisconnected(name: ComponentName) {
        connectionCallback.get()?.onServiceDisconnected()
    }
}
