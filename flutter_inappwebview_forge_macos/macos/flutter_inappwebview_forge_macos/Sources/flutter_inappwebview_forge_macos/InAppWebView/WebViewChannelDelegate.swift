//
//  WebViewChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 06/05/22.
//

import Foundation
import WebKit
import FlutterMacOS

public class WebViewChannelDelegate: ChannelDelegate {
    private weak var webView: InAppWebView?
    
    public init(webView: InAppWebView, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.webView = webView
    }

    private func canDispatchCallbacks() -> Bool {
        guard channel != nil, let webView = webView else { return false }
        return webView.acceptsCallbacks()
    }

    private func invokeMethod(_ method: String, arguments: Any) {
        guard canDispatchCallbacks(), let channel = channel else { return }
        channel.invokeMethod(method, arguments: arguments)
    }

    private func invokeMethod(_ method: String, arguments: Any, callback: MethodChannelResult) {
        guard canDispatchCallbacks(), let channel = channel else {
            callback.success(nil)
            return
        }
        channel.invokeMethod(method, arguments: arguments, callback: callback)
    }

    private func invokeMethod(_ method: String, arguments: Any, result: @escaping FlutterResult) {
        guard canDispatchCallbacks(), let channel = channel else {
            result(nil)
            return
        }
        channel.invokeMethod(method, arguments: arguments, result: result)
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            try handleThrowing(call, result: result)
        } catch {
            result(invalidArgumentsError(error, method: call.method))
        }
    }

    private func handleThrowing(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard webView?.acceptsCallbacks() == true else {
            result(nil)
            return
        }
        let arguments = call.arguments as? NSDictionary
        
        guard let method = WebViewChannelDelegateMethods.init(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        switch method {
        case .getUrl:
            result(webView?.url?.absoluteString)
            break
        case .getTitle:
            result(webView?.title)
            break
        case .getProgress:
            result( (webView != nil) ? Int(webView!.estimatedProgress * 100) : nil )
            break
        case .loadUrl:
            let urlRequest = try requiredArgument(arguments, "urlRequest", as: [String:Any?].self)
            let allowingReadAccessTo = arguments?["allowingReadAccessTo"] as? String
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = allowingReadAccessTo {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
            }
            webView?.loadUrl(urlRequest: URLRequest.init(fromPluginMap: urlRequest), allowingReadAccessTo: allowingReadAccessToURL)
            result(true)
            break
        case .postUrl:
            if let webView = webView {
                let url = try requiredArgument(arguments, "url", as: String.self)
                let postData = try requiredArgument(arguments, "postData", as: FlutterStandardTypedData.self)
                webView.postUrl(url: URL(string: url)!, postData: postData.data)
            }
            result(true)
            break
        case .loadData:
            let data = try requiredArgument(arguments, "data", as: String.self)
            let mimeType = try requiredArgument(arguments, "mimeType", as: String.self)
            let encoding = try requiredArgument(arguments, "encoding", as: String.self)
            let baseUrl = URL(string: try requiredArgument(arguments, "baseUrl", as: String.self))!
            let allowingReadAccessTo = arguments?["allowingReadAccessTo"] as? String
            var allowingReadAccessToURL: URL? = nil
            if let allowingReadAccessTo = allowingReadAccessTo {
                allowingReadAccessToURL = URL(string: allowingReadAccessTo)
            }
            webView?.loadData(data: data, mimeType: mimeType, encoding: encoding, baseUrl: baseUrl, allowingReadAccessTo: allowingReadAccessToURL)
            result(true)
            break
        case .loadFile:
            let assetFilePath = try requiredArgument(arguments, "assetFilePath", as: String.self)
            
            do {
                try webView?.loadFile(assetFilePath: assetFilePath)
            }
            catch let error as NSError {
                result(FlutterError(code: "WebViewChannelDelegate", message: error.domain, details: nil))
                return
            }
            result(true)
            break
        case .evaluateJavascript:
            if let webView = webView {
                let source = try requiredArgument(arguments, "source", as: String.self)
                let contentWorldMap = arguments?["contentWorld"] as? [String:Any?]
                if #available(macOS 11.0, *), let contentWorldMap = contentWorldMap {
                    let contentWorld = WKContentWorld.fromMap(map: contentWorldMap, windowId: webView.windowId)!
                    webView.evaluateJavascript(source: source, contentWorld: contentWorld) { (value) in
                        result(value)
                    }
                } else {
                    webView.evaluateJavascript(source: source) { (value) in
                        result(value)
                    }
                }
            }
            else {
                result(nil)
            }
            break
        case .injectJavascriptFileFromUrl:
            let urlFile = try requiredArgument(arguments, "urlFile", as: String.self)
            let scriptHtmlTagAttributes = arguments?["scriptHtmlTagAttributes"] as? [String:Any?]
            webView?.injectJavascriptFileFromUrl(urlFile: urlFile, scriptHtmlTagAttributes: scriptHtmlTagAttributes)
            result(true)
            break
        case .injectCSSCode:
            let source = try requiredArgument(arguments, "source", as: String.self)
            webView?.injectCSSCode(source: source)
            result(true)
            break
        case .injectCSSFileFromUrl:
            let urlFile = try requiredArgument(arguments, "urlFile", as: String.self)
            let cssLinkHtmlTagAttributes = arguments?["cssLinkHtmlTagAttributes"] as? [String:Any?]
            webView?.injectCSSFileFromUrl(urlFile: urlFile, cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes)
            result(true)
            break
        case .reload:
            webView?.reload()
            result(true)
            break
        case .goBack:
            webView?.goBack()
            result(true)
            break
        case .canGoBack:
            result(webView?.canGoBack ?? false)
            break
        case .goForward:
            webView?.goForward()
            result(true)
            break
        case .canGoForward:
            result(webView?.canGoForward ?? false)
            break
        case .goBackOrForward:
            let steps = try requiredArgument(arguments, "steps", as: Int.self)
            webView?.goBackOrForward(steps: steps)
            result(true)
            break
        case .canGoBackOrForward:
            let steps = try requiredArgument(arguments, "steps", as: Int.self)
            result(webView?.canGoBackOrForward(steps: steps) ?? false)
            break
        case .stopLoading:
            webView?.stopLoading()
            result(true)
            break
        case .isLoading:
            result(webView?.isLoading ?? false)
            break
        case .takeScreenshot:
            if let webView = webView, #available(macOS 10.13, *) {
                let screenshotConfiguration = arguments?["screenshotConfiguration"] as? [String: Any?]
                webView.takeScreenshot(with: screenshotConfiguration, completionHandler: { (screenshot) -> Void in
                    result(screenshot)
                })
            }
            else {
                result(nil)
            }
            break
        case .setSettings:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                let inAppBrowserSettings = InAppBrowserSettings()
                let inAppBrowserSettingsMap = try requiredArgument(arguments, "settings", as: [String: Any].self)
                let _ = inAppBrowserSettings.parse(settings: inAppBrowserSettingsMap)
                iabController.setSettings(newSettings: inAppBrowserSettings, newSettingsMap: inAppBrowserSettingsMap)
            } else {
                let inAppWebViewSettings = InAppWebViewSettings()
                let inAppWebViewSettingsMap = try requiredArgument(arguments, "settings", as: [String: Any].self)
                let _ = inAppWebViewSettings.parse(settings: inAppWebViewSettingsMap)
                webView?.setSettings(newSettings: inAppWebViewSettings, newSettingsMap: inAppWebViewSettingsMap)
            }
            result(true)
            break
        case .setContextMenu:
            webView?.contextMenu = arguments?["contextMenu"] as? [String: Any?]
            result(true)
            break
        case .getSettings:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                result(iabController.getSettings())
            } else {
                result(webView?.getSettings())
            }
            break
        case .close:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                iabController.close()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case .show:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                iabController.show()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case .hide:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                iabController.hide()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case .isHidden:
            if let iabController = webView?.inAppBrowserDelegate as? InAppBrowserWebViewController {
                result(iabController.isHidden)
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case .getCopyBackForwardList:
            result(webView?.getCopyBackForwardList())
            break
        case .findAll:
            if let webView = webView, let findInteractionController = webView.findInteractionController {
                let find = try requiredArgument(arguments, "find", as: String.self)
                findInteractionController.findAll(find: find, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "WebViewChannelDelegate", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
            } else {
                result(false)
            }
            break
        case .findNext:
            if let webView = webView, let findInteractionController = webView.findInteractionController {
                let forward = try requiredArgument(arguments, "forward", as: Bool.self)
                findInteractionController.findNext(forward: forward, completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "WebViewChannelDelegate", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
            } else {
                result(false)
            }
            break
        case .clearMatches:
            if let webView = webView, let findInteractionController = webView.findInteractionController {
                findInteractionController.clearMatches(completionHandler: {(value, error) in
                    if error != nil {
                        result(FlutterError(code: "WebViewChannelDelegate", message: error?.localizedDescription, details: nil))
                        return
                    }
                    result(true)
                })
            } else {
                result(false)
            }
            break
        case .clearCache:
            webView?.clearCache()
            result(true)
            break
        case .scrollTo:
            let x = try requiredArgument(arguments, "x", as: Int.self)
            let y = try requiredArgument(arguments, "y", as: Int.self)
            let animated = try requiredArgument(arguments, "animated", as: Bool.self)
            webView?.scrollTo(x: x, y: y, animated: animated)
            result(true)
            break
        case .scrollBy:
            let x = try requiredArgument(arguments, "x", as: Int.self)
            let y = try requiredArgument(arguments, "y", as: Int.self)
            let animated = try requiredArgument(arguments, "animated", as: Bool.self)
            webView?.scrollBy(x: x, y: y, animated: animated)
            result(true)
            break
        case .pauseTimers:
            webView?.pauseTimers()
            result(true)
            break
        case .resumeTimers:
            webView?.resumeTimers()
            result(true)
            break
        case .printCurrentPage:
            if let webView = webView {
                let settings = PrintJobSettings()
                if let settingsMap = arguments?["settings"] as? [String: Any?] {
                    let _ = settings.parse(settings: settingsMap)
                }
                result(webView.printCurrentPage(settings: settings))
            } else {
                result(nil)
            }
            break
        case .getContentHeight:
            webView?.getContentHeight { contentHeight, error in
                if let error = error {
                    print(error)
                    result(nil)
                    return
                }
                result(contentHeight)
            }
            break
        case .getContentWidth:
            webView?.getContentWidth { contentWidth, error in
                if let error = error {
                    print(error)
                    result(nil)
                    return
                }
                result(contentWidth)
            }
            break
        case .reloadFromOrigin:
            webView?.reloadFromOrigin()
            result(true)
            break
        case .getOriginalUrl:
            result(webView?.getOriginalUrl()?.absoluteString)
            break
        case .getZoomScale:
            result(nil)
            break
        case .hasOnlySecureContent:
            result(webView?.hasOnlySecureContent ?? false)
            break
        case .getSelectedText:
            if let webView = webView {
                webView.getSelectedText { (value, error) in
                    if let err = error {
                        print(err.localizedDescription)
                        result("")
                        return
                    }
                    result(value)
                }
            }
            else {
                result(nil)
            }
            break
        case .getScrollX:
            if let webView = webView {
                webView.getScrollX { scrollX, error in
                    if let error = error {
                        print(error)
                        result(nil)
                        return
                    }
                    result(scrollX)
                }
                
            } else {
                result(nil)
            }
            break
        case .getScrollY:
            if let webView = webView {
                webView.getScrollY { scrollY, error in
                    if let error = error {
                        print(error)
                        result(nil)
                        return
                    }
                    result(scrollY)
                }
                
            } else {
                result(nil)
            }
            break
        case .clearFocus:
            result(webView?.clearFocus())
            break
        case .requestFocus:
            result(webView?.requestFocus())
            break
        case .getCertificate:
            result(webView?.getCertificate()?.toMap())
            break
        case .addUserScript:
            if let webView = webView {
                let userScriptMap = try requiredArgument(arguments, "userScript", as: [String: Any?].self)
                let userScript = UserScript.fromMap(map: userScriptMap, windowId: webView.windowId)!
                webView.configuration.userContentController.addUserOnlyScript(userScript)
                webView.configuration.userContentController.sync(scriptMessageHandler: webView)
            }
            result(true)
            break
        case .removeUserScript:
            let index = try requiredArgument(arguments, "index", as: Int.self)
            let userScriptMap = try requiredArgument(arguments, "userScript", as: [String: Any?].self)
            let userScript = UserScript.fromMap(map: userScriptMap, windowId: webView?.windowId)!
            webView?.configuration.userContentController.removeUserOnlyScript(at: index, injectionTime: userScript.injectionTime)
            result(true)
            break
        case .removeUserScriptsByGroupName:
            let groupName = try requiredArgument(arguments, "groupName", as: String.self)
            webView?.configuration.userContentController.removeUserOnlyScripts(with: groupName)
            result(true)
            break
        case .removeAllUserScripts:
            webView?.configuration.userContentController.removeAllUserOnlyScripts()
            result(true)
            break
        case .callAsyncJavaScript:
            if let webView = webView {
                if #available(macOS 11.0, *) { // on iOS 14.0, for some reason, it crashes
                    let functionBody = try requiredArgument(arguments, "functionBody", as: String.self)
                    let functionArguments = try requiredArgument(arguments, "arguments", as: [String:Any].self)
                    var contentWorld = WKContentWorld.page
                    if let contentWorldMap = arguments?["contentWorld"] as? [String:Any?] {
                        contentWorld = WKContentWorld.fromMap(map: contentWorldMap, windowId: webView.windowId)!
                    }
                    webView.callAsyncJavaScript(functionBody: functionBody, arguments: functionArguments, contentWorld: contentWorld) { (value) in
                        result(value)
                    }
                } else {
                    let functionBody = try requiredArgument(arguments, "functionBody", as: String.self)
                    let functionArguments = try requiredArgument(arguments, "arguments", as: [String:Any].self)
                    webView.callAsyncJavaScript(functionBody: functionBody, arguments: functionArguments) { (value) in
                        result(value)
                    }
                }
            }
            else {
                result(nil)
            }
            break
        case .createPdf:
            if let webView = webView, #available(macOS 11.0, *) {
                let configuration = arguments?["pdfConfiguration"] as? [String: Any?]
                webView.createPdf(configuration: configuration, completionHandler: { (pdf) -> Void in
                    result(pdf)
                })
            }
            else {
                result(nil)
            }
            break
        case .createWebArchiveData:
            if let webView = webView, #available(macOS 11.0, *) {
                webView.createWebArchiveData(dataCompletionHandler: { (webArchiveData) -> Void in
                    result(webArchiveData)
                })
            }
            else {
                result(nil)
            }
            break
        case .saveWebArchive:
            if let webView = webView, #available(macOS 11.0, *) {
                let filePath = try requiredArgument(arguments, "filePath", as: String.self)
                let autoname = try requiredArgument(arguments, "autoname", as: Bool.self)
                webView.saveWebArchive(filePath: filePath, autoname: autoname, completionHandler: { (path) -> Void in
                    result(path)
                })
            }
            else {
                result(nil)
            }
            break
        case .isSecureContext:
            if let webView = webView {
                webView.isSecureContext(completionHandler: { (isSecureContext) in
                    result(isSecureContext)
                })
            }
            else {
                result(false)
            }
            break
        case .createWebMessageChannel:
            if let webView = webView {
                let _ = webView.createWebMessageChannel { (webMessageChannel) in
                    guard let webMessageChannel = webMessageChannel else {
                        result(nil)
                        return
                    }
                    result(webMessageChannel.toMap())
                }
            } else {
                result(nil)
            }
            break
        case .postWebMessage:
            if let webView = webView {
                var message = WebMessage.fromMap(map: try requiredArgument(arguments, "message", as: [String: Any?].self))
                let targetOrigin = try requiredArgument(arguments, "targetOrigin", as: String.self)
                
                var ports: [WebMessagePort] = []
                if let notConnectedPorts = message.ports {
                    for notConnectedPort in notConnectedPorts {
                        if let webMessageChannel = webView.webMessageChannels[notConnectedPort.webMessageChannelId] {
                            ports.append(webMessageChannel.ports[Int(notConnectedPort.index)])
                        }
                    }
                }
                message.ports = ports
                
                do {
                    try webView.postWebMessage(message: message, targetOrigin: targetOrigin) { (_) in
                        result(true)
                    }
                } catch let error as NSError {
                    result(FlutterError(code: "WebViewChannelDelegate", message: error.domain, details: nil))
                }
            } else {
                result(false)
            }
            break
        case .addWebMessageListener:
            if let webView = webView, let plugin = webView.plugin  {
                let webMessageListenerMap = try requiredArgument(arguments, "webMessageListener", as: [String: Any?].self)
                let webMessageListener = WebMessageListener.fromMap(plugin: plugin, map: webMessageListenerMap)!
                do {
                    try webView.addWebMessageListener(webMessageListener: webMessageListener)
                    result(false)
                } catch let error as NSError {
                    result(FlutterError(code: "WebViewChannelDelegate", message: error.domain, details: nil))
                }
            } else {
                result(false)
            }
            break
        case .canScrollVertically:
            if let webView = webView {
                webView.canScrollVertically { canScrollVertically, error in
                    if let error = error {
                        print(error)
                        result(false)
                        return
                    }
                    result(canScrollVertically)
                }
            } else {
                result(false)
            }
            break
        case .canScrollHorizontally:
            if let webView = webView {
                webView.canScrollHorizontally { canScrollHorizontally, error in
                    if let error = error {
                        print(error)
                        result(false)
                        return
                    }
                    result(canScrollHorizontally)
                }
            } else {
                result(false)
            }
            break
        case .pauseAllMediaPlayback:
            if let webView = webView, #available(macOS 12.0 , *) {
                webView.pauseAllMediaPlayback(completionHandler: { () -> Void in
                    result(true)
                })
            } else {
                result(false)
            }
            break
        case .setAllMediaPlaybackSuspended:
            if let webView = webView, #available(macOS 12.0 , *) {
                let suspended = try requiredArgument(arguments, "suspended", as: Bool.self)
                webView.setAllMediaPlaybackSuspended(suspended, completionHandler: { () -> Void in
                    result(true)
                })
            } else {
                result(false)
            }
            break
        case .closeAllMediaPresentations:
            if let webView = self.webView, #available(macOS 11.3, *) {
                if #available(macOS 12.0, *) {
                    webView.closeAllMediaPresentations {
                        result(true)
                    }
                } else {
                    webView.closeAllMediaPresentations()
                    result(true)
                }
            } else {
                result(false)
            }
            break
        case .requestMediaPlaybackState:
            if let webView = webView, #available(macOS 12.0, *) {
                webView.requestMediaPlaybackState(completionHandler: { (state) -> Void in
                    result(state.rawValue)
                })
            } else {
                result(nil)
            }
            break
        case .getMetaThemeColor:
            if let webView = webView, #available(macOS 12.0, *) {
                result(webView.themeColor?.hexString)
            } else {
                result(nil)
            }
            break
        case .isInFullscreen:
            if let webView = webView {
                if #available(macOS 13.0, *) {
                    result(webView.fullscreenState == .inFullscreen)
                } else {
                    result(webView.inFullscreen)
                }
            }
            else {
                result(false)
            }
            break
        case .getCameraCaptureState:
            if let webView = webView, #available(macOS 12.0, *) {
                result(webView.cameraCaptureState.rawValue)
            } else {
                result(nil)
            }
            break
        case .setCameraCaptureState:
            if let webView = webView, #available(macOS 12.0, *) {
                let state = WKMediaCaptureState.init(rawValue: try requiredArgument(arguments, "state", as: Int.self)) ?? WKMediaCaptureState.none
                webView.setCameraCaptureState(state) {
                    result(true)
                }
            } else {
                result(false)
            }
            break
        case .getMicrophoneCaptureState:
            if let webView = webView, #available(macOS 12.0, *) {
                result(webView.microphoneCaptureState.rawValue)
            } else {
                result(nil)
            }
            break
        case .setMicrophoneCaptureState:
            if let webView = webView, #available(macOS 12.0, *) {
                let state = WKMediaCaptureState.init(rawValue: try requiredArgument(arguments, "state", as: Int.self)) ?? WKMediaCaptureState.none
                webView.setMicrophoneCaptureState(state) {
                    result(true)
                }
            } else {
                result(false)
            }
            break
        case .loadSimulatedRequest:
            if let webView = webView, #available(macOS 12.0, *) {
                let request = URLRequest.init(fromPluginMap: try requiredArgument(arguments, "urlRequest", as: [String:Any?].self))
                let data = try requiredArgument(arguments, "data", as: FlutterStandardTypedData.self)
                var response: URLResponse? = nil
                if let urlResponse = arguments?["urlResponse"] as? [String:Any?] {
                    response = URLResponse.init(fromPluginMap: urlResponse)
                }
                if let response = response {
                    webView.loadSimulatedRequest(request, response: response, responseData: data.data)
                } else {
                    webView.loadSimulatedRequest(request, responseHTML: String(decoding: data.data, as: UTF8.self))
                }
                result(true)
            } else {
                result(false)
            }
            break
        case .saveState:
            if let webView = webView, #available(macOS 12.0, *) {
                result(webView.saveState())
            } else {
                result(nil)
            }
            break
        case .restoreState:
            if let webView = webView, #available(macOS 12.0, *) {
                let state = try requiredArgument(arguments, "state", as: FlutterStandardTypedData.self)
                webView.restoreState(state: state.data)
                result(true)
            } else {
                result(false)
            }
            break
        case .setAudioMuted:
            if let webView = webView {
                let muted = arguments?["muted"] as? Bool ?? false
                webView.setAudioMuted(muted: muted) {
                    result(true)
                }
            } else {
                result(false)
            }
            break
        case .isAudioMuted:
            result(webView?.isAudioMuted() ?? false)
            break
        case .fetchWebViewData:
            if let webView = webView {
                let dataTypes = arguments?["dataTypes"] as? [Int] ?? [1]
                webView.fetchWebViewData(dataTypes: dataTypes) { data in
                    result(data)
                }
            } else {
                result(nil)
            }
            break
        case .restoreWebViewData:
            if let webView = webView, let data = arguments?["data"] as? FlutterStandardTypedData {
                webView.restoreWebViewData(data: data.data) {
                    result(true)
                }
            } else {
                result(false)
            }
            break
        case .isBlockedByScreenTime:
            result(webView?.isBlockedByScreenTimeValue() ?? false)
            break
        }
    }
    
    @available(*, deprecated, message: "Use FindInteractionChannelDelegate.onFindResultReceived instead.")
    public func onFindResultReceived(activeMatchOrdinal: Int, numberOfMatches: Int, isDoneCounting: Bool) {
        let arguments: [String : Any?] = [
            "activeMatchOrdinal": activeMatchOrdinal,
            "numberOfMatches": numberOfMatches,
            "isDoneCounting": isDoneCounting
        ]
        invokeMethod("onFindResultReceived", arguments: arguments)
    }
    
    public func onLongPressHitTestResult(hitTestResult: HitTestResult) {
        invokeMethod("onLongPressHitTestResult", arguments: hitTestResult.toMap())
    }
    
    public func onScrollChanged(x: Int, y: Int) {
        let arguments: [String: Any?] = ["x": x, "y": y]
        invokeMethod("onScrollChanged", arguments: arguments)
    }
    
    public func onDownloadStarting(request: DownloadStartRequest) {
        invokeMethod("onDownloadStarting", arguments: request.toMap())
    }

    public func onDownloadStarting(request: DownloadStartRequest, callback: DownloadStartCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        invokeMethod("onDownloadStarting", arguments: request.toMap(), callback: callback)
    }

    public class DownloadStartCallback: BaseCallbackResult<DownloadStartResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return DownloadStartResponse.fromMap(map: obj as? [String: Any?])
            }
        }

        deinit {
            self.defaultBehaviour(nil)
        }
    }

    public func onWritingToolsActiveChanged(isActive: Bool) {
        invokeMethod("onWritingToolsActiveChanged", arguments: ["isActive": isActive])
    }
    
    public func onCreateContextMenu(hitTestResult: HitTestResult) {
        invokeMethod("onCreateContextMenu", arguments: hitTestResult.toMap())
    }
    
    public func onOverScrolled(x: Int, y: Int, clampedX: Bool, clampedY: Bool) {
        let arguments: [String: Any?] = ["x": x, "y": y, "clampedX": clampedX, "clampedY": clampedY]
        invokeMethod("onOverScrolled", arguments: arguments)
    }
    
    public func onContextMenuActionItemClicked(id: Any, title: String) {
        let iosId: String?
        switch id {
        case let id as String:
            iosId = id
        case let id as Int:
            iosId = String(id)
        case let id as Int64:
            iosId = String(id)
        case let id as NSNumber:
            iosId = id.stringValue
        default:
            iosId = nil
        }
        let arguments: [String: Any?] = [
            "id": id,
            "iosId": iosId,
            "androidId": nil,
            "title": title
        ]
        invokeMethod("onContextMenuActionItemClicked", arguments: arguments)
    }
    
    public func onHideContextMenu() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onHideContextMenu", arguments: arguments)
    }
    
    public func onEnterFullscreen() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onEnterFullscreen", arguments: arguments)
    }
    
    public func onExitFullscreen() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onExitFullscreen", arguments: arguments)
    }
    
    public class JsAlertCallback: BaseCallbackResult<JsAlertResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return JsAlertResponse.fromMap(map: obj as? [String:Any?])
            }
        }
    }
    
    public func onJsAlert(url: URL?, message: String, isMainFrame: Bool, callback: JsAlertCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments: [String: Any?] = [
            "url": url?.absoluteString,
            "message": message,
            "isMainFrame": isMainFrame
        ]
        invokeMethod("onJsAlert", arguments: arguments, callback: callback)
    }
    
    public class JsConfirmCallback: BaseCallbackResult<JsConfirmResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return JsConfirmResponse.fromMap(map: obj as? [String:Any?])
            }
        }
    }
    
    public func onJsConfirm(url: URL?, message: String, isMainFrame: Bool, callback: JsConfirmCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments: [String: Any?] = [
            "url": url?.absoluteString,
            "message": message,
            "isMainFrame": isMainFrame
        ]
        invokeMethod("onJsConfirm", arguments: arguments, callback: callback)
    }
    
    public class JsPromptCallback: BaseCallbackResult<JsPromptResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return JsPromptResponse.fromMap(map: obj as? [String:Any?])
            }
        }
    }
    
    public func onJsPrompt(url: URL?, message: String, defaultValue: String?, isMainFrame: Bool, callback: JsPromptCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments: [String: Any?] = [
            "url": url?.absoluteString,
            "message": message,
            "defaultValue": defaultValue,
            "isMainFrame": isMainFrame
        ]
        invokeMethod("onJsPrompt", arguments: arguments, callback: callback)
    }
    
    public class CreateWindowCallback: BaseCallbackResult<Bool> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return obj is Bool && obj as! Bool
            }
        }
    }
    
    public func onCreateWindow(createWindowAction: CreateWindowAction, callback: CreateWindowCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        invokeMethod("onCreateWindow", arguments: createWindowAction.toMap(), callback: callback)
    }
    
    public func onCloseWindow() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onCloseWindow", arguments: arguments)
    }
    
    public func onConsoleMessage(message: String, messageLevel: Int) {
        let arguments: [String: Any?] = [
            "message": message,
            "messageLevel": messageLevel
        ]
        invokeMethod("onConsoleMessage", arguments: arguments)
    }
    
    public func onProgressChanged(progress: Int) {
        let arguments: [String: Any?] = [
            "progress": progress
        ]
        invokeMethod("onProgressChanged", arguments: arguments)
    }
    
    public func onTitleChanged(title: String?) {
        let arguments: [String: Any?] = [
            "title": title
        ]
        invokeMethod("onTitleChanged", arguments: arguments)
    }
    
    public class PermissionRequestCallback: BaseCallbackResult<PermissionResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return PermissionResponse.fromMap(map: obj as? [String:Any?])
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func onPermissionRequest(request: PermissionRequest, callback: PermissionRequestCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        invokeMethod("onPermissionRequest", arguments: request.toMap(), callback: callback)
    }
    
    public class ShouldOverrideUrlLoadingCallback: BaseCallbackResult<WKNavigationActionPolicy> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                if let action = obj as? Int {
                    if action == WKNavigationActionPolicy.allow.rawValue + 2 {
                        return WKNavigationActionPolicy.init(
                            rawValue: WKNavigationActionPolicy.allow.rawValue + 2
                        ) ?? WKNavigationActionPolicy.allow
                    }
                    return WKNavigationActionPolicy.init(rawValue: action) ?? WKNavigationActionPolicy.cancel
                }
                return WKNavigationActionPolicy.cancel
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func shouldOverrideUrlLoading(navigationAction: WKNavigationAction, callback: ShouldOverrideUrlLoadingCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        invokeMethod("shouldOverrideUrlLoading", arguments: navigationAction.toMap(), callback: callback)
    }
    
    public func onLoadStart(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        invokeMethod("onLoadStart", arguments: arguments)
    }
    
    public func onLoadStop(url: String?) {
        let arguments: [String: Any?] = ["url": url]
        invokeMethod("onLoadStop", arguments: arguments)
    }
    
    public func onUpdateVisitedHistory(url: String?, isReload: Bool?) {
        let arguments: [String: Any?] = [
            "url": url,
            "isReload": nil
        ]
        invokeMethod("onUpdateVisitedHistory", arguments: arguments)
    }
    
    public func onReceivedError(request: WebResourceRequest, error: WebResourceError) {
        let arguments: [String: Any?] = [
            "request": request.toMap(),
            "error": error.toMap()
        ]
        invokeMethod("onReceivedError", arguments: arguments)
    }
    
    public func onReceivedHttpError(request: WebResourceRequest, errorResponse: WebResourceResponse) {
        let arguments: [String: Any?] = [
            "request": request.toMap(),
            "errorResponse": errorResponse.toMap()
        ]
        invokeMethod("onReceivedHttpError", arguments: arguments)
    }
    
    public class ReceivedHttpAuthRequestCallback: BaseCallbackResult<HttpAuthResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return HttpAuthResponse.fromMap(map: obj as? [String:Any?])
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func onReceivedHttpAuthRequest(challenge: HttpAuthenticationChallenge, callback: ReceivedHttpAuthRequestCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        // workaround for ProtectionSpace.toMap() SSL Certificate
        // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1678
        DispatchQueue.global().async {
            let arguments = challenge.toMap()
            DispatchQueue.main.async { [weak self] in
                if self?.canDispatchCallbacks() != true {
                    callback.defaultBehaviour(nil)
                    return
                }
                self?.invokeMethod("onReceivedHttpAuthRequest", arguments: arguments, callback: callback)
            }
        }
    }
    
    public class ReceivedServerTrustAuthRequestCallback: BaseCallbackResult<ServerTrustAuthResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return ServerTrustAuthResponse.fromMap(map: obj as? [String:Any?])
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func onReceivedServerTrustAuthRequest(challenge: ServerTrustChallenge, callback: ReceivedServerTrustAuthRequestCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        // workaround for ProtectionSpace.toMap() SSL Certificate
        // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1678
        DispatchQueue.global().async {
            let arguments = challenge.toMap()
            DispatchQueue.main.async { [weak self] in
                if self?.canDispatchCallbacks() != true {
                    callback.defaultBehaviour(nil)
                    return
                }
                self?.invokeMethod("onReceivedServerTrustAuthRequest", arguments: arguments, callback: callback)
            }
        }
    }
    
    public class ReceivedClientCertRequestCallback: BaseCallbackResult<ClientCertResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return ClientCertResponse.fromMap(map: obj as? [String:Any?])
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func onReceivedClientCertRequest(challenge: ClientCertChallenge, callback: ReceivedClientCertRequestCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        // workaround for ProtectionSpace.toMap() SSL Certificate
        // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1678
        DispatchQueue.global().async {
            let arguments = challenge.toMap()
            DispatchQueue.main.async { [weak self] in
                if self?.canDispatchCallbacks() != true {
                    callback.defaultBehaviour(nil)
                    return
                }
                self?.invokeMethod("onReceivedClientCertRequest", arguments: arguments, callback: callback)
            }
        }
    }
    
    public func onZoomScaleChanged(newScale: Float, oldScale: Float) {
        let arguments: [String: Any?] = [
            "newScale": newScale,
            "oldScale": oldScale
        ]
        invokeMethod("onZoomScaleChanged", arguments: arguments)
    }
    
    public func onPageCommitVisible(url: String?) {
        let arguments: [String: Any?] = [
            "url": url
        ]
        invokeMethod("onPageCommitVisible", arguments: arguments)
    }
    
    public class LoadResourceWithCustomSchemeCallback: BaseCallbackResult<CustomSchemeResponse> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return CustomSchemeResponse.fromMap(map: obj as? [String:Any?])
            }
        }
    }
    
    public func onLoadResourceWithCustomScheme(request: WebResourceRequest, callback: LoadResourceWithCustomSchemeCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments: [String: Any?] = ["request": request.toMap()]
        invokeMethod("onLoadResourceWithCustomScheme", arguments: arguments, callback: callback)
    }
    
    public class CallJsHandlerCallback: BaseCallbackResult<Any> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return obj
            }
        }
    }
    
    public func onCallJsHandler(handlerName: String, data: JavaScriptHandlerFunctionData, callback: CallJsHandlerCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments: [String: Any?] = [
            "handlerName": handlerName,
            "data": data.toMap()
        ]
        invokeMethod("onCallJsHandler", arguments: arguments, callback: callback)
    }
    
    public class NavigationResponseCallback: BaseCallbackResult<WKNavigationResponsePolicy> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                if let action = obj as? Int {
                    return WKNavigationResponsePolicy.init(rawValue: action) ?? WKNavigationResponsePolicy.cancel
                }
                return WKNavigationResponsePolicy.cancel
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func onNavigationResponse(navigationResponse: WKNavigationResponse, callback: NavigationResponseCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        invokeMethod("onNavigationResponse", arguments: navigationResponse.toMap(), callback: callback)
    }
    
    public class ShouldAllowDeprecatedTLSCallback: BaseCallbackResult<Bool> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                if let action = obj as? Int {
                    return action == 1
                }
                return false
            }
        }
        
        deinit {
            self.defaultBehaviour(nil)
        }
    }
    
    public func shouldAllowDeprecatedTLS(challenge: URLAuthenticationChallenge, callback: ShouldAllowDeprecatedTLSCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        // workaround for ProtectionSpace.toMap() SSL Certificate
        // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1678
        DispatchQueue.global().async {
            let arguments = challenge.toMap()
            DispatchQueue.main.async { [weak self] in
                if self?.canDispatchCallbacks() != true {
                    callback.defaultBehaviour(nil)
                    return
                }
                self?.invokeMethod("shouldAllowDeprecatedTLS", arguments: arguments, callback: callback)
            }
        }
    }
    
    public func onWebContentProcessDidTerminate() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onWebContentProcessDidTerminate", arguments: arguments)
    }
    
    public func onDidReceiveServerRedirectForProvisionalNavigation() {
        let arguments: [String: Any?] = [:]
        invokeMethod("onDidReceiveServerRedirectForProvisionalNavigation", arguments: arguments)
    }
    
    @available(macOS 12.0, *)
    public func onCameraCaptureStateChanged(oldState: WKMediaCaptureState?, newState: WKMediaCaptureState?) {
        let arguments = [
            "oldState": oldState?.rawValue,
            "newState": newState?.rawValue
        ]
        invokeMethod("onCameraCaptureStateChanged", arguments: arguments)
    }
    
    @available(macOS 12.0, *)
    public func onMicrophoneCaptureStateChanged(oldState: WKMediaCaptureState?, newState: WKMediaCaptureState?) {
        let arguments = [
            "oldState": oldState?.rawValue,
            "newState": newState?.rawValue
        ]
        invokeMethod("onMicrophoneCaptureStateChanged", arguments: arguments)
    }
    
    public class PrintRequestCallback: BaseCallbackResult<Bool> {
        override init() {
            super.init()
            self.decodeResult = { (obj: Any?) in
                return obj is Bool && obj as! Bool
            }
        }
    }
    
    public func onPrintRequest(url: URL?, printJobId: String?, callback: PrintRequestCallback) {
        if !canDispatchCallbacks() {
            callback.defaultBehaviour(nil)
            return
        }
        let arguments = [
            "url": url?.absoluteString,
            "printJobId": printJobId,
        ]
        invokeMethod("onPrintRequest", arguments: arguments, callback: callback)
    }
    
    internal func _onMouseDown(callback: @escaping () -> Void) {
        if !canDispatchCallbacks() {
            return
        }
        let arguments: [String:Any] = [:];
        invokeMethod("_onMouseDown", arguments: arguments) {(result) -> Void in
            callback()
        }
    }
    
    public override func dispose() {
        super.dispose()
        webView = nil
    }
    
    deinit {
        debugPrint("WebViewChannelDelegate - dealloc")
        dispose()
    }
}
