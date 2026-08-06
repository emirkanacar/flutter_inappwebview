package com.emirkanacar.flutter_inappwebview_forge_android.proxy

import androidx.webkit.ProxyConfig
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.ProxyRuleExt
import java.util.ArrayList
import java.util.HashMap

class ProxySettings : ISettings<ProxyConfig> {
    @JvmField
    var bypassRules: MutableList<String> = ArrayList()

    @JvmField
    var directs: MutableList<String> = ArrayList()

    @JvmField
    var proxyRules: MutableList<ProxyRuleExt> = ArrayList()

    @JvmField
    var bypassSimpleHostnames: Boolean? = null

    @JvmField
    var removeImplicitRules: Boolean? = null

    @JvmField
    var reverseBypassEnabled: Boolean? = false

    override fun parse(settings: MutableMap<String, Any?>): ProxySettings {
        settings.forEach { (key, value) ->
            when (key) {
                "bypassRules" -> {
                    if (value is List<*>) {
                        bypassRules = value.filterIsInstance<String>().toMutableList()
                    }
                }
                "directs" -> {
                    if (value is List<*>) {
                        directs = value.filterIsInstance<String>().toMutableList()
                    }
                }
                "proxyRules" -> {
                    proxyRules = ArrayList()
                    if (value is List<*>) {
                        value.mapNotNull { ruleValue ->
                            val ruleMap = ruleValue as? Map<*, *> ?: return@mapNotNull null
                            val typedRuleMap = HashMap<String, String>()
                            ruleMap.forEach { (ruleKey, ruleValue) ->
                                if (ruleKey is String && ruleValue is String) {
                                    typedRuleMap[ruleKey] = ruleValue
                                }
                            }
                            ProxyRuleExt.fromMap(typedRuleMap)
                        }.let { proxyRules.addAll(it) }
                    }
                }
                "bypassSimpleHostnames" -> bypassSimpleHostnames = value as? Boolean
                "removeImplicitRules" -> removeImplicitRules = value as? Boolean
                "reverseBypassEnabled" -> reverseBypassEnabled = value as? Boolean
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("bypassRules", bypassRules)
        put("directs", directs)
        put("proxyRules", proxyRules.map { it.toMap() })
        put("bypassSimpleHostnames", bypassSimpleHostnames)
        put("removeImplicitRules", removeImplicitRules)
        put("reverseBypassEnabled", reverseBypassEnabled)
    }

    override fun getRealSettings(obj: ProxyConfig): MutableMap<String, Any?> {
        val realSettings = toMap()
        val proxyRuleMapList = ArrayList<MutableMap<String, String>>()
        obj.proxyRules.forEach { proxyRule ->
            val proxyRuleMap = HashMap<String, String>()
            proxyRule.url?.let { proxyRuleMap["url"] = it }
            proxyRule.schemeFilter?.let { proxyRuleMap["schemeFilter"] = it }
            proxyRuleMapList.add(proxyRuleMap)
        }
        realSettings["bypassRules"] = obj.bypassRules
        realSettings["proxyRules"] = proxyRuleMapList
        realSettings["reverseBypassEnabled"] = obj.isReverseBypassEnabled
        return realSettings
    }
}
