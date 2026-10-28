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

# Real Anthropic key shape anywhere in git history (placeholders like sk-ant-your-key-here don't match).
if git log -p --all 2>/dev/null | grep -E 'sk-ant-(api|admin)[0-9]{2}-[A-Za-z0-9_-]{20,}' >/dev/null; then
  echo "ERROR: Found an Anthropic key pattern in git history"
  FOUND=1
fi

# Same check over the built site and the working tree (excluding dependencies).
if grep -rE 'sk-ant-(api|admin)[0-9]{2}-[A-Za-z0-9_-]{20,}' --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.venv --exclude-dir=.dart_tool . 2>/dev/null; then
  echo "ERROR: Found an Anthropic key pattern in the working tree"
  FOUND=1
fi

if [ $FOUND -eq 0 ]; then
  echo "No secrets found. OK."
  exit 0
else
  echo "SECRET CHECK FAILED"
  exit 1
fi
