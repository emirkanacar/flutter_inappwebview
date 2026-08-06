package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class URLCredential {
    private var id: Long? = null
    private var username: String? = null
    private var password: String? = null
    private var protectionSpaceId: Long? = null

    constructor(username: String?, password: String?) {
        this.username = username
        this.password = password
    }

    constructor(id: Long?, username: String, password: String, protectionSpaceId: Long?) {
        this.id = id
        this.username = username
        this.password = password
        this.protectionSpaceId = protectionSpaceId
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("username", username)
        put("password", password)
        put("certificates", null)
        put("persistence", null)
    }

    open fun getId(): Long? = id

    open fun setId(id: Long?) {
        this.id = id
    }

    open fun getUsername(): String? = username

    open fun setUsername(username: String?) {
        this.username = username
    }

    open fun getPassword(): String? = password

    open fun setPassword(password: String?) {
        this.password = password
    }

    open fun getProtectionSpaceId(): Long? = protectionSpaceId

    open fun setProtectionSpaceId(protectionSpaceId: Long?) {
        this.protectionSpaceId = protectionSpaceId
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as URLCredential
        return username == other.username && password == other.password
    }

    open override fun hashCode(): Int {
        var result = username?.hashCode() ?: 0
        result = 31 * result + (password?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "URLCredential{username='$username', password='$password'}"
}
