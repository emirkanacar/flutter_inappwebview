//
//  PullToRefreshChannelDelegate.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 05/05/22.
//

import Foundation
import UIKit
import Flutter

public class PullToRefreshChannelDelegate: ChannelDelegate {
    private weak var pullToRefreshControl: PullToRefreshControl?
    
    public init(pullToRefreshControl: PullToRefreshControl, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.pullToRefreshControl = pullToRefreshControl
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
        case "setEnabled":
            if let pullToRefreshView = pullToRefreshControl {
                let enabled = try requiredArgument(arguments, "enabled", as: Bool.self)
                if enabled {
                    pullToRefreshView.delegate?.enablePullToRefresh()
                } else {
                    pullToRefreshView.delegate?.disablePullToRefresh()
                }
                result(true)
            } else {
                result(false)
            }
            break
        case "isEnabled":
            if let pullToRefreshView = pullToRefreshControl {
                result(pullToRefreshView.delegate?.isPullToRefreshEnabled())
            } else {
                result(false)
            }
            break
        case "setRefreshing":
            if let pullToRefreshView = pullToRefreshControl {
                let refreshing = try requiredArgument(arguments, "refreshing", as: Bool.self)
                if refreshing {
                    pullToRefreshView.beginRefreshing()
                } else {
                    pullToRefreshView.endRefreshing()
                }
                result(true)
            } else {
                result(false)
            }
            break
        case "isRefreshing":
            if let pullToRefreshView = pullToRefreshControl {
                result(pullToRefreshView.isRefreshing)
            } else {
                result(false)
            }
            break
        case "setColor":
            if let pullToRefreshView = pullToRefreshControl {
                let color = try requiredArgument(arguments, "color", as: String.self)
                pullToRefreshView.tintColor = UIColor(hexString: color)
                result(true)
            } else {
                result(false)
            }
            break
        case "setBackgroundColor":
            if let pullToRefreshView = pullToRefreshControl {
                let color = try requiredArgument(arguments, "color", as: String.self)
                pullToRefreshView.backgroundColor = UIColor(hexString: color)
                result(true)
            } else {
                result(false)
            }
            break
        case "setStyledTitle":
            if let pullToRefreshView = pullToRefreshControl {
                let attributedTitleMap = try requiredArgument(arguments, "attributedTitle", as: [String: Any?].self)
                pullToRefreshView.attributedTitle = NSAttributedString.fromMap(map: attributedTitleMap)
                result(true)
            } else {
                result(false)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onRefresh() {
        guard canDispatchCallbacks() else { return }
        let arguments: [String: Any?] = [:]
        channel?.invokeMethod("onRefresh", arguments: arguments)
    }

    private func canDispatchCallbacks() -> Bool {
        guard channel != nil, let control = pullToRefreshControl else { return false }
        guard let webView = control.delegate as? InAppWebView else { return true }
        return webView.acceptsCallbacks()
    }
    
    public override func dispose() {
        super.dispose()
        pullToRefreshControl = nil
    }
    
    deinit {
        dispose()
    }
}
