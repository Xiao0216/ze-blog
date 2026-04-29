# Cat Doctor Blog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish the first version of the Hexo + Stellar static site for 猫博士(縉紳) at `https://zblog.wenshuai.site/`.

**Architecture:** The source site lives in `/root/ai-apps/ze-blog`, Hexo generates static files into `public/`, and a publish script syncs those files into `/var/www/zblog` because Nginx cannot traverse `/root`. Nginx serves `/var/www/zblog` directly for `zblog.wenshuai.site`; Cloudflare remains the public DNS/CDN/HTTPS layer.

**Tech Stack:** Hexo 7.3.0, `hexo-theme-stellar` 1.33.1, npm, static Markdown content, Nginx, Cloudflare.

---

## File Structure

- Create `.gitignore`: ignore generated output and local dependencies.
- Create `package.json`: pin Hexo, Stellar, feed, sitemap, search, renderer, and server dependencies.
- Create `_config.yml`: Hexo site config, permalink, feed, sitemap, search, generators.
- Create `_config.stellar.yml`: Stellar menu, sidebar, search, comments-disabled config, footer, colors.
- Create `bin/publish-local.sh`: build and sync `public/` to `/var/www/zblog`.
- Create `bin/smoke-test.sh`: verify generated files and key content after `npm run build`.
- Create `source/about/index.md`, `source/projects/index.md`, `source/notes/index.md`, `source/404.md`: core pages.
- Create `source/_posts/*.md`: initial blog posts.
- Create `source/_data/wiki.yml` and `source/_data/wiki/*.yml`: Stellar wiki registry and trees.
- Create `source/wiki/**.md`: initial wiki content.
- Create `ops/nginx/zblog.wenshuai.site.conf`: versioned Nginx site config.
- Modify `/etc/nginx/sites-available/zblog.wenshuai.site.conf`: copy the versioned config during deployment.
- Modify `/etc/nginx/sites-enabled/zblog.wenshuai.site.conf`: symlink to the available config.

## Tasks

### Task 1: Project Scaffold and Dependencies

**Files:**
- Create: `.gitignore`
- Create: `package.json`
- Create: `bin/publish-local.sh`

- [ ] **Step 1: Create `.gitignore`**

Use `apply_patch`:

```gitignore
node_modules/
public/
db.json
.deploy_git/
.DS_Store
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
package-lock.json.tmp
```

- [ ] **Step 2: Create `package.json`**

Use `apply_patch`:

```json
{
  "name": "cat-doctor-blog",
  "version": "1.0.0",
  "private": true,
  "description": "猫博士(縉紳) 的赛博书房博客",
  "scripts": {
    "clean": "hexo clean",
    "build": "hexo clean && hexo generate",
    "server": "hexo server --host 0.0.0.0 --port 4000",
    "publish:local": "bash bin/publish-local.sh"
  },
  "hexo": {
    "version": "7.3.0"
  },
  "dependencies": {
    "hexo": "7.3.0",
    "hexo-generator-archive": "2.0.0",
    "hexo-generator-category": "2.0.0",
    "hexo-generator-feed": "4.0.0",
    "hexo-generator-index": "4.0.0",
    "hexo-generator-search": "2.4.3",
    "hexo-generator-sitemap": "3.0.1",
    "hexo-generator-tag": "2.0.0",
    "hexo-renderer-ejs": "2.0.0",
    "hexo-renderer-marked": "7.0.1",
    "hexo-renderer-stylus": "3.0.1",
    "hexo-server": "3.0.0",
    "hexo-theme-stellar": "1.33.1"
  }
}
```

- [ ] **Step 3: Create `bin/publish-local.sh`**

Use `apply_patch`:

```bash
#!/usr/bin/env bash
set -euo pipefail

site_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
publish_root="/var/www/zblog"

cd "$site_root"
npm run build
install -d -m 0755 "$publish_root"
rsync -a --delete public/ "$publish_root"/
find "$publish_root" -type d -exec chmod 0755 {} \;
find "$publish_root" -type f -exec chmod 0644 {} \;
```

- [ ] **Step 4: Make the script executable**

Run:

```bash
chmod +x bin/publish-local.sh
```

Expected: command exits with status 0.

- [ ] **Step 5: Install dependencies**

