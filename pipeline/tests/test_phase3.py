"""Tests for Phase 3: clean.py, features.py and report.py."""

from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from flamesense.clean import clean, flag_suspect_rows
from flamesense.features import add_features
from flamesense.report import generate_report

FIXTURE_PATH = Path(__file__).parent / "fixtures" / "fixture_runs.csv"


def load_fixture() -> pd.DataFrame:
    """Load the 5-row test fixture."""
    return pd.read_csv(FIXTURE_PATH)


# --- clean.py -------------------------------------------------------------


def test_clean_strips_whitespace_and_lowercases_enums() -> None:
    """String whitespace is stripped and enum columns lowercase-normalised."""
    df = load_fixture().copy()
    df["fuel_name"] = "  PMMA  "
    df["platform"] = "ISS"
    df["fuel_class"] = "thin_solid"
    df["quality_flag"] = "OK"
    out, stats = clean(df, drop_duplicates=False, flag_suspect=False)
    assert out.loc[0, "fuel_name"] == "PMMA"
    assert out.loc[0, "platform"] == "iss"
    assert out.loc[0, "quality_flag"] == "ok"
    assert stats["dropped"] == 0
    assert stats["suspect"] == 0


def test_clean_drops_exact_duplicates_keeping_first() -> None:
    """Rows identical on the duplicate key are dropped, keeping the first."""
    df = load_fixture().copy()
    first = df.iloc[[0]].copy()
    dup = first.copy()
    dup["run_id"] = "fixture:duplicate_of_run_1"
    dup["notes"] = "a duplicate measurement"
    df = pd.concat([df, dup], ignore_index=True)

    out, stats = clean(df, flag_suspect=False)
    assert stats["dropped"] == 1
    assert len(out) == len(df) - 1
    assert "fixture:duplicate_of_run_1" not in out["run_id"].values
    # The kept row is the first occurrence.
    assert out["run_id"].iloc[0] == "fixture:run_1"


def test_clean_keeps_near_duplicates_with_different_key_values() -> None:
    """Rows differing on a key column (e.g. O2) are not dropped."""
    df = load_fixture().copy()
    near = df.iloc[[0]].copy()
    near["run_id"] = "fixture:near_duplicate"
    near["o2_mole_fraction"] = 0.22
    df = pd.concat([df, near], ignore_index=True)

    out, stats = clean(df, flag_suspect=False)
    assert stats["dropped"] == 0
    assert len(out) == len(df)


def test_flag_suspect_rows_marks_statistical_outliers() -> None:
    """A spread rate above the 99.5th percentile × 3 is flagged, not dropped."""
    rows = []
    for i in range(500):
        rows.append(
            {
                "run_id": f"fixture:base_{i}",
                "group_id": "fixture:series_x",
                "experiment": "BASS",
                "platform": "iss",
                "gravity_g": 1e-6,
                "fuel_name": f"fuel_{i}",
                "fuel_class": "thin_solid",
                "o2_mole_fraction": 0.21,
                "pressure_kpa": 101.325,
                "diluent": "n2",
                "flow_velocity_mm_s": 50.0,
                "flow_direction": "opposed",
                "ignited": True,
                "sustained": True,
                "flame_spread_rate_mm_s": 1.0,
                "source_id": "fixture_source",
                "source_file": "fixture",
                "source_citation": f"Fixture citation {i}",
                "quality_flag": "ok",
            }
        )
    rows.append(
        {
            **rows[0],
            "run_id": "fixture:outlier",
            "fuel_name": "outlier_fuel",
            "flame_spread_rate_mm_s": 5000.0,
        }
    )
    df = pd.DataFrame(rows)
    out = flag_suspect_rows(df)
    assert out.loc[out["run_id"] == "fixture:outlier", "quality_flag"].iloc[0] == "suspect"
    assert sum(out["quality_flag"] == "suspect") == 1
    assert len(out) == len(df)  # flagged, never deleted


# --- features.py -----------------------------------------------------------


