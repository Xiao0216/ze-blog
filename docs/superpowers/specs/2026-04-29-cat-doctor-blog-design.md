# 猫博士(縉紳) 博客站设计

日期：2026-04-29  
状态：已由用户口头批准，等待实施计划

## 背景

用户要在 `/root/ai-apps/ze-blog` 建立个人博客网站，昵称为“猫博士(縉紳)”，使用 `xaoxuu/hexo-theme-stellar`，并通过 Cloudflare 域名 `zblog.wenshuai.site` 对外访问。当前目录原为空目录，服务器已安装 Node.js、npm、Nginx，Nginx 正在监听 80 端口。`zblog.wenshuai.site` 已经通过 Cloudflare 指向这台机器，当前命中 Nginx 默认站点内容。

已确认的产品选择：

- 站点类型：综合型个人站。
- 视觉气质：赛博书房，兼具技术感、学者感和一点独立审美。
- 内容骨架：首页、博客、知识库、项目、碎碎念、关于。
- 部署方式：Hexo 生成静态文件，Nginx 直接服务 `public/`，Cloudflare 负责公网 DNS/CDN/HTTPS。
- 外部服务：评论和统计只预留配置位，第一版默认关闭。

## 参考依据

- Stellar 官方开始页说明它是内置文档系统的 Hexo 主题，适合内容创作者，支持标签和动态数据组件。
- Stellar GitHub README 将主题定位为“博客系统、知识库系统、专栏系统、笔记系统”的综合型 Hexo 主题。
- Stellar 文档建议使用站点根目录 `_config.yml` 配置标题、头像、favicon、语言，并用 `_config.stellar.yml` 覆盖主题配置。
- Stellar 文档系统通过 `source/_data/wiki/*.yml` 描述项目、`source/wiki/**.md` 承载页面、`source/_data/wiki.yml` 上架项目。
- Stellar 当前 npm 版本为 `1.33.1`。

## 目标

第一版要上线一个可访问、可持续更新、不是空壳的个人综合博客站。站点应让访问者立刻知道这是“猫博士(縉紳)”的赛博书房，并能进入博客、知识库、项目和碎碎念内容。

成功标准：

- `https://zblog.wenshuai.site/` 可以通过 Cloudflare 访问新站首页。
- 本机 `curl -H 'Host: zblog.wenshuai.site' http://127.0.0.1/` 返回新站 HTML。
- `npm run build` 可以稳定生成 `public/`。
- `nginx -t` 通过，reload 后不影响现有其他虚拟主机。
- 首页、博客、知识库、项目、关于页面都有可读内容。
- RSS、sitemap、本地搜索可用。
- 评论和统计未启用时不产生前端错误。

## 非目标

第一版不实现账号系统、在线后台、动态发布、评论服务部署、统计平台接入、复杂前端重写或主题源码深度定制。Memos、Giscus、Waline、Umami 等只保留后续启用空间。

## 信息架构

### 首页

首页作为个人入口，不做营销落地页。首屏呈现“猫博士(縉紳)”和一句短副标题，例如“赛博书房里的技术、AI 与长期笔记”。首页展示近期文章、知识库入口、项目入口和站点简介。

### 博客

博客承载较完整的文章，初始分类建议：

- AI 工具
- 服务器手札
- 编程与自动化
- 建站记录

第一批文章：

- 《开卷：猫博士的赛博书房》
- 《把一台服务器整理成工作台》
- 《AI 工具不是魔法，是新的笔记接口》
- 《Hexo + Stellar 建站记录》

### 知识库

使用 Stellar wiki 能力建立三个知识库项目：

- AI 工作流：提示词、工具链、自动化流程、实践原则。
- 服务器手札：Linux、Nginx、Cloudflare、部署记录。
- 建站笔记：Hexo、Stellar、内容组织、发布流程。

每个 wiki 项目至少有首页和一篇入门页面，目录树在 `source/_data/wiki/<id>.yml` 中显式维护。

### 项目

项目页展示个人实验和长期维护对象。第一版用静态项目内容，不依赖外部接口。

初始项目：

