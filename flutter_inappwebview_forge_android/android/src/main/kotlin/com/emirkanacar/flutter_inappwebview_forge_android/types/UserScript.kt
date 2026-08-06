package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class UserScript(
    var groupName: String?,
    var source: String,
    var injectionTime: UserScriptInjectionTime,
    contentWorld: ContentWorld?,
    allowedOriginRules: MutableSet<String>?,
    var isForMainFrameOnly: Boolean
) {
    private var contentWorldValue: ContentWorld = contentWorld ?: ContentWorld.PAGE
    private var allowedOriginRulesValue: MutableSet<String> =
        allowedOriginRules ?: mutableSetOf("*")

    fun getContentWorld(): ContentWorld = contentWorldValue

    fun setContentWorld(contentWorld: ContentWorld?) {
        contentWorldValue = contentWorld ?: ContentWorld.PAGE
    }

    fun getAllowedOriginRules(): MutableSet<String> = allowedOriginRulesValue

    fun setAllowedOriginRules(allowedOriginRules: MutableSet<String>) {
        allowedOriginRulesValue = allowedOriginRules
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is UserScript) return false
        return isForMainFrameOnly == other.isForMainFrameOnly &&
            groupName == other.groupName &&
            source == other.source &&
            injectionTime == other.injectionTime &&
            contentWorldValue == other.contentWorldValue &&
            allowedOriginRulesValue == other.allowedOriginRulesValue
    }

    override fun hashCode(): Int {
        var result = groupName?.hashCode() ?: 0
        result = 31 * result + source.hashCode()
        result = 31 * result + injectionTime.hashCode()
        result = 31 * result + contentWorldValue.hashCode()
        result = 31 * result + allowedOriginRulesValue.hashCode()
        result = 31 * result + isForMainFrameOnly.hashCode()
        return result
    }

    override fun toString(): String =
        "UserScript{" +
            "groupName='$groupName', " +
            "source='$source', " +
            "injectionTime=$injectionTime, " +
            "contentWorld=$contentWorldValue, " +
            "allowedOriginRules=$allowedOriginRulesValue, " +
            "forMainFrameOnly=$isForMainFrameOnly}"

    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): UserScript? {
            if (map == null) return null

            val source = map["source"] as? String
                ?: throw IllegalArgumentException("User script source is required.")
            val injectionTimeValue = (map["injectionTime"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("User script injectionTime is required.")
            val injectionTime = UserScriptInjectionTime.fromValue(injectionTimeValue)
            val contentWorld = ContentWorld.fromMap(asStringObjectMap(map["contentWorld"]))
            val allowedOriginRules = (map["allowedOriginRules"] as? List<*>)
                ?.filterIsInstance<String>()
                ?.toMutableSet()
                ?: mutableSetOf("*")
            val forMainFrameOnly = map["forMainFrameOnly"] as? Boolean
                ?: throw IllegalArgumentException("User script forMainFrameOnly is required.")

            return UserScript(
                map["groupName"] as? String,
                source,
                injectionTime,
                contentWorld,
                allowedOriginRules,
                forMainFrameOnly
            )
        }
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
