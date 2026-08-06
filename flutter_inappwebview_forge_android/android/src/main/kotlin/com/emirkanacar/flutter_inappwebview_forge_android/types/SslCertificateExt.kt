package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.net.http.SslCertificate
import android.os.Build
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import java.security.cert.CertificateEncodingException
import java.security.cert.X509Certificate
import java.util.HashMap

class SslCertificateExt private constructor(certificate: X509Certificate) : SslCertificate(certificate) {
    companion object {
        private fun dNameToMap(name: SslCertificate.DName?): MutableMap<String, Any?>? {
            if (name == null) return null
            return HashMap<String, Any?>().apply {
                put("CName", name.getCName())
                put("DName", name.getDName())
                put("OName", name.getOName())
                put("UName", name.getUName())
            }
        }

        @JvmStatic
        fun toMap(sslCertificate: SslCertificate?): MutableMap<String, Any?>? {
            if (sslCertificate == null) return null

            val x509CertificateData: ByteArray?
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                x509CertificateData = try {
                    sslCertificate.getX509Certificate()?.encoded
                } catch (e: CertificateEncodingException) {
                    e.printStackTrace()
                    null
                }
            } else {
                x509CertificateData = try {
                    Util.getX509CertFromSslCertHack(sslCertificate)?.encoded
                } catch (e: CertificateEncodingException) {
                    e.printStackTrace()
                    null
                }
            }

            return HashMap<String, Any?>().apply {
                put("issuedBy", dNameToMap(sslCertificate.getIssuedBy()))
                put("issuedTo", dNameToMap(sslCertificate.getIssuedTo()))
                put("validNotAfterDate", sslCertificate.getValidNotAfterDate().getTime())
                put("validNotBeforeDate", sslCertificate.getValidNotBeforeDate().getTime())
                put("x509Certificate", x509CertificateData)
            }
        }
    }
}
