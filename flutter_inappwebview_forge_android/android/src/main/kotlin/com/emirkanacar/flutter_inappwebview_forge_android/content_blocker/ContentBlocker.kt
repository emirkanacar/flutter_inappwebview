package com.emirkanacar.flutter_inappwebview_forge_android.content_blocker

class ContentBlocker(
    var trigger: ContentBlockerTrigger,
    var action: ContentBlockerAction
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ContentBlocker) return false
        return trigger == other.trigger && action == other.action
    }

    override fun hashCode(): Int = 31 * trigger.hashCode() + action.hashCode()

    override fun toString(): String = "ContentBlocker{trigger=$trigger, action=$action}"
}
