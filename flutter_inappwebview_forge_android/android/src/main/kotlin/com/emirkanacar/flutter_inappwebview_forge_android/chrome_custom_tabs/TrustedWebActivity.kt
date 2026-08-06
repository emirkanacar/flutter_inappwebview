package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.trusted.TrustedWebActivityIntent
import androidx.browser.trusted.TrustedWebActivityIntentBuilder

open class TrustedWebActivity : ChromeCustomTabsActivity() {
    companion object {
        @JvmField
        protected val LOG_TAG = "TrustedWebActivity"
    }

    @JvmField
    var trustedWebActivityBuilder: TrustedWebActivityIntentBuilder? = null

    override fun launchUrl(
        url: String,
        headers: Map<String, String>?,
        referrer: String?,
        otherLikelyURLs: List<String>?
    ) {
        val session = customTabsSession ?: return
        val uri = Uri.parse(url)

        mayLaunchUrl(url, otherLikelyURLs)
        val trustedWebActivityBuilder = TrustedWebActivityIntentBuilder(uri)
        this.trustedWebActivityBuilder = trustedWebActivityBuilder
        prepareCustomTabs()

        val trustedWebActivityIntent = trustedWebActivityBuilder.build(session)
        prepareCustomTabsIntent(trustedWebActivityIntent)

        CustomTabActivityHelper.openTrustedWebActivity(
            this,
            trustedWebActivityIntent,
            uri,
            headers,
            referrer?.let(Uri::parse),
            CHROME_CUSTOM_TAB_REQUEST_CODE
        )
    }

    private fun prepareCustomTabs() {
        val currentBuilder = trustedWebActivityBuilder ?: return
        val defaultColorSchemeBuilder = CustomTabColorSchemeParams.Builder()

        customSettings.toolbarBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
            defaultColorSchemeBuilder.setToolbarColor(Color.parseColor(it))
        }
        customSettings.navigationBarColor?.takeIf { it.isNotEmpty() }?.let {
            defaultColorSchemeBuilder.setNavigationBarColor(Color.parseColor(it))
        }
        customSettings.navigationBarDividerColor?.takeIf { it.isNotEmpty() }?.let {
            defaultColorSchemeBuilder.setNavigationBarDividerColor(Color.parseColor(it))
        }
        customSettings.secondaryToolbarColor?.takeIf { it.isNotEmpty() }?.let {
            defaultColorSchemeBuilder.setSecondaryToolbarColor(Color.parseColor(it))
        }
        currentBuilder.setDefaultColorSchemeParams(defaultColorSchemeBuilder.build())

        customSettings.additionalTrustedOrigins
            ?.takeIf { it.isNotEmpty() }
            ?.let(currentBuilder::setAdditionalTrustedOrigins)

        customSettings.displayMode?.let(currentBuilder::setDisplayMode)
        customSettings.screenOrientation?.let(currentBuilder::setScreenOrientation)
    }

    private fun prepareCustomTabsIntent(trustedWebActivityIntent: TrustedWebActivityIntent) {
        val intent: Intent = trustedWebActivityIntent.intent
        customSettings.packageName?.let {
            intent.setPackage(it)
        } ?: intent.setPackage(CustomTabsHelper.getPackageNameToUse(this))

        if (customSettings.keepAliveEnabled == true) {
            CustomTabsHelper.addKeepAliveExtra(this, intent)
        }

        if (customSettings.alwaysUseBrowserUI == true) {
            CustomTabsIntent.setAlwaysUseBrowserUI(intent)
        }
    }
}
