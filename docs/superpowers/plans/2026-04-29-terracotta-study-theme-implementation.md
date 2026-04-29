# Terracotta Study Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `Terracotta Study` skin to the existing Hexo/Stellar blog without changing the current navigation, sidebar, wiki, or page configuration.

**Architecture:** Use the already-injected `source/css/site-info.css` file as the post-`main.css` skin layer, because `_config.stellar.yml` already loads it after Stellar's compiled stylesheet. Keep `source/css/_custom.styl` as a small widget-style mirror so the existing custom widget styles remain readable in Stylus form, but do not edit `themes/stellar`.

**Tech Stack:** Hexo 7.3, Stellar 1.33.1, plain CSS, Stylus, npm scripts.

---

## File Structure

- Modify: `source/css/site-info.css`
  - Responsibility: actual Terracotta Study skin loaded after `/css/main.css` through the existing `_config.stellar.yml` `inject.head` entry.
- Modify: `source/css/_custom.styl`
  - Responsibility: Stylus mirror for the rightbar `.site-info-card` widget and rightbar markdown padding. It must not define global theme variables because this site-level file is not the reliable post-main override point.
- Read only: `_config.stellar.yml`
  - Responsibility: confirm the existing `<link rel="stylesheet" href="/css/site-info.css?v=20260429">` injection remains in place.
- Do not modify: `themes/stellar/**`
  - Responsibility: upstream theme package/submodule remains untouched for upgrade safety.

## Task 1: Add Post-Main Terracotta Skin CSS

**Files:**
- Modify: `source/css/site-info.css`
- Verify: `_config.stellar.yml`

- [ ] **Step 1: Verify the existing injection point**

Run:

```bash
grep -n 'site-info.css' _config.stellar.yml
```

Expected: output contains this existing injected stylesheet line:

```text
    - <link rel="stylesheet" href="/css/site-info.css?v=20260429">
```

- [ ] **Step 2: Verify the skin is not already present**

Run:

```bash
grep -q -- '--ts-rust' source/css/site-info.css
```

Expected: command exits with status `1`, because the new Terracotta variables are not present before this task.

- [ ] **Step 3: Replace `source/css/site-info.css` with the full skin**

Replace the complete file with:

