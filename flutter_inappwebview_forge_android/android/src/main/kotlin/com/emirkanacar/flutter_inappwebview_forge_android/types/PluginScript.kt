package com.emirkanacar.flutter_inappwebview_forge_android.types

class PluginScript(
    groupName: String?,
    source: String,
    injectionTime: UserScriptInjectionTime,
    contentWorld: ContentWorld?,
    requiredInAllContentWorlds: Boolean,
    allowedOriginRules: MutableSet<String>?,
    forMainFrameOnly: Boolean
) : UserScript(
    groupName,
    source,
    injectionTime,
    contentWorld,
    allowedOriginRules,
    forMainFrameOnly
) {
    var isRequiredInAllContentWorlds: Boolean = requiredInAllContentWorlds

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is PluginScript) return false
        if (!super.equals(other)) return false
        return isRequiredInAllContentWorlds == other.isRequiredInAllContentWorlds
    }

    override fun hashCode(): Int = 31 * super.hashCode() + isRequiredInAllContentWorlds.hashCode()

    override fun toString(): String =
        "PluginScript{requiredInContentWorld=$isRequiredInAllContentWorlds} ${super.toString()}"
}
