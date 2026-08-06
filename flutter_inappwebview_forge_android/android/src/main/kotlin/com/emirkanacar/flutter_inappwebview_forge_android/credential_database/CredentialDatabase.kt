package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.content.Context
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLCredential
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLProtectionSpace

open class CredentialDatabase private constructor(
    @JvmField var db: CredentialDatabaseHelper,
    @JvmField var protectionSpaceDao: URLProtectionSpaceDao,
    @JvmField var credentialDao: URLCredentialDao
) {
    companion object {
        @JvmField
        val DATABASE_VERSION = 2

        @JvmField
        val DATABASE_NAME = "CredentialDatabase.db"

        private var instance: CredentialDatabase? = null

        @JvmStatic
        fun getInstance(context: Context): CredentialDatabase {
            val current = instance
            if (current != null) return current

            val databaseHelper = CredentialDatabaseHelper(context)
            return CredentialDatabase(
                databaseHelper,
                URLProtectionSpaceDao(databaseHelper),
                URLCredentialDao(databaseHelper)
            ).also { instance = it }
        }
    }

    open fun getHttpAuthCredentials(
        host: String,
        protocol: String,
        realm: String?,
        port: Int?
    ): MutableList<URLCredential> {
        val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
        return if (protectionSpace != null) {
            credentialDao.getAllByProtectionSpaceId(protectionSpace.id)
        } else {
            mutableListOf()
        }
    }

    open fun clearAllAuthCredentials() {
        db.clearAllTables(db.writableDatabase)
    }

    open fun removeHttpAuthCredentials(host: String, protocol: String, realm: String?, port: Int?) {
        val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
        if (protectionSpace != null) {
            protectionSpaceDao.delete(protectionSpace)
        }
    }

    open fun removeHttpAuthCredential(
        host: String,
        protocol: String,
        realm: String?,
        port: Int?,
        username: String,
        password: String
    ) {
        val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
        if (protectionSpace != null) {
            val credential = credentialDao.find(username, password, protectionSpace.id)
            if (credential != null) {
                credentialDao.delete(credential)
            }
        }
    }

    open fun setHttpAuthCredential(
        host: String,
        protocol: String,
        realm: String?,
        port: Int?,
        username: String,
        password: String
    ) {
        val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
        val protectionSpaceId = if (protectionSpace == null) {
            val portValue = port ?: throw IllegalArgumentException("Protection space port is required.")
            protectionSpaceDao.insert(URLProtectionSpace(null, host, protocol, realm, portValue))
        } else {
            protectionSpace.id
        }

        val credential = credentialDao.find(username, password, protectionSpaceId)
        if (credential != null) {
            var needsUpdate = false
            if (credential.getUsername() != username) {
                credential.setUsername(username)
                needsUpdate = true
            }
            if (credential.getPassword() != password) {
                credential.setPassword(password)
                needsUpdate = true
            }
            if (needsUpdate) {
                credentialDao.update(credential)
            }
        } else {
            val newCredential = URLCredential(null, username, password, protectionSpaceId)
            newCredential.setId(credentialDao.insert(newCredential))
        }
    }
}
