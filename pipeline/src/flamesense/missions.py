"""Validation and export of data/manual/missions.json (PLAN.md §3.10, Phase 11B).

The lead fills every value from a cited NASA source; this module never adds one.
Entries with an empty `source` are exported but hidden by the app in release builds.
"""

from __future__ import annotations

import json
from pathlib import Path

REQUIRED_MISSION = ("id", "name_key", "gravity_g", "pressure_kpa", "o2")


def validate_missions(data: dict) -> tuple[list[str], list[str]]:
    """Return (errors, release_warnings). Errors block export; warnings mean 'hidden in release'."""
    errors: list[str] = []
    warnings: list[str] = []
    for m in data.get("missions", []):
        mid = m.get("id", "?")
        for key in REQUIRED_MISSION:
            if m.get(key) is None:
                errors.append(f"mission {mid}: '{key}' is missing")
        o2, p, g = m.get("o2"), m.get("pressure_kpa"), m.get("gravity_g")
        if isinstance(o2, (int, float)) and not 0 < o2 <= 1:
            errors.append(f"mission {mid}: o2 must be a fraction in (0, 1]")
        if isinstance(p, (int, float)) and not 0 < p <= 1000:
            errors.append(f"mission {mid}: pressure_kpa out of range")
        if isinstance(g, (int, float)) and not 0 < g <= 1.5:
            errors.append(f"mission {mid}: gravity_g out of range")
        if not str(m.get("source") or "").strip():
            warnings.append(f"mission {mid}: no source (hidden in release)")
    ids = {m.get("id") for m in data.get("missions", [])}
    for e in data.get("planned_experiments", []):
        eid = e.get("id", "?")
        if e.get("mission_id") not in ids:
            errors.append(f"planned {eid}: unknown mission_id {e.get('mission_id')!r}")
        for pt in e.get("points", []):
            if pt.get("o2") is None or pt.get("pressure_kpa") is None:
                errors.append(f"planned {eid}: every point needs o2 and pressure_kpa")
        if not str(e.get("source") or "").strip():
            warnings.append(f"planned {eid}: no source (hidden in release)")
    sweep = data.get("airflow_sweep_mm_s") or {}
    if not isinstance(sweep.get("n"), int) or sweep["n"] < 2:
        errors.append("airflow_sweep_mm_s.n must be an integer ≥ 2")
    return errors, warnings


def export_missions(src: Path, out_dir: Path) -> list[str]:
    """Validate and copy missions.json to the app assets; returns release warnings."""
    if not src.exists():
        return ["data/manual/missions.json is missing; the Missions page shows its empty state"]
    data = json.loads(src.read_text(encoding="utf-8"))
    errors, warnings = validate_missions(data)
    if errors:
        raise ValueError("missions.json invalid: " + "; ".join(errors))
    (out_dir / "missions.json").write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    return warnings
