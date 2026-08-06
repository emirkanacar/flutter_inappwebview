#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <release.apk|release.aab>" >&2
  exit 2
}

if [[ "$#" -ne 1 ]]; then
  usage
fi

artifact="$1"
if [[ ! -f "$artifact" ]]; then
  echo "Artifact not found: $artifact" >&2
  exit 2
fi

case "${artifact##*.}" in
  apk|aab) ;;
  *)
    echo "Expected an APK or AAB artifact: $artifact" >&2
    exit 2
    ;;
esac

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is required to inspect native libraries in $artifact" >&2
  exit 2
fi

readelf_bin=""
if command -v llvm-readelf >/dev/null 2>&1; then
  readelf_bin="$(command -v llvm-readelf)"
elif command -v readelf >/dev/null 2>&1; then
  readelf_bin="$(command -v readelf)"
fi

if [[ -z "$readelf_bin" ]]; then
  for ndk_root in "${ANDROID_NDK_ROOT:-}" "${ANDROID_NDK_HOME:-}" "${ANDROID_HOME:-}/ndk"; do
    [[ -d "$ndk_root" ]] || continue
    for candidate in "$ndk_root"/*/toolchains/llvm/prebuilt/*/bin/llvm-readelf \
      "$ndk_root"/toolchains/llvm/prebuilt/*/bin/llvm-readelf; do
      if [[ -x "$candidate" ]]; then
        readelf_bin="$candidate"
      fi
    done
  done
fi

entries="$(unzip -Z1 "$artifact" | awk '/\.so$/ { print }')"
if [[ -z "$entries" ]]; then
  echo "No native .so files found in $artifact; no ELF alignment check is required for this artifact."
  exit 0
fi

if [[ -z "$readelf_bin" ]]; then
  echo "llvm-readelf or readelf is required to validate ELF PT_LOAD alignment; add Android NDK LLVM tools to PATH or set ANDROID_NDK_ROOT." >&2
  exit 2
fi

if [[ "${artifact##*.}" == "apk" ]]; then
  zipalign_bin=""
  if command -v zipalign >/dev/null 2>&1; then
    zipalign_bin="$(command -v zipalign)"
  elif [[ -n "${ANDROID_HOME:-}" ]]; then
    for candidate in "$ANDROID_HOME"/build-tools/*/zipalign; do
      if [[ -x "$candidate" ]]; then
        zipalign_bin="$candidate"
      fi
    done
  fi

  if [[ -z "$zipalign_bin" ]]; then
    echo "zipalign is required to validate APK ZIP alignment; add Android build-tools to PATH or set ANDROID_HOME." >&2
    exit 2
  fi

  echo "Checking APK ZIP alignment with 16 KB pages..."
  "$zipalign_bin" -c -P 16 4 "$artifact"
else
  bundletool_bin="${BUNDLETOOL:-}"
  if [[ -z "$bundletool_bin" ]] && command -v bundletool >/dev/null 2>&1; then
    bundletool_bin="$(command -v bundletool)"
  fi
  if [[ -z "$bundletool_bin" ]]; then
    echo "bundletool is required to validate AAB PAGE_ALIGNMENT_16K configuration; set BUNDLETOOL or add it to PATH." >&2
    exit 2
  fi

  echo "Checking AAB bundle alignment configuration..."
  bundle_config="$($bundletool_bin dump config --bundle="$artifact")"
  if ! grep -q 'PAGE_ALIGNMENT_16K' <<<"$bundle_config"; then
    echo "AAB does not request PAGE_ALIGNMENT_16K." >&2
    echo "$bundle_config" >&2
    exit 1
  fi
fi

temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/flutter-inappwebview-16k.XXXXXX")"
trap 'rm -rf "$temporary_dir"' EXIT

failed=0
while IFS= read -r entry; do
  [[ -n "$entry" ]] || continue
  output_file="$temporary_dir/$(printf '%s' "$entry" | tr '/:' '__')"
  unzip -p "$artifact" "$entry" > "$output_file"

  alignments="$($readelf_bin -l "$output_file" | awk '$1 == "LOAD" { print $NF }')"
  if [[ -z "$alignments" ]]; then
    echo "Unable to find ELF PT_LOAD alignment for $entry" >&2
    failed=1
    continue
  fi

  while IFS= read -r alignment; do
    [[ -n "$alignment" ]] || continue
    numeric_alignment=$((alignment))
    if ((numeric_alignment < 16384)); then
      echo "UNALIGNED: $entry has PT_LOAD alignment $alignment (minimum: 0x4000)" >&2
      failed=1
    fi
  done <<<"$alignments"
done <<<"$entries"

if ((failed != 0)); then
  exit 1
fi

echo "All native libraries in $artifact use at least 16 KB ELF alignment."
