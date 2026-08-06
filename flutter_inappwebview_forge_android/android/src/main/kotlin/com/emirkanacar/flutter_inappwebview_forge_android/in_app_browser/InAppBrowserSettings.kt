package com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser

import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import com.emirkanacar.flutter_inappwebview_forge_android.R
import java.util.HashMap

class InAppBrowserSettings : ISettings<InAppBrowserActivity> {
    @JvmField
    var hidden: Boolean? = false

    @JvmField
    var hideToolbarTop: Boolean? = false

    @JvmField
    var toolbarTopBackgroundColor: String? = null

    @JvmField
    var toolbarTopFixedTitle: String? = null

    @JvmField
    var hideUrlBar: Boolean? = false

    @JvmField
    var hideProgressBar: Boolean? = false

    @JvmField
    var hideTitleBar: Boolean? = false

    @JvmField
    var closeOnCannotGoBack: Boolean? = true

    @JvmField
    var allowGoBackWithBackButton: Boolean? = true

    @JvmField
    var shouldCloseOnBackButtonPressed: Boolean? = false

    @JvmField
    var hideDefaultMenuItems: Boolean? = false

    override fun parse(settings: MutableMap<String, Any?>): InAppBrowserSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "hidden" -> hidden = value as? Boolean
                "hideToolbarTop" -> hideToolbarTop = value as? Boolean
                "toolbarTopBackgroundColor" -> toolbarTopBackgroundColor = value as? String
                "toolbarTopFixedTitle" -> toolbarTopFixedTitle = value as? String
                "hideUrlBar" -> hideUrlBar = value as? Boolean
                "hideTitleBar" -> hideTitleBar = value as? Boolean
                "closeOnCannotGoBack" -> closeOnCannotGoBack = value as? Boolean
                "hideProgressBar" -> hideProgressBar = value as? Boolean
                "allowGoBackWithBackButton" -> allowGoBackWithBackButton = value as? Boolean
                "shouldCloseOnBackButtonPressed" -> shouldCloseOnBackButtonPressed = value as? Boolean
                "hideDefaultMenuItems" -> hideDefaultMenuItems = value as? Boolean
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("hidden", hidden)
        put("hideToolbarTop", hideToolbarTop)
        put("toolbarTopBackgroundColor", toolbarTopBackgroundColor)
        put("toolbarTopFixedTitle", toolbarTopFixedTitle)
        put("hideUrlBar", hideUrlBar)
        put("hideTitleBar", hideTitleBar)
        put("closeOnCannotGoBack", closeOnCannotGoBack)
        put("hideProgressBar", hideProgressBar)
        put("allowGoBackWithBackButton", allowGoBackWithBackButton)
        put("shouldCloseOnBackButtonPressed", shouldCloseOnBackButtonPressed)
        put("hideDefaultMenuItems", hideDefaultMenuItems)
    }

    override fun getRealSettings(obj: InAppBrowserActivity): MutableMap<String, Any?> =
        toMap().apply {
            put("hidden", obj.isHidden)
            put("hideToolbarTop", obj.actionBar?.isShowing != true)
            put("hideUrlBar", obj.menu?.findItem(R.id.menu_search)?.isVisible != true)
            put("hideProgressBar", obj.progressBar?.max?.let { it == 0 } ?: true)
        }

    companion object {
        @JvmField
        val LOG_TAG = "InAppBrowserSettings"
    }
}
