import Foundation
import WebKit
import FlutterMacOS

@available(macOS 14.0, *)
public class ContainerManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_containercontroller"

    private var plugin: InAppWebViewFlutterPlugin?

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(
            name: ContainerManager.METHOD_CHANNEL_NAME,
            binaryMessenger: plugin.registrar.messenger
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
            guard let value = arguments?["containerId"] as? String,
                  let identifier = UUID(uuidString: value) else {
                result(false)
                return
            }
            WKWebsiteDataStore.fetchAllDataStoreIdentifiers { identifiers in
                result(identifiers.contains(identifier))
            }
        case "deleteContainer":
            guard let value = arguments?["containerId"] as? String,
                  let identifier = UUID(uuidString: value) else {
                result(false)
                return
            }
            WKWebsiteDataStore.remove(forIdentifier: identifier) { error in
                result(error == nil)
            }
        case "clearContainerData":
            guard let value = arguments?["containerId"] as? String,
                  let identifier = UUID(uuidString: value) else {
                result(false)
                return
            }
            WKWebsiteDataStore(forIdentifier: identifier).removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                modifiedSince: Date(timeIntervalSince1970: 0)
            ) {
                result(true)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public override func dispose() {
        super.dispose()
        plugin = nil
    }
}