Run:

```bash
npm install
```

Expected: command exits with status 0 and creates `package-lock.json`.

- [ ] **Step 6: Verify Hexo and Stellar are installed**

Run:

```bash
npx hexo version
npm ls hexo-theme-stellar
```

Expected: `npx hexo version` prints Hexo `7.3.0`; `npm ls` shows `hexo-theme-stellar@1.33.1`.

- [ ] **Step 7: Commit scaffold**

Run:

```bash
git add .gitignore package.json package-lock.json bin/publish-local.sh
git commit -m "chore: scaffold hexo stellar project"
```

Expected: commit succeeds.

### Task 2: Hexo and Stellar Configuration

**Files:**
- Create: `_config.yml`
- Create: `_config.stellar.yml`

- [ ] **Step 1: Create `_config.yml`**

Use `apply_patch`:

```yaml
title: 猫博士(縉紳)
subtitle: 赛博书房里的技术、AI 与长期笔记
description: 猫博士(縉紳) 的个人赛博书房，记录 AI 工具、服务器、自动化、建站和长期知识笔记。
keywords: AI, 技术博客, 服务器, 自动化, Hexo, Stellar, 猫博士, 縉紳
author: 猫博士(縉紳)
avatar: https://api.iconify.design/solar:cat-bold-duotone.svg?color=%231bcdfc
favicon: https://api.iconify.design/solar:cat-bold-duotone.svg?color=%231bcdfc
language: zh-CN
timezone: Asia/Shanghai

url: https://zblog.wenshuai.site
root: /
permalink: posts/:year/:month/:day/:title/
permalink_defaults:
pretty_urls:
  trailing_index: true
  trailing_html: true

source_dir: source
public_dir: public
tag_dir: blog/tags
archive_dir: blog/archives
category_dir: blog/categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

new_post_name: :title.md
default_layout: post
titlecase: false
external_link:
  enable: true
  field: site
  exclude: ''
filename_case: 0
render_drafts: false
post_asset_folder: false
relative_link: false
future: true
syntax_highlighter: highlight.js
highlight:
  line_number: true
  auto_detect: false
  tab_replace: ''
  wrap: true
  hljs: false
prismjs:
  preprocess: true
  line_number: true
  tab_replace: ''

index_generator:
  path: blog
  per_page: 10
  order_by: -date
archive_generator:
  per_page: 20
  yearly: true
  monthly: true
category_generator:
  per_page: 20
tag_generator:
  per_page: 20

date_format: YYYY-MM-DD
time_format: HH:mm:ss
updated_option: mtime

per_page: 10
pagination_dir: page

theme: stellar

deploy:
  type: ''

feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content: true
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
  icon: /favicon.svg
  autodiscovery: true

sitemap:
  path: sitemap.xml

search:
  path: search.json
  field: all
  content: true
```

- [ ] **Step 2: Create `_config.stellar.yml`**

Use `apply_patch`:

```yaml
canonical:
  closeEnable: true
  closeText: 关闭提示
  originalHost: zblog.wenshuai.site
  officialHosts:
    - zblog.wenshuai.site
    - localhost

open_graph:
  enable: true
  twitter_id:

structured_data:
  links:
    - https://zblog.wenshuai.site/

logo:
  avatar: '[{config.avatar}](/about/)'
  title: '[{config.title}](/)'
  subtitle: '{config.subtitle}'

menubar:
  columns: 3
  items:
    - id: post
      theme: '#1BCDFC'
      icon: solar:documents-bold-duotone
      title: 博客
      url: /blog/
    - id: wiki
      theme: '#3DC550'
      icon: solar:notebook-bookmark-bold-duotone
      title: 知识库
      url: /wiki/
    - id: projects
      theme: '#FFB000'
      icon: solar:planet-bold-duotone
      title: 项目
      url: /projects/
    - id: notes
      theme: '#9C6BFF'
      icon: solar:chat-square-like-bold-duotone
      title: 碎碎念
      url: /notes/
    - id: about
      theme: '#F44336'
      icon: solar:chat-square-like-bold-duotone
      title: 关于
      url: /about/
    - id: rss
      theme: '#FA6400'
      icon: solar:documents-bold-duotone
      title: RSS
      url: /atom.xml

site_tree:
  home:
    leftbar: welcome, recent
    rightbar:
  index_blog:
    base_dir: blog
    menu_id: post
    leftbar: welcome, recent
    rightbar:
  index_wiki:
    base_dir: wiki
    menu_id: wiki
    leftbar: related, recent
    rightbar:
  post:
    menu_id: post
    leftbar: related, recent
    rightbar: toc
  wiki:
    menu_id: wiki
    leftbar: tree, related, recent
    rightbar: toc
  page:
    leftbar: recent
    rightbar: toc
  error_page:
    menu_id: post
    '404': /404.html
    leftbar: recent
    rightbar:

article:
  type: tech
  auto_banner: false
  auto_excerpt: 160
  license: '本文采用 [署名-非商业性使用-相同方式共享 4.0 国际](https://creativecommons.org/licenses/by-nc-sa/4.0/) 许可协议，转载请注明出处。'
  share: [wechat, email, link]
  related_posts:
    enable: false

search:
  service: local_search
  local_search:
    field: all
    path: /search.json
    content: true
    skip_search:

comments:
  service:
  comment_title: 讨论区
  lazyload: false
  giscus:
    src: https://giscus.app/client.js
    data-repo:
    data-repo-id:
    data-category:
    data-category-id:
    data-mapping: pathname
    data-strict: 0
    data-reactions-enabled: 1
    data-emit-metadata: 0
    data-input-position: top
    data-theme: preferred_color_scheme
    data-lang: zh-CN
    crossorigin: anonymous
  twikoo:
    js: https://gcore.jsdelivr.net/npm/twikoo@1.6/dist/twikoo.all.min.js
    envId:
  waline:
    js: https://gcore.jsdelivr.net/npm/@waline/client@3.1/dist/waline.js
    css: https://gcore.jsdelivr.net/npm/@waline/client@3.1/dist/waline.css
    serverURL:
  artalk:
    css: https://unpkg.com/artalk@2.9/dist/artalk.css
    js: https://unpkg.com/artalk@2.9/dist/artalk.js
    server:
    site: ''

footer:
  social:
    rss:
      icon: solar:documents-bold-duotone
      url: /atom.xml
  sitemap:
    - title: 内容
      items:
        - '[博客](/blog/)'
        - '[分类](/blog/categories/)'
        - '[标签](/blog/tags/)'
        - '[归档](/blog/archives/)'
    - title: 书房
      items:
        - '[知识库](/wiki/)'
        - '[项目](/projects/)'
        - '[碎碎念](/notes/)'
        - '[关于](/about/)'
  content: |
    © 2026 猫博士(縉紳)。本站由 Hexo 与 Stellar 生成，作为一间长期维护的赛博书房。

plugins:
  preload:
    enable: true
    service: flying_pages
  pjax:
    enable: false
  copycode:
    enable: true
    default_text: Copy
    success_text: Copied
    toast: 复制成功
  heti:
    enable: false

style:
  prefers_theme: auto
  smooth_scroll: true
  font-size:
    root: 16px
    body: 17px
    code: 85%
    codeblock: 0.8125rem
  font-family:
    body: 'system-ui, "Microsoft Yahei", "Segoe UI", Arial, sans-serif'
    code: 'Menlo, Monaco, Consolas, system-ui, monospace, sans-serif'
    codeblock: 'Menlo, Monaco, Consolas, system-ui, monospace, sans-serif'
  text-align: left
  color:
    theme: 'hsl(192 88% 48%)'
    accent: 'hsl(38 90% 52%)'
    link: 'hsl(207 82% 52%)'
  leftbar:
    background-color-light: var(--card)
    background-color-dark: var(--card)
    background-image:
    blur-px: 80px
    blur-bg: var(--bg-a60)
    background-opacity: 0.88
  site:
    blur-px: 80px
    blur-bg: var(--bg-a75)
    blur-sat: 180%
  header_prefix:
    h2: '#'
    h3: '='
    h4: '|'
    h5: ':'

default:
  avatar: https://api.iconify.design/solar:cat-bold-duotone.svg?color=%231bcdfc
  cover: https://gcore.jsdelivr.net/gh/cdn-x/placeholder@1.0.12/cover/76b86c0226ffd.svg
  image: https://gcore.jsdelivr.net/gh/cdn-x/placeholder@1.0.12/image/2659360.svg
  banner: https://gcore.jsdelivr.net/gh/cdn-x/placeholder@1.0.12/banner/books.jpg
```

