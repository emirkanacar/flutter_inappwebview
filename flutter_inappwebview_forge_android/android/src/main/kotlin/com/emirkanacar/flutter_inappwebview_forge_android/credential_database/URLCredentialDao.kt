package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.content.ContentValues
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLCredential

open class URLCredentialDao(
    private val credentialDatabaseHelper: CredentialDatabaseHelper
) {
    private val projection = arrayOf(
        URLCredentialContract.FeedEntry._ID,
        URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME,
        URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD,
        URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID
    )

    open fun getAllByProtectionSpaceId(protectionSpaceId: Long?): MutableList<URLCredential> {
        val id = protectionSpaceId ?: throw IllegalArgumentException("Protection space id is required.")
        val selection = URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
        val selectionArgs = arrayOf(id.toString())

        return credentialDatabaseHelper.readableDatabase.query(
            URLCredentialContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        ).use { cursor ->
            val credentials = mutableListOf<URLCredential>()
            while (cursor.moveToNext()) {
                val rowId = cursor.getLong(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry._ID))
                val username = cursor.getString(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME))
                val password = cursor.getString(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD))
                credentials.add(URLCredential(rowId, username, password, id))
            }
            credentials
        }
    }

    open fun find(username: String, password: String, protectionSpaceId: Long?): URLCredential? {
        val id = protectionSpaceId ?: throw IllegalArgumentException("Protection space id is required.")
        val selection = URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME + " = ? AND " +
            URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + " = ? AND " +
            URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
        val selectionArgs = arrayOf(username, password, id.toString())

        return credentialDatabaseHelper.readableDatabase.query(
            URLCredentialContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        ).use { cursor ->
            if (!cursor.moveToNext()) return@use null
            val rowId = cursor.getLong(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry._ID))
            val rowUsername = cursor.getString(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME))
            val rowPassword = cursor.getString(cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD))
            URLCredential(rowId, rowUsername, rowPassword, id)
        }
    }

    open fun insert(urlCredential: URLCredential): Long {
        val credentialValues = ContentValues()
        putNullableString(credentialValues, URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME, urlCredential.getUsername())
        putNullableString(credentialValues, URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, urlCredential.getPassword())
        putNullableLong(credentialValues, URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID, urlCredential.getProtectionSpaceId())
        return credentialDatabaseHelper.writableDatabase.insert(
            URLCredentialContract.FeedEntry.TABLE_NAME,
            null,
            credentialValues
        )
    }

    open fun update(urlCredential: URLCredential): Long {
        val credentialValues = ContentValues()
        putNullableString(credentialValues, URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME, urlCredential.getUsername())
        putNullableString(credentialValues, URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, urlCredential.getPassword())

        val protectionSpaceId = urlCredential.getProtectionSpaceId()
            ?: throw IllegalArgumentException("Protection space id is required.")
        val whereClause = URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
        val whereArgs = arrayOf(protectionSpaceId.toString())
        return credentialDatabaseHelper.writableDatabase.update(
            URLCredentialContract.FeedEntry.TABLE_NAME,
            credentialValues,
            whereClause,
            whereArgs
        ).toLong()
    }

    open fun delete(urlCredential: URLCredential): Long {
        val id = urlCredential.getId() ?: throw IllegalArgumentException("Credential id is required.")
        val whereClause = URLCredentialContract.FeedEntry._ID + " = ?"
        val whereArgs = arrayOf(id.toString())
        return credentialDatabaseHelper.writableDatabase.delete(
            URLCredentialContract.FeedEntry.TABLE_NAME,
            whereClause,
            whereArgs
        ).toLong()
    }
}

private fun putNullableString(values: ContentValues, key: String, value: String?) {
    if (value == null) values.putNull(key) else values.put(key, value)
}

private fun putNullableLong(values: ContentValues, key: String, value: Long?) {
    if (value == null) values.putNull(key) else values.put(key, value)
}
