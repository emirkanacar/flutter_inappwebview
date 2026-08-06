//
//  WebAuthenticationSession.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/05/22.
//

import Foundation
import AuthenticationServices
import Flutter
import UIKit

public class WebAuthenticationSession: NSObject, ASWebAuthenticationPresentationContextProviding, Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_webauthenticationsession_"
    var id: String
    var plugin: InAppWebViewFlutterPlugin?
    var url: URL
    var callbackURLScheme: String?
    var settings: WebAuthenticationSessionSettings
    var session: Any?
    var channelDelegate: WebAuthenticationSessionChannelDelegate?
    private var _canStart = true
    
    public init(plugin: InAppWebViewFlutterPlugin, id: String, url: URL, callbackURLScheme: String?, settings: WebAuthenticationSessionSettings) {
        self.id = id
        self.plugin = plugin
        self.url = url
        self.settings = settings
        super.init()
        self.callbackURLScheme = callbackURLScheme
        let session = ASWebAuthenticationSession(url: self.url, callbackURLScheme: self.callbackURLScheme, completionHandler: self.completionHandler)
        session.presentationContextProvider = self
        self.session = session
        let channel = FlutterMethodChannel(name: WebAuthenticationSession.METHOD_CHANNEL_NAME_PREFIX + id,
                                           binaryMessenger: plugin.registrar.messenger())
        self.channelDelegate = WebAuthenticationSessionChannelDelegate(webAuthenticationSession: self, channel: channel)
    }
    
    public func prepare() {
        if let session = session as? ASWebAuthenticationSession {
            session.prefersEphemeralWebBrowserSession = settings.prefersEphemeralWebBrowserSession
        }
    }
    
    public func completionHandler(url: URL?, error: Error?) -> Void {
        channelDelegate?.onComplete(url: url, errorCode: error?._code)
    }
    
    public func canStart() -> Bool {
        guard let session = session as? ASWebAuthenticationSession else {
            return false
        }
        return _canStart && session.canStart
    }
    
    public func start() -> Bool {
        guard let session = session as? ASWebAuthenticationSession else {
            return false
        }
        let started = session.start()
        if started {
            _canStart = false
        }
        return started
    }
    
    public func cancel() {
        guard let session = session as? ASWebAuthenticationSession else {
            return
        }
        session.cancel()
    }
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.activeKeyWindow ?? ASPresentationAnchor()
    }
    
    public func dispose() {
        cancel()
        channelDelegate?.dispose()
        channelDelegate = nil
        session = nil
        plugin?.webAuthenticationSessionManager?.sessions[id] = nil
        plugin = nil
    }
    
    deinit {
        debugPrint("WebAuthenticationSession - dealloc")
        dispose()
    }
}
