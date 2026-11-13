#!/usr/bin/env bash
# Deploys FlameSense to Cloudflare Pages + Functions (PLAN.md §1.0 Hosting, Phase 16).
# Static app from app/build/web, /api/ask from functions/ (so run from the repo root).
#
#   bash scripts/deploy.sh --preview   # branch "preview" → https://preview.flamesense.pages.dev
#   bash scripts/deploy.sh             # production (branch main) → flamesense.pages.dev + custom domain
#   add --no-build to reuse an existing app/build/web
#
# Needs `npx wrangler login`, the Pages project, the GEMINI_API_KEY Pages secret and the
# RATE_KV binding in wrangler.toml (see README "Deploy"). Runs scripts/smoke.mjs afterwards.
set -euo pipefail

PROJECT=flamesense
PROD_URL=https://flamesense.ehsanur.com
PREVIEW=0
BUILD=1
for arg in "$@"; do
  case "$arg" in
    --preview) PREVIEW=1 ;;
    --no-build) BUILD=0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }

say "Checking the working tree"
if [ -n "$(git status --porcelain)" ]; then
  echo "Uncommitted changes. Commit them first; deploys are always a commit." >&2
  exit 1
fi
COMMIT="$(git rev-parse HEAD)"
if [ "$PREVIEW" = 0 ]; then
  if [ "$(git rev-parse --abbrev-ref HEAD)" != main ]; then
    echo "Production deploys only from main. Use --preview for other branches." >&2
    exit 1
  fi
  git fetch --quiet origin main
  if [ "$COMMIT" != "$(git rev-parse origin/main)" ]; then
    echo "Local main differs from origin/main. Push (or pull) first." >&2
    exit 1
  fi
fi

say "Checking Cloudflare login"
if ! npx wrangler whoami 2>/dev/null | grep -q "associated with the email\|You are logged in"; then
  echo "Not logged in to Cloudflare. Run: npx wrangler login" >&2
  exit 1
fi
if ! grep -q '^\[\[kv_namespaces\]\]' wrangler.toml; then
  echo "Warning: no RATE_KV binding in wrangler.toml; /api/ask will run without rate limits." >&2
fi

if [ "$BUILD" = 1 ] || [ ! -f app/build/web/index.html ]; then
  say "Building (pipeline, assets, analyze, test, web release)"
  bash scripts/build_all.sh
  # The build only restamps build time and git SHA in these; the stamps are already in
  # app/build/web, so restore them to keep the tree clean.
  git checkout -- app/assets/data/app_meta.json pipeline/out/app_assets/app_meta.json \
    app/assets/data/coverage.json pipeline/out/app_assets/coverage.json \
    docs/DATA_REPORT.md
else
  bash scripts/check_secrets.sh
fi
test -f app/build/web/index.html

if [ "$PREVIEW" = 1 ]; then BRANCH=preview; URL="https://preview.$PROJECT.pages.dev"; else BRANCH=main; URL="$PROD_URL"; fi
say "Deploying $(git rev-parse --short HEAD) to Cloudflare Pages ($PROJECT, branch $BRANCH)"
npx wrangler pages deploy app/build/web --project-name "$PROJECT" --branch "$BRANCH" \
  --commit-hash "$COMMIT" --commit-message "$(git log -1 --pretty=%s)" --commit-dirty=false

say "Smoke test ($URL)"
node scripts/smoke.mjs "$URL"
say "Deployed to $URL"
