# GitHub Issues Friends System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a GitHub Issues based friend-link system inside `Xiao0216/ze-blog` and wire the existing `/friends/` page to its generated data.

**Architecture:** GitHub Issues act as the editable source of friend-link applications. GitHub Actions parse approved Issues and RSS feeds into `output/v2/data.json`, while the Hexo/Stellar page keeps using its existing `ds-friends_and_posts` renderer. The site repository owns both the application workflow and the blog integration.

**Tech Stack:** Hexo 7.3, Stellar 1.33, GitHub Issue Forms, GitHub Actions, `xaoxuu/*` friend-link Actions, `peaceiris/actions-label-commenter`.

---

## File Structure

- Create `.github/ISSUE_TEMPLATE/config.yml`: disables blank Issues so applications use the structured form.
- Create `.github/ISSUE_TEMPLATE/template_friend.yaml`: collects friend-link data in a JSON block and applies `审核中`.
- Create `.github/configs/label-commenter-config.yml`: posts Chinese review comments when maintainer labels change.
- Create `.github/workflows/feed-posts-parser.yml`: parses RSS posts and regenerates `output/v2/data.json`.
- Create `.github/workflows/reachability-checker.yml`: checks site reachability and regenerates JSON.
- Create `.github/workflows/label-commenter.yml`: runs label-commenter on Issue label events.
- Create `.github/workflows/_migration.yml`: manual-only data migration workflow.
- Create `README.md`: public application guide and this site's friend-link metadata.
- Modify `source/friends/index.md`: point application links and data API to `Xiao0216/ze-blog`.
- Modify `source/_data/widgets.yml`: point the sidebar manual to this repository README.
- Do not edit `public/` manually; `npm run build` regenerates it.

### Task 1: Add Friend Application Issue Template

**Files:**
- Create: `.github/ISSUE_TEMPLATE/config.yml`
- Create: `.github/ISSUE_TEMPLATE/template_friend.yaml`
- Test: YAML parse command

- [ ] **Step 1: Create the Issue template directory**

Run:

```bash
mkdir -p .github/ISSUE_TEMPLATE
```

Expected: command exits with status 0.

- [ ] **Step 2: Add Issue template config**

Write `.github/ISSUE_TEMPLATE/config.yml` with:

````yaml
blank_issues_enabled: false
````

- [ ] **Step 3: Add the friend-link Issue form**

Write `.github/ISSUE_TEMPLATE/template_friend.yaml` with:

````yaml
name: 友链模板
description: 提交友链意向申请。
labels: ['审核中']
body:
  - type: checkboxes
    id: checks
    attributes:
      label: 检查清单
      description: 请认真检查以下清单中的每一项，并在真实满足后再勾选。
      options:
        - required: true
          label: 合法、非营利、无商业广告、无木马植入。
        - required: true
          label: 承诺不会对本站或友链接口进行高频爬取。若一次性爬取多个页面，1 天不超过 1 次；若仅访问 feed 地址，1 小时不超过 1 次。
        - required: false
          label: 有实质性原创内容的 HTTPS 站点，发布过至少 5 篇原创文章。
        - required: false
          label: 已添加本站友链，或会在审核通过后及时添加。
        - required: false
          label: 与站长有过有效互动，例如评论、Issue、PR 或其它公开交流。
  - type: textarea
    id: json-data
    validations:
      required: true
    attributes:
      label: 友链信息
      description: 请在双引号中填写，不要修改 JSON 字段名。
      value: |
        <!--
        字段说明：
        - title: 站点名称
        - url: 站点地址
        - icon: 网站头像或图标
        - snapshot: 网站截图或首页地址
        - description: 一句话简介
        - feed: RSS/Atom 订阅地址，没有可留空
        -->

        ```json
        {
            "title": "",
            "url": "",
            "icon": "",
            "snapshot": "",
            "description": "",
            "feed": ""
        }
        ```
  - type: input
    id: friends-html
    attributes:
      label: 友链页面
      description: 请输入您的友链页面地址，用于人工审核和自动检测。
      placeholder: "如: https://example.com/friends/"
    validations:
      required: true
  - type: input
    id: friends-repo
    attributes:
      label: 友链仓库（可选）
      description: 如果您使用 Issue 作为友链源，可以附上仓库链接，方便互相填写。
      placeholder: "如: https://github.com/yourname/friends/"
````

- [ ] **Step 4: Verify the Issue template YAML parses**

Run:

