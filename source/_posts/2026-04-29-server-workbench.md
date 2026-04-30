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
cover: https://w.wallhaven.cc/full/g8/wallhaven-g8r373.png
---

服务器不是只要能跑就算完成。真正可维护的服务器，应该能让下一个改动很快找到边界。

## 入口清晰

外部入口先收敛到 Nginx。每个域名一个站点配置，静态站点直接服务目录，动态服务再反向代理到本机端口。这样排查时可以先问：请求到 Nginx 了吗，Host 匹配了吗，后端端口活着吗。

## 目录清晰

源码目录和发布目录分开。源码可以放在工作区，发布目录应该让 Nginx 安全读取。当前博客的源码在 `/root/ai-apps/ze-blog`，发布目录使用 `/var/www/zblog`。

## 验证清晰

每次上线都至少做三件事：构建静态文件，测试 Nginx 配置，用本机 Host 请求验证源站。公网访问异常时，先分清是源站问题还是 Cloudflare 缓存与代理问题。