```css
:root {
  color-scheme: light;
  --ts-rust: #ae5238;
  --ts-mustard: #d39932;
  --ts-teal: #225d65;
  --ts-olive: #5c633e;
  --ts-cream: #e3d8c6;
  --ts-white: #fff;
  --ts-paper: #f6f0e7;
  --ts-card: #fffaf4;
  --ts-ink: #2f2925;
  --ts-muted: #776b60;
  --ts-line: rgba(174, 82, 56, 0.18);
  --ts-line-soft: rgba(92, 99, 62, 0.14);
  --ts-shadow: 0 14px 36px rgba(89, 57, 39, 0.08);
  --ts-shadow-soft: 0 8px 22px rgba(89, 57, 39, 0.06);
  --hue: 14deg;
  --sat: 51%;
  --light: 45%;
  --theme: var(--ts-rust);
  --theme-a10: rgba(174, 82, 56, 0.1);
  --theme-a20: rgba(174, 82, 56, 0.2);
  --theme-a30: rgba(174, 82, 56, 0.3);
  --accent: var(--ts-mustard);
  --link: var(--ts-teal);
  --link-a20: rgba(34, 93, 101, 0.18);
  --background: var(--ts-paper);
  --card: var(--ts-card);
  --block: rgba(174, 82, 56, 0.07);
  --block-border: rgba(174, 82, 56, 0.13);
  --text: var(--ts-ink);
  --text-reverse: var(--ts-white);
  --text-p1: rgba(47, 41, 37, 0.86);
  --text-p2: rgba(47, 41, 37, 0.72);
  --text-p3: rgba(47, 41, 37, 0.56);
  --text-p4: rgba(47, 41, 37, 0.42);
  --text-meta: rgba(47, 41, 37, 0.22);
  --text-code: var(--ts-teal);
  --text-a10: rgba(47, 41, 37, 0.1);
  --text-a20: rgba(47, 41, 37, 0.2);
}

:root[data-theme="dark"] {
  color-scheme: dark;
  --ts-paper: #171411;
  --ts-card: #211c18;
  --ts-ink: #f3eadf;
  --ts-muted: #b7a999;
  --ts-line: rgba(211, 153, 50, 0.22);
  --ts-line-soft: rgba(227, 216, 198, 0.13);
  --ts-shadow: 0 18px 42px rgba(0, 0, 0, 0.28);
  --ts-shadow-soft: 0 10px 26px rgba(0, 0, 0, 0.22);
  --theme: #c8694d;
  --theme-a10: rgba(200, 105, 77, 0.12);
  --theme-a20: rgba(200, 105, 77, 0.22);
  --theme-a30: rgba(200, 105, 77, 0.34);
  --accent: #e0aa47;
  --link: #6fb0b8;
  --link-a20: rgba(111, 176, 184, 0.22);
  --background: var(--ts-paper);
  --card: var(--ts-card);
  --block: rgba(227, 216, 198, 0.08);
  --block-border: rgba(227, 216, 198, 0.14);
  --text: var(--ts-ink);
  --text-reverse: #171411;
  --text-p1: rgba(243, 234, 223, 0.86);
  --text-p2: rgba(243, 234, 223, 0.72);
  --text-p3: rgba(243, 234, 223, 0.56);
  --text-p4: rgba(243, 234, 223, 0.42);
  --text-meta: rgba(243, 234, 223, 0.24);
  --text-code: #8fc2c8;
  --text-a10: rgba(243, 234, 223, 0.1);
  --text-a20: rgba(243, 234, 223, 0.2);
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    color-scheme: dark;
    --ts-paper: #171411;
    --ts-card: #211c18;
    --ts-ink: #f3eadf;
    --ts-muted: #b7a999;
    --ts-line: rgba(211, 153, 50, 0.22);
    --ts-line-soft: rgba(227, 216, 198, 0.13);
    --ts-shadow: 0 18px 42px rgba(0, 0, 0, 0.28);
    --ts-shadow-soft: 0 10px 26px rgba(0, 0, 0, 0.22);
    --theme: #c8694d;
    --theme-a10: rgba(200, 105, 77, 0.12);
    --theme-a20: rgba(200, 105, 77, 0.22);
    --theme-a30: rgba(200, 105, 77, 0.34);
    --accent: #e0aa47;
    --link: #6fb0b8;
    --link-a20: rgba(111, 176, 184, 0.22);
    --background: var(--ts-paper);
    --card: var(--ts-card);
    --block: rgba(227, 216, 198, 0.08);
    --block-border: rgba(227, 216, 198, 0.14);
    --text: var(--ts-ink);
    --text-reverse: #171411;
    --text-p1: rgba(243, 234, 223, 0.86);
    --text-p2: rgba(243, 234, 223, 0.72);
    --text-p3: rgba(243, 234, 223, 0.56);
    --text-p4: rgba(243, 234, 223, 0.42);
    --text-meta: rgba(243, 234, 223, 0.24);
    --text-code: #8fc2c8;
    --text-a10: rgba(243, 234, 223, 0.1);
    --text-a20: rgba(243, 234, 223, 0.2);
  }
}

body {
  background: var(--background);
  color: var(--text);
}

body > .sitebg {
  background: var(--background);
}

body > .sitebg::before {
  content: "";
  position: fixed;
  inset: 0;
  pointer-events: none;
  background-image:
    linear-gradient(rgba(174, 82, 56, 0.035) 1px, transparent 1px),
    linear-gradient(90deg, rgba(174, 82, 56, 0.025) 1px, transparent 1px);
  background-size: 34px 34px;
  opacity: 0.45;
}

body > .sitebg .siteblur {
  --blur-bg: transparent;
  --blur-px: 0;
  backdrop-filter: none;
  -webkit-backdrop-filter: none;
}

.l_body .l_left .leftbar-container,
.l_body .l_right,
.post-list .post-card,
.article.banner,
.md-text.content {
  border: 1px solid var(--ts-line-soft);
  box-shadow: var(--ts-shadow-soft);
}

.l_body .l_left .leftbar-container,
.l_body .l_right {
  background: rgba(255, 250, 244, 0.82);
}

:root[data-theme="dark"] .l_body .l_left .leftbar-container,
:root[data-theme="dark"] .l_body .l_right {
  background: rgba(33, 28, 24, 0.84);
}

.logo-wrap a.title .main {
  color: var(--ts-rust);
}

.logo-wrap a.title .sub {
  color: var(--ts-teal);
  font-weight: 650;
}

.logo-wrap a.avatar {
  background: var(--ts-cream);
  box-shadow: 0 0 0 3px rgba(174, 82, 56, 0.12);
}

.nav-area .menu .nav-item {
  color: var(--ts-muted);
  background: rgba(255, 250, 244, 0.56);
  border: 1px solid transparent;
}

.nav-area .menu .nav-item img,
.nav-area .menu .nav-item svg {
  filter: none;
  opacity: 0.66;
}

.nav-area .menu .nav-item:hover {
  color: var(--ts-teal);
  background: rgba(227, 216, 198, 0.5);
  border-color: rgba(34, 93, 101, 0.16);
}

.nav-area .menu .nav-item.active {
  color: var(--ts-rust);
  background: rgba(174, 82, 56, 0.1);
  border-color: rgba(174, 82, 56, 0.22);
}

.nav-area .menu .nav-item.active img,
.nav-area .menu .nav-item.active svg,
.nav-area .menu .nav-item:hover img,
.nav-area .menu .nav-item:hover svg {
  opacity: 0.95;
}

.nav-area .menu .nav-item.active::after {
  background: currentColor;
}

.widgets .widget-wrapper .widget-header {
  color: var(--text-p1);
  letter-spacing: 0;
}

.widgets .widget-wrapper .widget-header > span {
  display: inline-flex;
  align-items: center;
  gap: 0.42rem;
  opacity: 1;
}

.widgets .widget-wrapper .widget-header > span::before {
  content: "";
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: var(--ts-olive);
  box-shadow: 0 0 0 3px rgba(92, 99, 62, 0.12);
}

.widget-wrapper.markdown .widget-body {
  background: rgba(255, 250, 244, 0.68);
  border: 1px solid var(--ts-line-soft);
}

.l_right .widget-wrapper.markdown .widget-body {
  padding: 0.55rem 0.75rem !important;
}

.site-info-card {
  margin: 0.35rem 0 !important;
  padding: 0.15rem 0 !important;
}

.site-info-card > div {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  justify-content: space-between !important;
  gap: 0.5rem !important;
  min-height: 1.9rem;
  padding: 0.25rem 0.1rem;
  border-bottom: 1px dashed var(--ts-line-soft);
}

.site-info-card > div:last-child {
  border-bottom: 0;
}

.site-info-card > div > dt {
  display: block !important;
  flex: 0 0 auto !important;
  margin: 0 !important;
  color: var(--ts-olive);
  font-size: 0.78rem;
  line-height: 1.2;
  white-space: nowrap !important;
}

.site-info-card > div > dd {
  display: block !important;
  flex: 1 1 auto !important;
  min-width: 0 !important;
  margin: 0 !important;
  color: var(--ts-teal);
  font-size: 0.82rem;
  font-weight: 700;
  line-height: 1.2;
  text-align: right;
  white-space: nowrap !important;
  overflow: hidden;
  text-overflow: ellipsis;
}

.post-list .post-card {
  background: var(--card);
  border-color: var(--ts-line-soft);
  box-shadow: var(--ts-shadow-soft);
  transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
}

.post-list .post-card:hover {
  border-color: var(--ts-line);
  box-shadow: var(--ts-shadow);
  transform: translateY(-2px);
}

.l_main .post-list .post-title {
  color: var(--text);
}

.post-list .post-card:hover .post-title,
.l_main .post-list .post-title:hover {
  color: var(--ts-rust);
}

.post-list .post-card .meta.cap {
  color: var(--text-p3);
}

.post-list .post-card .meta.cap svg {
  color: var(--ts-olive);
}

.post-list .post-card .excerpt > p,
.post-list .md-text p {
  color: var(--text-p2);
}

.article.banner {
  background:
    linear-gradient(135deg, rgba(174, 82, 56, 0.1), rgba(211, 153, 50, 0.08)),
    var(--card);
  border-color: var(--ts-line-soft);
  border-radius: 16px;
  overflow: hidden;
}

.article.banner .content .title {
  color: var(--ts-rust);
}

.md-text.content {
  background: var(--card);
  border-radius: 16px;
  padding: 1.25rem 1.35rem 2.25rem;
}

.md-text.content h1,
.md-text.content h2,
.md-text.content h3 {
  color: var(--text);
  letter-spacing: 0;
}

.md-text.content h2 {
  padding-bottom: 0.35rem;
  border-bottom: 1px solid var(--ts-line-soft);
}

.md-text.content h2::before {
  color: var(--ts-rust);
}

.md-text.content h3::before {
  color: var(--ts-mustard);
}

.md-text.content p,
.md-text.content li {
  line-height: 1.78;
}

li:not([class]) a:not([class]),
p:not([class]) a:not([class]),
table a:not([class]) {
  color: var(--link);
  background: linear-gradient(0deg, rgba(34, 93, 101, 0.22), rgba(34, 93, 101, 0.22)) no-repeat left 100%/100% 2px;
}

li:not([class]) a:not([class]):hover,
p:not([class]) a:not([class]):hover,
table a:not([class]):hover {
  color: var(--ts-rust);
  background: linear-gradient(0deg, rgba(211, 153, 50, 0.25), rgba(211, 153, 50, 0.25)) no-repeat left 100%/100% 100%;
}

blockquote {
  color: var(--text-p2);
  background: rgba(211, 153, 50, 0.08);
  border-radius: 10px;
  padding: 0.65rem 1rem 0.65rem 1.15rem;
}

blockquote::before {
  background: var(--ts-mustard);
  opacity: 1;
}

p > code:not([class]),
li > code:not([class]) {
  color: var(--ts-teal);
  background: rgba(34, 93, 101, 0.09);
  border: 1px solid rgba(34, 93, 101, 0.12);
}

.md-text .highlight,
pre:not([class]):has(> code) {
  background: rgba(227, 216, 198, 0.42);
  border: 1px solid var(--ts-line-soft);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.35);
}

.md-text .highlight figcaption span {
  background: rgba(174, 82, 56, 0.1);
  color: var(--ts-rust);
}

.md-text .highlight .code::before {
  color: var(--ts-olive);
}

.widget-wrapper.toc .toc a {
  color: var(--text-p3);
}

.widget-wrapper.toc .toc a:hover {
  color: var(--ts-teal);
  background: rgba(34, 93, 101, 0.1);
}

.widget-wrapper.toc .toc a.toc-link.active {
  color: var(--ts-rust);
}

.widget-wrapper.toc .toc a.active::before {
  background: var(--ts-rust);
}

@media screen and (max-width: 667px) {
  body > .sitebg::before {
    background-size: 28px 28px;
    opacity: 0.26;
  }

  .l_body .l_left .leftbar-container,
  .l_body .l_right {
    background: var(--card);
  }

  .post-list .post-card,
  .article.banner,
  .md-text.content {
    border-radius: 12px;
  }

  .md-text.content {
    padding: 1rem 1rem 1.75rem;
  }
}
```

