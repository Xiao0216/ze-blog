#!/usr/bin/env bash
set -euo pipefail

host="${1:-zblog.wenshuai.site}"
base_url="${2:-http://127.0.0.1}"

fetch_headers() {
  local path="$1"
  curl -sS -D - -o /dev/null -H "Host: $host" "$base_url$path"
}

assert_status() {
  local label="$1"
  local headers="$2"
  local expected="$3"
  local actual

  actual="$(printf '%s\n' "$headers" | awk 'NR == 1 { print $2 }')"
  if [[ "$actual" != "$expected" ]]; then
    echo "unexpected status [$label]: expected $expected, got $actual" >&2
    printf '%s\n' "$headers" >&2
    exit 1
  fi
}

assert_header_contains() {
  local label="$1"
  local headers="$2"
  local needle="$3"

  if ! printf '%s\n' "$headers" | tr -d '\r' | grep -F "$needle" >/dev/null; then
    echo "missing header marker [$label]: $needle" >&2
    printf '%s\n' "$headers" >&2
    exit 1
  fi
}

assert_header_not_contains() {
  local label="$1"
  local headers="$2"
  local needle="$3"

  if printf '%s\n' "$headers" | tr -d '\r' | grep -F "$needle" >/dev/null; then
    echo "unexpected header marker [$label]: $needle" >&2
    printf '%s\n' "$headers" >&2
    exit 1
  fi
}

home_headers="$(fetch_headers /)"
assert_status "home" "$home_headers" "200"
assert_header_contains "home cache" "$home_headers" "Cache-Control: no-cache"

search_headers="$(fetch_headers /search.json)"
assert_status "search index" "$search_headers" "200"
assert_header_contains "search cache" "$search_headers" "Cache-Control: no-cache"

css_headers="$(fetch_headers /css/main.css)"
assert_status "main css" "$css_headers" "200"
assert_header_contains "asset cache" "$css_headers" "Cache-Control: public, max-age=2592000"
assert_header_not_contains "asset immutable" "$css_headers" "immutable"

favicon_headers="$(fetch_headers /favicon.svg)"
assert_status "favicon" "$favicon_headers" "200"
assert_header_contains "favicon cache" "$favicon_headers" "Cache-Control: public, max-age=2592000"

missing_directory_headers="$(fetch_headers /posts/)"
assert_status "missing directory" "$missing_directory_headers" "404"
assert_header_contains "missing directory cache" "$missing_directory_headers" "Cache-Control: no-cache"
