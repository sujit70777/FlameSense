#!/usr/bin/env bash
# Runs FlameSense locally in one command (from the repo root):
#   bash scripts/dev.sh          data pipeline → release build → site + Ask API on http://localhost:8788
#   bash scripts/dev.sh --quick  Flutter debug run in Chrome (hot reload; no Ask API)
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d pipeline/.venv ]; then
  echo "=== Creating Python venv (first run) ==="
  python3 -m venv pipeline/.venv
  pipeline/.venv/bin/pip install -q -r pipeline/requirements.txt
  pipeline/.venv/bin/pip install -q -e pipeline
fi

echo "=== Data pipeline ==="
pipeline/.venv/bin/python -m flamesense.cli all
bash scripts/sync_assets.sh >/dev/null

cd app
flutter pub get >/dev/null
flutter gen-l10n

if [ "${1:-}" = "--quick" ]; then
  exec flutter run -d chrome
fi

echo "=== Building web app ==="
flutter build web --release --no-web-resources-cdn
cd ..

[ -f .dev.vars ] || echo "Note: no .dev.vars, so the Ask page shows saved answers only."
echo "=== Serving on http://localhost:8788 (Ctrl+C to stop) ==="
exec npx wrangler pages dev app/build/web --port 8788