- [ ] **Step 4: Verify the new CSS variables exist**

Run:

```bash
grep -n -- '--ts-rust' source/css/site-info.css
```

Expected: output includes at least:

```text
3:  --ts-rust: #ae5238;
```

- [ ] **Step 5: Commit the post-main skin file**

Run:

```bash
git diff -- source/css/site-info.css
git add source/css/site-info.css
git commit -m "style: add terracotta study skin"
```

Expected: commit succeeds and includes only `source/css/site-info.css`.

## Task 2: Sync the Stylus Widget Mirror

**Files:**
- Modify: `source/css/_custom.styl`

- [ ] **Step 1: Verify the Stylus file still contains the existing widget selectors**

Run:

```bash
grep -n 'site-info-card' source/css/_custom.styl
```

Expected: output contains `.site-info-card`.

- [ ] **Step 2: Replace `source/css/_custom.styl` with the widget mirror**

Replace the complete file with:

```stylus
.site-info-card
  margin: .35rem 0
  padding: .15rem 0
  div
    display: flex
    align-items: center
    justify-content: space-between
    gap: .5rem
    min-height: 1.9rem
    padding: .25rem .1rem
    border-bottom: 1px dashed var(--ts-line-soft, var(--block))
  div:last-child
    border-bottom: 0
  dt
    flex: 0 0 auto
    margin: 0
    color: var(--ts-olive, var(--text-p3))
    font-size: .78rem
    line-height: 1.2
    white-space: nowrap
  dd
    flex: 1 1 auto
    min-width: 0
    margin: 0
    color: var(--ts-teal, var(--text-p1))
    font-size: .82rem
    font-weight: 700
    line-height: 1.2
    text-align: right
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis

.l_right .widget-wrapper.markdown .widget-body
  padding: .55rem .75rem
```

