package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.security.Principal
import java.util.Arrays

open class ClientCertChallenge(
    protectionSpace: URLProtectionSpace,
    open var principals: Array<Principal>?,
    open var keyTypes: Array<String>?
) : URLAuthenticationChallenge(protectionSpace) {
    open override fun toMap(): MutableMap<String, Any?> {
        val principalList = principals?.map { it.name }
        return super.toMap().apply {
            put("principals", principalList)
            put("keyTypes", keyTypes?.toList())
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        if (!super.equals(other)) return false
        other as ClientCertChallenge
        return Arrays.equals(principals, other.principals) &&
            Arrays.equals(keyTypes, other.keyTypes)
    }

    open override fun hashCode(): Int {
        var result = super.hashCode()
        result = 31 * result + Arrays.hashCode(principals)
        result = 31 * result + Arrays.hashCode(keyTypes)
        return result
    }

    open override fun toString(): String =
        "ClientCertChallenge{" +
            "principals=${Arrays.toString(principals)}, " +
            "keyTypes=${Arrays.toString(keyTypes)}} ${super.toString()}"
}
