#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 <path-to-appex-info-plist>"
  exit 2
fi

plist_path="$1"

if [ ! -f "$plist_path" ]; then
  echo "ERROR: plist not found: $plist_path"
  exit 1
fi

if ! /usr/bin/plutil -extract NSExtension xml1 -o - "$plist_path" >/dev/null 2>&1; then
  echo "ERROR: Missing NSExtension dictionary in $plist_path"
  exit 1
fi

echo "OK: NSExtension dictionary present in $plist_path"
