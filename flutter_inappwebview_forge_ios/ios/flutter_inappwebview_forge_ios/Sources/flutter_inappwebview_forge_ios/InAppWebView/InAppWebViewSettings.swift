//
//  InAppWebViewSettings.swift
//  flutter_inappwebview
//
//  Created by Lorenzo on 21/10/18.
//

import Foundation
import WebKit

@objcMembers
public class InAppWebViewSettings: ISettings<InAppWebView> {
    
    var useShouldOverrideUrlLoading = false
    var useOnLoadResource = false
    var useOnDownloadStart = false
    @available(*, deprecated, message: "Use InAppWebViewManager.clearAllCache instead.")
    var clearCache = false
    var userAgent = ""
    var applicationNameForUserAgent = ""
    var javaScriptEnabled = true
    var javaScriptCanOpenWindowsAutomatically = false
    var mediaPlaybackRequiresUserGesture = true
    var verticalScrollBarEnabled = true
    var horizontalScrollBarEnabled = true
    var resourceCustomSchemes: [String] = []
    var contentBlockers: [[String: [String : Any]]] = []
    var minimumFontSize = 0
    var useShouldInterceptAjaxRequest = false
    var useOnAjaxReadyStateChange = false
    var useOnAjaxProgress = false
    var interceptOnlyAsyncAjaxRequests = true
    var useShouldInterceptFetchRequest = false
    var incognito = false
    var cacheEnabled = true
    var containerId: String? = nil
    var proxySettings: [String: Any?]? = nil
    var transparentBackground = false
    var disableVerticalScroll = false
    var disableHorizontalScroll = false
    var disableContextMenu = false
    var supportZoom = true
    var allowUniversalAccessFromFileURLs = false
    var allowFileAccessFromFileURLs = false

    var disallowOverScroll = false
    var enableViewportScale = false
    var suppressesIncrementalRendering = false
    var allowsAirPlayForMediaPlayback = true
    var allowsBackForwardNavigationGestures = true
    var allowsLinkPreview = true
    var ignoresViewportScaleLimits = false
    var allowsInlineMediaPlayback = false
    var allowsPictureInPictureMediaPlayback = true
    var isFraudulentWebsiteWarningEnabled = true
    var selectionGranularity = 0
    var dataDetectorTypes: [String] = ["NONE"] // WKDataDetectorTypeNone
    var preferredContentMode = 0
    var sharedCookiesEnabled = false
    var automaticallyAdjustsScrollIndicatorInsets = false
    var accessibilityIgnoresInvertColors = false
    var decelerationRate = "NORMAL" // UIScrollView.DecelerationRate.normal
    var alwaysBounceVertical = false
    var alwaysBounceHorizontal = false
    var scrollsToTop = true
    var isPagingEnabled = false
    var maximumZoomScale = 1.0
    var minimumZoomScale = 1.0
    var contentInsetAdjustmentBehavior = 2 // UIScrollView.ContentInsetAdjustmentBehavior.never
    var isDirectionalLockEnabled = false
    var mediaType: String? = nil
    var pageZoom = 1.0
    var limitsNavigationsToAppBoundDomains = false
    var useOnNavigationResponse = false
    var applePayAPIEnabled = false
    var allowingReadAccessTo: String? = nil
    var disableLongPressContextMenuOnLinks = false
    var disableInputAccessoryView = false
    var disableAutocorrection = false
    var underPageBackgroundColor: String?
    var isTextInteractionEnabled = true
    var writingToolsBehavior: Int? = nil
    var isSiteSpecificQuirksModeEnabled = true
    var upgradeKnownHostsToHTTPS = true
    var isElementFullscreenEnabled = true
    var useNativeFullscreenContainer = true
    var isFindInteractionEnabled = false
    var minimumViewportInset: UIEdgeInsets? = nil
    var maximumViewportInset: UIEdgeInsets? = nil
    var isInspectable = false
    var shouldPrintBackgrounds = false
    var allowsInlinePredictions = false
    var obscuredContentInsets: UIEdgeInsets? = nil
    /// Smart Reply payload for `WKWebView.conversationContext` (iOS 26+, not Mac Catalyst).
    var conversationContext: [String: Any]? = nil
    var javaScriptHandlersOriginAllowList: [String]? = nil
    var javaScriptBridgeEnabled = true
    var javaScriptBridgeOriginAllowList: [String]? = nil
    var javaScriptBridgeForMainFrameOnly = false
    var pluginScriptsOriginAllowList: [String]? = nil
    var pluginScriptsForMainFrameOnly = false
    var isUserInteractionEnabled = true
    var alpha: Double? = nil
    
