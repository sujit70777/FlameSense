#!/usr/bin/env bash
set -euo pipefail

# Sync pipeline exports into app assets
SRC_ASSETS="pipeline/out/app_assets"
SRC_CORPUS="pipeline/out/corpus_chunks.json"
DST_ASSETS="app/assets/data"
DST_CORPUS="app/web/data"

mkdir -p "$DST_ASSETS" "$DST_CORPUS"

if [ -d "$SRC_ASSETS" ]; then
  cp -v "$SRC_ASSETS"/*.json "$DST_ASSETS/"
  echo "Synced app assets."
else
  echo "Warning: $SRC_ASSETS not found. Skipping app assets."
fi

if [ -f "$SRC_CORPUS" ]; then
  cp -v "$SRC_CORPUS" "$DST_CORPUS/"
  echo "Synced corpus chunks."
else
  echo "Warning: $SRC_CORPUS not found. Skipping corpus."
fi

echo "Asset sync complete."
