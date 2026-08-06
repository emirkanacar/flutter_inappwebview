package com.emirkanacar.flutter_inappwebview_forge_android.content_blocker

import java.util.regex.Pattern

class ContentBlockerTrigger(
    urlFilter: String,
    urlFilterIsCaseSensitive: Boolean?,
    resourceType: MutableList<ContentBlockerTriggerResourceType>?,
    ifDomain: MutableList<String>?,
    unlessDomain: MutableList<String>?,
    loadType: MutableList<String>?,
    ifTopUrl: MutableList<String>?,
    unlessTopUrl: MutableList<String>?
) {
    var urlFilter: String = urlFilter
    var urlFilterPatternCompiled: Pattern = Pattern.compile(
        urlFilter,
        if (urlFilterIsCaseSensitive == true) 0 else Pattern.CASE_INSENSITIVE
    )
    var urlFilterIsCaseSensitive: Boolean? = urlFilterIsCaseSensitive ?: false
    var resourceType: MutableList<ContentBlockerTriggerResourceType> =
        resourceType ?: mutableListOf()
    var ifDomain: MutableList<String> = ifDomain ?: mutableListOf()
    var unlessDomain: MutableList<String> = unlessDomain ?: mutableListOf()
    var loadType: MutableList<String> = loadType ?: mutableListOf()
    var ifTopUrl: MutableList<String> = ifTopUrl ?: mutableListOf()
    var unlessTopUrl: MutableList<String> = unlessTopUrl ?: mutableListOf()

    init {
        if (this.ifDomain.isNotEmpty() && this.unlessDomain.isNotEmpty()) {
            throw AssertionError()
        }
        if (this.loadType.size > 2) {
            throw AssertionError()
        }
        if (this.ifTopUrl.isNotEmpty() && this.unlessTopUrl.isNotEmpty()) {
            throw AssertionError()
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ContentBlockerTrigger) return false
        return urlFilter == other.urlFilter &&
            urlFilterPatternCompiled == other.urlFilterPatternCompiled &&
            urlFilterIsCaseSensitive == other.urlFilterIsCaseSensitive &&
            resourceType == other.resourceType &&
            ifDomain == other.ifDomain &&
            unlessDomain == other.unlessDomain &&
            loadType == other.loadType &&
            ifTopUrl == other.ifTopUrl &&
            unlessTopUrl == other.unlessTopUrl
    }

    override fun hashCode(): Int {
        var result = urlFilter.hashCode()
        result = 31 * result + urlFilterPatternCompiled.hashCode()
        result = 31 * result + (urlFilterIsCaseSensitive?.hashCode() ?: 0)
        result = 31 * result + resourceType.hashCode()
        result = 31 * result + ifDomain.hashCode()
        result = 31 * result + unlessDomain.hashCode()
        result = 31 * result + loadType.hashCode()
        result = 31 * result + ifTopUrl.hashCode()
        result = 31 * result + unlessTopUrl.hashCode()
        return result
    }

    override fun toString(): String =
        "ContentBlockerTrigger{" +
            "urlFilter='$urlFilter', " +
            "urlFilterPatternCompiled=$urlFilterPatternCompiled, " +
            "urlFilterIsCaseSensitive=$urlFilterIsCaseSensitive, " +
            "resourceType=$resourceType, " +
            "ifDomain=$ifDomain, " +
            "unlessDomain=$unlessDomain, " +
            "loadType=$loadType, " +
            "ifTopUrl=$ifTopUrl, " +
            "unlessTopUrl=$unlessTopUrl}"

    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>): ContentBlockerTrigger {
            val urlFilter = map["url-filter"] as? String
                ?: throw IllegalArgumentException("Content blocker url-filter is required.")
            val caseSensitive = map["url-filter-is-case-sensitive"] as? Boolean
            val resourceTypeValues = stringList(map["resource-type"])
            val resourceTypes = resourceTypeValues?.map {
                ContentBlockerTriggerResourceType.fromValue(it)
            }?.toMutableList() ?: valuesToMutableList()

            return ContentBlockerTrigger(
                urlFilter,
                caseSensitive,
                resourceTypes,
                stringList(map["if-domain"]),
                stringList(map["unless-domain"]),
                stringList(map["load-type"]),
                stringList(map["if-top-url"]),
                stringList(map["unless-top-url"])
            )
        }
    }
}

private fun stringList(value: Any?): MutableList<String>? =
    (value as? List<*>)?.filterIsInstance<String>()?.toMutableList()

private fun valuesToMutableList(): MutableList<ContentBlockerTriggerResourceType> =
    ContentBlockerTriggerResourceType.values().toMutableList()
