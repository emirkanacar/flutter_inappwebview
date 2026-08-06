package com.emirkanacar.flutter_inappwebview_forge_android.content_blocker

enum class ContentBlockerTriggerResourceType(private val value: String) {
    DOCUMENT("document"),
    IMAGE("image"),
    STYLE_SHEET("style-sheet"),
    SCRIPT("script"),
    FONT("font"),
    SVG_DOCUMENT("svg-document"),
    MEDIA("media"),
    POPUP("popup"),
    RAW("raw");

    fun equalsValue(otherValue: String): Boolean = value == otherValue

    override fun toString(): String = value

    companion object {
        @JvmStatic
        fun fromValue(value: String): ContentBlockerTriggerResourceType =
            values().firstOrNull { it.value == value }
                ?: throw IllegalArgumentException("No enum constant: $value")
    }
}