def test_features_derived_formulas_hand_computed() -> None:
    """Each derived column matches the §3.1 formula on hand-computed rows."""
    df = load_fixture()
    out = add_features(df)

    # run_1: gravity 1e-6 → log10(1e-6) = -6
    assert out.loc[0, "log10_gravity"] == pytest.approx(-6.0)
    # o2_partial = 0.21 × 101.325
    assert out.loc[0, "o2_partial_kpa"] == pytest.approx(0.21 * 101.325)
    # log10(50 + 1)
    assert out.loc[0, "log10_flow"] == pytest.approx(np.log10(51.0))
    # areal_density = 0.1/1000 × 1190
    assert out.loc[0, "areal_density_kg_m2"] == pytest.approx(0.1 / 1000.0 * 1190.0)

    # run_2: log10(61) and 0.2/1000 × 1380
    assert out.loc[1, "log10_flow"] == pytest.approx(np.log10(61.0))
    assert out.loc[1, "areal_density_kg_m2"] == pytest.approx(0.2 / 1000.0 * 1380.0)

    # run_3: quiescent (flow 0) → log10(1) = 0; droplet has no thickness/density → NaN
    assert out.loc[2, "log10_flow"] == pytest.approx(0.0)
    assert np.isnan(out.loc[2, "areal_density_kg_m2"])

    # run_4: ground gravity 1.0 → log10(1) = 0; log10(101); 5.0/1000 × 1190
    assert out.loc[3, "log10_gravity"] == pytest.approx(0.0)
    assert out.loc[3, "log10_flow"] == pytest.approx(np.log10(101.0))
    assert out.loc[3, "areal_density_kg_m2"] == pytest.approx(5.0 / 1000.0 * 1190.0)

    # run_5: o2 0.30 × pressure 85 = 25.5; log10(31); 0.15/1000 × 1500
    assert out.loc[4, "o2_partial_kpa"] == pytest.approx(0.30 * 85.0)
    assert out.loc[4, "log10_flow"] == pytest.approx(np.log10(31.0))
    assert out.loc[4, "areal_density_kg_m2"] == pytest.approx(0.15 / 1000.0 * 1500.0)


def test_features_clamps_gravity_at_1e_7() -> None:
    """gravity_g below 1e-7 is clamped before log10 (formula max(_, 1e-7))."""
    df = load_fixture().copy()
    df.loc[0, "gravity_g"] = 1e-9
    out = add_features(df)
    assert out.loc[0, "log10_gravity"] == pytest.approx(np.log10(1e-7))


def test_features_one_hot_only_present_values() -> None:
    """One-hot columns exist only for values actually present in the data."""
    df = load_fixture()
    out = add_features(df)

    for col in ["fuel_class__thin_solid", "fuel_class__droplet", "fuel_class__thick_solid"]:
        assert col in out.columns
    assert "fuel_class__gas_jet" not in out.columns
    assert "fuel_class__other" not in out.columns

    for col in ["flow_direction__opposed", "flow_direction__quiescent", "flow_direction__concurrent"]:
        assert col in out.columns
    assert "flow_direction__other" not in out.columns

    assert "diluent__n2" in out.columns
    assert "diluent__he" not in out.columns

    # run_1 is thin_solid + opposed + n2.
    assert out.loc[0, "fuel_class__thin_solid"] == 1
    assert out.loc[0, "fuel_class__droplet"] == 0
    assert out.loc[0, "flow_direction__opposed"] == 1
    assert out.loc[0, "diluent__n2"] == 1
    # run_3 is a droplet.
    assert out.loc[2, "fuel_class__droplet"] == 1
    assert out.loc[2, "fuel_class__thin_solid"] == 0


def test_features_expected_column_count() -> None:
    """25 canonical + 4 derived + 3+3+1 one-hot columns on the fixture."""
    df = load_fixture()
    out = add_features(df)
    assert len(out.columns) == 25 + 4 + 3 + 3 + 1


# --- report.py -------------------------------------------------------------


def test_report_writes_markdown_and_five_charts(tmp_path: Path) -> None:
    """generate_report writes DATA_REPORT.md and all five chart PNGs."""
    df = add_features(load_fixture())
    md = generate_report(df, tmp_path / "DATA_REPORT.md", tmp_path / "img")
    text = md.read_text(encoding="utf-8")

    assert "Key data facts" in text
    assert "Total runs" in text
    assert "Runs per experiment" in text
    assert "pct" not in text  # no placeholder junk

    chart_names = [
        "chart_runs_per_experiment.png",
        "chart_spread_vs_o2.png",
        "chart_sustained_vs_flow.png",
        "chart_o2_flow.png",
        "chart_pressure.png",
    ]
    for name in chart_names:
        assert (tmp_path / "img" / name).exists()
        assert (tmp_path / "img" / name).stat().st_size > 0


def test_report_handles_empty_data(tmp_path: Path) -> None:
    """An empty frame still yields readable markdown and valid PNGs."""
    empty = pd.DataFrame(columns=pd.read_csv(FIXTURE_PATH).columns)
    md = generate_report(empty, tmp_path / "DATA_REPORT.md", tmp_path / "img")
    text = md.read_text(encoding="utf-8")
    assert "0 runs" in text
    assert "No data." in text
    assert (tmp_path / "img" / "chart_runs_per_experiment.png").exists()