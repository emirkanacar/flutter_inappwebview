//
//  MyWebStorageManager.swift
//  connectivity
//
//  Created by Lorenzo Pichilli on 16/12/2019.
//

import Foundation
import WebKit
import FlutterMacOS

public class MyWebStorageManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_webstoragemanager"
    var plugin: InAppWebViewFlutterPlugin?
    static var websiteDataStore = WKWebsiteDataStore.default()
    
    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: MyWebStorageManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "fetchDataRecords":
                guard let dataTypes = arguments?["dataTypes"] as? [String] else {
                    result(FlutterError(code: "invalid_arguments", message: "dataTypes is required.", details: nil))
                    return
                }
                MyWebStorageManager.fetchDataRecords(dataTypes: Set(dataTypes), result: result)
                break
            case "removeDataFor":
                guard let dataTypes = arguments?["dataTypes"] as? [String],
                      let recordList = arguments?["recordList"] as? [[String: Any?]] else {
                    result(FlutterError(code: "invalid_arguments", message: "Invalid web storage records.", details: nil))
                    return
                }
                MyWebStorageManager.removeDataFor(dataTypes: Set(dataTypes), recordList: recordList, result: result)
                break
            case "removeDataModifiedSince":
                guard let dataTypes = arguments?["dataTypes"] as? [String],
                      let timestamp = arguments?["timestamp"] as? Int64 else {
                    result(FlutterError(code: "invalid_arguments", message: "Invalid web storage timestamp.", details: nil))
                    return
                }
                MyWebStorageManager.removeDataModifiedSince(dataTypes: Set(dataTypes), timestamp: timestamp, result: result)
                break
            case "deleteBrowsingData":
                MyWebStorageManager.deleteBrowsingData(result: result)
                break
            case "deleteBrowsingDataForSite":
                guard let site = arguments?["site"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: "site is required.", details: nil))
                    return
                }
                MyWebStorageManager.deleteBrowsingDataForSite(site: site, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public static func fetchDataRecords(dataTypes: Set<String>, result: @escaping FlutterResult) {
        var recordList: [[String: Any?]] = []
        
        MyWebStorageManager.websiteDataStore.fetchDataRecords(ofTypes: dataTypes) { (data) in
            for record in data {
                recordList.append([
                    "displayName": record.displayName,
                    "dataTypes": record.dataTypes.map({ (dataType) -> String in
                        return dataType
                    })
                ])
            }
            result(recordList)
        }
    }
    
    public static func removeDataFor(dataTypes: Set<String>, recordList: [[String: Any?]], result: @escaping FlutterResult) {
        var records: [WKWebsiteDataRecord] = []
        
        MyWebStorageManager.websiteDataStore.fetchDataRecords(ofTypes: dataTypes) { (data) in
            for record in data {
                for r in recordList {
                    guard let displayName = r["displayName"] as? String else {
                        continue
                    }
                    if (record.displayName == displayName) {
                        records.append(record)
                        break
                    }
                }
            }
            websiteDataStore.removeData(ofTypes: dataTypes, for: records) {
                result(true)
            }
        }
    }
    
    public static func removeDataModifiedSince(dataTypes: Set<String>, timestamp: Int64, result: @escaping FlutterResult) {
        // The Dart side sends DateTime.millisecondsSinceEpoch.
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
        MyWebStorageManager.websiteDataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
            result(true)
        }
    }

    public static func deleteBrowsingData(result: @escaping FlutterResult) {
        MyWebStorageManager.websiteDataStore.removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {
            result(true)
        }
    }

    public static func deleteBrowsingDataForSite(site: String, result: @escaping FlutterResult) {
        guard let host = WebsiteDataSiteMatcher.normalizedHost(site) else {
            result(nil)
            return
        }
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        MyWebStorageManager.websiteDataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            let names = records.map { $0.displayName }
            let matched = WebsiteDataSiteMatcher.matchingNames(host: host, recordNames: names)
            let toRemove = records.filter { matched.names.contains($0.displayName.lowercased()) }
            guard !toRemove.isEmpty else {
                result(matched.site)
                return
            }
            MyWebStorageManager.websiteDataStore.removeData(ofTypes: dataTypes, for: toRemove) {
                result(matched.site)
            }
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
