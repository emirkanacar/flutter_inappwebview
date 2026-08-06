package com.emirkanacar.flutter_inappwebview_forge_android.types

enum class NavigationActionPolicy(private val value: Int) {
    CANCEL(0),
    ALLOW(1);

    fun equalsValue(otherValue: Int): Boolean = value == otherValue

    fun rawValue(): Int = value

    override fun toString(): String = value.toString()

    companion object {
        @JvmStatic
        fun fromValue(value: Int): NavigationActionPolicy =
            entries.firstOrNull { it.value == value }
                ?: throw IllegalArgumentException("No enum constant: $value")
    }
}
