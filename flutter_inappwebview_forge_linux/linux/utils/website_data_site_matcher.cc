#include "website_data_site_matcher.h"

#include <algorithm>
#include <cctype>

namespace flutter_inappwebview_plugin {
namespace WebsiteDataSiteMatcher {

namespace {

std::string toLower(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return value;
}

std::string trim(const std::string& value) {
  const char* whitespace = " \t\r\n\f\v";
  auto start = value.find_first_not_of(whitespace);
  if (start == std::string::npos) {
    return "";
  }
  auto end = value.find_last_not_of(whitespace);
  return value.substr(start, end - start + 1);
}

bool endsWith(const std::string& value, const std::string& suffix) {
  return value.size() >= suffix.size() &&
         value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0;
}

bool isDigits(const std::string& value) {
  return !value.empty() &&
         std::all_of(value.begin(), value.end(),
                     [](unsigned char c) { return std::isdigit(c) != 0; });
}

}  // namespace

std::optional<std::string> normalizedHost(const std::string& site) {
  std::string value = toLower(trim(site));
  if (value.empty()) {
    return std::nullopt;
  }

  auto scheme = value.find("://");
  if (scheme != std::string::npos) {
    value = value.substr(scheme + 3);
  }

  // Authority ends at the first path, query, or fragment delimiter.
  auto authorityEnd = value.find_first_of("/?#");
  if (authorityEnd != std::string::npos) {
    value = value.substr(0, authorityEnd);
  }

  // Drop user info.
  auto at = value.rfind('@');
  if (at != std::string::npos) {
    value = value.substr(at + 1);
  }

  std::string host;
  if (!value.empty() && value.front() == '[') {
    // IPv6 literal, optionally followed by :port.
    auto close = value.find(']');
    if (close == std::string::npos) {
      return std::nullopt;
    }
    std::string rest = value.substr(close + 1);
    if (!rest.empty() && !(rest.front() == ':' && (rest.size() == 1 || isDigits(rest.substr(1))))) {
      return std::nullopt;
    }
    host = value.substr(1, close - 1);
  } else {
    auto colon = value.find(':');
    if (colon != std::string::npos) {
      std::string port = value.substr(colon + 1);
      if (!port.empty() && !isDigits(port)) {
        return std::nullopt;
      }
      value = value.substr(0, colon);
    }
    host = value;
  }

  while (!host.empty() && host.back() == '.') {
    host.pop_back();
  }
  if (host.empty() || host.find_first_of(" \t\r\n\f\v") != std::string::npos) {
    return std::nullopt;
  }
  return host;
}

Match matchingNames(const std::string& host,
                    const std::vector<std::string>& recordNames) {
  const std::string lowerHost = toLower(host);

  std::set<std::string> names;
  for (const auto& name : recordNames) {
    if (!name.empty()) {
      names.insert(toLower(name));
    }
  }

  std::optional<std::string> site;
  for (const auto& name : names) {
    if (lowerHost == name || endsWith(lowerHost, "." + name)) {
      if (!site.has_value() || name.size() < site->size()) {
        site = name;
      }
    }
  }

  if (!site.has_value()) {
    return Match{lowerHost, {}};
  }

  Match match{site.value(), {}};
  for (const auto& name : names) {
    if (name == match.site || endsWith(name, "." + match.site)) {
      match.names.insert(name);
    }
  }
  return match;
}

}  // namespace WebsiteDataSiteMatcher
}  // namespace flutter_inappwebview_plugin
