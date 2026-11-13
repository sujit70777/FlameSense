"""Phase 3C: coverage atlas built from fixture PSI investigations."""

from pathlib import Path

import pandas as pd
import pytest

from flamesense.catalog import O2_BANDS, P_BANDS, band, build_catalog, numbers, write_coverage

FIX = Path(__file__).parent / "fixtures" / "fixture_psi"


@pytest.fixture()
def cat(tmp_path: Path) -> dict:
    """Atlas of the three fixture investigations with no processed runs."""
    return build_catalog(FIX, tmp_path / "missing.parquet")


def by_id(cat: dict) -> dict:
    """Investigation records keyed by PSI id."""
    return {r["psi_id"]: r for r in cat["investigations"]}


def test_counts_and_placement(cat: dict) -> None:
    """Rows, matrix placements and skipped implausible values match the hand count."""
    a, b, c = (by_id(cat)[k] for k in ("PSI-1", "PSI-2", "PSI-3"))
    assert (a["n_rows"], a["rows_in_matrix"], a["implausible_values_skipped"]) == (4, 3, 1)
    assert (b["n_rows"], b["rows_in_matrix"]) == (2, 0)  # note row dropped, no pressure
    assert c["n_rows"] == 0 and c["tables"] == []
    assert cat["totals"] == {"investigations": 3, "rows": 6, "rows_in_matrix": 3}


def test_matrix_cells(cat: dict) -> None:
    """760 mmHg = 101.3 kPa and 380 mmHg = 50.7 kPa land in the right bands."""
    cells = {(m["gravity_class"], m["o2_band"], m["pressure_band"]): m["n_runs"]
             for m in cat["matrix"]}
    assert len(cells) == 3 * 5 * 3
    assert cells[("microgravity", "18-24", "70-110")] == 1
    assert cells[("microgravity", "<18", "70-110")] == 1
    assert cells[("microgravity", "30-36", "<70")] == 1
    assert sum(cells.values()) == 3
    assert all(v == 0 for (g, _, _), v in cells.items() if g == "moon_mars")


def test_detected_quantities(cat: dict) -> None:
    """Outcome, rate columns, ranges, fuel classes and gravity class come from the files."""
    a, b, c = (by_id(cat)[k] for k in ("PSI-1", "PSI-2", "PSI-3"))
    assert a["has_outcome"] and a["has_burning_rate"] and not a["has_spread_rate"]
    assert a["o2_range"] == [15.0, 30.0] and a["pressure_range"] == [50.66, 101.32]
    assert a["fuel_classes"] == ["droplet"] and a["years"] == "2010-2012"
    assert b["has_spread_rate"] and not b["has_outcome"] and b["fuel_classes"] == ["solid"]
    assert b["o2_range"] == [21.5, 21.5] and b["pressure_range"] is None
    assert b["gravity_class"] == "microgravity" and c["gravity_class"] == "earth"


def test_why_not_used_is_factual(cat: dict) -> None:
    """Reasons come only from what the files show."""
    a, b, c = (by_id(cat)[k] for k in ("PSI-1", "PSI-2", "PSI-3"))
    assert not a["used_in_models"]
    # PSI-1 has an outcome column but burns droplets; the models are solid-only.
    assert a["why_not_used"] == "droplet fuel; the models cover solid materials only"
    assert "no pressure column" in b["why_not_used"]
    assert c["why_not_used"] == "PSI lists no experimental table for this investigation"


def test_used_in_models_from_processed_runs(tmp_path: Path) -> None:
    """An investigation is 'used' once its experiment appears in the processed runs."""
    processed = tmp_path / "runs.parquet"
    pd.DataFrame({"experiment": ["FIXA"]}).to_parquet(processed)
    a = by_id(build_catalog(FIX, processed))["PSI-1"]
    assert a["used_in_models"] and a["why_not_used"] == ""


def test_helpers_and_write(tmp_path: Path) -> None:
    """Number parsing, banding edges and the JSON writer."""
    assert numbers("21; 26.5; 40") == [21.0, 26.5, 40.0]
    assert band(18.0, O2_BANDS) == "18-24" and band(17.99, O2_BANDS) == "<18"
    assert band(110.0, P_BANDS) == ">110"
    out = tmp_path / "coverage.json"
    write_coverage(FIX, tmp_path / "none.parquet", out)
    assert out.exists() and '"PSI-2"' in out.read_text()
