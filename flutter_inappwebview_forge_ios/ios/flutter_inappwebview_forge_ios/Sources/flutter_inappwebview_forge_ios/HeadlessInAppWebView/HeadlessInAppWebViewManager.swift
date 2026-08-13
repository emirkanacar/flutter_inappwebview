//
//  HeadlessInAppWebViewManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 10/05/2020.
//

import Foundation

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

public class HeadlessInAppWebViewManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_headless_inappwebview"
    var plugin: InAppWebViewFlutterPlugin?
    var webViews: [String: HeadlessInAppWebView] = [:]
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: HeadlessInAppWebViewManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let id: String = arguments!["id"] as! String

        switch call.method {
            case "run":
                let params = arguments!["params"] as! [String: Any?]
                run(id: id, params: params)
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func run(id: String, params: [String: Any?]) {
        guard let plugin = plugin else {
            return
        }
        webViews.removeValue(forKey: id)?.dispose()
        // Headless and regular WebViews share the native id namespace. Remove
        // and dispose the active owner before registering the replacement so a
        // duplicate id cannot leave a stale channel or WebView reachable.
        if let previousWebView = plugin.inAppWebViewManager?.webViews.removeValue(forKey: id) {
            previousWebView.dispose()
        }
        let flutterWebView = FlutterWebViewController(plugin: plugin,
            withFrame: CGRect.zero,
            viewIdentifier: id,
            params: params as NSDictionary)
        let headlessInAppWebView = HeadlessInAppWebView(plugin: plugin, id: id, flutterWebView: flutterWebView)
        webViews[id] = headlessInAppWebView
        
        headlessInAppWebView.prepare(params: params as NSDictionary)
        headlessInAppWebView.onWebViewCreated()
        flutterWebView.makeInitialLoad(params: params as NSDictionary)
    }
    
    public override func dispose() {
        super.dispose()
        let headlessWebViews = Array(webViews.values)
        webViews.removeAll()
        headlessWebViews.forEach { $0.dispose() }
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
