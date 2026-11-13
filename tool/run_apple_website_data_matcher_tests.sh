#!/bin/sh
# Runs the Foundation-only WebsiteDataSiteMatcher tests with swiftc and checks
# that the iOS and macOS copies of the matcher stay identical.
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ios_source="$repo_root/flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/WebsiteDataSiteMatcher.swift"
macos_source="$repo_root/flutter_inappwebview_forge_macos/macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/WebsiteDataSiteMatcher.swift"
test_file="$repo_root/flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Tests/WebsiteDataSiteMatcherTests.swift"

if ! cmp -s "$ios_source" "$macos_source"; then
  echo "WebsiteDataSiteMatcher.swift differs between iOS and macOS" >&2
  exit 1
fi

output_file=$(mktemp "${TMPDIR:-/tmp}/forge-website-data-matcher.XXXXXX")
module_cache=$(mktemp -d "${TMPDIR:-/tmp}/forge-website-data-matcher-cache.XXXXXX")
trap 'rm -f "$output_file"; rm -rf "$module_cache"' EXIT

swiftc -parse-as-library -module-cache-path "$module_cache" "$ios_source" "$test_file" -o "$output_file"
"$output_file"
