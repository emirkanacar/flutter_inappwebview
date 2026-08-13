#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_file="$repo_root/flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/WebViewLifecycleCoordinator.swift"
test_file="$repo_root/flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Tests/WebViewLifecycleCoordinatorTests.swift"
output_file=$(mktemp "${TMPDIR:-/tmp}/forge-ios-lifecycle.XXXXXX")
module_cache=$(mktemp -d "${TMPDIR:-/tmp}/forge-ios-lifecycle-cache.XXXXXX")
trap 'rm -f "$output_file"; rm -rf "$module_cache"' EXIT

swiftc -DDEBUG -parse-as-library -module-cache-path "$module_cache" "$source_file" "$test_file" -o "$output_file"
"$output_file"
