//
//  WebsiteDataSiteMatcher.swift
//
//  Maps a host or URL to the WKWebsiteDataRecord display names that belong to
//  the same site. WebKit groups website data by registrable domain (eTLD+1)
//  and exposes that domain as WKWebsiteDataRecord.displayName, but it has no
//  public Public Suffix List API. The site is therefore taken from the record
//  names themselves: the shortest record name that equals the host or is one
//  of its parent domains is the site, and every record for that site or one
//  of its subdomains is matched.
//
//  This file depends only on Foundation so it can be unit tested with swiftc
//  (see tool/run_apple_website_data_matcher_tests.sh).
//

import Foundation

public enum WebsiteDataSiteMatcher {
    public struct Match: Equatable {
        /// The site whose data is deleted: the matched registrable record
        /// name, or the normalized host when no record matches.
        public let site: String
        /// Lowercased record names to delete.
        public let names: Set<String>
    }

    /// Returns the lowercased host of [site], which may be a bare host
    /// (`www.example.com`), a host with port, or an absolute URL. Returns nil
    /// when no host can be derived.
    public static func normalizedHost(_ site: String) -> String? {
        let trimmed = site.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return nil
        }
        let candidate = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let host = URLComponents(string: candidate)?.host else {
            return nil
        }
        var normalized = host
        while normalized.hasSuffix(".") {
            normalized.removeLast()
        }
        if normalized.hasPrefix("[") && normalized.hasSuffix("]") {
            normalized = String(normalized.dropFirst().dropLast())
        }
        return normalized.isEmpty ? nil : normalized
    }

    /// Selects the record names that belong to the site of [host].
    public static func matchingNames(host: String, recordNames: [String]) -> Match {
        let lowerHost = host.lowercased()
        let names = Set(recordNames.map { $0.lowercased() }.filter { !$0.isEmpty })
        let siteCandidates = names.filter { lowerHost == $0 || lowerHost.hasSuffix("." + $0) }
        guard let site = siteCandidates.min(by: { $0.count < $1.count }) else {
            return Match(site: lowerHost, names: [])
        }
        let matched = names.filter { $0 == site || $0.hasSuffix("." + site) }
        return Match(site: site, names: matched)
    }
}