```bash
node -e "const fs=require('fs'); const yaml=require('js-yaml'); for (const f of ['.github/ISSUE_TEMPLATE/config.yml','.github/ISSUE_TEMPLATE/template_friend.yaml']) yaml.load(fs.readFileSync(f,'utf8')); console.log('issue templates yaml ok')"
```

Expected output:

```text
issue templates yaml ok
```

- [ ] **Step 5: Commit Task 1**

Run:

```bash
git add .github/ISSUE_TEMPLATE/config.yml .github/ISSUE_TEMPLATE/template_friend.yaml
git commit -m "feat: add friends issue template"
```

Expected: commit succeeds.

### Task 2: Add Friends Automation Workflows

**Files:**
- Create: `.github/configs/label-commenter-config.yml`
- Create: `.github/workflows/feed-posts-parser.yml`
- Create: `.github/workflows/reachability-checker.yml`
- Create: `.github/workflows/label-commenter.yml`
- Create: `.github/workflows/_migration.yml`
- Test: YAML parse command

- [ ] **Step 1: Create workflow and config directories**

Run:

```bash
mkdir -p .github/configs .github/workflows
```

Expected: command exits with status 0.

- [ ] **Step 2: Add label-commenter config**

Write `.github/configs/label-commenter-config.yml` with:

```yaml
labels:
  - name: '审核中'
    labeled:
      issue:
        body: |
          **感谢支持，友链申请已收到。**

          我会根据申请信息、站点可访问性和内容情况进行审核。审核通过后会移除 `审核中` 标签，稍后即可在友链页面看到您的站点。
    unlabeled:
      issue:
        body: |
          **友链审核已通过。**

          稍后刷新 [友链页面](https://zblog.wenshuai.site/friends/) 即可看到链接。如果站点信息发生变化，请直接在本 Issue 下留言或更新正文。

  - name: '缺少互动'
    labeled:
      issue:
        body: |
          **目前还缺少一些双向互动。**

          感谢申请。这个标签表示当前还需要更多公开互动记录，例如评论、Issue、PR 或其它长期交流。

  - name: '缺少文章'
    labeled:
      issue:
        body: |
          **目前原创内容数量还不够。**

          感谢申请。建议补充稳定、可公开访问的原创内容后，再在本 Issue 下留言复核。

  - name: '未添加友链'
    labeled:
      issue:
        body: |
          **请添加本站友链。**

          距离通过只剩这一步。请把本站添加到您的友链页面，然后在本 Issue 下留言告知。

  - name: '失联'
    labeled:
      issue:
        body: |
          **站点暂时无法访问。**

          自动检测发现您的站点当前不可访问。恢复后请在本 Issue 下留言，我会复核后移除此标签。

  - name: '长期失联'
    labeled:
      issue:
        action: close
        body: |
          **站点长期无法访问，已暂时下架。**

          如果站点已经恢复，请重新打开或评论本 Issue，人工审核后可以恢复。
```

- [ ] **Step 3: Add feed parser workflow**

Write `.github/workflows/feed-posts-parser.yml` with:

```yaml
name: Feed Posts Parser

on:
  workflow_dispatch:
  schedule:
    - cron: '0 21 * * *'

jobs:
  feed-parser:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      contents: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run Feed Post Parser
        uses: xaoxuu/feed-posts-parser@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          posts_count: 3

      - name: Generate data.json
        uses: xaoxuu/issues2json@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          sort: 'posts-desc'
          exclude_issue_with_labels: '审核中, 风险网站, 失联, 长期失联'
          hide_labels: '白名单'

      - name: Setup Git Config
        run: |
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'

      - name: Commit and Push to output branch
        run: |
          git fetch origin output || true
          git checkout -B output
          git add --all
          git commit -m "Update data from issues" || echo "No changes to commit"
          git push -f origin output
```

- [ ] **Step 4: Add reachability checker workflow**

Write `.github/workflows/reachability-checker.yml` with:

```yaml
name: Reachability Checker

on:
  issues:
    types: [opened, closed, reopened, labeled, unlabeled]
  workflow_dispatch:
  schedule:
    - cron: '0 20 * * *'

jobs:
  reachability-checker:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Check Reachability
        uses: xaoxuu/links-checker@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          checker: 'reachability'
          unreachable_label: '失联'
          exclude_issue_with_labels: '审核中, 白名单'

      - name: Generate data.json
        uses: xaoxuu/issues2json@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          sort: 'posts-desc'
          exclude_issue_with_labels: '审核中, 风险网站, 失联, 长期失联'
          hide_labels: '白名单'

      - name: Setup Git Config
        run: |
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'

      - name: Commit and Push to output branch
        run: |
          git fetch origin output || true
          git checkout -B output
          git add --all
          git commit -m "Update data from issues" || echo "No changes to commit"
          git push -f origin output
```

