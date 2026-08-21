import Foundation
import FlutterMacOS
import WebKit

@available(macOS 11.3, *)
public class DownloadJobManager: NSObject, Disposable {
    var plugin: InAppWebViewFlutterPlugin?
    var jobs: [String: DownloadJobController] = [:]

    public init(plugin: InAppWebViewFlutterPlugin?) {
        super.init()
        self.plugin = plugin
    }

    public func dispose() {
        let jobValues = Array(jobs.values)
        jobs.removeAll()
        jobValues.forEach { $0.dispose() }
        plugin = nil
    }

    deinit {
        dispose()
    }
}