- [ ] **Step 3: Verify the fallback variables are present**

Run:

```bash
grep -n -- 'var(--ts-olive, var(--text-p3))' source/css/_custom.styl
```

Expected: output contains the `dt` color line.

- [ ] **Step 4: Commit the Stylus mirror**

Run:

```bash
git diff -- source/css/_custom.styl
git add source/css/_custom.styl
git commit -m "style: sync terracotta widget stylus"
```

Expected: commit succeeds and includes only `source/css/_custom.styl`.

## Task 3: Build and Static Output Verification

**Files:**
- Verify generated output under `public/`
- Do not commit generated `public/` files unless the repository already expects generated output in the current workflow and `git status --short public` shows tracked changes that the user wants included.

- [ ] **Step 1: Run the Hexo build**

Run:

```bash
npm run build
```

Expected: command exits with status `0` and prints Hexo generation output ending without errors.

- [ ] **Step 2: Verify the injected stylesheet is present in generated HTML**

Run:

```bash
grep -n 'site-info.css' public/index.html
```

Expected:

```text
  <link rel="stylesheet" href="/css/site-info.css?v=20260429">
```

- [ ] **Step 3: Verify generated CSS contains the Terracotta variables**

Run:

```bash
grep -n -- '--ts-rust' public/css/site-info.css
```

