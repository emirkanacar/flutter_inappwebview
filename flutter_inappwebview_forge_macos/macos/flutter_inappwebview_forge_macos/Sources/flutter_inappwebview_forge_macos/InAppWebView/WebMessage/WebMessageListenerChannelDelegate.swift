//
//  WebMessageListenerChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/05/22.
//

import Foundation
import FlutterMacOS

public class WebMessageListenerChannelDelegate: ChannelDelegate {
    private weak var webMessageListener: WebMessageListener?
    private var pendingResults: [UUID: FlutterResult] = [:]
    
    public init(webMessageListener: WebMessageListener, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.webMessageListener = webMessageListener
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard canDispatchCallbacks() else {
            result(nil)
            return
        }
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "postMessage":
            if let webView = webMessageListener?.webView, let jsObjectName = webMessageListener?.jsObjectName {
                let jsObjectNameEscaped = jsObjectName.replacingOccurrences(of: "\'", with: "\\'")
                let message = WebMessage.fromMap(map: arguments!["message"] as! [String: Any?])
                
                let source = """
                (function() {
                    var webMessageListener = window['\(jsObjectNameEscaped)'];
                    if (webMessageListener != null) {
                        var event = {data: \(message.jsData)};
                        if (webMessageListener.onmessage != null) {
                            webMessageListener.onmessage(event);
                        }
                        for (var listener of webMessageListener.listeners) {
                            listener(event);
                        }
                    }
                })();
                """
                let requestId = track(result)
                webView.evaluateJavascript(source: source) { [weak self] (_) in
                    self?.complete(requestId, value: true)
                }
            } else {
               result(true)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onPostMessage(message: WebMessage?, sourceOrigin: URL?, isMainFrame: Bool) {
        guard canDispatchCallbacks() else { return }
        let arguments: [String:Any?] = [
            "message": message?.toMap(),
            "sourceOrigin": sourceOrigin?.absoluteString,
            "isMainFrame": isMainFrame
        ]
        channel?.invokeMethod("onPostMessage", arguments: arguments)
    }
    
    public override func dispose() {
        let results = pendingResults.values
        pendingResults.removeAll()
        results.forEach { $0(nil) }
        super.dispose()
        webMessageListener = nil
    }

    private func canDispatchCallbacks() -> Bool {
        guard channel != nil, let webMessageListener = webMessageListener else { return false }
        guard let webView = webMessageListener.webView else { return true }
        return webView.acceptsCallbacks()
    }

    private func track(_ result: @escaping FlutterResult) -> UUID {
        let requestId = UUID()
        pendingResults[requestId] = result
        return requestId
    }

    private func complete(_ requestId: UUID, value: Any?) {
        guard let result = pendingResults.removeValue(forKey: requestId) else { return }
        result(value)
    }
    
    deinit {
        dispose()
    }
}
