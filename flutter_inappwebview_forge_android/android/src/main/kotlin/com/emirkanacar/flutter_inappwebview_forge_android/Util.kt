package com.emirkanacar.flutter_inappwebview_forge_android

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Insets
import android.graphics.Rect
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.http.SslCertificate
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowInsets
import android.view.WindowManager
import android.view.WindowMetrics
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.types.Size2D
import com.emirkanacar.flutter_inappwebview_forge_android.types.SyncBaseCallbackResultImpl
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.lang.reflect.InvocationTargetException
import java.net.HttpURLConnection
import java.net.Inet6Address
import java.net.InetAddress
import java.net.URL
import java.security.Key
import java.security.KeyStore
import java.security.PrivateKey
import java.security.cert.Certificate
import java.security.cert.CertificateException
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.HashMap
import java.util.Objects
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern
import javax.net.ssl.SSLHandshakeException
import org.json.JSONArray
import org.json.JSONObject

class Util private constructor() {
    companion object {
        @JvmField
        val LOG_TAG = "Util"

        @JvmField
        val ANDROID_ASSET_URL = "file:///android_asset/"

        private const val SYNC_METHOD_CHANNEL_TIMEOUT_MILLIS = 500L
        private const val MAX_CONCURRENT_SYNC_METHOD_CHANNEL_CALLS = 4
        private val mainLooperHandler = Handler(Looper.getMainLooper())
        private val synchronousMethodChannelCallsInFlight = AtomicInteger(0)

        @JvmStatic
        @Throws(IOException::class)
        fun getUrlAsset(plugin: InAppWebViewFlutterPlugin, assetFilePath: String): String {
            val key = assetPath(plugin, assetFilePath)
            getFileAsset(plugin, assetFilePath).use { }
            return ANDROID_ASSET_URL + key
        }

        @JvmStatic
        @Throws(IOException::class)
        fun getFileAsset(plugin: InAppWebViewFlutterPlugin, assetFilePath: String): InputStream {
            val key = assetPath(plugin, assetFilePath)
            val context = plugin.applicationContext
                ?: throw IOException("Application context is not available.")
            return context.resources.assets.open(key)
        }

        private fun assetPath(plugin: InAppWebViewFlutterPlugin, assetFilePath: String): String {
            val assets = plugin.flutterAssets
                ?: throw IllegalStateException("Flutter assets are not available outside the engine lifecycle.")
            return assets.getAssetFilePathByName(assetFilePath)
        }

        @JvmStatic
        @Throws(InterruptedException::class)
        fun <T> invokeMethodAndWaitResult(
            channel: MethodChannel,
            method: String,
            arguments: Any?,
            callback: SyncBaseCallbackResultImpl<T>,
            timeoutMillis: Long = SYNC_METHOD_CHANNEL_TIMEOUT_MILLIS
        ): T? {
            if (Looper.myLooper() == Looper.getMainLooper()) {
                channel.invokeMethod(method, arguments, callback)
                return null
            }

            if (
                synchronousMethodChannelCallsInFlight.incrementAndGet() >
                MAX_CONCURRENT_SYNC_METHOD_CHANNEL_CALLS
            ) {
                synchronousMethodChannelCallsInFlight.decrementAndGet()
                Log.w(
                    LOG_TAG,
                    "Too many synchronous method channel callbacks are pending; " +
                        "returning the default response for $method"
                )
                return null
            }

            try {
                if (!mainLooperHandler.post {
                        channel.invokeMethod(method, arguments, callback)
                    }
                ) {
                    Log.w(LOG_TAG, "Unable to dispatch synchronous method channel callback: $method")
                    return null
                }
                if (!callback.latch.await(
                        timeoutMillis,
                        TimeUnit.MILLISECONDS
                    )
                ) {
                    Log.w(LOG_TAG, "Timed out waiting for synchronous method channel callback: $method")
                }
                return callback.result
            } finally {
                synchronousMethodChannelCallsInFlight.decrementAndGet()
            }
        }

        @JvmStatic
        fun loadPrivateKeyAndCertificate(
            plugin: InAppWebViewFlutterPlugin,
            certificatePath: String,
            certificatePassword: String?,
            keyStoreType: String
        ): PrivateKeyAndCertificates? {
            var certificateFileStream: InputStream? = null
            try {
                certificateFileStream = try {
                    getFileAsset(plugin, certificatePath)
                } catch (_: IOException) {
                    null
                }
                if (certificateFileStream == null) {
                    certificateFileStream = FileInputStream(certificatePath)
                }

                val password = (certificatePassword ?: "").toCharArray()
                val keyStore = KeyStore.getInstance(keyStoreType)
                keyStore.load(certificateFileStream, password)
                val aliases = keyStore.aliases()
                val alias = aliases.nextElement()
                val key: Key? = keyStore.getKey(alias, password)
                if (key is PrivateKey) {
                    val certificate = keyStore.getCertificate(alias) as X509Certificate
                    return PrivateKeyAndCertificates(key, arrayOf(certificate))
                }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "", e)
            } finally {
                try {
                    certificateFileStream?.close()
                } catch (e: IOException) {
                    Log.e(LOG_TAG, "", e)
                }
            }
            return null
        }

