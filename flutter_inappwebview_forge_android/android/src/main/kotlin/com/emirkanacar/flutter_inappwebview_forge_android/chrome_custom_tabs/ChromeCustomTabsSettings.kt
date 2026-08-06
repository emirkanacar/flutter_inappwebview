package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import androidx.browser.customtabs.CustomTabsIntent
import androidx.browser.trusted.ScreenOrientation
import androidx.browser.trusted.TrustedWebActivityDisplayMode
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.AndroidResource
import java.util.HashMap

@Suppress("DEPRECATION")
class ChromeCustomTabsSettings : ISettings<ChromeCustomTabsActivity> {
    @JvmField
    @Deprecated("Use shareState instead.")
    var addDefaultShareMenuItem: Boolean? = null

    @JvmField
    var shareState: Int? = CustomTabsIntent.SHARE_STATE_DEFAULT

    @JvmField
    var showTitle: Boolean? = true

    @JvmField
    var toolbarBackgroundColor: String? = null

    @JvmField
    var navigationBarColor: String? = null

    @JvmField
    var navigationBarDividerColor: String? = null

    @JvmField
    var secondaryToolbarColor: String? = null

    @JvmField
    var enableUrlBarHiding: Boolean? = false

    @JvmField
    var instantAppsEnabled: Boolean? = false

    @JvmField
    var packageName: String? = null

    @JvmField
    var keepAliveEnabled: Boolean? = false

    @JvmField
    var isSingleInstance: Boolean? = false

    @JvmField
    var noHistory: Boolean? = false

    @JvmField
    var isTrustedWebActivity: Boolean? = false

    @JvmField
    var additionalTrustedOrigins: MutableList<String> = ArrayList()

    @JvmField
    var displayMode: TrustedWebActivityDisplayMode? = null

    @JvmField
    var screenOrientation: Int? = ScreenOrientation.DEFAULT

    @JvmField
    var startAnimations: MutableList<AndroidResource> = ArrayList()

    @JvmField
    var exitAnimations: MutableList<AndroidResource> = ArrayList()

    @JvmField
    var alwaysUseBrowserUI: Boolean? = false

    override fun parse(settings: MutableMap<String, Any?>): ChromeCustomTabsSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "addDefaultShareMenuItem" -> addDefaultShareMenuItem = value as? Boolean
                "shareState" -> shareState = (value as? Number)?.toInt()
                "showTitle" -> showTitle = value as? Boolean
                "toolbarBackgroundColor" -> toolbarBackgroundColor = value as? String
                "navigationBarColor" -> navigationBarColor = value as? String
                "navigationBarDividerColor" -> navigationBarDividerColor = value as? String
                "secondaryToolbarColor" -> secondaryToolbarColor = value as? String
                "enableUrlBarHiding" -> enableUrlBarHiding = value as? Boolean
                "instantAppsEnabled" -> instantAppsEnabled = value as? Boolean
                "packageName" -> packageName = value as? String
                "keepAliveEnabled" -> keepAliveEnabled = value as? Boolean
                "isSingleInstance" -> isSingleInstance = value as? Boolean
                "noHistory" -> noHistory = value as? Boolean
                "isTrustedWebActivity" -> isTrustedWebActivity = value as? Boolean
                "additionalTrustedOrigins" -> {
                    if (value is List<*>) {
                        additionalTrustedOrigins = value.filterIsInstance<String>().toMutableList()
                    }
                }
                "displayMode" -> displayMode = parseDisplayMode(value)
                "screenOrientation" -> screenOrientation = (value as? Number)?.toInt()
                "startAnimations" -> startAnimations = parseResources(value)
                "exitAnimations" -> exitAnimations = parseResources(value)
                "alwaysUseBrowserUI" -> alwaysUseBrowserUI = value as? Boolean
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("addDefaultShareMenuItem", addDefaultShareMenuItem)
        put("showTitle", showTitle)
        put("toolbarBackgroundColor", toolbarBackgroundColor)
        put("navigationBarColor", navigationBarColor)
        put("navigationBarDividerColor", navigationBarDividerColor)
        put("secondaryToolbarColor", secondaryToolbarColor)
        put("enableUrlBarHiding", enableUrlBarHiding)
        put("instantAppsEnabled", instantAppsEnabled)
        put("packageName", packageName)
        put("keepAliveEnabled", keepAliveEnabled)
        put("isSingleInstance", isSingleInstance)
        put("noHistory", noHistory)
        put("isTrustedWebActivity", isTrustedWebActivity)
        put("additionalTrustedOrigins", additionalTrustedOrigins)
        put("screenOrientation", screenOrientation)
        put("alwaysUseBrowserUI", alwaysUseBrowserUI)
    }

    override fun getRealSettings(obj: ChromeCustomTabsActivity): MutableMap<String, Any?> =
        toMap().apply {
            val intent = obj.intent
            put("packageName", intent?.`package`)
            put(
                "keepAliveEnabled",
                intent?.hasExtra(CustomTabsHelper.EXTRA_CUSTOM_TABS_KEEP_ALIVE) == true
            )
        }

    companion object {
        @JvmField
        val LOG_TAG = "ChromeCustomTabsSettings"
    }
}

private fun parseDisplayMode(value: Any?): TrustedWebActivityDisplayMode? {
    val displayModeMap = asStringObjectMap(value) ?: return null
    return when (displayModeMap["type"] as? String) {
        "IMMERSIVE_MODE" -> {
            val isSticky = displayModeMap["isSticky"] as? Boolean ?: false
            val cutoutMode = (displayModeMap["displayCutoutMode"] as? Number)?.toInt() ?: 0
            TrustedWebActivityDisplayMode.ImmersiveMode(isSticky, cutoutMode)
        }
        "DEFAULT_MODE" -> TrustedWebActivityDisplayMode.DefaultMode()
        else -> null
    }
}

private fun parseResources(value: Any?): MutableList<AndroidResource> {
    if (value !is List<*>) return ArrayList()
    return value.mapNotNull { AndroidResource.fromMap(asStringObjectMap(it)) }.toMutableList()
}

private fun asStringObjectMap(value: Any?): MutableMap<String, Any?>? {
    val source = value as? Map<*, *> ?: return null
    return HashMap<String, Any?>().apply {
        source.forEach { (key, entryValue) ->
            if (key is String) put(key, entryValue)
        }
    }
}
