"""Cached answers for the 6 suggested Ask questions (PLAN.md Phase 12 step 10).

Calls a running /api/ask (default http://localhost:8788, `wrangler pages dev`) for each
question in English and Bangla and writes ask_cache.json. The lead reviews all 12 answers.
Questions are read from app/lib/l10n/app_en.arb / app_bn.arb (askQ1–askQ6) so the cache
always matches the UI copy.
"""

from __future__ import annotations

import json
import urllib.request
from pathlib import Path

QUESTION_KEYS = [f"askQ{i}" for i in range(1, 7)]


def load_questions(l10n_dir: Path) -> dict[str, tuple[str, str]]:
    """askQn → (English, Bangla) from the ARB files."""
    en = json.loads((l10n_dir / "app_en.arb").read_text(encoding="utf-8"))
    bn = json.loads((l10n_dir / "app_bn.arb").read_text(encoding="utf-8"))
    return {k: (en[k], bn[k]) for k in QUESTION_KEYS}


def ask(base_url: str, question: str, lang: str, origin: str) -> dict:
    """POST one question; raises on HTTP errors."""
    body = json.dumps({"question": question, "lang": lang}).encode("utf-8")
    req = urllib.request.Request(f"{base_url.rstrip('/')}/api/ask", data=body, method="POST",
                                 headers={"content-type": "application/json", "Origin": origin})
    with urllib.request.urlopen(req, timeout=60) as res:
        return json.loads(res.read().decode("utf-8"))


def build_cache(base_url: str, l10n_dir: Path, origin: str | None = None) -> dict:
    """ask_cache.json content: one entry per question id and language (`askQ1_en`, `askQ1_bn`)."""
    origin = origin or base_url.rstrip("/")
    out: dict = {}
    for key, (q_en, q_bn) in load_questions(l10n_dir).items():
        for lang, q in (("en", q_en), ("bn", q_bn)):
            answer = ask(base_url, q, lang, origin)
            answer["cached"] = True
            out[f"{key}_{lang}"] = {"q_en": q_en, "q_bn": q_bn, "answer": answer}
    return out