- [ ] **Step 3: Run config parse check**

Run:

```bash
npx hexo config title
npx hexo config theme
```

Expected: first command prints `猫博士(縉紳)`; second command prints `stellar`.

- [ ] **Step 4: Commit configuration**

Run:

```bash
git add _config.yml _config.stellar.yml
git commit -m "feat: configure cat doctor stellar site"
```

Expected: commit succeeds.

### Task 3: Core Pages and Initial Posts

**Files:**
- Create: `source/index.md`
- Create: `source/about/index.md`
- Create: `source/projects/index.md`
- Create: `source/notes/index.md`
- Create: `source/404.md`
- Create: `source/_posts/2026-04-29-opening-cyber-study.md`
- Create: `source/_posts/2026-04-29-server-workbench.md`
- Create: `source/_posts/2026-04-29-ai-tools-are-note-interfaces.md`
- Create: `source/_posts/2026-04-29-hexo-stellar-build-log.md`

- [ ] **Step 1: Create core pages**

Use `apply_patch` with these files:

`source/index.md`:

```markdown
---
title: 猫博士(縉紳)
date: 2026-04-29 11:55:00
layout: page
menu_id: post
---

# 猫博士(縉紳)

这里是我的赛博书房。技术、AI、服务器和长期笔记会在这里慢慢归档。

## 入口

- [博客](/blog/)：完整文章、建站记录、服务器手札和 AI 工具观察。
- [知识库](/wiki/)：更稳定的专题整理，适合长期复用。
- [项目](/projects/)：正在维护的实验、工具和服务。
- [碎碎念](/notes/)：短记录、现场判断和还没成文的想法。

## 最近的方向

我会先把这个站作为工作台使用：记录服务器如何整理，AI 工具如何进入真实流程，以及静态博客如何稳定发布到 Cloudflare 后面。

如果你第一次来到这里，可以从《开卷：猫博士的赛博书房》开始。
```

`source/about/index.md`:

```markdown
---
title: 关于
date: 2026-04-29 12:00:00
layout: page
menu_id: about
---

# 猫博士(縉紳)

这里是一间赛博书房：技术是书架，服务器是桌面，AI 工具是新的笔记接口。

我把这个站当作长期工作台，记录 AI 工具、代码实践、服务器维护、自动化脚本和一些不急着下结论的观察。

## 站点会写什么

- AI 工具如何进入真实工作流。
- 一台服务器如何从零散服务整理成稳定工作台。
- Hexo、Nginx、Cloudflare 这类基础设施的配置记录。
- 项目、脚本、实验和阶段性复盘。

## 联系方式

第一版先保留 RSS 与站点地图入口。需要公开 GitHub、邮箱或评论区时，再在这里补上明确地址。
```

`source/projects/index.md`:

```markdown
---
title: 项目
date: 2026-04-29 12:05:00
layout: page
menu_id: projects
---

# 项目

这里放持续维护的实验、工具和服务。第一版先记录三个方向，后续每个方向都可以展开成文章或知识库。

## 个人博客

当前站点本身。它用 Hexo 生成静态内容，用 Stellar 组织博客、知识库和项目入口，用 Nginx 提供源站访问，再交给 Cloudflare 对外分发。

## AI 应用实验室

用于记录 AI 工具、提示词、自动化流程和小应用。目标不是追逐每一个新工具，而是留下可以复用的工作方式。

## 自动化脚本箱

用于整理服务器、文件、构建和发布相关的脚本。每个脚本都应该有明确边界：解决什么问题、依赖什么环境、如何验证结果。
```

`source/notes/index.md`:

```markdown
---
title: 碎碎念
date: 2026-04-29 12:10:00
layout: page
menu_id: notes
---

# 碎碎念

短记录先放在这里。它们不一定完整成文，但应该保留现场感。

## 2026-04-29

站点第一版从空目录开始。先把结构搭起来，再让内容慢慢长出自己的秩序。

## 记录原则

- 能变成文章的，沉淀到博客。
- 能长期复用的，整理到知识库。
- 只是当时的判断，就留在这里。
```

