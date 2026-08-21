import Foundation
import Flutter

public class DownloadJobChannelDelegate: ChannelDelegate {
    private weak var downloadJobController: DownloadJobController?

    public init(downloadJobController: DownloadJobController, channel: FlutterMethodChannel) {
        super.init(channel: channel)
        self.downloadJobController = downloadJobController
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "cancel":
            downloadJobController?.cancel()
            result(true)
        case "getInfo":
            result(downloadJobController?.getInfo())
        case "dispose":
            downloadJobController?.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onProgressChanged(progress: Double) {
        channel?.invokeMethod("onProgressChanged", arguments: ["progress": progress])
    }

    public func onComplete(completed: Bool, error: String?) {
        channel?.invokeMethod("onComplete", arguments: ["completed": completed, "error": error])
    }

    public override func dispose() {
        super.dispose()
        downloadJobController = nil
    }
}
