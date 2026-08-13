//
//  WebAuthenticationSessionManager.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/05/22.
//

import Flutter
import UIKit
import WebKit
import Foundation
import AVFoundation

public class WebAuthenticationSessionManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_webauthenticationsession"
    var plugin: InAppWebViewFlutterPlugin?
    var sessions: [String: WebAuthenticationSession] = [:]
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: WebAuthenticationSessionManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary

        switch call.method {
            case "create":
                let id = arguments!["id"] as! String
                let url = arguments!["url"] as! String
                let callbackURLScheme = arguments!["callbackURLScheme"] as? String
                let initialSettings = arguments!["initialSettings"] as! [String: Any?]
                create(id: id, url: url, callbackURLScheme: callbackURLScheme, settings: initialSettings, result: result)
                break
            case "isAvailable":
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func create(id: String, url: String, callbackURLScheme: String?, settings: [String: Any?], result: @escaping FlutterResult) {
        if let plugin = plugin {
            let sessionUrl = URL(string: url) ?? URL(string: "about:blank")!
            let initialSettings = WebAuthenticationSessionSettings()
            let _ = initialSettings.parse(settings: settings)
            let session = WebAuthenticationSession(plugin: plugin, id: id, url: sessionUrl, callbackURLScheme: callbackURLScheme, settings: initialSettings)
            session.prepare()
            sessions[id] = session
            result(true)
            return
        }
        
        result(FlutterError.init(code: "WebAuthenticationSessionManager", message: "WebAuthenticationSession is not available!", details: nil))
    }
    
    public override func dispose() {
        super.dispose()
        let sessionValues = Array(sessions.values)
        sessions.removeAll()
        sessionValues.forEach { (session: WebAuthenticationSession) in
            session.cancel()
            session.dispose()
        }
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}