`source/404.md`:

```markdown
---
title: 页面走失了
date: 2026-04-29 12:15:00
layout: page
menu_id: post
---

# 页面走失了

你访问的页面不在这间书房里。可以回到[首页](/)，或者查看[知识库](/wiki/)和[归档](/blog/archives/)。
```

- [ ] **Step 2: Create initial blog posts**

Use `apply_patch` with these files:

`source/_posts/2026-04-29-opening-cyber-study.md`:

```markdown
---
title: 开卷：猫博士的赛博书房
date: 2026-04-29 12:20:00
categories: 建站记录
tags:
  - 博客
  - 知识管理
  - 赛博书房
description: 这篇文章说明这个站为什么存在，以及它准备如何记录技术、AI 与长期笔记。
---

这个站不是临时展示页，而是一张长期使用的桌面。

我会把它叫作赛博书房：书房意味着慢，赛博意味着工具密度足够高。这里会出现 AI 工具、服务器配置、自动化脚本、建站记录，也会出现一些还没有整理成体系的判断。

## 为什么要有这个站

许多记录如果只留在聊天窗口、命令历史或零散文档里，很快就会失去上下文。博客的价值不是把所有事都写得宏大，而是把一个问题从发生、排查、选择到复盘的路径保存下来。

## 会怎样更新

博客记录完整过程，知识库保存可复用结构，项目页记录正在维护的东西，碎碎念保留短判断。它们不互相替代，而是服务于不同粒度的记忆。

这就是第一篇。先把灯打开，再慢慢把书放上架。
```

`source/_posts/2026-04-29-server-workbench.md`:

```markdown
---
title: 把一台服务器整理成工作台
date: 2026-04-29 12:30:00
categories: 服务器手札
tags:
  - Linux
  - Nginx
  - Cloudflare
  - 部署
description: 一台服务器要稳定承载多个小服务，关键是入口、目录、权限和验证流程清晰。
---

服务器不是只要能跑就算完成。真正可维护的服务器，应该能让下一个改动很快找到边界。

## 入口清晰

外部入口先收敛到 Nginx。每个域名一个站点配置，静态站点直接服务目录，动态服务再反向代理到本机端口。这样排查时可以先问：请求到 Nginx 了吗，Host 匹配了吗，后端端口活着吗。

## 目录清晰

源码目录和发布目录分开。源码可以放在工作区，发布目录应该让 Nginx 安全读取。当前博客的源码在 `/root/ai-apps/ze-blog`，发布目录使用 `/var/www/zblog`。

## 验证清晰

每次上线都至少做三件事：构建静态文件，测试 Nginx 配置，用本机 Host 请求验证源站。公网访问异常时，先分清是源站问题还是 Cloudflare 缓存与代理问题。
```

`source/_posts/2026-04-29-ai-tools-are-note-interfaces.md`:

```markdown
---
title: AI 工具不是魔法，是新的笔记接口
date: 2026-04-29 12:40:00
categories: AI 工具
tags:
  - AI
  - 工作流
  - 知识管理
description: 把 AI 当作笔记接口，而不是答案机器，会更容易建立可复用的工作流。
---

AI 工具最容易被误用成答案机器。答案当然重要，但更稳定的价值在于它改变了记录和整理的接口。

## 从对话到结构

一次对话可以产出草稿、清单、代码、排查路径，也可以暴露问题的未知部分。关键是不要让这些结果停在对话框里，而是转移到文章、知识库或脚本中。

## 从提示词到流程

提示词不是咒语，而是流程说明。好的提示词应该说明目标、输入、约束、输出格式和验证方式。它越像工程说明，越容易复用。

## 从工具到判断

工具会变化，判断应该沉淀。这个站会记录我怎样把 AI 放进真实工作台：哪些环节适合自动化，哪些环节必须保留人工判断，哪些结果需要重新验证。
```

`source/_posts/2026-04-29-hexo-stellar-build-log.md`:

