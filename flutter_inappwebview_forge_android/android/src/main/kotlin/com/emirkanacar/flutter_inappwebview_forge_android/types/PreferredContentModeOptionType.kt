package com.emirkanacar.flutter_inappwebview_forge_android.types

enum class PreferredContentModeOptionType(private val value: Int) {
    RECOMMENDED(0),
    MOBILE(1),
    DESKTOP(2);

    fun equalsValue(otherValue: Int): Boolean = value == otherValue

    fun toValue(): Int = value

    companion object {
        @JvmStatic
        fun fromValue(value: Int): PreferredContentModeOptionType {
            return values().firstOrNull { it.toValue() == value }
                ?: throw IllegalArgumentException("No enum constant: $value")
        }
    }
}
