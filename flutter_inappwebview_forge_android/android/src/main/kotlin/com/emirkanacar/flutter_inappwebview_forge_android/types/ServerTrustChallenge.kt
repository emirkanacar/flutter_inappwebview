package com.emirkanacar.flutter_inappwebview_forge_android.types

open class ServerTrustChallenge(
    protectionSpace: URLProtectionSpace
) : URLAuthenticationChallenge(protectionSpace) {
    open override fun toString(): String = "ServerTrustChallenge{} ${super.toString()}"
}
