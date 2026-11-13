#ifndef FLUTTER_INAPPWEBVIEW_LINUX_WEBSITE_DATA_SITE_MATCHER_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_WEBSITE_DATA_SITE_MATCHER_H_

// Maps a host or URL to the WebKitWebsiteData record names that belong to the
// same site. WebKit groups website data by registrable domain (eTLD+1) and
// exposes it through webkit_website_data_get_name(), but it has no public
// Public Suffix List API. The site is therefore taken from the record names:
// the shortest record name that equals the host or is one of its parent
// domains is the site, and every record for that site or one of its
// subdomains is matched. This mirrors the Apple WebsiteDataSiteMatcher.swift.
//
// This file depends only on the C++ standard library so it can be tested
// without WPE (see tool/run_linux_website_data_matcher_tests.sh).

#include <optional>
#include <set>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {
namespace WebsiteDataSiteMatcher {

struct Match {
  // The matched registrable record name, or the normalized host when no
  // record matches.
  std::string site;
  // Lowercased record names to delete.
  std::set<std::string> names;
};

// Returns the lowercased host of `site`, which may be a bare host
// (www.example.com), a host with port, or an absolute URL. Returns
// std::nullopt when no host can be derived.
std::optional<std::string> normalizedHost(const std::string& site);

// Selects the record names that belong to the site of `host`.
Match matchingNames(const std::string& host,
                    const std::vector<std::string>& recordNames);

}  // namespace WebsiteDataSiteMatcher
}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_LINUX_WEBSITE_DATA_SITE_MATCHER_H_
