#!/usr/bin/env bash
set -euo pipefail

FOUND=0

# Check built web output
if [ -d "app/build/web" ]; then
  if grep -r 'sk-ant-' app/build/web/ 2>/dev/null; then
    echo "ERROR: Found 'sk-ant-' pattern in app/build/web/"
    FOUND=1
  fi
  if grep -r 'ANTHROPIC_API_KEY=' app/build/web/ 2>/dev/null | grep -v 'ANTHROPIC_API_KEY=sk-ant-your-key-here'; then
    echo "ERROR: Found ANTHROPIC_API_KEY value in app/build/web/"
    FOUND=1
  fi
fi

# Check repo (excluding .git, node_modules, .venv, build)
if grep -r 'sk-ant-api' --include='*.dart' --include='*.ts' --include='*.js' --include='*.json' --include='*.yaml' --include='*.toml' . 2>/dev/null | grep -v '.dev.vars.example' | grep -v 'node_modules' | grep -v '.git'; then
  echo "ERROR: Found API key pattern in source files"
  FOUND=1
fi

if [ $FOUND -eq 0 ]; then
  echo "No secrets found. OK."
  exit 0
else
  echo "SECRET CHECK FAILED"
  exit 1
fi
