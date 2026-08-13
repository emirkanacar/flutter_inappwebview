//
//  FlutterWebViewFactory.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 13/11/18.
//

import Flutter
import Foundation

public class FlutterWebViewFactory: NSObject, FlutterPlatformViewFactory {
    static let VIEW_TYPE_ID = "com.emirkanacar/flutter_inappwebview"
    
    private var plugin: InAppWebViewFlutterPlugin
    
    init(plugin: InAppWebViewFlutterPlugin) {
        self.plugin = plugin
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary
        var flutterWebView: FlutterWebViewController?
        var id: Any = viewId
        var transferredFromHeadless = false
        
        let keepAliveId = arguments?["keepAliveId"] as? String
        let headlessWebViewId = arguments?["headlessWebViewId"] as? String
        let preventGestureDelay = arguments?["preventGestureDelay"] as? Bool ?? false
        
        if let headlessWebViewId = headlessWebViewId,
           let headlessWebView = plugin.headlessInAppWebViewManager?.webViews.removeValue(forKey: headlessWebViewId) {
            // Detach ownership before moving the native view into the platform
            // view. A later manager teardown must not dispose the transferred
            // instance through the old headless owner.
            if let platformView = headlessWebView.disposeAndGetFlutterWebView(withFrame: frame) {
                flutterWebView = platformView
                transferredFromHeadless = true
                flutterWebView?.keepAliveId = keepAliveId
            } else {
                // A stale headless entry must be cleaned up rather than being
                // silently dropped from the manager.
                headlessWebView.dispose()
            }
        }
        
        if let keepAliveId = keepAliveId,
           flutterWebView == nil,
           let keepAliveWebView = plugin.inAppWebViewManager?.keepAliveWebViews[keepAliveId] {
            flutterWebView = keepAliveWebView
            if let view = flutterWebView?.view() {
                // remove from parent
                view.removeFromSuperview()
            }
        }
        
        let shouldMakeInitialLoad = flutterWebView == nil
        if flutterWebView == nil {
            if let keepAliveId = keepAliveId {
                id = keepAliveId
            }
            flutterWebView = FlutterWebViewController(plugin: plugin,
                                                      withFrame: frame,
                                                      viewIdentifier: id,
                                                      params: arguments!)
        }
        
        if let keepAliveId = keepAliveId {
            plugin.inAppWebViewManager?.registerKeepAlive(keepAliveId: keepAliveId,
                                                          flutterWebView: flutterWebView!)
        }

        if transferredFromHeadless,
           let transferredWebView = flutterWebView?.webView(),
           let transferredWebViewID = transferredWebView.id {
            plugin.inAppWebViewManager?.webViews[String(describing: transferredWebViewID)] = transferredWebView
        }
        
        flutterWebView?.webView()?.preventGestureDelay = preventGestureDelay
        
        if shouldMakeInitialLoad {
            flutterWebView?.makeInitialLoad(params: arguments!)
        }

        flutterWebView?.webView()?.markRetainedWebViewReattached()
        
        return flutterWebView!
    }
}
