package com.emirkanacar.flutter_inappwebview_forge_android.container

import androidx.webkit.ProfileStore
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Bridges AndroidX WebKit's persistent ProfileStore to the Dart API. */
open class ContainerManager(initialPlugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)) {
    companion object {
        @JvmField
        protected val LOG_TAG = "ContainerManager"

        @JvmField
        val METHOD_CHANNEL_NAME =
            "com.emirkanacar/flutter_inappwebview_containercontroller"
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    private fun profileStoreOrNull(): ProfileStore? {
        return if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)) {
            ProfileStore.getInstance()
        } else {
            null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val profileStore = profileStoreOrNull()
        when (call.method) {
            "getAllContainerNames" -> {
                result.success(profileStore?.allProfileNames ?: emptyList<String>())
            }
            "hasContainer" -> {
                val containerId = call.argument<String>("containerId")
                result.success(
                    profileStore?.allProfileNames?.contains(containerId) == true
                )
            }
            "deleteContainer" -> {
                val containerId = call.argument<String>("containerId")
                if (profileStore == null || containerId.isNullOrEmpty()) {
                    result.success(false)
                } else {
                    try {
                        result.success(
                            profileStore.allProfileNames.contains(containerId) &&
                                profileStore.deleteProfile(containerId)
                        )
                    } catch (_: RuntimeException) {
                        // WebKit rejects deletion while a profile is in use.
                        result.success(false)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }
}
