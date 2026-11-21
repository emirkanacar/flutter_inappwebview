//
//  InAppWebView+KeyboardFocus.swift
//  flutter_inappwebview_forge
//
//  Keyboard and VoiceOver focus going into and out of the page
//  (InAppWebViewSettings.enableAccessibilityFocus, default false).
//
//  The web view is a Flutter platform view. Flutter focus can stand on it, but
//  nothing makes the web view AppKit's first responder, so Tab stops on it
//  without getting into the page, and VoiceOver, which follows the first
//  responder and finds only an empty group for the view in the Flutter
//  semantics tree, cannot read the page. With the setting on, the Dart side
//  (MacOSInAppWebViewWidget) moves the first responder with Flutter focus.
//  With the setting off every entry point here keeps the earlier behavior.
//

import AppKit
import WebKit

extension InAppWebView {
    var isAccessibilityFocusEnabled: Bool {
        return settings?.enableAccessibilityFocus == true
    }

    /// The Flutter view hosting the web view. It is the first responder whenever Flutter has
    /// the keyboard.
    var flutterHostView: NSView? {
        var view = superview
        while let current = view {
            if String(describing: type(of: current)).contains("FlutterView") {
                return current
            }
            view = current.superview
        }
        return nil
    }

    private var hasKeyboardFocus: Bool {
        guard let responder = window?.firstResponder as? NSView else { return false }
        return responder === self || responder.isDescendant(of: self)
    }

    /// Gives the page the keyboard focus. `"next"` starts at its first focusable element
    /// (Tab came forward into it), `"previous"` at its last one (Shift+Tab), anything else
    /// at the page itself (for example, VoiceOver moved onto it).
    ///
    /// WebKit chooses the first or last element itself: a web view that becomes first
    /// responder through the window's key view loop sets its initial focus by the direction
    /// of the loop. The loop is pointed through the web view only for the moment of the move.
    func focusPage(direction: String?) {
        guard isAccessibilityFocusEnabled, let window = window, !hasKeyboardFocus else { return }
        if let host = flutterHostView {
            if direction == "next" {
                let saved = host.nextKeyView
                host.nextKeyView = self
                window.selectKeyView(following: host)
                host.nextKeyView = saved
            } else if direction == "previous" {
                let saved = nextKeyView
                nextKeyView = host
                window.selectKeyView(preceding: host)
                nextKeyView = saved
            }
        }
        if !hasKeyboardFocus {
            window.makeFirstResponder(self)
        }
    }

    /// Flutter focus left the web view: the keyboard goes back to Flutter.
    func releasePage() {
        guard isAccessibilityFocusEnabled, let window = window, hasKeyboardFocus,
              let host = flutterHostView else { return }
        window.makeFirstResponder(host)
    }

    /// WKUIDelegate (private): Tab went past the last focusable element of the page
    /// (Shift+Tab before the first one). `direction` is `_WKFocusDirection` (0 backward,
    /// 1 forward).
    ///
    /// With the setting off this does what WebKit does when the delegate does not implement
    /// the method: it walks the window's key view loop. With it on, the keyboard goes back
    /// to Flutter and Flutter focus continues in its own order.
    @objc(_webView:takeFocus:)
    func webView(_ webView: WKWebView, takeFocus direction: Int) {
        let forward = direction == 1
        guard isAccessibilityFocusEnabled else {
            if forward {
                window?.selectKeyView(following: self)
            } else {
                window?.selectKeyView(preceding: self)
            }
            return
        }
        if let host = flutterHostView {
            window?.makeFirstResponder(host)
        }
        channelDelegate?._onTakeFocus(forward: forward)
    }
}
