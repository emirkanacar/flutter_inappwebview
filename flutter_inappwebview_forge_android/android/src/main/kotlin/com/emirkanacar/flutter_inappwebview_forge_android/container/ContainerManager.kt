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
            "clearContainerData" -> {
                val containerId = call.argument<String>("containerId")
                if (profileStore == null || containerId.isNullOrEmpty()) {
                    result.success(false)
                    return
                }
                try {
                    val profile = profileStore.getProfile(containerId)
                    if (profile == null) {
                        result.success(false)
                        return
                    }
                    profile.getCookieManager().removeAllCookies(null)
                    profile.getWebStorage().deleteAllData()
                    profile.getGeolocationPermissions().clearAll()
                    result.success(true)
                } catch (_: RuntimeException) {
                    result.success(false)
                }
            }
            "addCustomHeader" -> {
                val containerId = call.argument<String>("containerId")
                val headerName = call.argument<String>("headerName")
                val headerValue = call.argument<String>("headerValue")
                val originRules = call.argument<List<String>>("originRules")?.toSet()
                if (profileStore == null ||
                    containerId.isNullOrEmpty() ||
                    headerName.isNullOrEmpty() ||
                    headerValue == null ||
                    !WebViewFeature.isFeatureSupported("CUSTOM_REQUEST_HEADERS")
                ) {
                    result.success(false)
                    return
                }
                try {
                    val profile = profileStore.getOrCreateProfile(containerId)
                    val method = profile.javaClass.methods.firstOrNull { it.name == "addCustomHeader" }
                    if (method == null) {
                        result.success(false)
                        return
                    }
                    when (method.parameterCount) {
                        2 -> method.invoke(profile, headerName, headerValue)
                        3 -> method.invoke(profile, headerName, headerValue, originRules)
                        else -> {
                            result.success(false)
                            return
                        }
                    }
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
                }
            }
            "removeCustomHeader" -> {
                val containerId = call.argument<String>("containerId")
                val headerName = call.argument<String>("headerName")
                if (profileStore == null ||
                    containerId.isNullOrEmpty() ||
                    headerName.isNullOrEmpty() ||
                    !WebViewFeature.isFeatureSupported("CUSTOM_REQUEST_HEADERS")
                ) {
                    result.success(false)
                    return
                }
                try {
                    val profile = profileStore.getProfile(containerId)
                    val method = profile?.javaClass?.methods?.firstOrNull { it.name == "removeCustomHeader" }
                    if (profile == null || method == null) {
                        result.success(false)
                        return
                    }
                    method.invoke(profile, headerName)
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
                }
            }
            "prefetchUrl" -> {
                val containerId = call.argument<String>("containerId")
                val url = call.argument<String>("url")
                if (profileStore == null ||
                    containerId.isNullOrEmpty() ||
                    url.isNullOrEmpty() ||
                    !WebViewFeature.isFeatureSupported("PROFILE_URL_PREFETCH")
                ) {
                    result.success(false)
                    return
                }
                try {
                    val profile = profileStore.getOrCreateProfile(containerId)
                    val method = profile.javaClass.methods.firstOrNull { it.name == "prefetchUrlAsync" }
                    if (method == null) {
                        result.success(false)
                        return
                    }
                    method.invoke(profile, url)
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
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
