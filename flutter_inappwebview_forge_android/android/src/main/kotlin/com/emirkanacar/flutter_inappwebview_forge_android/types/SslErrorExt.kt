package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.net.http.SslError
import android.net.http.SslCertificate
import java.util.HashMap

class SslErrorExt private constructor(
    error: Int,
    certificate: SslCertificate?,
    url: String?
) : SslError(error, certificate, url) {
    companion object {
        @JvmStatic
        fun toMap(sslError: SslError?): MutableMap<String, Any?>? {
            if (sslError == null) return null

            val primaryError = sslError.getPrimaryError()
            val message = when (primaryError) {
                SslError.SSL_DATE_INVALID -> "The date of the certificate is invalid"
                SslError.SSL_EXPIRED -> "The certificate has expired"
                SslError.SSL_IDMISMATCH -> "Hostname mismatch"
                SslError.SSL_INVALID -> "A generic error occurred"
                SslError.SSL_NOTYETVALID -> "The certificate is not yet valid"
                SslError.SSL_UNTRUSTED -> "The certificate authority is not trusted"
                else -> null
            }
            return HashMap<String, Any?>().apply {
                put("code", if (primaryError >= 0) primaryError else null)
                put("message", message)
            }
        }
    }
}