- 个人博客：当前站点本身。
- AI 应用实验室：用于记录 AI 工具和小应用。
- 自动化脚本箱：用于记录服务器和工作流自动化脚本。

### 碎碎念

第一版用独立页面或笔记式短文模拟短记录，不接外部动态服务。后续如果用户提供 Memos 服务地址，再启用 Stellar 的 Memos 插件玩法。

### 关于

关于页介绍“猫博士(縉紳)”的站点身份、内容范围和联系方式占位。联系方式第一版不暴露敏感信息，仅预留 GitHub、邮箱、RSS 等位置。

## 主题配置

站点根配置 `_config.yml`：

- `title: 猫博士(縉紳)`
- `subtitle: 赛博书房里的技术、AI 与长期笔记`
- `url: https://zblog.wenshuai.site`
- `language: zh-CN`
- `timezone: Asia/Shanghai`
- `theme: stellar`
- 配置分类、标签、归档、permalink、RSS、sitemap。

主题覆盖配置 `_config.stellar.yml`：

- 配置 logo 区域、导航菜单、首页侧边栏、文章页目录。
- 菜单包含首页、博客、知识库、项目、碎碎念、关于。
- 启用本地搜索，生成 `/search.json`。
- 启用 Open Graph 基础信息。
- 评论服务字段保留为空。
- 页脚保留主题信息、版权说明、RSS 和站点地图入口。

不直接修改主题包源码。需要覆盖的样式放在站点自有资源中，控制在小范围。

## 内容风格

中文为主，语气冷静、有个人辨识度，不写成模板宣传文。标题和正文围绕“赛博书房”的隐喻，但避免堆砌概念。初始内容可以作为正式发布内容存在，后续用户可以逐步替换为真实文章。

## 部署设计

生产流量不经过 Node.js。构建命令生成静态文件：

```bash
npm run build
```

Nginx 增加独立站点配置：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name zblog.wenshuai.site;

    root /root/ai-apps/ze-blog/public;
    index index.html;

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

如果文件属主或 Nginx 访问权限阻止读取 `/root/ai-apps/ze-blog/public`，优先调整部署目录到 `/var/www/zblog` 或建立安全的发布目录，而不是放宽整个 `/root` 权限。实施阶段要以实际权限验证结果决定。

Cloudflare 侧继续使用 `zblog.wenshuai.site` 代理到源站 80 端口，HTTPS 由 Cloudflare 对外提供。源站 Nginx 只需正确响应 Host 为 `zblog.wenshuai.site` 的 HTTP 请求。

## 构建脚本

`package.json` 至少包含：

- `npm run clean`: 清理 Hexo 生成缓存。
- `npm run build`: `hexo clean && hexo generate`。
- `npm run server`: 本地预览。
- `npm run deploy:local`: 可选，用于构建并验证静态输出。

## 错误处理

- 404 页面使用 Hexo/Stellar 自定义页面。
- 评论和统计未配置时保持关闭，不加载空脚本。
- Nginx 配置先写入 `sites-available`，用 symlink 启用，先 `nginx -t` 再 reload。
- 如果已有默认站点仍匹配 `zblog.wenshuai.site`，新增精确 `server_name` 的站点应覆盖默认站点。
- 如果 Cloudflare 访问仍显示旧内容，先用本机 Host curl 验证源站，再判断 Cloudflare 缓存或 DNS 状态。

## 验证计划

实施完成后运行：

```bash
npm install
npm run build
nginx -t
systemctl reload nginx
curl -I -H 'Host: zblog.wenshuai.site' http://127.0.0.1/
curl -I https://zblog.wenshuai.site/
```

还要人工检查：

- 首页不是默认 Hexo 页面。
- 导航链接可访问。
- wiki 列表和每个 wiki 首页可访问。
- RSS、sitemap、search.json 存在。
- 浏览器控制台没有明显资源 404 或脚本错误。

## 后续扩展

后续可以逐步启用：

- Giscus、Waline、Twikoo 或 Artalk 评论。
- Umami、Google Analytics、百度统计等访问统计。
- Memos 短动态。
- GitHub Actions 或服务器定时构建。
- 更完整的个人头像、favicon、封面图和品牌视觉资源。
