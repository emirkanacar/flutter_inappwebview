package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.provider.BaseColumns

class URLProtectionSpaceContract private constructor() {
    class FeedEntry : BaseColumns {
        companion object {
            @JvmField
            val _ID = "_id"

            @JvmField
            val TABLE_NAME = "protection_space"

            @JvmField
            val COLUMN_NAME_HOST = "host"

            @JvmField
            val COLUMN_NAME_PROTOCOL = "protocol"

            @JvmField
            val COLUMN_NAME_REALM = "realm"

            @JvmField
            val COLUMN_NAME_PORT = "port"
        }
    }
}
