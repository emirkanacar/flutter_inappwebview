// Standard-library-only tests for WebsiteDataSiteMatcher. Not part of the
// gtest runner; run with tool/run_linux_website_data_matcher_tests.sh.

#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>

#include "../utils/website_data_site_matcher.h"

using flutter_inappwebview_plugin::WebsiteDataSiteMatcher::matchingNames;
using flutter_inappwebview_plugin::WebsiteDataSiteMatcher::normalizedHost;

namespace {

int checks = 0;

void expect(bool condition, const char* message) {
  checks++;
  if (!condition) {
    std::fprintf(stderr, "Assertion failed: %s\n", message);
    std::exit(1);
  }
}

bool hostIs(const std::string& input, const std::string& expected) {
  auto host = normalizedHost(input);
  return host.has_value() && host.value() == expected;
}

void testNormalizesHostsAndUrls() {
  expect(hostIs("www.Example.com", "www.example.com"), "bare host");
  expect(hostIs(" https://WWW.example.com/path?q=1 ", "www.example.com"), "URL");
  expect(hostIs("example.com:8443", "example.com"), "host with port");
  expect(hostIs("example.com.", "example.com"), "trailing dot");
  expect(hostIs("https://user:pw@example.com:8443/a", "example.com"), "user info");
  expect(hostIs("http://[::1]:8080/", "::1"), "IPv6 literal");
  expect(hostIs("example.com#frag", "example.com"), "fragment");
}

void testRejectsInputWithoutHost() {
  expect(!normalizedHost("").has_value(), "empty");
  expect(!normalizedHost("   ").has_value(), "blank");
  expect(!normalizedHost("file:///tmp/a.html").has_value(), "file URL has no host");
  expect(!normalizedHost("example.com:abc").has_value(), "invalid port");
  expect(!normalizedHost("http://[::1").has_value(), "unterminated IPv6");
}

void testMatchesRegistrableDomainFromSubdomainHost() {
  auto match = matchingNames("www.example.co.uk", {"example.co.uk", "other.com"});
  expect(match.site == "example.co.uk", "site is the matching record name");
  expect(match.names == std::set<std::string>{"example.co.uk"}, "only the site record");
}

void testMatchesSubdomainRecordsOfSite() {
  auto match = matchingNames("example.com", {"Example.com", "cdn.example.com", "example.org"});
  expect(match.site == "example.com", "site");
  expect(match.names == std::set<std::string>{"example.com", "cdn.example.com"},
         "site and subdomain records");
}

void testDoesNotMatchLookalikeDomains() {
  auto match = matchingNames("example.com", {"badexample.com", "example.com.evil.net"});
  expect(match.names.empty(), "lookalike domains must not match");
}

void testReturnsHostWhenNoRecordMatches() {
  auto match = matchingNames("news.example.com", {});
  expect(match.site == "news.example.com", "falls back to host");
  expect(match.names.empty(), "nothing to delete");
}

void testIgnoresEmptyRecordNames() {
  auto match = matchingNames("example.com", {"", "example.com"});
  expect(match.names == std::set<std::string>{"example.com"}, "empty names ignored");
}

}  // namespace

int main() {
  testNormalizesHostsAndUrls();
  testRejectsInputWithoutHost();
  testMatchesRegistrableDomainFromSubdomainHost();
  testMatchesSubdomainRecordsOfSite();
  testDoesNotMatchLookalikeDomains();
  testReturnsHostWhenNoRecordMatches();
  testIgnoresEmptyRecordNames();
  std::printf("Linux website data site matcher tests passed (%d checks)\n", checks);
  return 0;
}
