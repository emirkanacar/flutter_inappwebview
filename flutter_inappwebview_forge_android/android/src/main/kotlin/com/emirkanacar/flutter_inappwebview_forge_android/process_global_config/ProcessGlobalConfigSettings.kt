package com.emirkanacar.flutter_inappwebview_forge_android.process_global_config

import android.content.Context
import androidx.webkit.ProcessGlobalConfig
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import java.io.File
import java.util.HashMap

class ProcessGlobalConfigSettings : ISettings<ProcessGlobalConfig> {
    @JvmField
    var dataDirectorySuffix: String? = null

    @JvmField
    var directoryBasePaths: DirectoryBasePaths? = null

    override fun parse(settings: MutableMap<String, Any?>): ProcessGlobalConfigSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "dataDirectorySuffix" -> dataDirectorySuffix = value as? String
                "directoryBasePaths" -> {
                    directoryBasePaths = asStringObjectMap(value)?.let { DirectoryBasePaths().parse(it) }
                }
            }
        }
        return this
    }

    fun toProcessGlobalConfig(context: Context): ProcessGlobalConfig {
        val config = ProcessGlobalConfig()
        val suffix = dataDirectorySuffix
        if (suffix != null &&
            WebViewFeature.isStartupFeatureSupported(
                context,
                WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX
            )
        ) {
            config.setDataDirectorySuffix(context, suffix)
        }

        val paths = directoryBasePaths
        if (paths != null &&
            WebViewFeature.isStartupFeatureSupported(
                context,
                WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS
            )
        ) {
            val dataPath = paths.dataDirectoryBasePath
                ?: throw IllegalArgumentException("dataDirectoryBasePath is required.")
            val cachePath = paths.cacheDirectoryBasePath
                ?: throw IllegalArgumentException("cacheDirectoryBasePath is required.")
            config.setDirectoryBasePaths(context, File(dataPath), File(cachePath))
        }
        return config
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("dataDirectorySuffix", dataDirectorySuffix)
    }

    override fun getRealSettings(obj: ProcessGlobalConfig): MutableMap<String, Any?> = toMap()

    class DirectoryBasePaths : ISettings<Any> {
        @JvmField
        var cacheDirectoryBasePath: String? = null

        @JvmField
        var dataDirectoryBasePath: String? = null

        override fun parse(settings: MutableMap<String, Any?>): DirectoryBasePaths {
            settings.forEach { (key, value) ->
                when (key) {
                    "cacheDirectoryBasePath" -> cacheDirectoryBasePath = value as? String
                    "dataDirectoryBasePath" -> dataDirectoryBasePath = value as? String
                }
            }
            return this
        }

        override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
            put("cacheDirectoryBasePath", cacheDirectoryBasePath)
            put("dataDirectoryBasePath", dataDirectoryBasePath)
        }

        override fun getRealSettings(obj: Any): MutableMap<String, Any?> = toMap()

        companion object {
            @JvmField
            val LOG_TAG = "ProcessGlobalConfigSettings"
        }
    }

    companion object {
        @JvmField
        val LOG_TAG = "ProcessGlobalConfigSettings"
    }
}

private fun asStringObjectMap(value: Any?): MutableMap<String, Any?>? {
    val source = value as? Map<*, *> ?: return null
    return HashMap<String, Any?>().apply {
        source.forEach { (key, entryValue) ->
            if (key is String) put(key, entryValue)
        }
    }
}
