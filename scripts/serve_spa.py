"""Serve app/build/web with SPA fallback to index.html (local preview only).

Usage: python3 scripts/serve_spa.py [port]
"""

import http.server
import os
import sys
from functools import partial
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "app" / "build" / "web"


class SpaHandler(http.server.SimpleHTTPRequestHandler):
    """Static handler that falls back to index.html for unknown paths."""

    def send_head(self):  # noqa: D102
        path = self.translate_path(self.path.split("?")[0])
        if not os.path.exists(path):
            self.path = "/index.html"
        return super().send_head()

    def log_message(self, *args):  # noqa: D102
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8790
    server = http.server.ThreadingHTTPServer(("127.0.0.1", port), partial(SpaHandler, directory=str(ROOT)))
    print(f"Serving {ROOT} on http://127.0.0.1:{port}")
    server.serve_forever()
