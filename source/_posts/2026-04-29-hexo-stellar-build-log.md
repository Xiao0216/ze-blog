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
cover: https://w.wallhaven.cc/full/1p/wallhaven-1pd6l1.png
---

这个站点的第一版采用静态博客路线。

## 技术选择

Hexo 负责生成静态文件，Stellar 负责主题、博客列表、知识库和侧边栏体验。Nginx 直接服务生成后的静态目录，Cloudflare 负责外部 HTTPS、DNS 和缓存。

## 为什么不跑 Node 服务

生产访问只需要静态文件。把 Node 服务留给构建和本地预览，可以减少常驻进程和端口管理，也让恢复路径更简单：重新构建，重新同步发布目录，重载 Nginx。

## 下一步

第一版先把站点结构、内容骨架和发布链路跑通。后续再补充真实项目、评论系统、统计系统和更完整的视觉资产。
