package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.regex.Pattern
import java.util.regex.PatternSyntaxException

/**
 * Compiled URL filter for `shouldInterceptRequestUrlFilter`.
 *
 * An empty filter matches every URL. A URL matches when at least one pattern
 * finds a partial match. Patterns are compiled once; [Pattern] is thread-safe,
 * so [matches] can be called from WebView's background request threads.
 */
class UrlRegexFilter private constructor(
    private val patterns: List<Pattern>,
    /** The first source that could not be compiled, or null. */
    val invalidPattern: String?
) {
    val isEmpty: Boolean
        get() = patterns.isEmpty()

    fun matches(url: String?): Boolean {
        if (patterns.isEmpty()) return true
        if (url == null) return false
        for (pattern in patterns) {
            if (pattern.matcher(url).find()) return true
        }
        return false
    }

    companion object {
        @JvmField
        val NONE = UrlRegexFilter(emptyList(), null)

        /**
         * Compiles [sources]. A null/non-String entry or an invalid regular
         * expression disables the whole filter (every URL matches), so a typo
         * never hides requests that the app expects to intercept.
         */
        @JvmStatic
        fun compile(sources: List<*>?): UrlRegexFilter {
            if (sources.isNullOrEmpty()) return NONE
            val patterns = ArrayList<Pattern>(sources.size)
            for (source in sources) {
                if (source !is String) {
                    return UrlRegexFilter(emptyList(), source.toString())
                }
                try {
                    patterns.add(Pattern.compile(source))
                } catch (_: PatternSyntaxException) {
                    return UrlRegexFilter(emptyList(), source)
                }
            }
            return UrlRegexFilter(patterns, null)
        }
    }
}
