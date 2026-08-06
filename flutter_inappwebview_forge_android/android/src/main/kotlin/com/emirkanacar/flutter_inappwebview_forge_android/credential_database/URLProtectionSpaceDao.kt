package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.content.ContentValues
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLProtectionSpace

open class URLProtectionSpaceDao(
    private val credentialDatabaseHelper: CredentialDatabaseHelper
) {
    private val projection = arrayOf(
        URLProtectionSpaceContract.FeedEntry._ID,
        URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST,
        URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL,
        URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM,
        URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT
    )

    open fun getAll(): MutableList<URLProtectionSpace> =
        credentialDatabaseHelper.readableDatabase.query(
            URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
            projection,
            null,
            null,
            null,
            null,
            null
        ).use { cursor ->
            val protectionSpaces = mutableListOf<URLProtectionSpace>()
            while (cursor.moveToNext()) {
                protectionSpaces.add(readProtectionSpace(cursor))
            }
            protectionSpaces
        }

    open fun find(
        host: String,
        protocol: String,
        realm: String?,
        port: Int?
    ): URLProtectionSpace? {
        val portValue = port ?: throw IllegalArgumentException("Protection space port is required.")
        val selection = URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + " = ? AND " +
            URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + " = ? AND " +
            URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + " = ? AND " +
            URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + " = ?"
        val selectionArgs = arrayOf(host, protocol, realm, portValue.toString())

        return credentialDatabaseHelper.readableDatabase.query(
            URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        ).use { cursor ->
            if (!cursor.moveToNext()) return@use null
            readProtectionSpace(cursor)
        }
    }

    open fun insert(protectionSpace: URLProtectionSpace): Long {
        val values = ContentValues()
        values.put(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST, protectionSpace.host)
        values.put(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL, protectionSpace.protocol)
        if (protectionSpace.realm == null) {
            values.putNull(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM)
        } else {
            values.put(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM, protectionSpace.realm)
        }
        values.put(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT, protectionSpace.port)
        return credentialDatabaseHelper.writableDatabase.insert(
            URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
            null,
            values
        )
    }

    open fun delete(protectionSpace: URLProtectionSpace): Long {
        val id = protectionSpace.id ?: throw IllegalArgumentException("Protection space id is required.")
        val whereClause = URLProtectionSpaceContract.FeedEntry._ID + " = ?"
        val whereArgs = arrayOf(id.toString())
        return credentialDatabaseHelper.writableDatabase.delete(
            URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
            whereClause,
            whereArgs
        ).toLong()
    }

    private fun readProtectionSpace(cursor: android.database.Cursor): URLProtectionSpace {
        val rowId = cursor.getLong(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry._ID))
        val rowHost = cursor.getString(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST))
        val rowProtocol = cursor.getString(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL))
        val rowRealm = cursor.getString(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM))
        val rowPort = cursor.getInt(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT))
        return URLProtectionSpace(rowId, rowHost, rowProtocol, rowRealm, rowPort)
    }
}