Expected: output contains:

```text
  --ts-rust: #ae5238;
```

- [ ] **Step 4: Verify the generated CSS order keeps the skin after Stellar main CSS**

Run:

```bash
grep -n 'css/main.css\|css/site-info.css' public/index.html
```

Expected: `main.css` appears on a lower line number than `site-info.css`, with output shaped like:

```text
51:  <link rel="stylesheet" href="/css/main.css?v=1.33.1">
61:  <link rel="stylesheet" href="/css/site-info.css?v=20260429">
```

## Task 4: Local Preview and Page Checks

**Files:**
- Verify rendered pages only.

- [ ] **Step 1: Start the local Hexo server**

Run:

```bash
npm run server
```

Expected: server prints that it is running on `http://0.0.0.0:4000/`.

- [ ] **Step 2: Verify the homepage responds**

In a second shell, run:

```bash
curl -I http://127.0.0.1:4000/
```

Expected: output contains:

```text
HTTP/1.1 200 OK
```

- [ ] **Step 3: Verify representative pages respond**

Run:

```bash
curl -I http://127.0.0.1:4000/about/
curl -I http://127.0.0.1:4000/wiki/
curl -I http://127.0.0.1:4000/posts/2026/04/29/2026-04-29-hexo-stellar-build-log/
```

Expected: each command returns `HTTP/1.1 200 OK`.

- [ ] **Step 4: Inspect the loaded CSS through the generated file**

Run:

```bash
curl -s http://127.0.0.1:4000/css/site-info.css | grep -n -- '--ts-teal'
```

Expected: output contains the Deep Teal variable:

```text
5:  --ts-teal: #225d65;
```

- [ ] **Step 5: Stop the local Hexo server**

Stop the `npm run server` process with `Ctrl+C`.

Expected: server process exits and no long-running task remains.

## Task 5: Final Workspace Review

**Files:**
- Review git state and commits.

- [ ] **Step 1: Inspect scoped changes**

Run:

```bash
git status --short
```

Expected: the two theme commits are present in history, and remaining dirty files are pre-existing unrelated work or generated output from `npm run build`.

- [ ] **Step 2: Verify no Stellar source files were changed by this implementation**

Run:

```bash
git status --short themes/stellar
```

Expected: output is unchanged from before the implementation. The implementation must not add new changes under `themes/stellar`.

- [ ] **Step 3: Summarize the result**

Report:

```text
Implemented Terracotta Study as a post-main CSS skin in source/css/site-info.css.
Kept Stellar config, site tree, navigation, wiki structure, and themes/stellar source unchanged.
Verified npm run build and local representative pages.
```
