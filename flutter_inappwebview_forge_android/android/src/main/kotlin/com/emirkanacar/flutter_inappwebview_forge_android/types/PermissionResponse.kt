package com.emirkanacar.flutter_inappwebview_forge_android.types

open class PermissionResponse(
    open var resources: MutableList<String>,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): PermissionResponse? {
            if (map == null) return null

            val resources = (map["resources"] as? List<*>)?.mapIndexed { index, resource ->
                resource as? String
                    ?: throw IllegalArgumentException("Permission resource at index $index is invalid.")
            }?.toMutableList()
                ?: throw IllegalArgumentException("Permission resources are required.")
            val action = (map["action"] as? Number)?.toInt()
            return PermissionResponse(resources, action)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as PermissionResponse
        return resources == other.resources && action == other.action
    }

    open override fun hashCode(): Int {
        var result = resources.hashCode()
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "PermissionResponse{" +
            "resources=$resources, " +
            "action=$action}"
}
