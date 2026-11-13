#!/usr/bin/env bash
set -euo pipefail

echo "=== Running pipeline ==="
source pipeline/.venv/bin/activate
python -m flamesense.cli all
deactivate

echo "=== Syncing assets ==="
bash scripts/sync_assets.sh

echo "=== Building Flutter web ==="
cd app
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn ${ASK_API_BASE:+--dart-define=ASK_API_BASE=$ASK_API_BASE}
# No .gz copies: Cloudflare Pages compresses (brotli/gzip) at the edge.
cd ..

echo "=== Checking for secrets ==="
bash scripts/check_secrets.sh

echo "Build complete."
