//
//  WebAuthenticationSessionSettings.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 08/05/22.
//

import Foundation
import AuthenticationServices

@objcMembers
public class WebAuthenticationSessionSettings: ISettings<WebAuthenticationSession> {
    
    var prefersEphemeralWebBrowserSession = false
    var additionalHeaderFields: [String: String]? = nil
    
    override init(){
        super.init()
    }
    
    override func getRealSettings(obj: WebAuthenticationSession?) -> [String: Any?] {
        var realOptions: [String: Any?] = toMap()
        if let session = obj?.session as? ASWebAuthenticationSession {
            realOptions["prefersEphemeralWebBrowserSession"] = session.prefersEphemeralWebBrowserSession
            if #available(iOS 17.4, *) {
                realOptions["additionalHeaderFields"] = session.additionalHeaderFields
            }
        }
        return realOptions
    }
}
