package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Browser
import androidx.browser.customtabs.CustomTabsCallback
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.customtabs.CustomTabsServiceConnection
import androidx.browser.customtabs.CustomTabsSession
import androidx.browser.trusted.TrustedWebActivityIntent

open class CustomTabActivityHelper : ServiceConnectionCallback {
    private var mCustomTabsSession: CustomTabsSession? = null
    private var mClient: CustomTabsClient? = null
    private var mConnection: CustomTabsServiceConnection? = null
    private var mConnectionCallback: ConnectionCallback? = null
    private var mCustomTabsCallback: CustomTabsCallback? = null

    companion object {
        @JvmStatic
        fun openCustomTab(
            activity: Activity,
            intent: Intent,
            uri: Uri,
            headers: Map<String, String>?,
            referrer: Uri?,
            requestCode: Int
        ) {
            intent.data = uri
            if (headers != null) {
                val bundleHeaders = Bundle()
                for ((key, value) in headers) {
                    bundleHeaders.putString(key, value)
                }
                intent.putExtra(Browser.EXTRA_HEADERS, bundleHeaders)
            }
            if (referrer != null) {
                intent.putExtra(Intent.EXTRA_REFERRER, referrer)
            }
            activity.startActivityForResult(intent, requestCode)
        }

        @JvmStatic
        fun openCustomTab(
            activity: Activity,
            customTabsIntent: CustomTabsIntent,
            uri: Uri,
            headers: Map<String, String>?,
            referrer: Uri?,
            requestCode: Int
        ) {
            openCustomTab(activity, customTabsIntent.intent, uri, headers, referrer, requestCode)
        }

        @JvmStatic
        fun openTrustedWebActivity(
            activity: Activity,
            trustedWebActivityIntent: TrustedWebActivityIntent,
            uri: Uri,
            headers: Map<String, String>?,
            referrer: Uri?,
            requestCode: Int
        ) {
            openCustomTab(
                activity,
                trustedWebActivityIntent.intent,
                uri,
                headers,
                referrer,
                requestCode
            )
        }

        @JvmStatic
        fun isAvailable(activity: Activity): Boolean =
            CustomTabsHelper.getPackageNameToUse(activity) != null
    }

    fun unbindCustomTabsService(activity: Activity) {
        val connection = mConnection ?: return
        activity.unbindService(connection)
        mClient = null
        mCustomTabsSession = null
        mConnection = null
    }

    fun getSession(): CustomTabsSession? {
        val client = mClient
        if (client == null) {
            mCustomTabsSession = null
        } else if (mCustomTabsSession == null) {
            mCustomTabsSession = client.newSession(mCustomTabsCallback)
        }
        return mCustomTabsSession
    }

    fun setConnectionCallback(connectionCallback: ConnectionCallback) {
        mConnectionCallback = connectionCallback
    }

    fun setCustomTabsCallback(customTabsCallback: CustomTabsCallback) {
        mCustomTabsCallback = customTabsCallback
    }

    fun bindCustomTabsService(activity: Activity): Boolean {
        if (mClient != null) return true
        val packageName = CustomTabsHelper.getPackageNameToUse(activity) ?: return false
        val connection = ServiceConnection(this)
        mConnection = connection
        return CustomTabsClient.bindCustomTabsService(activity, packageName, connection)
    }

    fun mayLaunchUrl(uri: Uri, extras: Bundle?, otherLikelyBundles: List<Bundle>?): Boolean {
        if (mClient == null) return false
        val session = getSession() ?: return false
        return session.mayLaunchUrl(uri, extras, otherLikelyBundles)
    }

    override fun onServiceConnected(client: CustomTabsClient) {
        mClient = client
        client.warmup(0L)
        mConnectionCallback?.onCustomTabsConnected()
    }

    override fun onServiceDisconnected() {
        mClient = null
        mCustomTabsSession = null
        mConnectionCallback?.onCustomTabsDisconnected()
    }

    interface ConnectionCallback {
        fun onCustomTabsConnected()
        fun onCustomTabsDisconnected()
    }
}
