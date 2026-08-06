package com.emirkanacar.flutter_inappwebview_forge_android.types

open class HttpAuthenticationChallenge(
    protectionSpace: URLProtectionSpace,
    open var previousFailureCount: Int,
    open var proposedCredential: URLCredential?
) : URLAuthenticationChallenge(protectionSpace) {
    open override fun toMap(): MutableMap<String, Any?> = super.toMap().apply {
        put("previousFailureCount", previousFailureCount)
        put("proposedCredential", proposedCredential?.toMap())
        put("failureResponse", null)
        put("error", null)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        if (!super.equals(other)) return false
        other as HttpAuthenticationChallenge
        return previousFailureCount == other.previousFailureCount &&
            proposedCredential == other.proposedCredential
    }

    open override fun hashCode(): Int {
        var result = super.hashCode()
        result = 31 * result + previousFailureCount
        result = 31 * result + (proposedCredential?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "HttpAuthenticationChallenge{" +
            "previousFailureCount=$previousFailureCount, " +
            "proposedCredential=$proposedCredential} " + super.toString()
}
