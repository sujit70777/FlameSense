"""Tests for canonical schema validation rules."""

from pathlib import Path

import pandas as pd

from flamesense.schema import validate

FIXTURE_PATH = Path(__file__).parent / "fixtures" / "fixture_runs.csv"


def load_fixture() -> pd.DataFrame:
    """Load the clean 5-row test fixture."""
    return pd.read_csv(FIXTURE_PATH)


def test_valid_fixture_passes() -> None:
    """Verify clean fixture rows pass schema validation without errors."""
    df = load_fixture()
    errors = validate(df)
    assert errors == [], f"Expected 0 errors on clean fixture, got: {errors}"


def test_missing_required_column() -> None:
    """Verify missing canonical columns trigger an error."""
    df = load_fixture().drop(columns=["run_id"])
    errors = validate(df)
    assert len(errors) == 1
    assert "Missing canonical columns" in errors[0]
    assert "run_id" in errors[0]


def test_null_in_required_column() -> None:
    """Verify null in required columns triggers an error."""
    df = load_fixture()
    df.loc[0, "fuel_name"] = None
    errors = validate(df)
    assert any("Required column 'fuel_name' has 1 null value(s)" in e for e in errors)


def test_enum_violation() -> None:
    """Verify invalid enum value triggers an error."""
    df = load_fixture()
    df.loc[0, "platform"] = "outer_space"
    errors = validate(df)
    assert any("Column 'platform' has 1 enum violation(s)" in e for e in errors)

    df2 = load_fixture()
    df2.loc[1, "quality_flag"] = "unverified"
    errors2 = validate(df2)
    assert any("Column 'quality_flag' has 1 enum violation(s)" in e for e in errors2)


def test_o2_range_validation() -> None:
    """Verify o2_mole_fraction outside (0, 1] triggers error."""
    df = load_fixture()
    df.loc[0, "o2_mole_fraction"] = 0.0
    errors = validate(df)
    assert any("'o2_mole_fraction' has 1 value(s) outside (0, 1]" in e for e in errors)

    df2 = load_fixture()
    df2.loc[0, "o2_mole_fraction"] = 1.05
    errors2 = validate(df2)
    assert any("'o2_mole_fraction' has 1 value(s) outside (0, 1]" in e for e in errors2)


def test_pressure_range_validation() -> None:
    """Verify pressure_kpa outside (0, 1000] triggers error."""
    df = load_fixture()
    df.loc[0, "pressure_kpa"] = -5.0
    errors = validate(df)
    assert any("'pressure_kpa' has 1 value(s) outside (0, 1000]" in e for e in errors)

    df2 = load_fixture()
    df2.loc[0, "pressure_kpa"] = 1200.0
    errors2 = validate(df2)
    assert any("'pressure_kpa' has 1 value(s) outside (0, 1000]" in e for e in errors2)


def test_gravity_range_validation() -> None:
    """Verify gravity_g outside (0, 1.5] triggers error."""
    df = load_fixture()
    df.loc[0, "gravity_g"] = 0.0
    errors = validate(df)
    assert any("'gravity_g' has 1 value(s) outside (0, 1.5]" in e for e in errors)

    df2 = load_fixture()
    df2.loc[0, "gravity_g"] = 2.0
    errors2 = validate(df2)
    assert any("'gravity_g' has 1 value(s) outside (0, 1.5]" in e for e in errors2)


def test_negative_rates() -> None:
    """Verify negative flame spread rate or burning rate triggers error."""
    df = load_fixture()
    df.loc[0, "flame_spread_rate_mm_s"] = -1.2
    errors = validate(df)
    assert any("'flame_spread_rate_mm_s' has 1 negative value(s)" in e for e in errors)

    df2 = load_fixture()
    df2.loc[2, "burning_rate_k_mm2_s"] = -0.5
    errors2 = validate(df2)
    assert any("'burning_rate_k_mm2_s' has 1 negative value(s)" in e for e in errors2)


def test_duplicate_run_id() -> None:
    """Verify duplicate run_id triggers error."""
    df = load_fixture()
    df.loc[1, "run_id"] = df.loc[0, "run_id"]
    errors = validate(df)
    assert any("'run_id' has 2 duplicate value(s)" in e for e in errors)


def test_empty_source_citation() -> None:
    """Verify empty or whitespace source citation triggers error."""
    df = load_fixture()
    df.loc[0, "source_citation"] = "   "
    errors = validate(df)
    assert any("'source_citation' has 1 empty value(s)" in e for e in errors)
