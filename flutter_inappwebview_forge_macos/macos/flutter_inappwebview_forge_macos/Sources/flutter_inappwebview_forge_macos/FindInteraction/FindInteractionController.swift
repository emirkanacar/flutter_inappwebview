//
//  FindInteractionController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/10/22.
//

import Foundation
import FlutterMacOS
import WebKit

public class FindInteractionController: NSObject, Disposable {
    
    static var METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_inappwebview_find_interaction_";
    var plugin: InAppWebViewFlutterPlugin?
    var webView: InAppWebView?
    var channelDelegate: FindInteractionChannelDelegate?
    var settings: FindInteractionSettings?
    var shouldCallOnRefresh = false
    var searchText: String?
    var activeFindSession: FindSession?
    
    public init(plugin: InAppWebViewFlutterPlugin, id: Any, webView: InAppWebView, settings: FindInteractionSettings?) {
        super.init()
        self.plugin = plugin
        self.webView = webView
        self.settings = settings
        let channel = FlutterMethodChannel(name: FindInteractionController.METHOD_CHANNEL_NAME_PREFIX + String(describing: id),
                                           binaryMessenger: plugin.registrar.messenger)
        self.channelDelegate = FindInteractionChannelDelegate(findInteractionController: self, channel: channel)
    }
    
    public func prepare() {
//        if let settings = settings {
//
//        }
    }
    
    public func findAll(find: String?, completionHandler: ((Any?, Error?) -> Void)?) {
        guard let webView else {
            if let completionHandler = completionHandler {
                completionHandler(nil, nil)
            }
            return
        }
        
        var find = find
        if find == nil {
            find = searchText
        } else {
            // updated searchText
            searchText = find
        }
        
        guard let find else {
            if let completionHandler = completionHandler {
                completionHandler(nil, nil)
            }
            return
        }
        
        if find != "" {
            let startSearch = "window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findAllAsync('\(find)');"
            webView.evaluateJavaScript(startSearch, completionHandler: completionHandler)
        }
    }

    public func findNext(forward: Bool, completionHandler: ((Any?, Error?) -> Void)?) {
        guard let webView else {
            if let completionHandler = completionHandler {
                completionHandler(nil, nil)
            }
            return
        }
        webView.evaluateJavaScript("window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._findNext(\(forward ? "true" : "false"));", completionHandler: completionHandler)
    }

    public func clearMatches(completionHandler: ((Any?, Error?) -> Void)?) {
        guard let webView else {
            if let completionHandler = completionHandler {
                completionHandler(nil, nil)
            }
            return
        }
        webView.evaluateJavaScript("window.\(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())._clearMatches();", completionHandler: completionHandler)
    }

    public func findString(
        find: String,
        caseSensitive: Bool,
        backwards: Bool,
        wraps: Bool,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        guard let webView else {
            completionHandler(false, nil)
            return
        }
        if #available(macOS 11.0, *) {
            let configuration = WKFindConfiguration()
            configuration.caseSensitive = caseSensitive
            configuration.backwards = backwards
            configuration.wraps = wraps
            webView.find(find, configuration: configuration) { result in
                completionHandler(result.matchFound, nil)
            }
        } else {
            completionHandler(false, nil)
        }
    }
    
    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        webView = nil
        activeFindSession = nil
        plugin = nil
    }
    
    deinit {
        debugPrint("FindInteractionControl - dealloc")
        dispose()
    }
}
