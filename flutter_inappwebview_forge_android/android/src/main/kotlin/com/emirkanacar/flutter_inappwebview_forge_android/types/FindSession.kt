package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class FindSession(
    open var resultCount: Int,
    open var highlightedResultIndex: Int
) {
    open var searchResultDisplayStyle: Int = 2

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("resultCount", resultCount)
        put("highlightedResultIndex", highlightedResultIndex)
        put("searchResultDisplayStyle", searchResultDisplayStyle)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as FindSession
        return resultCount == other.resultCount &&
            highlightedResultIndex == other.highlightedResultIndex &&
            searchResultDisplayStyle == other.searchResultDisplayStyle
    }

    open override fun hashCode(): Int {
        var result = resultCount
        result = 31 * result + highlightedResultIndex
        result = 31 * result + searchResultDisplayStyle
        return result
    }

    open override fun toString(): String =
        "FindSession{" +
            "resultCount=$resultCount, " +
            "highlightedResultIndex=$highlightedResultIndex, " +
            "searchResultDisplayStyle=$searchResultDisplayStyle}"
}
