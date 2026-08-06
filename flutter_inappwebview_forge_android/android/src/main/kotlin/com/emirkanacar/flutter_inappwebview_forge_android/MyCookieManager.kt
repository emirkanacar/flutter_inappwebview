package com.emirkanacar.flutter_inappwebview_forge_android

import android.os.Build
import android.util.Log
import android.webkit.CookieManager
import android.webkit.CookieSyncManager
import android.webkit.ValueCallback
import androidx.webkit.CookieManagerCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.Arrays
import java.util.Date
import java.util.HashMap
import java.util.Locale
import java.util.TimeZone

open class MyCookieManager(initialPlugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(
        MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
    ) {
    companion object {
        @JvmField
        protected val LOG_TAG = "MyCookieManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_cookiemanager"

        @JvmField
        var cookieManager: CookieManager? = null

        @JvmStatic
        fun init() {
            if (cookieManager == null) {
                cookieManager = getCookieManager()
            }
        }

        private fun getCookieManager(): CookieManager? {
            if (cookieManager == null) {
                try {
                    cookieManager = CookieManager.getInstance()
                } catch (_: IllegalArgumentException) {
                    return null
                } catch (exception: Exception) {
                    val message = exception.message
                    val canonicalName = exception::class.java.canonicalName
                    if (message != null &&
                        canonicalName == "android.webkit.WebViewFactory.MissingWebViewPackageException"
                    ) {
                        return null
                    }
                    throw exception
                }
            }
            return cookieManager
        }

        @JvmStatic
        fun getCookieExpirationDate(timestamp: Long?): String {
            val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("GMT")
            return sdf.format(Date(timestamp ?: 0L))
        }
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        init()
        when (call.method) {
            "setCookie" -> {
                val url = call.argument<String>("url")
                val name = call.argument<String>("name")
                val value = call.argument<String>("value")
                val path = call.argument<String>("path")
                if (url == null || name == null || value == null || path == null) {
                    result.error("invalid_arguments", "url, name, value, and path are required.", null)
                    return
                }
                val expiresDate = call.argument<String>("expiresDate")?.toLongOrNull()
                setCookie(
                    url,
                    name,
                    value,
                    call.argument<String>("domain"),
                    path,
                    expiresDate,
                    call.argument<Int>("maxAge"),
                    call.argument<Boolean>("isSecure"),
                    call.argument<Boolean>("isHttpOnly"),
                    call.argument<String>("sameSite"),
                    result
                )
            }
            "getCookies" -> {
                val url = call.argument<String>("url")
                if (url == null) {
                    result.error("invalid_arguments", "url is required.", null)
                    return
                }
                result.success(getCookies(url))
            }
            "deleteCookie" -> {
                val url = call.argument<String>("url")
                val name = call.argument<String>("name")
                val path = call.argument<String>("path")
                if (url == null || name == null || path == null) {
                    result.error("invalid_arguments", "url, name, and path are required.", null)
                    return
                }
                deleteCookie(url, name, call.argument<String>("domain"), path, result)
            }
            "deleteCookies" -> {
                val url = call.argument<String>("url")
                val path = call.argument<String>("path")
                if (url == null || path == null) {
                    result.error("invalid_arguments", "url and path are required.", null)
                    return
                }
                deleteCookies(url, call.argument<String>("domain"), path, result)
            }
            "deleteAllCookies" -> deleteAllCookies(result)
            "removeSessionCookies" -> removeSessionCookies(result)
            "flush" -> flush(result)
            else -> result.notImplemented()
        }
    }

    fun setCookie(
        url: String,
        name: String,
        value: String,
        domain: String?,
        path: String,
        expiresDate: Long?,
        maxAge: Int?,
        isSecure: Boolean?,
        isHttpOnly: Boolean?,
        sameSite: String?,
        result: MethodChannel.Result
    ) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }

        var cookieValue = "$name=$value; Path=$path"
        if (domain != null) cookieValue += "; Domain=$domain"
        if (expiresDate != null) cookieValue += "; Expires=${getCookieExpirationDate(expiresDate)}"
        if (maxAge != null) cookieValue += "; Max-Age=$maxAge"
        if (isSecure == true) cookieValue += "; Secure"
        if (isHttpOnly == true) cookieValue += "; HttpOnly"
        if (sameSite != null) cookieValue += "; SameSite=$sameSite"
        cookieValue += ";"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            manager.setCookie(url, cookieValue, ValueCallback<Boolean> { successful ->
                result.success(successful)
            })
            manager.flush()
        } else {
            val context = plugin?.applicationContext
            if (context != null) {
                val cookieSyncManager = CookieSyncManager.createInstance(context)
                cookieSyncManager.startSync()
                manager.setCookie(url, cookieValue)
                cookieSyncManager.stopSync()
                cookieSyncManager.sync()
            } else {
                manager.setCookie(url, cookieValue)
            }
            result.success(true)
        }
    }

    fun getCookies(url: String): MutableList<MutableMap<String, Any?>> {
        val cookieListMap = mutableListOf<MutableMap<String, Any?>>()
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) return cookieListMap

        val cookies: List<String> = if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_COOKIE_INFO)) {
            CookieManagerCompat.getCookieInfo(manager, url)
        } else {
            manager.getCookie(url)?.split(";") ?: emptyList()
        }

        for (cookie in cookies) {
            val cookieParams = cookie.split(";")
            if (cookieParams.isEmpty()) continue

            val nameValue = cookieParams[0].split("=", limit = 2)
            val name = nameValue[0].trim()
            val value = nameValue.getOrNull(1)?.trim() ?: ""
            val cookieMap = HashMap<String, Any?>()
            cookieMap["name"] = name
            cookieMap["value"] = value
            cookieMap["expiresDate"] = null
            cookieMap["isSessionOnly"] = null
            cookieMap["domain"] = null
            cookieMap["sameSite"] = null
            cookieMap["isSecure"] = null
            cookieMap["isHttpOnly"] = null
            cookieMap["path"] = null

            if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_COOKIE_INFO)) {
                cookieMap["isSecure"] = false
                cookieMap["isHttpOnly"] = false
                for (i in 1 until cookieParams.size) {
                    val cookieParamNameValue = cookieParams[i].split("=", limit = 2)
                    val cookieParamName = cookieParamNameValue[0].trim()
                    val cookieParamValue = cookieParamNameValue.getOrNull(1)?.trim() ?: ""
                    when {
                        cookieParamName.equals("Expires", ignoreCase = true) -> {
                            try {
                                val sdf = SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US)
                                sdf.parse(cookieParamValue)?.let { cookieMap["expiresDate"] = it.time }
                            } catch (error: ParseException) {
                                Log.e(LOG_TAG, "", error)
                            }
                        }
                        cookieParamName.equals("Max-Age", ignoreCase = true) -> {
                            try {
                                val maxAge = cookieParamValue.toLong()
                                cookieMap["expiresDate"] = System.currentTimeMillis() + maxAge
                            } catch (error: NumberFormatException) {
                                Log.e(LOG_TAG, "", error)
                            }
                        }
                        cookieParamName.equals("Domain", ignoreCase = true) -> cookieMap["domain"] = cookieParamValue
                        cookieParamName.equals("SameSite", ignoreCase = true) -> cookieMap["sameSite"] = cookieParamValue
                        cookieParamName.equals("Secure", ignoreCase = true) -> cookieMap["isSecure"] = true
                        cookieParamName.equals("HttpOnly", ignoreCase = true) -> cookieMap["isHttpOnly"] = true
                        cookieParamName.equals("Path", ignoreCase = true) -> cookieMap["path"] = cookieParamValue
                    }
                }
            }
            cookieListMap.add(cookieMap)
        }
        return cookieListMap
    }

    fun deleteCookie(
        url: String,
        name: String,
        domain: String?,
        path: String,
        result: MethodChannel.Result
    ) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }

        var cookieValue = "$name=; Path=$path; Max-Age=-1"
        if (domain != null) cookieValue += "; Domain=$domain"
        cookieValue += ";"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            manager.setCookie(url, cookieValue, ValueCallback<Boolean> { successful ->
                result.success(successful)
            })
            manager.flush()
        } else {
            val context = plugin?.applicationContext
            if (context != null) {
                val cookieSyncManager = CookieSyncManager.createInstance(context)
                cookieSyncManager.startSync()
                manager.setCookie(url, cookieValue)
                cookieSyncManager.stopSync()
                cookieSyncManager.sync()
            } else {
                manager.setCookie(url, cookieValue)
            }
            result.success(true)
        }
    }

    fun deleteCookies(url: String, domain: String?, path: String, result: MethodChannel.Result) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }

        var cookieSyncManager: CookieSyncManager? = null
        val cookiesString = manager.getCookie(url)
        if (cookiesString != null) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                plugin?.applicationContext?.let { context ->
                    cookieSyncManager = CookieSyncManager.createInstance(context)
                    cookieSyncManager?.startSync()
                }
            }

            for (cookie in cookiesString.split(";")) {
                val name = cookie.split("=", limit = 2)[0].trim()
                var cookieValue = "$name=; Path=$path; Max-Age=-1"
                if (domain != null) cookieValue += "; Domain=$domain"
                cookieValue += ";"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    manager.setCookie(url, cookieValue, null)
                } else {
                    manager.setCookie(url, cookieValue)
                }
            }

            if (cookieSyncManager != null) {
                cookieSyncManager?.stopSync()
                cookieSyncManager?.sync()
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                manager.flush()
            }
        }
        result.success(true)
    }

    fun deleteAllCookies(result: MethodChannel.Result) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            manager.removeAllCookies(ValueCallback<Boolean> { successful -> result.success(successful) })
            manager.flush()
        } else {
            val context = plugin?.applicationContext
            if (context != null) {
                val cookieSyncManager = CookieSyncManager.createInstance(context)
                cookieSyncManager.startSync()
                manager.removeAllCookie()
                cookieSyncManager.stopSync()
                cookieSyncManager.sync()
            } else {
                manager.removeAllCookie()
            }
            result.success(true)
        }
    }

    fun removeSessionCookies(result: MethodChannel.Result) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            manager.removeSessionCookies(ValueCallback<Boolean> { successful -> result.success(successful) })
            manager.flush()
        } else {
            val context = plugin?.applicationContext
            if (context != null) {
                val cookieSyncManager = CookieSyncManager.createInstance(context)
                cookieSyncManager.startSync()
                manager.removeSessionCookie()
                cookieSyncManager.stopSync()
                cookieSyncManager.sync()
            } else {
                manager.removeSessionCookie()
            }
            result.success(true)
        }
    }

    fun flush(result: MethodChannel.Result) {
        val manager = getCookieManager()
        cookieManager = manager
        if (manager == null) {
            result.success(false)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            manager.flush()
        } else {
            plugin?.applicationContext?.let { context ->
                CookieSyncManager.createInstance(context).sync()
            }
        }
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }
}
