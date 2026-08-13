//
//  HeadlessInAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 26/03/21.
//

import Foundation
import Flutter
import UIKit

public class HeadlessInAppWebView: Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_headless_inappwebview_"

    var id: String
    var channelDelegate: HeadlessWebViewChannelDelegate?
    var flutterWebView: FlutterWebViewController?
    var plugin: InAppWebViewFlutterPlugin?
    private let lifecycle = WebViewLifecycleCoordinator()
    
    public init(plugin: InAppWebViewFlutterPlugin, id: String, flutterWebView: FlutterWebViewController) {
        self.id = id
        self.flutterWebView = flutterWebView
        self.plugin = plugin
        let channel = FlutterMethodChannel(name: HeadlessInAppWebView.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = HeadlessWebViewChannelDelegate(headlessWebView: self, channel: channel)
    }
    
    public func onWebViewCreated() {
        channelDelegate?.onWebViewCreated()
    }

    func acceptsCallbacks() -> Bool {
        lifecycle.acceptsCallbacks
    }
    
    public func prepare(params: NSDictionary) {
        guard lifecycle.beginPreparing() else { return }
        if let view = flutterWebView?.view() {
            view.alpha = 0.01
            let initialSize = params["initialSize"] as? [String: Any?]
            if let size = Size2D.fromMap(map: initialSize) {
                setSize(size: size)
            } else {
                view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            if let keyWindow = UIApplication.shared.activeKeyWindow {
                /// Note: The WKWebView behaves very unreliable when rendering offscreen
                /// on a device. This is especially true with JavaScript, which simply
                /// won't be executed sometimes.
                /// So, add the headless WKWebView to the view hierarchy.
                /// This way is also possible to take screenshots.
                keyWindow.insertSubview(view, at: 0)
                keyWindow.sendSubviewToBack(view)
            }
        }
        lifecycle.markAttached()
        lifecycle.markReady()
    }
    
    public func setSize(size: Size2D) {
        if let view = flutterWebView?.view() {
            let width = size.width == -1.0 ? UIScreen.main.bounds.width : CGFloat(size.width)
            let height = size.height == -1.0 ? UIScreen.main.bounds.height : CGFloat(size.height)
            view.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
    }
    
    public func getSize() -> Size2D? {
        if let view = flutterWebView?.view() {
            return Size2D(width: Double(view.frame.width), height: Double(view.frame.height))
        }
        return nil
    }
    
    public func disposeAndGetFlutterWebView(withFrame frame: CGRect) -> FlutterWebViewController? {
        let newFlutterWebView = flutterWebView
        guard let currentFlutterWebView = flutterWebView,
              let view = currentFlutterWebView.myView else {
            // A headless entry without a native view cannot be transferred.
            // Dispose it instead of returning an owner that is no longer
            // reachable from a manager.
            dispose()
            return nil
        }
        if let webView = currentFlutterWebView.webView(),
           let manager = plugin?.inAppWebViewManager,
           let webViewID = webView.id,
           manager.webViews[String(describing: webViewID)] === webView {
            manager.webViews.removeValue(forKey: String(describing: webViewID))
        }
        // restore WebView frame and alpha
        view.frame = frame
        view.alpha = 1.0
        // remove from parent
        view.removeFromSuperview()
        currentFlutterWebView.webView()?.markRetainedWebViewDetached()
        dispose(disposeWebView: false)
        return newFlutterWebView
    }
    
    public func dispose(disposeWebView: Bool) {
        guard lifecycle.beginDisposal() else { return }
        defer { lifecycle.finishDisposal() }

        channelDelegate?.dispose()
        channelDelegate = nil
        if plugin?.headlessInAppWebViewManager?.webViews[id] === self {
            plugin?.headlessInAppWebViewManager?.webViews.removeValue(forKey: id)
        }
        if disposeWebView {
            flutterWebView?.dispose(removeFromSuperview: true)
        }
        flutterWebView = nil
        plugin = nil
    }
    
    public func dispose() {
        dispose(disposeWebView: true)
    }
    
    deinit {
        debugPrint("HeadlessInAppWebView - dealloc")
        dispose()
    }
}