- [ ] **Step 5: Add label-commenter workflow**

Write `.github/workflows/label-commenter.yml` with:

```yaml
name: Label Commenter

on:
  issues:
    types:
      - labeled
      - unlabeled

jobs:
  comment:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      issues: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Label Commenter
        uses: peaceiris/actions-label-commenter@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          config_file: .github/configs/label-commenter-config.yml
```

- [ ] **Step 6: Add data migration workflow**

Write `.github/workflows/_migration.yml` with:

```yaml
name: Data Migration

on:
  workflow_dispatch:

jobs:
  friends-data-migration:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - name: Friends Data Migration
        uses: xaoxuu/friends-data-migration@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 7: Verify all GitHub YAML files parse**

Run:

```bash
node -e "const fs=require('fs'); const yaml=require('js-yaml'); const files=['.github/configs/label-commenter-config.yml','.github/workflows/feed-posts-parser.yml','.github/workflows/reachability-checker.yml','.github/workflows/label-commenter.yml','.github/workflows/_migration.yml']; for (const f of files) yaml.load(fs.readFileSync(f,'utf8')); console.log('workflow yaml ok')"
```

Expected output:

```text
workflow yaml ok
```

- [ ] **Step 8: Commit Task 2**

Run:

```bash
git add .github/configs/label-commenter-config.yml .github/workflows/feed-posts-parser.yml .github/workflows/reachability-checker.yml .github/workflows/label-commenter.yml .github/workflows/_migration.yml
git commit -m "ci: add friends automation workflows"
```

Expected: commit succeeds.

### Task 3: Add Repository Friend-Link Guide

**Files:**
- Create: `README.md`
- Test: content grep command

- [ ] **Step 1: Add README guide**

Write `README.md` with:

````markdown
# 縉紳(jinshen) 的友链申请

**申请前须知**

- 本站友链为动态友链，页面加载后通过接口渲染友链数据。
- 友链默认按最近文章发布时间倒序展示，越活跃的站点越靠前。
- 没有 RSS/Atom feed 的站点可以申请，但可能会排在后面。
- 本仓库只定期解析申请中填写的 feed 地址，不会爬取其它页面内容。
- 站点长期无法访问、存在安全风险或内容明显不适合公开展示时，会暂时下架。

<br>

**自助友链申请流程**

1. 确认站点合法、安全、可公开访问。
2. 通过 [友链 Issue 模板](https://github.com/Xiao0216/ze-blog/issues/new/choose) 提交申请。
3. 按模板填写站点名称、地址、头像、截图、简介和 RSS/Atom feed。
4. 等待审核；通过后会移除 `审核中` 标签。
5. 审核通过后，请及时在您的友链页面添加本站。

<br>

**本站信息**

当你添加本站友链时，建议复制以下信息：

```yaml
title: 縉紳(jinshen)
url: https://zblog.wenshuai.site
avatar: https://zblog.wenshuai.site/favicon.svg?v=cat-professor-round-20260429
icon: https://zblog.wenshuai.site/favicon.svg?v=cat-professor-round-20260429
snapshot: https://zblog.wenshuai.site/
description: 縉紳(jinshen) 的个人生活空间，记录建站、长期知识笔记和生活日常。
feed: https://zblog.wenshuai.site/atom.xml
```

<br>

**维护说明**

- 新申请会自动带上 `审核中` 标签。
- 移除 `审核中` 后，GitHub Actions 会把该 Issue 纳入友链数据。
- `风险网站`、`失联`、`长期失联` 标签会从前端数据中排除。
- `白名单` 标签会参与检测排除，并在生成前端数据时隐藏。
- 如果站点信息变化，请直接修改原 Issue 内容或在 Issue 下留言。
````

- [ ] **Step 2: Verify README points at this repository and site**

Run:

```bash
grep -n "Xiao0216/ze-blog/issues/new/choose" README.md && grep -n "https://zblog.wenshuai.site/atom.xml" README.md
```

Expected: both `grep` commands print matching lines and exit with status 0.

- [ ] **Step 3: Commit Task 3**

Run:

```bash
git add README.md
git commit -m "docs: add friends application guide"
```

Expected: commit succeeds.

### Task 4: Wire the Blog Friends Page to This Repository

**Files:**
- Modify: `source/friends/index.md`
- Modify: `source/_data/widgets.yml`
- Generated by build: `public/friends/index.html`
- Test: `npm run build`

- [ ] **Step 1: Update the friends page**

Replace `source/friends/index.md` with:

```markdown
---
title: 小伙伴们
date: 2026-04-29 12:20:00
updated: 2026-04-30 00:00:00
layout: page
type: story
indent: true
menu_id: social
leftbar: friends_nav, recent
rightbar: friends_manual
banner: https://w.wallhaven.cc/full/21/wallhaven-21zr8g.jpg
banner_info:
  title: 小伙伴们
  avatar: /favicon.svg?v=cat-professor-round-20260429
  subtitle: 赛博书房外也有很多亮着灯的窗口。这里收集朋友们的新文章和站点近况，路过就打个招呼，常来就坐一会儿。
