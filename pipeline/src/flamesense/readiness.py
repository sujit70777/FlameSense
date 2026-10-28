"""Demo-readiness report: which human inputs are still missing (PLAN.md Phase 0, AUDIT.md).

`python -m flamesense.cli readiness` prints one line per item with the next action.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

from flamesense import config


@dataclass
class Item:
    """One readiness check."""

    name: str
    ok: bool
    detail: str
    action: str


def _table_rows(path: Path) -> int:
    """Data rows in the first markdown table of a file (0 if missing)."""
    if not path.exists():
        return 0
    rows = [ln for ln in path.read_text(encoding="utf-8").splitlines() if ln.startswith("|")]
    return max(0, len(rows) - 2)


def _json(path: Path) -> dict:
    """JSON content or {}."""
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


def data_items(assets: Path) -> list[Item]:
    """Runs and model availability."""
    meta, spec = _json(assets / "app_meta.json"), _json(assets / "feature_spec.json")
    tasks = spec.get("tasks", {})
    n = meta.get("n_runs", 0)
    return [
        Item("NASA runs", n > 0, f"{n} runs", "Add data/raw or data/manual/*.csv (docs/DATA_CANDIDATES.md), then `cli all`"),
        Item("Burning model", bool(tasks.get("sustain", {}).get("available")),
             tasks.get("sustain", {}).get("reason_if_unavailable") or "trained", "≥ 40 runs with ignited/sustained, ≥ 8 of each outcome"),
        Item("Spread models", bool(tasks.get("spread", {}).get("available")),
             tasks.get("spread", {}).get("reason_if_unavailable") or "trained", "≥ 40 solid-fuel runs with a spread rate"),
        Item("DATA_SOURCES.md", _table_rows(config.DOCS / "DATA_SOURCES.md") > 0,
             f"{_table_rows(config.DOCS / 'DATA_SOURCES.md')} sources", "List every dataset you opened (PLAN §3.0)"),
        Item("CHALLENGE_REQUIREMENTS.md", _table_rows(config.DOCS / "CHALLENGE_REQUIREMENTS.md") > 0,
             f"{_table_rows(config.DOCS / 'CHALLENGE_REQUIREMENTS.md')} requirements", "Map the full challenge statement (PLAN §0.4)"),
    ]


def science_items(assets: Path) -> list[Item]:
    """Physics, constraints, missions, lessons, usability."""
    from flamesense.physics import load_params, validate_params
    from flamesense.train import MONOTONE_CONFIRMED_BY_LEAD

    params = load_params(config.DATA_MANUAL / "physics_params.json")
    problems = validate_params(params)
    missions = _json(config.DATA_MANUAL / "missions.json").get("missions", [])
    sourced = sum(1 for m in missions if str(m.get("source") or "").strip())
    lessons = _json(assets / "lessons.json").get("lessons", [])
    approved = sum(1 for lesson in lessons if lesson.get("status") == "approved")
    tasks = _json(assets / "usability.json").get("tasks", [])
    return [
        Item("Physics parameters", not problems, f"{len(problems)} problem(s)", "Fill data/manual/physics_params.json with sources"),
        Item("Physics sign-off", bool(params and params.get("signed_off_by_lead")), "signed_off_by_lead",
             "Tick docs/PHYSICS_SPEC.md and set signed_off_by_lead: true"),
        Item("Monotone signs (Q-2)", MONOTONE_CONFIRMED_BY_LEAD, "MONOTONE_CONFIRMED_BY_LEAD", "Confirm in QUESTIONS.md, flip the constant in train.py"),
        Item("Mission sources", sourced == len(missions) > 0, f"{sourced}/{len(missions)} sourced", "Fill `source` in data/manual/missions.json (Q-7)"),
        Item("Earth lessons", approved > 0, f"{approved} approved", "Write data/manual/lessons_draft.md (Q-11)"),
        Item("Usability test", len(tasks) > 0, f"{len(tasks)} tasks", "Run the test; fill data/manual/usability.csv"),
    ]


def ask_items(assets: Path) -> list[Item]:
    """Corpus, key, cached answers."""
    corpus = _json(config.PIPELINE_OUT / "corpus_chunks.json")
    cache = _json(assets / "ask_cache.json")
    return [
        Item("Ask corpus", bool(corpus.get("docs")), f"{len(corpus.get('docs', []))} docs",
             "Add PDFs + data/corpus_raw/corpus_meta.csv, run `cli corpus`"),
        Item("Local API key", (config.ROOT / ".dev.vars").exists(), ".dev.vars", "Create .dev.vars with ANTHROPIC_API_KEY (never commit)"),
        Item("Cached answers", len(cache) >= 12, f"{len(cache)}/12", "With wrangler running: `cli ask-cache`, then review all 12"),
    ]


def team_items() -> list[Item]:
    """Bangla review and audit blockers."""
    bn = config.ROOT / "app" / "lib" / "l10n" / "app_bn.arb"
    pending = bn.read_text(encoding="utf-8").count('"bn-pending"') if bn.exists() else 0
    audit = (config.DOCS / "AUDIT.md").read_text(encoding="utf-8") if (config.DOCS / "AUDIT.md").exists() else ""
    blockers = len(re.findall(r"^- \[ \] \[B\]", audit, flags=re.MULTILINE))
    return [
        Item("Bangla review", pending == 0, f"{pending} strings pending", "Native speaker reviews app/tool/l10n_source.py"),
        Item("AUDIT blockers", blockers == 0, f"{blockers} open", "Work through docs/AUDIT.md"),
    ]


def readiness() -> list[Item]:
    """Every check, grouped data → science → Ask → team."""
    assets = config.ROOT / "app" / "assets" / "data"
    return data_items(assets) + science_items(assets) + ask_items(assets) + team_items()
