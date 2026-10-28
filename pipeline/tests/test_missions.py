"""Tests for missions.json validation (Phase 11B)."""

import json
from pathlib import Path

import pytest

from flamesense.missions import export_missions, validate_missions


def fixture_missions() -> dict:
    """A small missions file with FIXTURE values (not NASA numbers)."""
    return {
        "version": "1",
        "missions": [
            {"id": "a", "name_key": "missionIss", "gravity_g": 1e-6, "pressure_kpa": 100.0,
             "o2": 0.2, "source": "FIXTURE"},
            {"id": "b", "name_key": "missionEarth", "gravity_g": 1.0, "pressure_kpa": 100.0,
             "o2": 0.2, "source": ""},
        ],
        "planned_experiments": [
            {"id": "p", "mission_id": "a", "points": [{"o2": 0.25, "pressure_kpa": 50}],
             "source": ""},
        ],
        "airflow_sweep_mm_s": {"min": 0, "max": None, "n": 24},
    }


def test_valid_file_reports_unsourced_as_warnings() -> None:
    """Unsourced entries are warnings (hidden in release), not errors."""
    errors, warnings = validate_missions(fixture_missions())
    assert errors == []
    assert any("mission b" in w for w in warnings)
    assert any("planned p" in w for w in warnings)


def test_missing_numbers_and_bad_ranges_are_errors() -> None:
    """Required numbers and physical ranges are enforced."""
    data = fixture_missions()
    data["missions"][0]["o2"] = None
    data["missions"][1]["o2"] = 34
    data["planned_experiments"][0]["mission_id"] = "zzz"
    errors, _ = validate_missions(data)
    assert len(errors) == 3


def test_export_copies_and_raises_on_invalid(tmp_path: Path) -> None:
    """Valid files are copied; invalid ones stop the export."""
    src = tmp_path / "missions.json"
    src.write_text(json.dumps(fixture_missions()))
    (tmp_path / "out").mkdir()
    export_missions(src, tmp_path / "out")
    assert (tmp_path / "out" / "missions.json").exists()
    bad = fixture_missions()
    bad["airflow_sweep_mm_s"]["n"] = 1
    src.write_text(json.dumps(bad))
    with pytest.raises(ValueError):
        export_missions(src, tmp_path / "out")


def test_shipped_template_has_no_sources() -> None:
    """The committed template carries no invented sources and no FM2 points."""
    path = Path(__file__).resolve().parents[2] / "data" / "manual" / "missions.json"
    data = json.loads(path.read_text())
    errors, _ = validate_missions(data)
    assert errors == []
    assert all(m["source"] == "" for m in data["missions"])
    assert data["planned_experiments"][0]["points"] == []
