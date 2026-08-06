package com.emirkanacar.flutter_inappwebview_forge_android.service_worker

import android.os.Build
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import androidx.annotation.RequiresApi
import androidx.webkit.ServiceWorkerClientCompat
import androidx.webkit.ServiceWorkerControllerCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceResponseExt

@RequiresApi(api = Build.VERSION_CODES.N)
open class ServiceWorkerManager(initialPlugin: InAppWebViewFlutterPlugin) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG = "ServiceWorkerManager"

        @JvmField
        val METHOD_CHANNEL_NAME =
            "com.emirkanacar/flutter_inappwebview_serviceworkercontroller"

        @JvmField
        var serviceWorkerController: ServiceWorkerControllerCompat? = null

        @JvmStatic
        fun init() {
            if (serviceWorkerController == null &&
                WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE)
            ) {
                serviceWorkerController = ServiceWorkerControllerCompat.getInstance()
            }
        }
    }

    @JvmField
    var channelDelegate: ServiceWorkerChannelDelegate? = null

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    init {
        val channel = io.flutter.plugin.common.MethodChannel(
            initialPlugin.requireMessenger(),
            METHOD_CHANNEL_NAME
        )
        channelDelegate = ServiceWorkerChannelDelegate(this, channel)
    }

    fun setServiceWorkerClient(isNull: Boolean?) {
        val controller = serviceWorkerController ?: return
        controller.setServiceWorkerClient(
            if (isNull == true) {
                dummyServiceWorkerClientCompat()
            } else {
                object : ServiceWorkerClientCompat() {
                    override fun shouldInterceptRequest(request: WebResourceRequest): WebResourceResponse? {
                        val requestExt = WebResourceRequestExt.fromWebResourceRequest(request)
                        val response = try {
                            channelDelegate?.shouldInterceptRequest(requestExt)
                        } catch (error: InterruptedException) {
                            Log.e(LOG_TAG, "", error)
                            return null
                        }

                        if (response == null) {
                            return null
                        }

                        val inputStream = response.data?.let { java.io.ByteArrayInputStream(it) }
                        val statusCode = response.statusCode
                        val reasonPhrase = response.reasonPhrase
                        return if (statusCode != null && reasonPhrase != null) {
                            WebResourceResponse(
                                response.contentType,
                                response.contentEncoding,
                                statusCode,
                                reasonPhrase,
                                response.headers,
                                inputStream
                            )
                        } else {
                            WebResourceResponse(
                                response.contentType,
                                response.contentEncoding,
                                inputStream
                            )
                        }
                    }
                }
            }
        )
    }

    private fun dummyServiceWorkerClientCompat(): ServiceWorkerClientCompat =
        DummyServiceWorkerClientCompat()

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        plugin = null
    }

    private class DummyServiceWorkerClientCompat : ServiceWorkerClientCompat() {
        override fun shouldInterceptRequest(request: WebResourceRequest): WebResourceResponse? = null
    }
}
