package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.os.Build
import android.webkit.WebViewDatabase
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLCredential
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

@RequiresApi(Build.VERSION_CODES.O)
open class CredentialDatabaseHandler(
    plugin: InAppWebViewFlutterPlugin
) : ChannelDelegateImpl(MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME)) {
    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = plugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        plugin?.let { init(it) }

        try {
            when (call.method) {
                "getAllAuthCredentials" -> {
                    val allCredentials = mutableListOf<MutableMap<String, Any?>>()
                    credentialDatabase?.let { database ->
                        for (protectionSpace in database.protectionSpaceDao.getAll()) {
                            val credentials = mutableListOf<MutableMap<String, Any?>>()
                            for (credential in database.credentialDao.getAllByProtectionSpaceId(protectionSpace.id)) {
                                credentials.add(credential.toMap())
                            }
                            allCredentials.add(hashMapOf(
                                "protectionSpace" to protectionSpace.toMap(),
                                "credentials" to credentials
                            ))
                        }
                    }
                    result.success(allCredentials)
                }

                "getHttpAuthCredentials" -> {
                    val credentials = mutableListOf<MutableMap<String, Any?>>()
                    credentialDatabase?.let { database ->
                        val host = requiredString(call, "host")
                        val protocol = requiredString(call, "protocol")
                        val realm = call.argument<String>("realm")
                        val port = requiredPort(call)
                        for (credential in database.getHttpAuthCredentials(host, protocol, realm, port)) {
                            credentials.add(credential.toMap())
                        }
                    }
                    result.success(credentials)
                }

                "setHttpAuthCredential" -> {
                    val database = credentialDatabase
                    if (database == null) {
                        result.success(false)
                    } else {
                        database.setHttpAuthCredential(
                            requiredString(call, "host"),
                            requiredString(call, "protocol"),
                            call.argument<String>("realm"),
                            requiredPort(call),
                            requiredString(call, "username"),
                            requiredString(call, "password")
                        )
                        result.success(true)
                    }
                }

                "removeHttpAuthCredential" -> {
                    val database = credentialDatabase
                    if (database == null) {
                        result.success(false)
                    } else {
                        database.removeHttpAuthCredential(
                            requiredString(call, "host"),
                            requiredString(call, "protocol"),
                            call.argument<String>("realm"),
                            requiredPort(call),
                            requiredString(call, "username"),
                            requiredString(call, "password")
                        )
                        result.success(true)
                    }
                }

                "removeHttpAuthCredentials" -> {
                    val database = credentialDatabase
                    if (database == null) {
                        result.success(false)
                    } else {
                        database.removeHttpAuthCredentials(
                            requiredString(call, "host"),
                            requiredString(call, "protocol"),
                            call.argument<String>("realm"),
                            requiredPort(call)
                        )
                        result.success(true)
                    }
                }

                "clearAllAuthCredentials" -> {
                    val database = credentialDatabase
                    if (database == null) {
                        result.success(false)
                    } else {
                        database.clearAllAuthCredentials()
                        plugin?.applicationContext?.let { context ->
                            WebViewDatabase.getInstance(context).clearHttpAuthUsernamePassword()
                        }
                        result.success(true)
                    }
                }

                else -> result.notImplemented()
            }
        } catch (error: IllegalArgumentException) {
            result.error("invalid_arguments", error.message, null)
        }
    }

    private fun requiredString(call: MethodCall, name: String): String =
        call.argument<String>(name)
            ?: throw IllegalArgumentException("The '$name' argument is required.")

    private fun requiredPort(call: MethodCall): Int =
        call.argument<Number>("port")?.toInt()
            ?: throw IllegalArgumentException("The 'port' argument is required.")

    override fun dispose() {
        super.dispose()
        plugin = null
        credentialDatabase = null
    }

    companion object {
        @JvmField
        protected val LOG_TAG = "CredentialDatabaseHandler"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_credential_database"

        @JvmField
        var credentialDatabase: CredentialDatabase? = null

        @JvmStatic
        fun init(plugin: InAppWebViewFlutterPlugin) {
            if (credentialDatabase != null) return
            val context = plugin.applicationContext ?: return
            credentialDatabase = CredentialDatabase.getInstance(context)
        }
    }
}
