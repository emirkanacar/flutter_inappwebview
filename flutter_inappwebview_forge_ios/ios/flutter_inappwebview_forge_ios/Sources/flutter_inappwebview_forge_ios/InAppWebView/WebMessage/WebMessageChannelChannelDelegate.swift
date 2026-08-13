//
//  WebMessageChannelChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 07/05/22.
//

import Foundation
import Flutter

public class WebMessageChannelChannelDelegate: ChannelDelegate {
    private weak var webMessageChannel: WebMessageChannel?
    private var pendingResults: [UUID: FlutterResult] = [:]
    
    public init(webMessageChannel: WebMessageChannel, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.webMessageChannel = webMessageChannel
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard canDispatchCallbacks() else {
            result(nil)
            return
        }
        let arguments = call.arguments as? NSDictionary
        
        switch call.method {
        case "setWebMessageCallback":
            if let _ = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
                guard let index = arguments?["index"] as? Int, ports.indices.contains(index) else {
                    result(FlutterError(code: "invalid_arguments", message: "Invalid port index.", details: nil))
                    return
                }
                let port = ports[index]
                let requestId = track(result)
                do {
                    try port.setWebMessageCallback { [weak self] (_) in
                        self?.complete(requestId, value: true)
                    }
                } catch let error as NSError {
                    complete(requestId, value: FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
                }
                
            } else {
                result(true)
            }
            break
        case "postMessage":
            if let webView = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
                guard let index = arguments?["index"] as? Int,
                      ports.indices.contains(index),
                      let messageMap = arguments?["message"] as? [String: Any?] else {
                    result(FlutterError(code: "invalid_arguments", message: "Invalid port message.", details: nil))
                    return
                }
                let message = WebMessage.fromMap(map: messageMap)
                let port = ports[index]
                
                var ports: [WebMessagePort] = []
                if let notConnectedPorts = message.ports {
                    for notConnectedPort in notConnectedPorts {
                        if let webMessageChannel = webView.webMessageChannels[notConnectedPort.webMessageChannelId] {
                            ports.append(webMessageChannel.ports[Int(notConnectedPort.index)])
                        }
                    }
                }
                message.ports = ports

                let requestId = track(result)
                do {
                    try port.postMessage(message: message) { [weak self] (_) in
                        self?.complete(requestId, value: true)
                    }
                } catch let error as NSError {
                    complete(requestId, value: FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
                }
            } else {
                result(true)
            }
            break
        case "close":
            if let _ = webMessageChannel?.webView, let ports = webMessageChannel?.ports, ports.count > 0 {
                guard let index = arguments?["index"] as? Int, ports.indices.contains(index) else {
                    result(FlutterError(code: "invalid_arguments", message: "Invalid port index.", details: nil))
                    return
                }
                let port = ports[index]
                let requestId = track(result)
                do {
                    try port.close { [weak self] (_) in
                        self?.complete(requestId, value: true)
                    }
                } catch let error as NSError {
                    complete(requestId, value: FlutterError(code: "WebMessageChannel", message: error.domain, details: nil))
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
    
    public func onMessage(index: Int64, message: WebMessage?) {
        guard canDispatchCallbacks() else { return }
        let arguments: [String:Any?] = [
            "index": index,
            "message": message?.toMap()
        ]
        channel?.invokeMethod("onMessage", arguments: arguments)
    }
    
    public override func dispose() {
        let results = pendingResults.values
        pendingResults.removeAll()
        results.forEach { $0(nil) }
        super.dispose()
        webMessageChannel = nil
    }

    private func canDispatchCallbacks() -> Bool {
        guard channel != nil, let webMessageChannel = webMessageChannel else { return false }
        guard let webView = webMessageChannel.webView else { return true }
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
