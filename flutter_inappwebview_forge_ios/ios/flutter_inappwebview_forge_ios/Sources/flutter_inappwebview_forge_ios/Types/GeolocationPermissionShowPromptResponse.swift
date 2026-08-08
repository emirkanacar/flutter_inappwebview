//
//  GeolocationPermissionShowPromptResponse.swift
//  flutter_inappwebview_forge_ios
//

import Foundation

public class GeolocationPermissionShowPromptResponse: NSObject {
    var origin: String
    var allow: Bool
    var retain: Bool

    public init(origin: String, allow: Bool, retain: Bool) {
        self.origin = origin
        self.allow = allow
        self.retain = retain
    }

    public static func fromMap(map: [String: Any?]?) -> GeolocationPermissionShowPromptResponse? {
        guard let map = map,
              let origin = map["origin"] as? String,
              let allow = map["allow"] as? Bool,
              let retain = map["retain"] as? Bool else {
            return nil
        }
        return GeolocationPermissionShowPromptResponse(
            origin: origin,
            allow: allow,
            retain: retain
        )
    }
}
