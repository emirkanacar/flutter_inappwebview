package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.content.Context
import java.util.HashMap

class AndroidResource(
    var name: String,
    var defType: String?,
    var defPackage: String?
) {
    fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("name", name)
        put("defType", defType)
        put("defPackage", defPackage)
    }

    fun getIdentifier(context: Context): Int =
        context.resources.getIdentifier(name, defType, defPackage)

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is AndroidResource) return false
        return name == other.name && defType == other.defType && defPackage == other.defPackage
    }

    override fun hashCode(): Int {
        var result = name.hashCode()
        result = 31 * result + (defType?.hashCode() ?: 0)
        result = 31 * result + (defPackage?.hashCode() ?: 0)
        return result
    }

    override fun toString(): String =
        "AndroidResource{name='$name', type='$defType', defPackage='$defPackage'}"

    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): AndroidResource? {
            if (map == null) return null

            val name = map["name"] as? String
                ?: throw IllegalArgumentException("Android resource name is required.")
            val defType = map["defType"] as? String
            val defPackage = map["defPackage"] as? String
            return AndroidResource(name, defType, defPackage)
        }
    }
}
