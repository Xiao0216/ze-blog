# GitHub Issues Friends System Design

## Goal

Build a friends-link system inside `Xiao0216/ze-blog`, modeled after `xaoxuu/friends`, so the existing Hexo/Stellar `/friends/` page reads approved friends from this same GitHub repository instead of `wenshuai/friends`.

The repository will use GitHub Issues as the application database. GitHub Actions will turn approved Issues into `output/v2/data.json`, and the blog page will render that JSON through Stellar's existing `friends_and_posts` data service.

## Scope

In scope:

- Add GitHub Issue templates for friend-link applications.
- Add GitHub Actions workflows for feed parsing, link reachability checks, label comments, and optional one-time data migration.
- Add label-commenter configuration with site-specific Chinese review messages.
- Add a repository README that explains application rules and the site's own friend-link metadata.
- Update `source/friends/index.md` to point application links and data API URLs at `Xiao0216/ze-blog`.
- Update `source/_data/widgets.yml` so the friends manual widget reads this repository's README.
- Verify the Hexo build still succeeds after configuration changes.

Out of scope:

- Creating a separate `Xiao0216/friends` repository.
- Rewriting Stellar's friends rendering components.
- Building a custom backend or crawler.
- Automatically creating GitHub labels. Labels are expected to be created manually in GitHub if they do not exist.

## Repository Flow

Applicants open a new Issue using the friend-link template. The Issue starts with the `审核中` label and contains a JSON block with:

- `title`
- `url`
- `icon`
- `snapshot`
- `description`
- `feed`

The blog owner reviews the Issue. When the friend link is approved, the owner removes `审核中` and optionally applies review labels such as `未添加友链`, `缺少文章`, `缺少互动`, `失联`, `长期失联`, `风险网站`, or `白名单`.

The Actions workflows generate the public data from Issues that are not excluded by review labels.

## Workflows

Add these workflows under `.github/workflows/`:

- `feed-posts-parser.yml`: runs daily and manually, parses recent RSS posts, generates JSON, and force-pushes the generated data to the `output` branch.
- `reachability-checker.yml`: runs on relevant Issue events, daily, and manually; labels unreachable sites and regenerates JSON.
- `label-commenter.yml`: comments on Issues when review labels are added or removed.
- `_migration.yml`: manual-only workflow for future data format migration.

The workflows will use the same upstream GitHub Actions as the reference repo:

- `xaoxuu/feed-posts-parser@main`
- `xaoxuu/issues2json@main`
- `xaoxuu/links-checker@main`
- `peaceiris/actions-label-commenter@v1`
- `xaoxuu/friends-data-migration@main`

The generated API URL consumed by the blog will be:

```text
https://raw.githubusercontent.com/Xiao0216/ze-blog/output/v2/data.json
```

## Blog Integration

The current `/friends/` page already uses Stellar's `ds-friends_and_posts` component. Keep that rendering path and only update the source URLs:

- Issue application links become `https://github.com/Xiao0216/ze-blog/issues` or the Issue chooser URL.
- The data API becomes `https://raw.githubusercontent.com/Xiao0216/ze-blog/output/v2/data.json`.
- The right-sidebar manual in `source/_data/widgets.yml` becomes `https://raw.githubusercontent.com/Xiao0216/ze-blog/master/README.md`.

The page keeps the current visual design, banner, sidebars, and copy style.

## Site Metadata

Use the existing blog configuration as the default friend-link metadata:

```yaml
title: 縉紳(jinshen)
url: https://zblog.wenshuai.site
avatar: https://zblog.wenshuai.site/favicon.svg?v=cat-professor-round-20260429
screenshot: https://zblog.wenshuai.site/
description: 縉紳(jinshen) 的个人生活空间，记录建站、长期知识笔记和生活日常。
feed: https://zblog.wenshuai.site/atom.xml
```

Use the site homepage URL as the default screenshot reference in README text unless a real screenshot asset is added later.

## Error Handling

- If a feed cannot be parsed, Stellar's existing renderer shows `RSS 解析失败`.
- If no feed is provided, Stellar's existing renderer shows `未设置 RSS 链接`.
- If a site is unreachable, the workflow applies the configured unreachable label so excluded Issues do not appear in generated JSON.
- If Actions have not run yet, `/friends/` may show an empty/loading data area until `output/v2/data.json` exists.

## Verification

Implementation is complete only after these checks pass:

- `npm run build`
- Git status review confirms the intended files changed.
- The generated `public/friends/index.html` contains the `Xiao0216/ze-blog/output/v2/data.json` API URL after build.

## Acceptance Criteria

- A visitor can open `/friends/` and the page is wired to this repository's future generated friends JSON.
- A friend applicant can use GitHub's Issue template to submit structured data.
- A repository maintainer can approve or reject applicants by applying/removing labels.
- GitHub Actions can generate the `output` branch data from approved Issues.
- The manual/sidebar content no longer points at `wenshuai/friends`.
