//
//  InAppWebViewManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/12/2019.
//

import Foundation
import WebKit
import Flutter

public class InAppWebViewManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_manager"
    var plugin: InAppWebViewFlutterPlugin?
    var webViewForUserAgent: WKWebView?
    var defaultUserAgent: String?
    
    var keepAliveWebViews: [String:FlutterWebViewController] = [:]
    var webViews: [String: InAppWebView] = [:]
    var windowWebViews: [Int64:WebViewTransport] = [:]
    var windowAutoincrementId: Int64 = 0
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: InAppWebViewManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
            case "getDefaultUserAgent":
                getDefaultUserAgent(completionHandler: { (value) in
                    result(value)
                })
                break
            case "handlesURLScheme":
                let urlScheme = arguments!["urlScheme"] as! String
                if #available(iOS 11.0, *) {
                    result(WKWebView.handlesURLScheme(urlScheme))
                } else {
                    result(false)
                }
                break
            case "disposeKeepAlive":
                let keepAliveId = arguments!["keepAliveId"] as! String
                disposeKeepAlive(keepAliveId: keepAliveId)
                result(true)
                break
            case "clearAllCache":
                let includeDiskFiles = arguments!["includeDiskFiles"] as! Bool
                clearAllCache(includeDiskFiles: includeDiskFiles, completionHandler: {
                    result(true)
                })
            case "setJavaScriptBridgeName":
                let bridgeName = arguments!["bridgeName"] as! String
                JavaScriptBridgeJS.set_JAVASCRIPT_BRIDGE_NAME(bridgeName: bridgeName)
                result(true)
                break
            case "getJavaScriptBridgeName":
                result(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func getDefaultUserAgent(completionHandler: @escaping (_ value: String?) -> Void) {
        if defaultUserAgent == nil {
            webViewForUserAgent = WKWebView()
            webViewForUserAgent?.evaluateJavaScript("navigator.userAgent") { (value, error) in

                if error != nil {
                    print("Error occurred to get userAgent")
                    self.webViewForUserAgent = nil
                    completionHandler(nil)
                    return
                }

                if let unwrappedUserAgent = value as? String {
                    self.defaultUserAgent = unwrappedUserAgent
                    completionHandler(self.defaultUserAgent)
                } else {
                    print("Failed to get userAgent")
                }
                self.webViewForUserAgent = nil
            }
        } else {
            completionHandler(defaultUserAgent)
        }
    }
    
    public func disposeKeepAlive(keepAliveId: String) {
        guard let flutterWebView = keepAliveWebViews.removeValue(forKey: keepAliveId) else {
            return
        }
        flutterWebView.keepAliveId = nil
        flutterWebView.dispose(removeFromSuperview: true)
    }

    func registerKeepAlive(keepAliveId: String, flutterWebView: FlutterWebViewController) {
        let previousWebView = keepAliveWebViews.updateValue(flutterWebView, forKey: keepAliveId)
        if let previousWebView = previousWebView, previousWebView !== flutterWebView {
            previousWebView.keepAliveId = nil
            previousWebView.dispose(removeFromSuperview: true)
        }
    }
    
    public func clearAllCache(includeDiskFiles: Bool, completionHandler: @escaping () -> Void) {
        if #available(iOS 9.0, *) {
            var websiteDataTypes = Set([WKWebsiteDataTypeMemoryCache])
            if includeDiskFiles {
                websiteDataTypes.insert(WKWebsiteDataTypeDiskCache)
                if #available(iOS 11.3, *) {
                    websiteDataTypes.insert(WKWebsiteDataTypeFetchCache)
                }
                websiteDataTypes.insert(WKWebsiteDataTypeOfflineWebApplicationCache)
            }
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date as Date, completionHandler: completionHandler)
        } else {
            URLCache.shared.removeAllCachedResponses()
            completionHandler()
        }
    }
    
    public override func dispose() {
        super.dispose()
        let keepAliveWebViewValues = Array(keepAliveWebViews.values)
        let activeWebViewValues = Array(webViews.values)
        keepAliveWebViews.removeAll()
        webViews.removeAll()
        keepAliveWebViewValues.forEach { keepAliveWebView in
            keepAliveWebView.keepAliveId = nil
            keepAliveWebView.dispose(removeFromSuperview: true)
        }
        activeWebViewValues.forEach { webView in
            if !keepAliveWebViewValues.contains(where: { $0.webView() === webView }) {
                webView.dispose()
            }
        }
        windowWebViews.removeAll()
        webViewForUserAgent = nil
        defaultUserAgent = nil
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
