//
//  ChannelEventFilter.swift
//  flutter_inappwebview_forge
//

import Foundation

/// Fire-and-forget WebView channel events that Dart reported as having no
/// listener, so they are not encoded or sent over the platform channel.
///
/// Dart sends the list in the `skippedEvents` creation parameter of every
/// platform-view creation (new, KeepAlive reuse, and headless transfer), so
/// the filter always matches the callbacks of the widget that currently owns
/// the WebView. A missing or malformed value clears the filter and every event
/// is sent, which is the pre-filter behavior.
///
/// Only notifications whose Dart handler is a no-op without a listener are
/// accepted. Callbacks that wait for a Dart result are never filtered.
public class ChannelEventFilter {
    static let CREATION_PARAM = "skippedEvents"

    static let SKIPPABLE_EVENTS: Set<String> = [
        "onConsoleMessage",
        "onScrollChanged",
        "onProgressChanged",
        "onTitleChanged",
        "onOverScrolled",
        "onZoomScaleChanged"
    ]

    private var skipped: Set<String> = []

    public init() {}

    public func update(_ raw: Any?) {
        guard let names = raw as? [Any] else {
            skipped = []
            return
        }
        skipped = Set(names.compactMap { $0 as? String })
            .intersection(ChannelEventFilter.SKIPPABLE_EVENTS)
    }

    public func isSkipped(_ method: String) -> Bool {
        return skipped.contains(method)
    }
}