---

<div class="tag-plugin colorful note">
  <div class="title"><strong><p>[持续同步] 朋友们的近况</p></strong></div>
  <div class="body">
    <p>这里会按朋友们的 RSS 和文章更新时间展示最近动态。如果你也想把自己的窗口接进来，可以在 <a target="_blank" rel="external nofollow noopener noreferrer" href="https://github.com/Xiao0216/ze-blog/issues/new/choose">issue</a> 里留下站点名、地址、头像和 RSS，我会定期同步。</p>
  </div>
</div>

<div class="tag-plugin users-posts-wrap"><div class="data-service ds-friends_and_posts" data-api="https://raw.githubusercontent.com/Xiao0216/ze-blog/output/v2/data.json"><div class="grid-box"></div></div></div>

<div class="tag-plugin colorful note">
  <div class="title"><strong><p>[链接维护] 搬家或短暂离线</p></strong></div>
  <div class="body">
    <p>站点搬家、换域名或短暂离线都可以在原来的 <a target="_blank" rel="external nofollow noopener noreferrer" href="https://github.com/Xiao0216/ze-blog/issues">issue</a> 里留言。长期无法访问的链接会先隐藏，恢复后再放回列表。</p>
  </div>
</div>
```

- [ ] **Step 2: Update the friends manual widget**

In `source/_data/widgets.yml`, change only the `friends_manual.src` value to:

```yaml
friends_manual:
  layout: markdown
  title: 友链申请手册
  src: https://raw.githubusercontent.com/Xiao0216/ze-blog/master/README.md
```

- [ ] **Step 3: Verify old friend repository references are gone from source**

Run:

```bash
! grep -R "wenshuai/friends" -n source/friends source/_data/widgets.yml README.md .github
```

Expected: no output and exit status 0.

- [ ] **Step 4: Build the site**

Run:

```bash
npm run build
```

Expected: command exits with status 0 and Hexo generates `public/`.

- [ ] **Step 5: Verify generated friends page uses the new API**

Run:

```bash
grep -n "Xiao0216/ze-blog/output/v2/data.json" public/friends/index.html
```

Expected: one matching line from `public/friends/index.html`.

- [ ] **Step 6: Commit Task 4**

Run:

```bash
git add source/friends/index.md source/_data/widgets.yml public
git commit -m "feat: wire friends page to github issues data"
```

Expected: commit succeeds.

### Task 5: Final Verification and Push

**Files:**
- Review: all files changed by Tasks 1-4
- Test: Git status, YAML parse, build, generated HTML grep

- [ ] **Step 1: Re-run YAML validation**

Run:

```bash
node -e "const fs=require('fs'); const yaml=require('js-yaml'); const files=['.github/ISSUE_TEMPLATE/config.yml','.github/ISSUE_TEMPLATE/template_friend.yaml','.github/configs/label-commenter-config.yml','.github/workflows/feed-posts-parser.yml','.github/workflows/reachability-checker.yml','.github/workflows/label-commenter.yml','.github/workflows/_migration.yml']; for (const f of files) yaml.load(fs.readFileSync(f,'utf8')); console.log('all github yaml ok')"
```

Expected output:

```text
all github yaml ok
```

- [ ] **Step 2: Re-run Hexo build**

Run:

```bash
npm run build
```

Expected: command exits with status 0.

- [ ] **Step 3: Check generated output contains the local repository API**

Run:

```bash
grep -n "https://raw.githubusercontent.com/Xiao0216/ze-blog/output/v2/data.json" public/friends/index.html
```

Expected: one matching line from `public/friends/index.html`.

- [ ] **Step 4: Review git status**

Run:

```bash
git status --short --branch
```

Expected: branch is ahead of `origin/master` with no unstaged or staged changes.

- [ ] **Step 5: Push to GitHub**

Run:

```bash
git push origin master
```

Expected: push succeeds and updates `git@github.com:Xiao0216/ze-blog.git`.
