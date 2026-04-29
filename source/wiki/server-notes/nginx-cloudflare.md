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
