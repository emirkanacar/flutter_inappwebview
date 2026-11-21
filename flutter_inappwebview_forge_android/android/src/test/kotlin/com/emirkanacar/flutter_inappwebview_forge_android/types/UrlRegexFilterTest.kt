package com.emirkanacar.flutter_inappwebview_forge_android.types

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class UrlRegexFilterTest {
    @Test
    fun emptyOrNullFilterMatchesEverything() {
        assertSame(UrlRegexFilter.NONE, UrlRegexFilter.compile(null))
        assertSame(UrlRegexFilter.NONE, UrlRegexFilter.compile(emptyList<String>()))
        assertTrue(UrlRegexFilter.NONE.matches("https://example.com/a.png"))
        assertTrue(UrlRegexFilter.NONE.matches(null))
    }

    @Test
    fun matchesWhenAnyPatternFindsAPartialMatch() {
        val filter = UrlRegexFilter.compile(
            listOf("^https://api\\.example\\.com/", "\\.json(\\?|$)")
        )
        assertFalse(filter.isEmpty)
        assertNull(filter.invalidPattern)
        assertTrue(filter.matches("https://api.example.com/v1/items"))
        assertTrue(filter.matches("https://cdn.example.com/data.json"))
        assertTrue(filter.matches("https://cdn.example.com/data.json?v=2"))
        assertFalse(filter.matches("https://cdn.example.com/logo.png"))
        assertFalse(filter.matches("https://evil.com/?https://api.example.com/"))
        assertFalse(filter.matches(null))
    }

    @Test
    fun invalidPatternDisablesTheWholeFilter() {
        val filter = UrlRegexFilter.compile(listOf("^https://ok/", "(unclosed"))
        assertTrue(filter.isEmpty)
        assertEquals("(unclosed", filter.invalidPattern)
        assertTrue(filter.matches("https://anything/"))
    }

    @Test
    fun nonStringEntryDisablesTheWholeFilter() {
        val filter = UrlRegexFilter.compile(listOf("^https://ok/", 42))
        assertTrue(filter.isEmpty)
        assertEquals("42", filter.invalidPattern)
        assertTrue(filter.matches("https://anything/"))
    }
}
