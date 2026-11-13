#!/usr/bin/env bash
# Deploys the static web app to the Namecheap subdomain (flamesense.ehsanur.com) over SSH:
# checks → build_all.sh → .gz copies → server backup → rsync (no --delete) → health check.
# The static host has no /api/ask: the Ask page's saved answers work; free-form questions need
# the function on Cloudflare Pages (build with ASK_API_BASE=https://flamesense.pages.dev).
#
#   bash scripts/deploy_namecheap.sh             # build and upload
#   bash scripts/deploy_namecheap.sh --dry-run   # rsync preview, no remote changes
#
# Settings come from scripts/deploy.env (git-ignored): SSH_HOST SSH_USER SSH_PORT SSH_KEY
# REMOTE_PATH APP_URL.
# Never deploys uncommitted code, and only from a pushed `main`.
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/scripts/deploy.env"
if [ ! -f "$CONFIG" ]; then
  echo "Missing $CONFIG. Copy scripts/deploy.env.example to it and fill it in." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG"
for name in SSH_HOST SSH_USER SSH_PORT REMOTE_PATH APP_URL; do
  if [ -z "${!name:-}" ]; then echo "Missing $name in $CONFIG" >&2; exit 1; fi
done
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
SSH_KEY="${SSH_KEY/#\~/$HOME}"
SSH_OPTS=(-p "$SSH_PORT" -i "$SSH_KEY" -o IdentitiesOnly=yes)

say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }

cd "$ROOT"

say "Checking the working tree"
if [ -n "$(git status --porcelain)" ]; then
  echo "Uncommitted changes. Commit them first; deploys are always a commit." >&2
  exit 1
fi
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH" != main ]; then
  echo "Deploys only from main (you are on $BRANCH)." >&2
  exit 1
fi
git fetch --quiet origin main
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
  echo "Local main differs from origin/main. Push (or pull) first so the server matches GitHub." >&2
  exit 1
fi
COMMIT="$(git rev-parse --short HEAD)"

if [ "$DRY_RUN" = 0 ] || [ ! -f app/build/web/index.html ]; then
  say "Building (pipeline, assets, analyze, test, web release)"
  bash scripts/build_all.sh
  # The build only restamps build time and git SHA in these; the stamps are
  # already in app/build/web, so restore them to keep the next deploy clean.
  git checkout -- app/assets/data/app_meta.json pipeline/out/app_assets/app_meta.json \
    app/assets/data/coverage.json pipeline/out/app_assets/coverage.json \
    docs/DATA_REPORT.md
fi
test -f app/build/web/index.html
test -f app/build/web/.htaccess

# LiteSpeed serves these precompressed copies (app/web/.htaccess gzip rules).
say "Precompressing (.gz copies of wasm/js/json/ttf/otf)"
find app/build/web -type f \( -name '*.wasm' -o -name '*.js' -o -name '*.json' -o -name '*.ttf' -o -name '*.otf' \) \
  -exec gzip -9 -k -f {} \;

# No --delete: this deploy must never remove remote files (cPanel's
# .well-known and cgi-bin live in the same folder).
RSYNC_FLAGS=(-az --exclude='*.symbols' --exclude='.DS_Store')
[ "$DRY_RUN" = 1 ] && RSYNC_FLAGS+=(--dry-run --itemize-changes)
if [ "$DRY_RUN" = 0 ]; then
  BACKUP="${REMOTE_PATH%/}_backup_$(date +%Y%m%d_%H%M)"
  say "Backing up the live folder to $BACKUP"
  ssh "${SSH_OPTS[@]}" "$SSH_USER@$SSH_HOST" "cp -a '${REMOTE_PATH%/}' '$BACKUP'"
fi
say "Uploading app/build/web @ $COMMIT ($SSH_USER@$SSH_HOST:$REMOTE_PATH)"
rsync "${RSYNC_FLAGS[@]}" -e "ssh ${SSH_OPTS[*]}" \
  app/build/web/ "$SSH_USER@$SSH_HOST:${REMOTE_PATH%/}/"

if [ "$DRY_RUN" = 1 ]; then
  say "Dry run complete; nothing changed on the server"
  exit 0
fi

say "Health check ($APP_URL)"
status="$(curl -s -o /dev/null -w '%{http_code}' "$APP_URL")"
route_status="$(curl -s -o /dev/null -w '%{http_code}' "${APP_URL%/}/lab")"
echo "/ → $status, /lab → $route_status"
if [ "$status" != 200 ] || [ "$route_status" != 200 ]; then
  echo "Health check failed." >&2
  exit 1
fi
say "Deployed $COMMIT to $APP_URL"
