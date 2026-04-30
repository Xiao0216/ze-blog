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
