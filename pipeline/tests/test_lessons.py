"""Tests for lessons/usability conversion (fixture text only, no lesson science)."""

from pathlib import Path

from flamesense.lessons import build_usability, parse_lessons

DRAFT = """# Lessons draft

## L1
status: approved
icon: air
title_en: FIXTURE title
title_bn: FIXTURE শিরোনাম
space_finding_en: FIXTURE finding
source: FIXTURE source | https://example.test/a
reviewed_by: LEAD
reviewed_on: 2026-11-12

## L2
status: approved
title_en: FIXTURE without a source stays draft
reviewed_by: LEAD

## L3
status: draft
title_en: FIXTURE draft
"""


def test_parse_lessons_keeps_only_reviewed_sourced_lessons_approved() -> None:
    """Approved needs a reviewer and a source URL; everything else stays draft."""
    lessons = parse_lessons(DRAFT)
    assert [lesson["id"] for lesson in lessons] == ["L1", "L2", "L3"]
    assert [lesson["status"] for lesson in lessons] == ["approved", "draft", "draft"]
    assert lessons[0]["sources"] == [{"label": "FIXTURE source", "url": "https://example.test/a"}]
    assert lessons[0]["title_bn"] == "FIXTURE শিরোনাম"


def test_usability_csv(tmp_path: Path) -> None:
    """usability.csv rows become tasks; missing file → no tasks."""
    assert build_usability(tmp_path)["tasks"] == []
    (tmp_path / "usability.csv").write_text("task_en,task_bn,completed,total,median_seconds\nFind a run,,5,5,42\n")
    u = build_usability(tmp_path)
    assert u["tasks"][0] == {"task_en": "Find a run", "task_bn": "Find a run", "completed": 5, "total": 5,
                             "median_seconds": 42.0}
