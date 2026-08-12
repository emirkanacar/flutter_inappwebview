//
//  ContainerManager.swift
//  flutter_inappwebview_forge_ios
//

import Foundation
import WebKit
import Flutter

@available(iOS 17.0, *)
public class ContainerManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_containercontroller"

    private var plugin: InAppWebViewFlutterPlugin?

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(
            name: ContainerManager.METHOD_CHANNEL_NAME,
            binaryMessenger: plugin.registrar.messenger()
        ))
        self.plugin = plugin
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "getAllContainerNames":
            WKWebsiteDataStore.fetchAllDataStoreIdentifiers { identifiers in
                result(identifiers.map { $0.uuidString })
            }
        case "hasContainer":
            guard let containerId = arguments?["containerId"] as? String,
                  let identifier = UUID(uuidString: containerId) else {
                result(false)
                return
            }
            WKWebsiteDataStore.fetchAllDataStoreIdentifiers { identifiers in
                result(identifiers.contains(identifier))
            }
        case "deleteContainer":
            guard let containerId = arguments?["containerId"] as? String,
                  let identifier = UUID(uuidString: containerId) else {
                result(false)
                return
            }
            WKWebsiteDataStore.fetchAllDataStoreIdentifiers { identifiers in
                guard identifiers.contains(identifier) else {
                    result(false)
                    return
                }
                Task { @MainActor in
                    WKWebsiteDataStore.remove(forIdentifier: identifier) { error in
                        result(error == nil)
                    }
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public override func dispose() {
        super.dispose()
        plugin = nil
    }

    deinit {
        dispose()
    }
}
