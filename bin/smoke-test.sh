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
  "public/atom.xml"
  "public/sitemap.xml"
  "public/search.json"
  "public/404.html"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "missing generated file: $path" >&2
    exit 1
  fi
done

grep -R "猫博士" public/index.html public/about/index.html >/dev/null
grep -R "赛博书房" public/index.html public/about/index.html public/posts >/dev/null
grep -R "AI 工作流" public/wiki/index.html public/wiki/ai-workflow/index.html >/dev/null
grep -R "服务器手札" public/wiki/index.html public/wiki/server-notes/index.html >/dev/null
grep -R "建站笔记" public/wiki/index.html public/wiki/site-building/index.html >/dev/null
grep -R "Hexo" public/search.json >/dev/null
