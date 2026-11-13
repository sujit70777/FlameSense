# Environment — flamesense-prep (data preparation only)

Checked on 2026-11-02, macOS 27.0.1 (darwin-arm64), package manager Homebrew 7.0.11. No sudo was used.

## Tools

| Tool | Version | Status | Notes |
|---|---|---|---|
| git | 2.54.0 (Apple Git-157) | ok | |
| Python | 3.13.1 (`/Library/Frameworks/Python.framework/Versions/3.13/bin/python3`) | ok | venv + pip available. Homebrew also has 3.15.1; 3.13 used for wheel compatibility |
| Node.js | v26.12.1 | ok | |
| npm | 12.2.1 | ok | |
| Flutter | 3.47.6, channel stable | ok | `flutter doctor`, web lines: Flutter ✓, Chrome (develop for the web) ✓, Connected device ✓, Network resources ✓. The one issue doctor reports is in a non-web category |
| Wrangler | 4.156.0 | installed | `npm install -g wrangler` (prefix /opt/homebrew). Install scripts allowed only for esbuild, fsevents, workerd |
| poppler-utils (pdftoppm) | 26.10.0 | ok | |

## Python venv `./.venv` (Python 3.13.1, pip 26.2.2)

| Package | Version | Status |
|---|---|---|
| requests | 2.34.2 | installed |
| pandas | 3.1.0 | installed |
| openpyxl | 3.1.5 | installed |
| pyarrow | 26.0.0 | installed |
| pymupdf | 2.0 | installed (use `import pymupdf`; `import fitz` is deprecated) |
| pdfplumber | 0.11.10 | installed |
| beautifulsoup4 | 4.15.0 | installed |
| lxml | 6.1.3 | installed |
| tqdm | 4.70.1 | installed |

All packages import successfully. Activate with `source .venv/bin/activate`.
