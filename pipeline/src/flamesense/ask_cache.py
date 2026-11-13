"""Cached answers for the 6 suggested Ask questions (PLAN.md Phase 12 step 10).

Calls a running /api/ask (default http://localhost:8788, `wrangler pages dev`) for each
question and writes ask_cache.json. The lead reviews all 6 answers. English only: the
Bangla UI is cut (PLAN.md §1.0). Questions are read from app/lib/l10n/app_en.arb
(askQ1–askQ6) so the cache always matches the UI copy.
"""

from __future__ import annotations

import json
import time
import urllib.request
from pathlib import Path

QUESTION_KEYS = [f"askQ{i}" for i in range(1, 7)]


def load_questions(l10n_dir: Path) -> dict[str, str]:
    """askQn → English question from the ARB file."""
    en = json.loads((l10n_dir / "app_en.arb").read_text(encoding="utf-8"))
    return {k: en[k] for k in QUESTION_KEYS}


def ask(base_url: str, question: str, lang: str, origin: str) -> dict:
    """POST one question; raises on HTTP errors."""
    body = json.dumps({"question": question, "lang": lang}).encode("utf-8")
    req = urllib.request.Request(f"{base_url.rstrip('/')}/api/ask", data=body, method="POST",
                                 headers={"content-type": "application/json", "Origin": origin})
    with urllib.request.urlopen(req, timeout=60) as res:
        return json.loads(res.read().decode("utf-8"))


def build_cache(base_url: str, l10n_dir: Path, origin: str | None = None,
                pause_s: float = 0.0) -> dict:
    """ask_cache.json content: one English entry per question id (`askQ1_en`).

    `pause_s` spaces the requests so free-tier per-minute limits are respected (no retries).
    """
    origin = origin or base_url.rstrip("/")
    out: dict = {}
    for i, (key, q_en) in enumerate(load_questions(l10n_dir).items()):
        if i and pause_s:
            time.sleep(pause_s)
        answer = ask(base_url, q_en, "en", origin)
        answer["cached"] = True
        out[f"{key}_en"] = {"q_en": q_en, "answer": answer}
    return out