        @JvmStatic
        fun makeHttpRequest(
            urlString: String,
            method: String,
            headers: Map<String, String>?
        ): HttpURLConnection? {
            var urlConnection: HttpURLConnection? = null
            try {
                urlConnection = URL(urlString).openConnection() as HttpURLConnection
                urlConnection.requestMethod = method
                headers?.forEach { (key, value) ->
                    urlConnection.setRequestProperty(key, value)
                }
                urlConnection.connectTimeout = 15000
                urlConnection.readTimeout = 15000
                urlConnection.doInput = true
                urlConnection.instanceFollowRedirects = true
                if (method.equals("GET", ignoreCase = true)) {
                    urlConnection.doOutput = false
                }
                urlConnection.connect()
                return urlConnection
            } catch (e: Exception) {
                if (e !is SSLHandshakeException) {
                    Log.e(LOG_TAG, "", e)
                }
                urlConnection?.disconnect()
            }
            return null
        }

        @JvmStatic
        fun getX509CertFromSslCertHack(sslCert: SslCertificate): X509Certificate? {
            val bundle: Bundle = SslCertificate.saveState(sslCert)
            val bytes = bundle.getByteArray("x509-certificate") ?: return null
            return try {
                val certFactory = CertificateFactory.getInstance("X.509")
                certFactory.generateCertificate(ByteArrayInputStream(bytes)) as X509Certificate
            } catch (_: CertificateException) {
                null
            }
        }

        @JvmStatic
        @RequiresApi(Build.VERSION_CODES.KITKAT)
        @Suppress("UNCHECKED_CAST")
        fun JSONStringify(value: Any?): String {
            return when (value) {
                null -> "null"
                is Map<*, *> -> JSONObject(value as Map<String, Any?>).toString()
                is List<*> -> JSONArray(value as List<Any?>).toString()
                is String -> JSONObject.quote(value)
                else -> JSONObject.wrap(value)?.toString() ?: "null"
            }
        }

        @JvmStatic
        fun objEquals(a: Any?, b: Any?): Boolean {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                Objects.equals(a, b)
            } else {
                a === b || (a != null && a == b)
            }
        }

        @JvmStatic
        fun replaceAll(s: String, oldString: String, newString: String): String {
            return TextUtils.join(newString, s.split(Pattern.quote(oldString).toRegex()))
        }

        @JvmStatic
        fun log(tag: String, message: String) {
            var index = 0
            val length = message.length
            while (index < length) {
                val newline = message.indexOf('\n', index).let { if (it == -1) length else it }
                do {
                    val end = minOf(newline, index + 4000)
                    Log.d(tag, message.substring(index, end))
                    index = end
                } while (index < newline)
            }
        }

        @JvmStatic
        fun getPixelDensity(context: Context): Float =
            context.resources.displayMetrics.density

        @JvmStatic
        fun getFullscreenSize(context: Context): Size2D {
            val fullscreenSize = Size2D(-1.0, -1.0)
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            if (windowManager != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val metrics: WindowMetrics = windowManager.currentWindowMetrics
                    val windowInsets = metrics.windowInsets
                    val insets: Insets = windowInsets.getInsetsIgnoringVisibility(
                        WindowInsets.Type.navigationBars() or WindowInsets.Type.displayCutout()
                    )
                    val bounds: Rect = metrics.bounds
                    fullscreenSize.width =
                        (bounds.width() - insets.right - insets.left).toDouble()
                    fullscreenSize.height =
                        (bounds.height() - insets.top - insets.bottom).toDouble()
                } else {
                    val displayMetrics = DisplayMetrics()
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay.getMetrics(displayMetrics)
                    fullscreenSize.width = displayMetrics.widthPixels.toDouble()
                    fullscreenSize.height = displayMetrics.heightPixels.toDouble()
                }
            }
            return fullscreenSize
        }

        @JvmStatic
        fun isClass(className: String): Boolean = try {
            Class.forName(className)
            true
        } catch (_: ClassNotFoundException) {
            false
        }

        @JvmStatic
        fun isIPv6(address: String): Boolean = try {
            Inet6Address.getByName(address)
            true
        } catch (_: java.net.UnknownHostException) {
            false
        }

        @JvmStatic
        @Throws(Exception::class)
        fun normalizeIPv6(address: String): String {
            if (!isIPv6(address)) {
                throw Exception("Invalid address: $address")
            }
            return InetAddress.getByName(address).canonicalHostName
        }

        @JvmStatic
        @Suppress("UNCHECKED_CAST")
        fun <T> getOrDefault(map: Map<String, Any?>, key: String, defaultValue: T): T =
            if (map.containsKey(key)) map[key] as T else defaultValue

        @JvmStatic
        fun readAllBytes(inputStream: InputStream?): ByteArray? {
            val stream = inputStream ?: return null
            return try {
                stream.use { source ->
                    ByteArrayOutputStream().use { output ->
                        source.copyTo(output, 4 * 0x400)
                        output.toByteArray()
                    }
                }
            } catch (_: IOException) {
                null
            }
        }

        @JvmStatic
        fun <O> invokeMethodIfExists(o: O?, methodName: String, vararg args: Any?): Any? {
            val target = o ?: return null
            for (method in target::class.java.methods) {
                if (method.name == methodName) {
                    try {
                        return method.invoke(target, *args)
                    } catch (_: IllegalAccessException) {
                        return null
                    } catch (_: InvocationTargetException) {
                        return null
                    }
                }
            }
            return null
        }

        @JvmStatic
        fun drawableFromBytes(context: Context, data: ByteArray): Drawable =
            BitmapDrawable(
                context.resources,
                BitmapFactory.decodeByteArray(data, 0, data.size)
            )
    }

    class PrivateKeyAndCertificates(
        @JvmField val privateKey: PrivateKey,
        @JvmField val certificates: Array<X509Certificate>
    )
}
