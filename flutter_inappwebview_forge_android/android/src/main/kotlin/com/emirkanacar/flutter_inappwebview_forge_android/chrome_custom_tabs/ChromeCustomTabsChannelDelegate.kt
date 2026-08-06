package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsService
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomTabsSecondaryToolbar
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class ChromeCustomTabsChannelDelegate(
    activity: ChromeCustomTabsActivity,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {
    private var chromeCustomTabsActivity: ChromeCustomTabsActivity? = activity

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val activity = chromeCustomTabsActivity
        when (call.method) {
            "launchUrl" -> {
                val url = call.argument<String>("url")
                if (activity == null || url == null) {
                    result.success(false)
                    return
                }
                activity.launchUrl(
                    url,
                    call.argument<MutableMap<String, String>>("headers"),
                    call.argument<String>("referrer"),
                    call.argument<MutableList<String>>("otherLikelyURLs")
                )
                result.success(true)
            }

            "mayLaunchUrl" -> {
                if (activity == null) {
                    result.success(false)
                    return
                }
                result.success(
                    activity.mayLaunchUrl(
                        call.argument<String>("url"),
                        call.argument<MutableList<String>>("otherLikelyURLs")
                    )
                )
            }

            "updateActionButton" -> {
                if (activity == null) {
                    result.success(false)
                    return
                }
                val icon = call.argument<ByteArray>("icon")
                val description = call.argument<String>("description")
                if (icon == null || description == null) {
                    result.success(false)
                    return
                }
                activity.updateActionButton(icon, description)
                result.success(true)
            }

            "validateRelationship" -> {
                val session = activity?.customTabsSession
                val relation = call.argument<Int>("relation")
                val origin = call.argument<String>("origin")
                if (session == null || relation == null || origin == null) {
                    result.success(false)
                    return
                }
                result.success(session.validateRelationship(relation, Uri.parse(origin), null))
            }

            "updateSecondaryToolbar" -> {
                if (activity == null) {
                    result.success(false)
                    return
                }
                val secondaryToolbar = CustomTabsSecondaryToolbar.fromMap(
                    call.argument<MutableMap<String, Any?>>("secondaryToolbar")
                )
                if (secondaryToolbar == null) {
                    result.success(false)
                    return
                }
                activity.updateSecondaryToolbar(secondaryToolbar)
                result.success(true)
            }

            "requestPostMessageChannel" -> {
                val session = activity?.customTabsSession
                val sourceOrigin = call.argument<String>("sourceOrigin")
                if (session == null || sourceOrigin == null) {
                    result.success(false)
                    return
                }
                val targetOrigin = call.argument<String>("targetOrigin")
                result.success(
                    session.requestPostMessageChannel(
                        Uri.parse(sourceOrigin),
                        targetOrigin?.let(Uri::parse),
                        Bundle()
                    )
                )
            }

            "postMessage" -> {
                val session = activity?.customTabsSession
                if (session == null) {
                    result.success(CustomTabsService.RESULT_FAILURE_MESSAGING_ERROR)
                    return
                }
                val message = call.argument<String>("message")
                if (message == null) {
                    result.success(CustomTabsService.RESULT_FAILURE_MESSAGING_ERROR)
                    return
                }
                result.success(session.postMessage(message, Bundle()))
            }

            "isEngagementSignalsApiAvailable" -> {
                val session = activity?.customTabsSession
                if (session == null) {
                    result.success(false)
                    return
                }
                result.success(
                    try {
                        session.isEngagementSignalsApiAvailable(Bundle())
                    } catch (_: Throwable) {
                        false
                    }
                )
            }

            "close" -> {
                if (activity == null) {
                    result.success(false)
                    return
                }
                activity.close()

                val manager = activity.manager
                val managerActivity = manager?.plugin?.activity
                if (managerActivity != null) {
                    // https://stackoverflow.com/a/41596629/4637638
                    val restartIntent = Intent(managerActivity, managerActivity.javaClass).apply {
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                    managerActivity.startActivity(restartIntent)
                }
                activity.dispose()
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun invoke(method: String, arguments: Map<String, Any?> = emptyMap()) {
        getChannel()?.invokeMethod(method, HashMap(arguments))
    }

    fun onServiceConnected() = invoke("onServiceConnected")

    fun onOpened() = invoke("onOpened")

    fun onCompletedInitialLoad() = invoke("onCompletedInitialLoad")

    fun onNavigationEvent(navigationEvent: Int) =
        invoke("onNavigationEvent", mapOf("navigationEvent" to navigationEvent))

    fun onClosed() = invoke("onClosed")

    fun onItemActionPerform(id: Int, url: String?, title: String?) = invoke(
        "onItemActionPerform",
        mapOf("id" to id, "url" to url, "title" to title)
    )

    fun onSecondaryItemActionPerform(name: String?, url: String?) = invoke(
        "onSecondaryItemActionPerform",
        mapOf("name" to name, "url" to url)
    )

    fun onRelationshipValidationResult(
        relation: Int,
        requestedOrigin: Uri,
        relationshipResult: Boolean
    ) = invoke(
        "onRelationshipValidationResult",
        mapOf(
            "relation" to relation,
            "requestedOrigin" to requestedOrigin.toString(),
            "result" to relationshipResult
        )
    )

    fun onMessageChannelReady() = invoke("onMessageChannelReady")

    fun onPostMessage(message: String) = invoke("onPostMessage", mapOf("message" to message))

    fun onVerticalScrollEvent(isDirectionUp: Boolean) =
        invoke("onVerticalScrollEvent", mapOf("isDirectionUp" to isDirectionUp))

    fun onGreatestScrollPercentageIncreased(scrollPercentage: Int) = invoke(
        "onGreatestScrollPercentageIncreased",
        mapOf("scrollPercentage" to scrollPercentage)
    )

    fun onSessionEnded(didUserInteract: Boolean) =
        invoke("onSessionEnded", mapOf("didUserInteract" to didUserInteract))

    override fun dispose() {
        super.dispose()
        chromeCustomTabsActivity = null
    }
}
