package com.emirkanacar.flutter_inappwebview_forge_android.types

enum class UserScriptInjectionTime(private val value: Int) {
    AT_DOCUMENT_START(0),
    AT_DOCUMENT_END(1);

    fun equalsValue(otherValue: Int): Boolean = value == otherValue

    fun toValue(): Int = value

    companion object {
        @JvmStatic
        fun fromValue(value: Int): UserScriptInjectionTime =
            entries.firstOrNull { it.value == value }
                ?: throw IllegalArgumentException("No enum constant: $value")
    }
}
