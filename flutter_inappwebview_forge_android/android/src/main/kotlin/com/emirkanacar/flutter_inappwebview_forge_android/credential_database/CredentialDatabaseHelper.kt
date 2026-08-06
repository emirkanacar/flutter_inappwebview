package com.emirkanacar.flutter_inappwebview_forge_android.credential_database

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

open class CredentialDatabaseHelper(context: Context) :
    SQLiteOpenHelper(context, CredentialDatabase.DATABASE_NAME, null, CredentialDatabase.DATABASE_VERSION) {

    private companion object {
        val SQL_CREATE_PROTECTION_SPACE_TABLE =
            "CREATE TABLE " + URLProtectionSpaceContract.FeedEntry.TABLE_NAME + " (" +
                URLProtectionSpaceContract.FeedEntry._ID + " INTEGER PRIMARY KEY," +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + " TEXT NOT NULL," +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + " TEXT," +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + " TEXT," +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + " INTEGER," +
                "UNIQUE(" + URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + ", " +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + ", " +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + ", " +
                URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + ")" +
                ");"

        val SQL_CREATE_CREDENTIAL_TABLE =
            "CREATE TABLE " + URLCredentialContract.FeedEntry.TABLE_NAME + " (" +
                URLCredentialContract.FeedEntry._ID + " INTEGER PRIMARY KEY," +
                URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME + " TEXT NOT NULL," +
                URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + " TEXT NOT NULL," +
                URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " INTEGER NOT NULL," +
                "UNIQUE(" + URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME + ", " +
                URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + ", " +
                URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + ")," +
                "FOREIGN KEY (" + URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID +") REFERENCES " +
                URLProtectionSpaceContract.FeedEntry.TABLE_NAME + " (" +
                URLProtectionSpaceContract.FeedEntry._ID + ") ON DELETE CASCADE" +
                ");"

        val SQL_DELETE_PROTECTION_SPACE_TABLE =
            "DROP TABLE IF EXISTS " + URLProtectionSpaceContract.FeedEntry.TABLE_NAME

        val SQL_DELETE_CREDENTIAL_TABLE =
            "DROP TABLE IF EXISTS " + URLCredentialContract.FeedEntry.TABLE_NAME
    }

    open override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(SQL_CREATE_PROTECTION_SPACE_TABLE)
        db.execSQL(SQL_CREATE_CREDENTIAL_TABLE)
    }

    open override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // This database is only a cache for online data, so discard it on upgrade.
        db.execSQL(SQL_DELETE_PROTECTION_SPACE_TABLE)
        db.execSQL(SQL_DELETE_CREDENTIAL_TABLE)
        onCreate(db)
    }

    open override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        onUpgrade(db, oldVersion, newVersion)
    }

    open fun clearAllTables(db: SQLiteDatabase) {
        db.execSQL(SQL_DELETE_PROTECTION_SPACE_TABLE)
        db.execSQL(SQL_DELETE_CREDENTIAL_TABLE)
        onCreate(db)
    }
}