```markdown
---
title: Hexo + Stellar 建站记录
date: 2026-04-29 12:50:00
categories: 建站记录
tags:
  - Hexo
  - Stellar
  - Nginx
  - Cloudflare
description: 第一版博客使用 Hexo 与 Stellar 生成静态站点，并通过 Nginx 与 Cloudflare 发布。
---

这个站点的第一版采用静态博客路线。

## 技术选择

Hexo 负责生成静态文件，Stellar 负责主题、博客列表、知识库和侧边栏体验。Nginx 直接服务生成后的静态目录，Cloudflare 负责外部 HTTPS、DNS 和缓存。

## 为什么不跑 Node 服务

生产访问只需要静态文件。把 Node 服务留给构建和本地预览，可以减少常驻进程和端口管理，也让恢复路径更简单：重新构建，重新同步发布目录，重载 Nginx。

## 下一步

第一版先把站点结构、内容骨架和发布链路跑通。后续再补充真实项目、评论系统、统计系统和更完整的视觉资产。
```

- [ ] **Step 3: Build and check page generation**

Run:

```bash
npm run build
test -f public/index.html
test -f public/blog/index.html
test -f public/about/index.html
test -f public/projects/index.html
test -f public/notes/index.html
test -f public/404.html
test -f public/atom.xml
test -f public/sitemap.xml
test -f public/search.json
```

Expected: build exits with status 0 and every `test -f` exits with status 0.

- [ ] **Step 4: Commit pages and posts**

Run:

```bash
git add source/index.md source/about source/projects source/notes source/404.md source/_posts
git commit -m "feat: add initial cat doctor content"
```

Expected: commit succeeds.

### Task 4: Stellar Wiki Structure

**Files:**
- Create: `source/_data/wiki.yml`
- Create: `source/_data/wiki/ai-workflow.yml`
- Create: `source/_data/wiki/server-notes.yml`
- Create: `source/_data/wiki/site-building.yml`
- Create: `source/wiki/ai-workflow/index.md`
- Create: `source/wiki/ai-workflow/prompt-workflow.md`
- Create: `source/wiki/server-notes/index.md`
- Create: `source/wiki/server-notes/nginx-cloudflare.md`
- Create: `source/wiki/site-building/index.md`
- Create: `source/wiki/site-building/hexo-stellar.md`

- [ ] **Step 1: Create wiki registry and project trees**

Use `apply_patch`:

`source/_data/wiki.yml`:

```yaml
ai-workflow:
  title: AI 工作流
  description: 把 AI 工具放进真实工作台的记录。
  order: 1
server-notes:
  title: 服务器手札
  description: Linux、Nginx、Cloudflare 与部署记录。
  order: 2
site-building:
  title: 建站笔记
  description: Hexo、Stellar、内容组织和发布流程。
  order: 3
```

`source/_data/wiki/ai-workflow.yml`:

```yaml
title: AI 工作流
description: 把 AI 工具放进真实工作台的记录。
icon: solar:magic-stick-3-bold-duotone
base_dir: /wiki/ai-workflow/
order: 1
tree:
  - index
  - prompt-workflow
```

`source/_data/wiki/server-notes.yml`:

```yaml
title: 服务器手札
description: Linux、Nginx、Cloudflare 与部署记录。
icon: solar:server-square-cloud-bold-duotone
base_dir: /wiki/server-notes/
order: 2
tree:
  - index
  - nginx-cloudflare
```

`source/_data/wiki/site-building.yml`:

```yaml
title: 建站笔记
description: Hexo、Stellar、内容组织和发布流程。
icon: solar:document-add-bold-duotone
base_dir: /wiki/site-building/
order: 3
tree:
  - index
  - hexo-stellar
```

- [ ] **Step 2: Create wiki pages**

Use `apply_patch`:

`source/wiki/ai-workflow/index.md`:

```markdown
---
title: AI 工作流
date: 2026-04-29 13:00:00
wiki: ai-workflow
---

# AI 工作流

这里整理 AI 工具进入日常工作台后的方法。重点不是收集工具名，而是记录可复用的流程。

## 当前原则

- 先定义任务边界，再选择模型或工具。
- 输出必须能被验证，不能只看起来顺滑。
- 有复用价值的对话要沉淀成文档、脚本或检查清单。
```

`source/wiki/ai-workflow/prompt-workflow.md`:

