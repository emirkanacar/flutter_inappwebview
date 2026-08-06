package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.provider.BaseColumns

class URLCredentialContract private constructor() {
    class FeedEntry : BaseColumns {
        companion object {
            @JvmField
            val _ID = "_id"

            @JvmField
            val TABLE_NAME = "credential"

            @JvmField
            val COLUMN_NAME_USERNAME = "username"

            @JvmField
            val COLUMN_NAME_PASSWORD = "password"

            @JvmField
            val COLUMN_NAME_PROTECTION_SPACE_ID = "protection_space_id"
        }
    }
}
