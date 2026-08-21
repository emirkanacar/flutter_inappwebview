import Foundation
import Flutter
import WebKit

@available(iOS 14.5, *)
public class DownloadJobController: NSObject, Disposable, WKDownloadDelegate {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_inappwebview_downloadjobcontroller_"

    var id: String
    var plugin: InAppWebViewFlutterPlugin?
    var download: WKDownload?
    var destinationURL: URL
    var sourceURL: String?
    var channelDelegate: DownloadJobChannelDelegate?
    var state: Int = 1
    var progress: Double = 0
    var error: String?
    var resumeDataBase64: String?
    private var progressObservation: NSKeyValueObservation?

    public init(plugin: InAppWebViewFlutterPlugin, id: String, download: WKDownload, destinationURL: URL) {
        self.id = id
        self.plugin = plugin
        self.download = download
        self.destinationURL = destinationURL
        self.sourceURL = download.originalRequest?.url?.absoluteString
        super.init()
        let channel = FlutterMethodChannel(
            name: DownloadJobController.METHOD_CHANNEL_NAME_PREFIX + id,
            binaryMessenger: plugin.registrar.messenger()
        )
        self.channelDelegate = DownloadJobChannelDelegate(downloadJobController: self, channel: channel)
        download.delegate = self
        observeProgress(download.progress)
    }

    private func observeProgress(_ progressObject: Progress) {
        progressObservation = progressObject.observe(\.fractionCompleted, options: [.new]) { [weak self] progress, _ in
            guard let self = self else { return }
            self.progress = progress.fractionCompleted
            self.channelDelegate?.onProgressChanged(progress: self.progress)
        }
    }

    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        completionHandler(destinationURL)
    }

    public func downloadDidFinish(_ download: WKDownload) {
        state = 2
        progress = 1
        channelDelegate?.onProgressChanged(progress: 1)
        channelDelegate?.onComplete(completed: true, error: nil)
    }

    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        state = 3
        self.error = error.localizedDescription
        if let resumeData = resumeData {
            resumeDataBase64 = resumeData.base64EncodedString()
        }
        channelDelegate?.onComplete(completed: false, error: self.error)
    }

    public func cancel() {
        download?.cancel { [weak self] resumeData in
            self?.resumeDataBase64 = resumeData?.base64EncodedString()
        }
        state = 4
        channelDelegate?.onComplete(completed: false, error: "canceled")
    }

    public func getInfo() -> [String: Any?] {
        return [
            "id": id,
            "url": sourceURL,
            "resultFilePath": destinationURL.path,
            "progress": progress,
            "state": state,
            "error": error,
            "resumeDataBase64": resumeDataBase64
        ]
    }

    public func dispose() {
        progressObservation?.invalidate()
        progressObservation = nil
        download?.delegate = nil
        download = nil
        plugin?.downloadJobManager?.jobs.removeValue(forKey: id)
        channelDelegate?.dispose()
        channelDelegate = nil
        plugin = nil
    }
}