```markdown
---
title: 提示词作为流程说明
date: 2026-04-29 13:05:00
wiki: ai-workflow
---

# 提示词作为流程说明

有效提示词通常包含五件事：目标、输入、约束、输出格式和验证方式。

## 一个基本模板

~~~text
目标：说明要完成什么。
输入：说明已有材料在哪里。
约束：说明不能改变什么、必须遵守什么。
输出：说明结果格式。
验证：说明怎样判断结果可用。
~~~

把提示词写成流程说明，AI 输出就更容易进入工程链路，而不是停留在一次性回答。
```

`source/wiki/server-notes/index.md`:

```markdown
---
title: 服务器手札
date: 2026-04-29 13:10:00
wiki: server-notes
---

# 服务器手札

这里记录服务器维护、域名入口、Nginx 配置和发布链路。

## 检查顺序

1. 进程是否存在。
2. 端口是否监听。
3. Nginx 是否匹配 Host。
4. 源站是否返回正确内容。
5. Cloudflare 是否缓存或代理了旧响应。
```

`source/wiki/server-notes/nginx-cloudflare.md`:

```markdown
---
title: Nginx 与 Cloudflare 边界
date: 2026-04-29 13:15:00
wiki: server-notes
---

# Nginx 与 Cloudflare 边界

Cloudflare 在公网侧提供 DNS、HTTPS 和缓存；Nginx 在源站侧负责 Host 匹配、静态文件服务和反向代理。

## 本站的边界

- Cloudflare：接收 `https://zblog.wenshuai.site/` 的公网请求。
- Nginx：接收源站 HTTP 请求并服务 `/var/www/zblog`。
- Hexo：只在构建阶段运行，生产流量不经过 Node.js。
```

`source/wiki/site-building/index.md`:

```markdown
---
title: 建站笔记
date: 2026-04-29 13:20:00
wiki: site-building
---

# 建站笔记

这里记录这个站点的结构、配置和发布方式。

## 目录

- Hexo 负责源码与生成。
- Stellar 负责主题、知识库、侧边栏和文章体验。
- Nginx 负责源站静态服务。
```

`source/wiki/site-building/hexo-stellar.md`:

```markdown
---
title: Hexo + Stellar 第一版配置
date: 2026-04-29 13:25:00
wiki: site-building
---

# Hexo + Stellar 第一版配置

第一版配置分成两层：

- `_config.yml` 保存 Hexo 站点信息、生成器、RSS、sitemap 和 search 输出。
- `_config.stellar.yml` 保存 Stellar 的菜单、侧边栏、评论预留位、页脚和主题色。

