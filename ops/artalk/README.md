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

## GitHub Login

Create a GitHub OAuth App with these values:

```text
Application name: zblog comments
Homepage URL: https://zblog.wenshuai.site
Authorization callback URL: https://zblog.wenshuai.site/atk/api/v2/auth/github/callback
```

Then create the local environment file:

```bash
cd /root/ai-apps/ze-blog/ops/artalk
cp .env.example .env
```

Edit `.env` and replace the GitHub OAuth values:

```text
ARTALK_AUTH_ENABLED=true
ARTALK_AUTH_ANONYMOUS=true
ARTALK_AUTH_GITHUB_ENABLED=true
ARTALK_AUTH_GITHUB_CLIENT_ID=...
ARTALK_AUTH_GITHUB_CLIENT_SECRET=...
```

Restart Artalk after changing `.env`:

```bash
docker compose up -d
```

`.env` is intentionally ignored by Git because it contains the GitHub client secret.
