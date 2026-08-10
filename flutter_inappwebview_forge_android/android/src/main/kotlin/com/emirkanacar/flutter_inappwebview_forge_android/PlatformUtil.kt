@file:Suppress("DEPRECATION")

package com.emirkanacar.flutter_inappwebview_forge_android

import android.os.Build
import androidx.annotation.Nullable
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class PlatformUtil(plugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME)) {

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = plugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSystemVersion" -> result.success(Build.VERSION.SDK_INT.toString())
            "formatDate" -> {
                val date = call.argument<Long>("date")
                if (date == null) {
                    result.error("invalid_arguments", "The 'date' argument is required.", null)
                    return
                }
                val format = call.argument<String>("format")
                if (format == null) {
                    result.error("invalid_arguments", "The 'format' argument is required.", null)
                    return
                }
                val locale = getLocaleFromString(call.argument<String>("locale"))
                val timezone = call.argument<String>("timezone") ?: "UTC"
                result.success(formatDate(date, format, locale, TimeZone.getTimeZone(timezone)))
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }

    companion object {
        private const val LOG_TAG = "PlatformUtil"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_platformutil"

        @JvmStatic
        fun getLocaleFromString(@Nullable locale: String?): Locale {
            if (locale == null) {
                return Locale.US
            }
            val localeSplit = locale.split("_")
            val language = localeSplit[0]
            val country = if (localeSplit.size > 1) localeSplit[1] else ""
            val variant = if (localeSplit.size > 2) localeSplit[2] else ""
            return Locale(language, country, variant)
        }

        @JvmStatic
        fun formatDate(date: Long, format: String, locale: Locale, timezone: TimeZone): String {
            return SimpleDateFormat(format, locale).apply {
                timeZone = timezone
            }.format(Date(date))
        }
    }
}
