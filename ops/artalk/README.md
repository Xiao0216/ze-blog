# Artalk Comments

This directory contains the self-hosted Artalk service used by the blog comment UI.

## Start

```bash
cd /root/ai-apps/ze-blog/ops/artalk
docker compose up -d
```

The service listens on `127.0.0.1:23366` and is exposed publicly by Nginx at:

```text
https://zblog.wenshuai.site/atk/
```

Comment data and uploaded images are stored in `ops/artalk/data/` and are intentionally ignored by Git.
