#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "public/index.html"
  "public/about/index.html"
  "public/friends/index.html"
  "public/projects/index.html"
  "public/notes/index.html"
  "public/notes/bookmark/index.html"
  "public/notes/server/index.html"
  "public/notes/json/index.html"
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

  if ! grep -R -F -- "$needle" "$@" >/dev/null; then
    echo "missing content marker [$label]: $needle" >&2
    exit 1
  fi
}

assert_not_contains() {
  local label="$1"
  local needle="$2"
  shift 2

  if grep -R -F -- "$needle" "$@" >/dev/null; then
    echo "unexpected content marker [$label]: $needle" >&2
    exit 1
  fi
}

assert_file_contains() {
  local label="$1"
  local file="$2"
  local needle="$3"

  if ! grep -F -- "$needle" "$file" >/dev/null; then
    echo "missing content marker [$label] in $file: $needle" >&2
    exit 1
  fi
}

assert_contains "home/about branding" "縉紳(jinshen)" public/index.html public/about/index.html
assert_contains "welcome branding alias" "猫博士 · 縉紳(jinshen)" public/welcome/index.html public/search.json
assert_not_contains "old welcome branding alias" "猫博士(縉紳)" public/welcome/index.html public/search.json
assert_contains "logo english subtitle" "Zodiac Zest" public/index.html public/about/index.html
assert_contains "logo chinese subtitle" "本心热忱" public/index.html public/about/index.html
assert_not_contains "old logo english subtitle" "For all time, always." public/index.html public/about/index.html
assert_not_contains "old logo chinese subtitle" "风暴前夕" public/index.html public/about/index.html
assert_contains "site slogan" "赛博书房" public/index.html public/about/index.html public/posts
assert_contains "about story layout" 'layout="page" type="story" text-indent' public/about/index.html
assert_contains "about banner" 'class="article banner' public/about/index.html
assert_file_contains "about leftbar social widget" public/about/index.html '<widget class="widget-wrapper linklist"><div class="widget-header dis-select"><span class="name">社交</span>'
assert_file_contains "about friends social tab" public/about/index.html '<a class="link" title="小伙伴们" href="/friends/">'
assert_file_contains "about active social tab" public/about/index.html '<a class="link active" title="关于本站" href="/about/">'
assert_contains "about tabs" 'class="tag-plugin tabs" align="center"' public/about/index.html
assert_contains "about topic tab" '💬 话题' public/about/index.html
assert_contains "about music tab" '🎵 音乐' public/about/index.html
assert_contains "about game tab" '🎮 游戏' public/about/index.html
assert_contains "about movie tab" '🎬 电影' public/about/index.html
assert_contains "about novel tab" '📚 小说' public/about/index.html
assert_contains "about mbti" "ENFP-T" public/about/index.html
assert_contains "about music names" "周杰伦" public/about/index.html
assert_contains "about music names 2" "张杰" public/about/index.html
assert_contains "about music names 3" "林俊杰" public/about/index.html
assert_contains "about music names 4" "五月天" public/about/index.html
assert_contains "about game names" "CSGO" public/about/index.html
assert_contains "about game names 2" "无畏契约" public/about/index.html
assert_contains "about game names 3" "PUBG" public/about/index.html
assert_contains "about game names 4" "杀戮尖塔 2" public/about/index.html
assert_contains "about movie placeholders" "肖申克的救赎" public/about/index.html
assert_contains "about novel placeholders" "三体" public/about/index.html
assert_not_contains "about card fake icon data" "api.iconify.design" source/_data/links
assert_not_contains "about card fake icon output" 'data-src="https://api.iconify.design' public/about/index.html
assert_contains "about music real images" "music.126.net" public/about/index.html
assert_contains "about apple music real images" "mzstatic.com" public/about/index.html
assert_contains "about douban original image sources" "doubanio.com" source/_data/links/about_movies.yml source/_data/links/about_novels.yml
assert_contains "about local douban image cache" "/images/about/" public/about/index.html
assert_contains "about steam real images" "steamstatic.com" public/about/index.html
assert_contains "about tencent game real images" "game.gtimg.cn" public/about/index.html
assert_contains "opening post link" "/posts/2026/04/29/2026-04-29-opening-cyber-study/" public/index.html
assert_contains "wallhaven covers on home cards" "w.wallhaven.cc" public/index.html
assert_file_contains "wallhaven card ambient style" public/index.html "--card-cover:url('https://w.wallhaven.cc/"
assert_contains "wallhaven covers in posts" "w.wallhaven.cc" source/_posts
assert_file_contains "opening post cover" source/_posts/2026-04-29-opening-cyber-study.md "cover: https://w.wallhaven.cc/"
assert_file_contains "ai tools post cover" source/_posts/2026-04-29-ai-tools-are-note-interfaces.md "cover: https://w.wallhaven.cc/"
assert_file_contains "server workbench post cover" source/_posts/2026-04-29-server-workbench.md "cover: https://w.wallhaven.cc/"
assert_file_contains "hexo stellar post cover" source/_posts/2026-04-29-hexo-stellar-build-log.md "cover: https://w.wallhaven.cc/"
assert_contains "wiki ai workflow" "AI 工作流" public/wiki/index.html public/wiki/ai-workflow/index.html
assert_contains "wiki server notes" "服务器手札" public/wiki/index.html public/wiki/server-notes/index.html
assert_contains "wiki site building" "建站笔记" public/wiki/index.html public/wiki/site-building/index.html
assert_contains "search index" "Hexo" public/search.json
assert_contains "left sidebar menubar" 'class="nav-item' public/notes/index.html
assert_file_contains "home recent rss action" public/index.html 'class="cap-action" id="rss" title="Subscribe" href="/atom.xml"'
assert_file_contains "home recent rss widget icon" public/index.html '<span class="name">最近更新</span><a class="cap-action" id="rss"'
assert_not_contains "sidebar footer rss entry" 'class="social" href="/atom.xml"' public/index.html public/notes/index.html
assert_file_contains "pjax config" public/index.html "window.StellarPjaxConfig"
assert_file_contains "pjax script" public/index.html "/js/plugins/pjax.js"
assert_file_contains "pjax loading css" public/css/main.css "body.pjax-loading .page-loading-bar"
assert_contains "artalk container" "artalk_container" public/posts/2026/05/02/2026-05-02-agent-learning-week-3-prompt-engineering-part-1/index.html
assert_contains "artalk init" "Artalk.init" public/posts/2026/05/02/2026-05-02-agent-learning-week-3-prompt-engineering-part-1/index.html
assert_not_contains "artalk early util dependency" "util.viewportLazyload" public/posts/2026/05/02/2026-05-02-agent-learning-week-3-prompt-engineering-part-1/index.html
assert_file_contains "home activity timeline widget" public/index.html '<widget class="widget-wrapper timeline"><div class="widget-header dis-select"><span class="name">近期动态</span></div><div class="widget-body fs14"><div class="tag-plugin timeline">'
assert_file_contains "home overview timeline node" public/index.html '<div class="timenode" index="0"><div class="header"><span>站点概览</span></div><div class="body fs14">'
assert_file_contains "home overview visit count" public/index.html 'id="busuanzi_value_site_pv"'
assert_file_contains "home overview post count" public/index.html '<dt>文章数</dt>'
assert_file_contains "home overview total words" public/index.html '<dt>总字数</dt>'
assert_file_contains "home visit counter script" public/index.html 'busuanzi.pure.mini.js'
assert_file_contains "home activity timeline node" public/index.html '<div class="timenode" index="1"><div class="header"><span>2026-04-29</span></div><div class="body fs14">'
assert_not_contains "old activity markdown widget" '<widget class="widget-wrapper markdown"><div class="widget-header dis-select"><span class="name">近期动态</span>' public/index.html
assert_contains "main css cache bust" "/css/main.css?v=20260429-xaoxuu-pjax1" public/index.html public/notes/index.html
assert_not_contains "old main css cache bust" "/css/main.css?v=1.33.1" public/index.html public/notes/index.html
assert_contains "blog menubar entry" 'title="博客" href="/" style="color:#1BCDFC"' public/index.html
assert_contains "wiki menubar entry" 'title="项目" href="/wiki/" style="color:#3DC550"' public/index.html
assert_contains "notes menubar entry" 'title="探索" href="/notes/" style="color:#FA6400"' public/notes/index.html
assert_contains "social menubar entry" 'title="社交" href="/friends/" style="color:#F44336"' public/index.html
assert_contains "active notes menubar entry" 'class="nav-item active" title="探索"' public/notes/index.html
assert_contains "notes scoped search" 'placeholder="在 探索 中搜索"' public/notes/index.html
assert_file_contains "notes keeps site avatar header" public/notes/index.html '<a class="avatar" href="/about/">'
assert_not_contains "notes header should not become explore" '<header class="header"><div class="logo-wrap"><div class="icon"><img no-lazy class="icon" src="https://api.iconify.design/solar:planet-bold-duotone.svg?color=%23FA6400"' public/notes/index.html
assert_file_contains "friends story layout" public/friends/index.html 'layout="page" type="story" text-indent'
assert_file_contains "friends search placeholder" public/friends/index.html 'placeholder="站内搜索"'
assert_file_contains "friends leftbar social widget" public/friends/index.html '<widget class="widget-wrapper linklist"><div class="widget-header dis-select"><span class="name">社交</span>'
assert_file_contains "friends active social tab" public/friends/index.html '<a class="link active" title="小伙伴们" href="/friends/">'
assert_file_contains "friends about social tab" public/friends/index.html '<a class="link" title="关于本站" href="/about/">'
assert_file_contains "friends wallhaven banner source" source/friends/index.md "banner: https://w.wallhaven.cc/full/21/wallhaven-21zr8g.jpg"
assert_file_contains "friends wallhaven banner output" public/friends/index.html "wallhaven-21zr8g.jpg"
assert_file_contains "friends banner title" public/friends/index.html '<h1 class="text title"><span>小伙伴们</span></h1>'
assert_file_contains "friends banner copy" public/friends/index.html '赛博书房外也有很多亮着灯的窗口'
assert_file_contains "friends update note" public/friends/index.html '[持续同步] 朋友们的近况'
assert_file_contains "friends issue copy" public/friends/index.html '如果你也想把自己的窗口接进来'
assert_file_contains "friends posts datasource" public/friends/index.html 'class="data-service ds-friends_and_posts" data-api="https://raw.githubusercontent.com/Xiao0216/ze-blog/output/v2/data.json"'
assert_file_contains "friends lost contact note" public/friends/index.html '[链接维护] 搬家或短暂离线'
assert_file_contains "friends restore copy" public/friends/index.html '恢复后再放回列表'
assert_not_contains "friends old xaoxuu repo" "xaoxuu/friends" public/friends/index.html
assert_contains "animated avatar background" "rainbow64@3x.webp" public/index.html public/notes/index.html
assert_contains "xaoxuu font lazy load" "lxgw-wenkai-screen-webfont/style.css" public/index.html public/notes/index.html
assert_contains "single-row menubar columns" "grid-template-columns: repeat(4, minmax(0, 1fr));" public/css/main.css
assert_contains "single-row menubar flow" "grid-auto-flow: column;" public/css/main.css
assert_contains "xaoxuu nav hover background" "background: var(--bg-a100);" public/css/main.css
assert_not_contains "removed custom css injection" "/css/site-info.css" public/index.html public/notes/index.html
assert_not_contains "removed terracotta cache bust" "terracotta" public/index.html public/notes/index.html public/css
assert_not_contains "removed terracotta rust" "AE5238" public/index.html public/notes/index.html public/css
assert_not_contains "removed terracotta variables" "--ts-rust" public/css
assert_not_contains "404 sitemap exclusion" "https://zblog.wenshuai.site/404" public/sitemap.xml
assert_not_contains "404 search path exclusion" '"path":"/404.html"' public/search.json
assert_not_contains "404 search title exclusion" "页面走失了" public/search.json
