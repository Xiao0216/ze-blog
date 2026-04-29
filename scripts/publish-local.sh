#!/usr/bin/env bash
set -euo pipefail

site_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
publish_root="/var/www/zblog"

cd "$site_root"
rm -rf public/
npm run build
if [[ ! -f public/index.html ]]; then
  echo "publish:local aborted: public/index.html was not created by npm run build" >&2
  exit 1
fi
install -d -m 0755 "$publish_root"
rsync -a --delete public/ "$publish_root"/
find "$publish_root" -type d -exec chmod 0755 {} \;
find "$publish_root" -type f -exec chmod 0644 {} \;
