#!/bin/sh
# Builds and runs the standard-library-only Linux WebsiteDataSiteMatcher
# tests. They need no WPE WebKit, so they run on any host with a C++17
# compiler.
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
linux_dir="$repo_root/flutter_inappwebview_forge_linux/linux"
cxx=${CXX:-c++}

output_file=$(mktemp "${TMPDIR:-/tmp}/forge-linux-website-data-matcher.XXXXXX")
trap 'rm -f "$output_file"' EXIT

"$cxx" -std=c++17 -Wall -Wextra -Werror \
  "$linux_dir/utils/website_data_site_matcher.cc" \
  "$linux_dir/test/website_data_site_matcher_test.cc" \
  -o "$output_file"
"$output_file"
