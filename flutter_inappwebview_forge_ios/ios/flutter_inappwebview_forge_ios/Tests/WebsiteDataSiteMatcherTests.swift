import Foundation

@main
struct WebsiteDataSiteMatcherTests {
    static func main() {
        testNormalizesHostsAndUrls()
        testRejectsInputWithoutHost()
        testMatchesRegistrableDomainFromSubdomainHost()
        testMatchesSubdomainRecordsOfSite()
        testDoesNotMatchLookalikeDomains()
        testReturnsHostWhenNoRecordMatches()
        print("Apple website data site matcher tests passed (6)")
    }

    private static func testNormalizesHostsAndUrls() {
        expect(WebsiteDataSiteMatcher.normalizedHost("www.Example.com") == "www.example.com", "bare host")
        expect(WebsiteDataSiteMatcher.normalizedHost(" https://WWW.example.com/path?q=1 ") == "www.example.com", "URL")
        expect(WebsiteDataSiteMatcher.normalizedHost("example.com:8443") == "example.com", "host with port")
        expect(WebsiteDataSiteMatcher.normalizedHost("example.com.") == "example.com", "trailing dot")
    }

    private static func testRejectsInputWithoutHost() {
        expect(WebsiteDataSiteMatcher.normalizedHost("") == nil, "empty")
        expect(WebsiteDataSiteMatcher.normalizedHost("   ") == nil, "blank")
        expect(WebsiteDataSiteMatcher.normalizedHost("file:///tmp/a.html") == nil, "file URL has no host")
    }

    private static func testMatchesRegistrableDomainFromSubdomainHost() {
        let match = WebsiteDataSiteMatcher.matchingNames(
            host: "www.example.co.uk",
            recordNames: ["example.co.uk", "other.com"]
        )
        expect(match.site == "example.co.uk", "site is the matching record name")
        expect(match.names == ["example.co.uk"], "only the site record is matched")
    }

    private static func testMatchesSubdomainRecordsOfSite() {
        let match = WebsiteDataSiteMatcher.matchingNames(
            host: "example.com",
            recordNames: ["Example.com", "cdn.example.com", "example.org"]
        )
        expect(match.site == "example.com", "site")
        expect(match.names == ["example.com", "cdn.example.com"], "site and subdomain records")
    }

    private static func testDoesNotMatchLookalikeDomains() {
        let match = WebsiteDataSiteMatcher.matchingNames(
            host: "example.com",
            recordNames: ["badexample.com", "example.com.evil.net"]
        )
        expect(match.names.isEmpty, "lookalike domains must not match")
    }

    private static func testReturnsHostWhenNoRecordMatches() {
        let match = WebsiteDataSiteMatcher.matchingNames(host: "news.example.com", recordNames: [])
        expect(match.site == "news.example.com", "falls back to host")
        expect(match.names.isEmpty, "nothing to delete")
    }

    private static func expect(_ condition: Bool, _ message: String) {
        if !condition {
            fatalError("Assertion failed: \(message)")
        }
    }
}
