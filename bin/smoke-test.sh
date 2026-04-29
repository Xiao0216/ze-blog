#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "public/index.html"
  "public/blog/index.html"
  "public/about/index.html"
  "public/projects/index.html"
  "public/notes/index.html"
  "public/wiki/index.html"
  "public/wiki/ai-workflow/index.html"
  "public/wiki/server-notes/index.html"
  "public/wiki/site-building/index.html"
  "public/posts/2026/04/29/2026-04-29-opening-cyber-study/index.html"
  "public/atom.xml"
  "public/sitemap.xml"
  "public/search.json"
  "public/favicon.svg"
  "public/404.html"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "missing generated file: $path" >&2
    exit 1
  fi
done

rejected_files=(
  "public/404/index.html"
)

for path in "${rejected_files[@]}"; do
  if [[ -e "$path" ]]; then
    echo "unexpected generated file: $path" >&2
    exit 1
  fi
done

assert_contains() {
  local label="$1"
  local needle="$2"
  shift 2

  if ! grep -R -F "$needle" "$@" >/dev/null; then
    echo "missing content marker [$label]: $needle" >&2
    exit 1
  fi
}

assert_not_contains() {
  local label="$1"
  local needle="$2"
  shift 2

  if grep -R -F "$needle" "$@" >/dev/null; then
    echo "unexpected content marker [$label]: $needle" >&2
    exit 1
  fi
}

assert_contains "home/about branding" "猫博士" public/index.html public/about/index.html
assert_contains "site slogan" "赛博书房" public/index.html public/about/index.html public/posts
assert_contains "opening post link" "/posts/2026/04/29/2026-04-29-opening-cyber-study/" public/index.html
assert_contains "wiki ai workflow" "AI 工作流" public/wiki/index.html public/wiki/ai-workflow/index.html
assert_contains "wiki server notes" "服务器手札" public/wiki/index.html public/wiki/server-notes/index.html
assert_contains "wiki site building" "建站笔记" public/wiki/index.html public/wiki/site-building/index.html
assert_contains "search index" "Hexo" public/search.json
assert_not_contains "404 sitemap exclusion" "https://zblog.wenshuai.site/404" public/sitemap.xml
assert_not_contains "404 search path exclusion" '"path":"/404.html"' public/search.json
assert_not_contains "404 search title exclusion" "页面走失了" public/search.json
