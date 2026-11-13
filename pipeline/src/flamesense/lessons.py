"""Earth lessons and usability results → app assets (PLAN.md §3.8, Phase 13).

The agent never writes lesson science: it only converts what the lead wrote in
data/manual/lessons_draft.md. Format (one block per lesson, `key: value` lines):

    ## L1
    status: approved            # or draft (drafts are hidden in release builds)
    icon: air
    title_en: ...
    title_bn: ...
    space_finding_en: ...
    space_finding_bn: ...
    earth_meaning_en: ...
    earth_meaning_bn: ...
    what_to_do_en: ...
    what_to_do_bn: ...
    source: Label text | https://link
    source: Second label | https://second-link
    reviewed_by: LEAD
    reviewed_on: 2026-11-12

An "approved" lesson must have a reviewer and at least one source URL, else it is kept as draft.

data/manual/usability.csv columns: task_en,task_bn,completed,total,median_seconds
(one row per task) and an optional data/manual/usability_change.txt with one sentence.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

LESSON_FIELDS = [
    "icon", "title_en", "title_bn", "space_finding_en", "space_finding_bn", "earth_meaning_en",
    "earth_meaning_bn", "what_to_do_en", "what_to_do_bn", "reviewed_by", "reviewed_on",
]


def parse_lessons(text: str) -> list[dict]:
    """Parse lessons_draft.md blocks into §3.8 lesson dicts."""
    lessons: list[dict] = []
    for block in re.split(r"(?m)^##\s+", text)[1:]:
        lines = block.strip().splitlines()
        lesson: dict = {"id": lines[0].strip(), "status": "draft", "sources": []}
        for line in lines[1:]:
            key, sep, value = line.partition(":")
            key, value = key.strip(), value.strip()
            if not sep:
                continue
            if key == "source":
                label, _, url = value.partition("|")
                lesson["sources"].append({"label": label.strip(), "url": url.strip()})
            elif key == "status":
                lesson["status"] = value.lower()
            elif key in LESSON_FIELDS:
                lesson[key] = value
        has_source = any(s["url"].startswith("http") for s in lesson["sources"])
        if lesson["status"] == "approved" and not (lesson.get("reviewed_by") and has_source):
            lesson["status"] = "draft"
        lessons.append(lesson)
    return lessons


def build_lessons(manual_dir: Path) -> dict:
    """lessons.json content; empty when lessons_draft.md is absent."""
    path = manual_dir / "lessons_draft.md"
    if not path.exists():
        return {"lessons": []}
    return {"lessons": parse_lessons(path.read_text(encoding="utf-8"))}


def build_usability(manual_dir: Path) -> dict:
    """usability.json content; `tasks` is empty when usability.csv is absent."""
    path = manual_dir / "usability.csv"
    out: dict = {"tasks": [], "change": ""}
    if path.exists():
        with open(path, newline="", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                out["tasks"].append({
                    "task_en": row["task_en"], "task_bn": row.get("task_bn") or row["task_en"],
                    "completed": int(row["completed"]), "total": int(row["total"]),
                    "median_seconds": float(row["median_seconds"]),
                })
    change = manual_dir / "usability_change.txt"
    if change.exists():
        out["change"] = change.read_text(encoding="utf-8").strip()
    return out