    override init(){
        super.init()
    }
    
    override func parse(settings: [String: Any?]) -> InAppWebViewSettings {
        var settings = settings // re-assing to be able to use removeValue
        if let minimumViewportInsetMap = settings["minimumViewportInset"] as? [String : Double] {
            minimumViewportInset = UIEdgeInsets.fromMap(map: minimumViewportInsetMap)
            settings.removeValue(forKey: "minimumViewportInset")
        }
        if let maximumViewportInsetMap = settings["maximumViewportInset"] as? [String : Double] {
            maximumViewportInset = UIEdgeInsets.fromMap(map: maximumViewportInsetMap)
            settings.removeValue(forKey: "maximumViewportInset")
        }
        if let obscuredContentInsetsMap = settings["obscuredContentInsets"] as? [String : Double] {
            obscuredContentInsets = UIEdgeInsets.fromMap(map: obscuredContentInsetsMap)
            settings.removeValue(forKey: "obscuredContentInsets")
        }
        if settings.keys.contains("conversationContext") {
            if let conversationContextMap = settings["conversationContext"] as? [String: Any] {
                conversationContext = conversationContextMap
            } else {
                conversationContext = nil
            }
            settings.removeValue(forKey: "conversationContext")
        }
        // nullable values with primitive type (Int, Double, etc.)
        // must be handled here as super.parse will not work
        if let alphaValue = settings["alpha"] as? Double {
            alpha = alphaValue
            settings.removeValue(forKey: "alpha")
        }
        let _ = super.parse(settings: settings)
        if #available(iOS 13.0, *) {} else {
            applePayAPIEnabled = false
        }
        return self
    }
    
    override func getRealSettings(obj: InAppWebView?) -> [String: Any?] {
        var realSettings: [String: Any?] = toMap()
        if let webView = obj {
            realSettings["isUserInteractionEnabled"] = webView.isUserInteractionEnabled
            realSettings["alpha"] = Double(webView.alpha)
            let configuration = webView.configuration
            if #available(iOS 9.0, *) {
                realSettings["userAgent"] = webView.customUserAgent
                realSettings["applicationNameForUserAgent"] = configuration.applicationNameForUserAgent
                realSettings["allowsAirPlayForMediaPlayback"] = configuration.allowsAirPlayForMediaPlayback
                realSettings["allowsLinkPreview"] = webView.allowsLinkPreview
                realSettings["allowsPictureInPictureMediaPlayback"] = configuration.allowsPictureInPictureMediaPlayback
            }
            realSettings["javaScriptCanOpenWindowsAutomatically"] = configuration.preferences.javaScriptCanOpenWindowsAutomatically
            if #available(iOS 10.0, *) {
                realSettings["mediaPlaybackRequiresUserGesture"] = configuration.mediaTypesRequiringUserActionForPlayback == .all
                realSettings["ignoresViewportScaleLimits"] = configuration.ignoresViewportScaleLimits
                realSettings["dataDetectorTypes"] = Util.getDataDetectorTypeString(type: configuration.dataDetectorTypes)
            } else {
                realSettings["mediaPlaybackRequiresUserGesture"] = configuration.mediaPlaybackRequiresUserAction
            }
            realSettings["minimumFontSize"] = Int(configuration.preferences.minimumFontSize)
            realSettings["suppressesIncrementalRendering"] = configuration.suppressesIncrementalRendering
            realSettings["allowsBackForwardNavigationGestures"] = webView.allowsBackForwardNavigationGestures
            realSettings["allowsInlineMediaPlayback"] = configuration.allowsInlineMediaPlayback
            if #available(iOS 13.0, *) {
                realSettings["isFraudulentWebsiteWarningEnabled"] = configuration.preferences.isFraudulentWebsiteWarningEnabled
                realSettings["preferredContentMode"] = configuration.defaultWebpagePreferences.preferredContentMode.rawValue
                realSettings["automaticallyAdjustsScrollIndicatorInsets"] = webView.scrollView.automaticallyAdjustsScrollIndicatorInsets
            }
            realSettings["selectionGranularity"] = configuration.selectionGranularity.rawValue
            if #available(iOS 11.0, *) {
                realSettings["accessibilityIgnoresInvertColors"] = webView.accessibilityIgnoresInvertColors
                realSettings["contentInsetAdjustmentBehavior"] = webView.scrollView.contentInsetAdjustmentBehavior.rawValue
            }
            realSettings["decelerationRate"] = Util.getDecelerationRateString(type: webView.scrollView.decelerationRate)
            realSettings["alwaysBounceVertical"] = webView.scrollView.alwaysBounceVertical
            realSettings["alwaysBounceHorizontal"] = webView.scrollView.alwaysBounceHorizontal
            realSettings["scrollsToTop"] = webView.scrollView.scrollsToTop
            realSettings["isPagingEnabled"] = webView.scrollView.isPagingEnabled
            realSettings["maximumZoomScale"] = webView.scrollView.maximumZoomScale
            realSettings["minimumZoomScale"] = webView.scrollView.minimumZoomScale
            realSettings["allowUniversalAccessFromFileURLs"] = configuration.value(forKey: "allowUniversalAccessFromFileURLs")
            realSettings["allowFileAccessFromFileURLs"] = configuration.preferences.value(forKey: "allowFileAccessFromFileURLs")
            realSettings["isDirectionalLockEnabled"] = webView.scrollView.isDirectionalLockEnabled
            realSettings["javaScriptEnabled"] = configuration.preferences.javaScriptEnabled
            if #available(iOS 14.0, *) {
                realSettings["mediaType"] = webView.mediaType
                realSettings["pageZoom"] = Float(webView.pageZoom)
                realSettings["limitsNavigationsToAppBoundDomains"] = configuration.limitsNavigationsToAppBoundDomains
                realSettings["javaScriptEnabled"] = configuration.defaultWebpagePreferences.allowsContentJavaScript
            }
            if #available(iOS 15.0, *) {
                realSettings["isTextInteractionEnabled"] = configuration.preferences.isTextInteractionEnabled
                realSettings["upgradeKnownHostsToHTTPS"] = configuration.upgradeKnownHostsToHTTPS
                realSettings["underPageBackgroundColor"] = webView.underPageBackgroundColor.hexString
            }
            if #available(iOS 15.4, *) {
                realSettings["isSiteSpecificQuirksModeEnabled"] = configuration.preferences.isSiteSpecificQuirksModeEnabled
                realSettings["isElementFullscreenEnabled"] = configuration.preferences.isElementFullscreenEnabled
            }
            if #available(iOS 15.5, *) {
                realSettings["minimumViewportInset"] = webView.minimumViewportInset.toMap()
                realSettings["maximumViewportInset"] = webView.maximumViewportInset.toMap()
            }
            if #available(iOS 16.0, *) {
                realSettings["isFindInteractionEnabled"] = webView.isFindInteractionEnabled
            }
            if #available(iOS 16.4, *) {
                realSettings["isInspectable"] = webView.isInspectable
                realSettings["shouldPrintBackgrounds"] = configuration.preferences.shouldPrintBackgrounds
            }
            if #available(iOS 18.0, *) {
                realSettings["writingToolsBehavior"] = configuration.writingToolsBehavior.rawValue
            }
            if #available(iOS 17.0, *) {
                realSettings["allowsInlinePredictions"] = configuration.allowsInlinePredictions
            }
            if #available(iOS 26.0, *) {
                realSettings["obscuredContentInsets"] = UIEdgeInsets(
                    top: webView.obscuredContentInsets.top,
                    left: webView.obscuredContentInsets.leading,
                    bottom: webView.obscuredContentInsets.bottom,
                    right: webView.obscuredContentInsets.trailing
                ).toMap()
            }
            realSettings["conversationContext"] = conversationContext
        }
        return realSettings
    }

    /// Builds a soft-linked `UIConversationContext` subclass from a Dart settings map.
    ///
    /// Uses `NSClassFromString` + KVC so older SDKs that lack the UIKit Smart Reply
    /// headers still compile. Unsupported keys are ignored.
    static func makeConversationContext(from map: [String: Any]) -> NSObject? {
        #if targetEnvironment(macCatalyst)
        return nil
        #else
        let type = ((map["type"] as? String) ?? "message").lowercased()
        let isMail = type == "mail"
        let contextClassName = isMail
            ? "UIMailConversationContext"
            : "UIMessageConversationContext"
        guard let contextClass = NSClassFromString(contextClassName) as? NSObject.Type else {
            return nil
        }
        let context = contextClass.init()

        if let threadIdentifier = map["threadIdentifier"] as? String {
            ConversationContextKVC.setString(threadIdentifier, forKey: "threadIdentifier", on: context)
        }
        if let selfIdentifiers = stringArray(from: map["selfIdentifiers"]) {
            ConversationContextKVC.setStringSet(selfIdentifiers, forKey: "selfIdentifiers", on: context)
        }
        if let recipients = stringArray(from: map["responsePrimaryRecipientIdentifiers"]) {
            ConversationContextKVC.setStringSet(
                recipients,
                forKey: "responsePrimaryRecipientIdentifiers",
                on: context
            )
        }
        if let participantNames = map["participantNameByIdentifier"] as? [String: Any] {
            let names = NSMutableDictionary()
            for (identifier, value) in participantNames {
                if let components = personNameComponents(from: value) {
                    names[identifier] = components
                }
            }
            if names.count > 0 {
                ConversationContextKVC.setValue(names, forKey: "participantNameByIdentifier", on: context)
            }
        }
        if !isMail, let isJunk = map["isJunk"] as? Bool {
            ConversationContextKVC.setValue(NSNumber(value: isJunk), forKey: "isJunk", on: context)
        }

        let entryClassName = isMail
            ? "UIMailConversationEntry"
            : "UIMessageConversationEntry"
        if let rawEntries = map["entries"] as? [Any],
           let entryClass = NSClassFromString(entryClassName) as? NSObject.Type {
            let entries = NSMutableArray()
            for rawEntry in rawEntries {
                guard let entryMap = rawEntry as? [String: Any] else { continue }
                let entry = entryClass.init()
                populateConversationEntry(entry, from: entryMap, isMail: isMail)
                entries.add(entry)
            }
            if entries.count > 0 {
                ConversationContextKVC.setValue(entries, forKey: "entries", on: context)
            }
        }

        return context
        #endif
    }

    private static func populateConversationEntry(
        _ entry: NSObject,
        from map: [String: Any],
        isMail: Bool
    ) {
        if let text = map["text"] as? String {
            ConversationContextKVC.setString(text, forKey: "text", on: entry)
        }
        if let senderIdentifier = map["senderIdentifier"] as? String {
            ConversationContextKVC.setString(senderIdentifier, forKey: "senderIdentifier", on: entry)
        }
        if let entryIdentifier = map["entryIdentifier"] as? String {
            ConversationContextKVC.setString(entryIdentifier, forKey: "entryIdentifier", on: entry)
        }
        if let replyThreadIdentifier = map["replyThreadIdentifier"] as? String {
            ConversationContextKVC.setString(
                replyThreadIdentifier,
                forKey: "replyThreadIdentifier",
                on: entry
            )
        }
        if let primaryRecipients = stringArray(from: map["primaryRecipientIdentifiers"]) {
            ConversationContextKVC.setStringSet(
                primaryRecipients,
                forKey: "primaryRecipientIdentifiers",
                on: entry
            )
        }
        if let sentDate = date(from: map["sentDate"]) {
            ConversationContextKVC.setValue(sentDate, forKey: "sentDate", on: entry)
        }
        guard isMail else { return }
        if let kind = mailEntryKind(from: map["kind"]) {
            ConversationContextKVC.setValue(NSNumber(value: kind), forKey: "kind", on: entry)
        }
        if let secondary = stringArray(from: map["responseSecondaryRecipientIdentifiers"]) {
            ConversationContextKVC.setStringSet(
                secondary,
                forKey: "responseSecondaryRecipientIdentifiers",
                on: entry
            )
        }
    }

    private static func stringArray(from value: Any?) -> [String]? {
        if let strings = value as? [String] {
            return strings
        }
        if let anyValues = value as? [Any] {
            let strings = anyValues.compactMap { $0 as? String }
            return strings.isEmpty ? nil : strings
        }
        return nil
    }

    private static func personNameComponents(from value: Any) -> PersonNameComponents? {
        if let fullName = value as? String {
            var components = PersonNameComponents()
            components.nickname = fullName
            let parts = fullName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if let given = parts.first {
                components.givenName = String(given)
            }
            if parts.count > 1 {
                components.familyName = String(parts[1])
            }
            return components
        }
        guard let map = value as? [String: Any] else { return nil }
        var components = PersonNameComponents()
        if let givenName = map["givenName"] as? String { components.givenName = givenName }
        if let familyName = map["familyName"] as? String { components.familyName = familyName }
        if let middleName = map["middleName"] as? String { components.middleName = middleName }
        if let nickname = map["nickname"] as? String { components.nickname = nickname }
        if let namePrefix = map["namePrefix"] as? String { components.namePrefix = namePrefix }
        if let nameSuffix = map["nameSuffix"] as? String { components.nameSuffix = nameSuffix }
        return components
    }

    private static func date(from value: Any?) -> Date? {
        guard let number = value as? NSNumber else { return nil }
        let raw = number.doubleValue
        // Dart DateTime / MethodChannel usually sends milliseconds since epoch.
        let seconds = raw > 1_000_000_000_000 ? raw / 1000.0 : raw
        return Date(timeIntervalSince1970: seconds)
    }

    private static func mailEntryKind(from value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        guard let name = (value as? String)?.lowercased() else { return nil }
        switch name {
        case "none": return 0
        case "personal": return 1
        case "promotion", "promotional": return 2
        case "social": return 3
        case "transaction", "transactional": return 4
        case "news": return 5
        default: return nil
        }
    }
}

/// Soft KVC helpers for UIKit Smart Reply types that may be missing at compile time.
private enum ConversationContextKVC {
    static func setterSelector(forKey key: String) -> Selector {
        let first = key.prefix(1).uppercased()
        let rest = key.dropFirst()
        return NSSelectorFromString("set\(first)\(rest):")
    }

    static func setValue(_ value: Any?, forKey key: String, on object: NSObject) {
        guard object.responds(to: setterSelector(forKey: key)) else { return }
        object.setValue(value, forKey: key)
    }

    static func setString(_ value: String, forKey key: String, on object: NSObject) {
        setValue(value as NSString, forKey: key, on: object)
    }

    static func setStringSet(_ values: [String], forKey key: String, on object: NSObject) {
        setValue(NSSet(array: values), forKey: key, on: object)
    }
}
