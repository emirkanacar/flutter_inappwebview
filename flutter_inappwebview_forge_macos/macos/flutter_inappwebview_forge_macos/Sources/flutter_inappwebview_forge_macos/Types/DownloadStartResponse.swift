import Foundation

public class DownloadStartResponse: NSObject {
    var handled: Bool
    var action: Int?
    var resultFilePath: String?

    public init(handled: Bool, action: Int?, resultFilePath: String?) {
        self.handled = handled
        self.action = action
        self.resultFilePath = resultFilePath
    }

    public static func fromMap(map: [String: Any?]?) -> DownloadStartResponse? {
        guard let map = map else { return nil }
        return DownloadStartResponse(
            handled: map["handled"] as? Bool ?? false,
            action: map["action"] as? Int,
            resultFilePath: map["resultFilePath"] as? String
        )
    }
}
