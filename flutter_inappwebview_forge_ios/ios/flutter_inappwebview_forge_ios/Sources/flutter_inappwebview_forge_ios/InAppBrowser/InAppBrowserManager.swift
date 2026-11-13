//
//  InAppBrowserManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 18/12/2019.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

public class InAppBrowserManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappbrowser"
    static let WEBVIEW_STORYBOARD = "WebView"
    static let WEBVIEW_STORYBOARD_CONTROLLER_ID = "viewController"
    static let NAV_STORYBOARD_CONTROLLER_ID = "navController"
    var plugin: InAppWebViewFlutterPlugin?

    var navControllers: [String: InAppBrowserNavigationController] = [:]
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: InAppBrowserManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            try handleThrowing(call, result: result)
        } catch {
            result(invalidArgumentsError(error, method: call.method))
        }
    }

    private func handleThrowing(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "open":
                try open(arguments: arguments)
                result(true)
                break
            case "openWithSystemBrowser":
                let url = try requiredArgument(arguments, "url", as: String.self)
                openWithSystemBrowser(url: url, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func prepareInAppBrowserWebViewController(settings: [String: Any?]) -> InAppBrowserWebViewController {
        let browserSettings = InAppBrowserSettings()
        let _ = browserSettings.parse(settings: settings)
        
        let webViewSettings = InAppWebViewSettings()
        let _ = webViewSettings.parse(settings: settings)
        
        let webViewController = InAppBrowserWebViewController()
        webViewController.plugin = plugin
        webViewController.browserSettings = browserSettings
        webViewController.isHidden = browserSettings.hidden
        webViewController.webViewSettings = webViewSettings
        return webViewController
    }
    
    public func open(arguments: NSDictionary?) throws {
        let id = try requiredArgument(arguments, "id", as: String.self)
        let urlRequest = arguments?["urlRequest"] as? [String:Any?]
        let assetFilePath = arguments?["assetFilePath"] as? String
        let data = arguments?["data"] as? String
        let mimeType = arguments?["mimeType"] as? String
        let encoding = arguments?["encoding"] as? String
        let baseUrl = arguments?["baseUrl"] as? String
        let settings = try requiredArgument(arguments, "settings", as: [String: Any?].self)
        let contextMenu = try requiredArgument(arguments, "contextMenu", as: [String: Any].self)
        let windowId = arguments?["windowId"] as? Int64
        let initialUserScripts = arguments?["initialUserScripts"] as? [[String: Any]]
        let pullToRefreshInitialSettings = try requiredArgument(arguments, "pullToRefreshSettings", as: [String: Any?].self)
        let menuItems = try requiredArgument(arguments, "menuItems", as: [[String: Any?]].self)
        
        let webViewController = prepareInAppBrowserWebViewController(settings: settings)
        
        webViewController.id = id
        webViewController.initialUrlRequest = urlRequest != nil ? URLRequest.init(fromPluginMap: urlRequest!) : nil
        webViewController.initialFile = assetFilePath
        webViewController.initialData = data
        webViewController.initialMimeType = mimeType
        webViewController.initialEncoding = encoding
        webViewController.initialBaseUrl = baseUrl
        webViewController.contextMenu = contextMenu
        webViewController.windowId = windowId
        webViewController.initialUserScripts = initialUserScripts ?? []
        webViewController.pullToRefreshInitialSettings = pullToRefreshInitialSettings
        for menuItem in menuItems {
            webViewController.menuItems.append(InAppBrowserMenuItem.fromMap(map: menuItem)!)
        }
        
        presentViewController(webViewController: webViewController)
    }
    
    public func presentViewController(webViewController: InAppBrowserWebViewController) {
        #if SWIFT_PACKAGE
            let storyboard = UIStoryboard(name: InAppBrowserManager.WEBVIEW_STORYBOARD, bundle: Bundle.module)
        #else
            let storyboard = UIStoryboard(name: InAppBrowserManager.WEBVIEW_STORYBOARD, bundle: Bundle(for: InAppWebViewFlutterPlugin.self))
        #endif
        let navController = storyboard.instantiateViewController(withIdentifier: InAppBrowserManager.NAV_STORYBOARD_CONTROLLER_ID) as! InAppBrowserNavigationController
        webViewController.edgesForExtendedLayout = []
        navController.pushViewController(webViewController, animated: false)
        webViewController.prepareNavigationControllerBeforeViewWillAppear()
        
        guard let visibleViewController = UIApplication.shared.visibleViewController else {
            assertionFailure("Failure init the visibleViewController!")
            return
        }
        
        if let popover = webViewController.popoverPresentationController {
            let sourceView = visibleViewController.view ?? UIView()

            popover.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
            popover.sourceView = sourceView
        }

        if let browserSettings = webViewController.browserSettings, browserSettings.hidden {
            webViewController.loadViewIfNeeded()
        } else {
            visibleViewController.present(navController, animated: true)
        }
        
        navControllers[webViewController.id] = navController
    }
    
    public func openWithSystemBrowser(url: String, result: @escaping FlutterResult) {
        guard let absoluteUrl = URL(string: url)?.absoluteURL else {
            result(FlutterError(code: "InAppBrowserManager", message: url + " cannot be opened!", details: nil))
            return
        }
        UIApplication.shared.open(absoluteUrl, options: [:]) { success in
            if success {
                result(true)
            } else {
                result(FlutterError(code: "InAppBrowserManager", message: url + " cannot be opened!", details: nil))
            }
        }
    }
    
    public override func dispose() {
        super.dispose()
        let navControllersValues = Array(navControllers.values)
        navControllers.removeAll()
        navControllersValues.forEach { (navController: InAppBrowserNavigationController) in
            navController.dismiss(animated: false)
        }
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
