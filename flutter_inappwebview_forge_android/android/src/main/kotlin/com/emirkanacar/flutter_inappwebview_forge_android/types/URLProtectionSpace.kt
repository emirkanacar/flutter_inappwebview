package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.net.http.SslCertificate
import android.net.http.SslError
import java.util.HashMap

open class URLProtectionSpace private constructor(
    open var id: Long?,
    open var host: String,
    open var protocol: String,
    open var realm: String?,
    open var port: Int,
    open var sslCertificate: SslCertificate?,
    open var sslError: SslError?
) {
    constructor(
        host: String,
        protocol: String,
        realm: String?,
        port: Int,
        sslCertificate: SslCertificate?,
        sslError: SslError?
    ) : this(null, host, protocol, realm, port, sslCertificate, sslError)

    constructor(
        id: Long?,
        host: String,
        protocol: String,
        realm: String?,
        port: Int
    ) : this(id, host, protocol, realm, port, null, null)

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("host", host)
        put("protocol", protocol)
        put("realm", realm)
        put("port", port)
        put("sslCertificate", SslCertificateExt.toMap(sslCertificate))
        put("sslError", SslErrorExt.toMap(sslError))
        put("authenticationMethod", null)
        put("distinguishedNames", null)
        put("receivesCredentialSecurely", null)
        put("isProxy", null)
        put("proxyType", null)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as URLProtectionSpace
        return port == other.port &&
            host == other.host &&
            protocol == other.protocol &&
            realm == other.realm &&
            sslCertificate == other.sslCertificate &&
            sslError == other.sslError
    }

    open override fun hashCode(): Int {
        var result = host.hashCode()
        result = 31 * result + protocol.hashCode()
        result = 31 * result + (realm?.hashCode() ?: 0)
        result = 31 * result + port
        result = 31 * result + (sslCertificate?.hashCode() ?: 0)
        result = 31 * result + (sslError?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "URLProtectionSpace{" +
            "host='$host', " +
            "protocol='$protocol', " +
            "realm='$realm', " +
            "port=$port, " +
            "sslCertificate=$sslCertificate, " +
            "sslError=$sslError}"
}