这种拆分能减少升级主题时的冲突，也让站点配置更容易迁移。
```

- [ ] **Step 3: Build and verify wiki output**

Run:

```bash
npm run build
test -f public/wiki/index.html
test -f public/wiki/ai-workflow/index.html
test -f public/wiki/ai-workflow/prompt-workflow/index.html
test -f public/wiki/server-notes/index.html
test -f public/wiki/site-building/index.html
grep -R "AI 工作流" public/wiki/index.html public/wiki/ai-workflow/index.html
```

Expected: build exits with status 0, every `test -f` exits with status 0, and `grep` prints matching lines.

- [ ] **Step 4: Commit wiki content**

Run:

```bash
git add source/_data source/wiki
git commit -m "feat: add stellar wiki sections"
```

Expected: commit succeeds.

### Task 5: Generated Site Smoke Test

**Files:**
- Create: `bin/smoke-test.sh`

- [ ] **Step 1: Write the smoke test**

Use `apply_patch`:

```bash
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
```

- [ ] **Step 2: Make the smoke test executable**

Run:

```bash
chmod +x bin/smoke-test.sh
```

Expected: command exits with status 0.

- [ ] **Step 3: Run build and smoke test**

Run:

```bash
npm pkg set scripts.smoke="bash bin/smoke-test.sh"
npm run build
npm run smoke
```

Expected: both commands exit with status 0.

- [ ] **Step 4: Commit smoke test**

Run:

```bash
git add package.json package-lock.json bin/smoke-test.sh
git commit -m "test: add static site smoke test"
```

Expected: commit succeeds.

### Task 6: Nginx Configuration and Local Publish

**Files:**
- Create: `ops/nginx/zblog.wenshuai.site.conf`
- Modify: `/etc/nginx/sites-available/zblog.wenshuai.site.conf`
- Modify: `/etc/nginx/sites-enabled/zblog.wenshuai.site.conf`
- Modify: `/var/www/zblog/**`

- [ ] **Step 1: Create versioned Nginx config**

Use `apply_patch`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name zblog.wenshuai.site;

    root /var/www/zblog;
    index index.html;

    access_log /var/log/nginx/zblog.access.log;
    error_log /var/log/nginx/zblog.error.log;

    location / {
        try_files $uri $uri/ /404.html;
    }

    location ~* \.(?:css|js|png|jpg|jpeg|gif|webp|svg|ico|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    location ~* \.(?:html|xml|json)$ {
        expires -1;
        add_header Cache-Control "no-cache";
        try_files $uri =404;
    }
}
```

- [ ] **Step 2: Publish static files to `/var/www/zblog`**

Run:

```bash
npm run publish:local
test -f /var/www/zblog/index.html
test -f /var/www/zblog/wiki/index.html
test -f /var/www/zblog/search.json
```

Expected: build and sync exit with status 0, and every `test -f` exits with status 0.

- [ ] **Step 3: Install Nginx site config**

Run:

```bash
cp ops/nginx/zblog.wenshuai.site.conf /etc/nginx/sites-available/zblog.wenshuai.site.conf
ln -sfn /etc/nginx/sites-available/zblog.wenshuai.site.conf /etc/nginx/sites-enabled/zblog.wenshuai.site.conf
nginx -t
```

Expected: `nginx -t` prints `syntax is ok` and `test is successful`.

- [ ] **Step 4: Reload Nginx**

Run:

```bash
systemctl reload nginx
systemctl is-active nginx
```

Expected: reload exits with status 0 and `systemctl is-active nginx` prints `active`.

- [ ] **Step 5: Verify source response**

Run:

```bash
curl -sS -H 'Host: zblog.wenshuai.site' http://127.0.0.1/ | grep -E '猫博士|赛博书房'
curl -I -H 'Host: zblog.wenshuai.site' http://127.0.0.1/search.json
```

Expected: first command prints a matching line; second command returns HTTP 200.

- [ ] **Step 6: Commit deploy files**

Run:

```bash
git add ops/nginx/zblog.wenshuai.site.conf bin/publish-local.sh
git commit -m "chore: add local publish and nginx config"
```

Expected: commit succeeds. If `bin/publish-local.sh` is unchanged from Task 1, commit only `ops/nginx/zblog.wenshuai.site.conf`.

### Task 7: Public Verification

**Files:**
- No source files created.

- [ ] **Step 1: Verify Cloudflare-facing URL**

Run:

```bash
curl -I https://zblog.wenshuai.site/
curl -sS https://zblog.wenshuai.site/ | grep -E '猫博士|赛博书房'
```

Expected: first command returns HTTP 200 or 304; second command prints a matching line.

- [ ] **Step 2: Verify generated endpoints**

Run:

```bash
curl -I https://zblog.wenshuai.site/atom.xml
curl -I https://zblog.wenshuai.site/sitemap.xml
curl -I https://zblog.wenshuai.site/search.json
curl -I https://zblog.wenshuai.site/wiki/ai-workflow/
```

Expected: each command returns HTTP 200 or 304.

- [ ] **Step 3: Inspect Nginx errors**

Run:

```bash
tail -n 50 /var/log/nginx/zblog.error.log
```

Expected: no new `error` lines for missing files, permission denied, or upstream failures.

- [ ] **Step 4: Record final status**

Run:

```bash
git status --short
git log --oneline -5
```

Expected: source tree is clean or only contains intentionally untracked generated artifacts ignored by `.gitignore`; recent commits show scaffold, config, content, wiki, smoke test, and deploy config.

## Self-Review

- Spec coverage: The plan covers static Hexo/Stellar setup,综合站结构,初始博客内容, wiki sections, projects, notes, comments/statistics disabled with reserved fields, RSS, sitemap, local search, Nginx direct static serving, Cloudflare verification, and smoke checks.
- Placeholder scan: The plan contains concrete file paths, commands, and file contents. It does not rely on unresolved values.
- Type and path consistency: `zblog.wenshuai.site` is used consistently as the domain; source is `/root/ai-apps/ze-blog`; publish root is `/var/www/zblog`; the Nginx root and publish script match.
