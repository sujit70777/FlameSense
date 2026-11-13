"""Tests for the app_meta.json single source of truth (PLAN.md §1.0 "Counts")."""

from pathlib import Path

import pandas as pd
import pytest

from flamesense.clean import clean
from flamesense.export import (
    authorship,
    build_app_meta,
    build_runs_json,
    load_dropped_rows,
    model_use_counts,
)
from flamesense.report import key_facts, provenance_section
from flamesense.train import TASKS, prepare_task
from tests.fixtures.fixture_synthetic import fixture_synthetic_runs

FIXTURE_PATH = Path(__file__).parent / "fixtures" / "fixture_runs.csv"
MOON = {"missionId": "fixture_moon", "o2_mole_fraction": 0.34, "pressure_kpa": 56.5,
        "gravity_g": 0.1654}


def _meta(df: pd.DataFrame, dropped: list[dict] | None = None, moon: dict | None = MOON) -> dict:
    """app_meta for fixture rows (fixtures are unlabelled third-party, so not strict)."""
    tasks = {t: prepare_task(df, t) for t in TASKS}
    return build_app_meta(df, build_runs_json(df), tasks, dropped, moon, strict_authorship=False)


def test_every_breakdown_sums_to_n_runs() -> None:
    """source_type, gravity, experiment, exclusive model use and sources all sum to n_runs."""
    df = fixture_synthetic_runs()
    meta = _meta(df)
    n = meta["n_runs"]
    assert n == len(df)
    assert sum(meta["source_type"].values()) == n
    assert sum(meta["gravity_class"].values()) == n
    assert sum(meta["experiment"].values()) == n
    mu = meta["model_use"]
    assert mu["sustain_only"] + mu["spread_only"] + mu["both"] + mu["neither"] == n
    assert mu["sustain"] == mu["sustain_only"] + mu["both"]
    assert sum(s["n_runs"] for s in meta["sources"]) == n


def test_experiment_counts_use_the_experiment_names() -> None:
    """Experiment count keys equal the experiment list (no lowercasing)."""
    meta = _meta(fixture_synthetic_runs())
    assert sorted(meta["experiment"]) == meta["experiments"]


def test_unknown_source_type_is_not_silently_uncounted() -> None:
    """A source_type outside the four allowed values makes export fail."""
    df = fixture_synthetic_runs()
    df.loc[0, "source_type"] = "blog"
    with pytest.raises(ValueError, match="do not sum"):
        _meta(df)


def test_authorship_labels_sharma_as_nasa_coauthored() -> None:
    """Sharma 2024 is 'NASA co-authored'; Takahashi 2026 is independent (PLAN.md §1.0)."""
    assert authorship("third_party", "https://doi.org/10.1007/s12217-024-10106-y") == "nasa_coauthored"
    assert authorship("third_party", "https://doi.org/10.1016/j.proci.2026.106097") == "independent"
    assert authorship("nasa_report", "") == "nasa"


def test_unlabelled_third_party_source_fails_strict_export() -> None:
    """A new third-party paper without an authorship label is refused."""
    with pytest.raises(ValueError, match="THIRD_PARTY_AUTHORSHIP"):
        authorship("third_party", "https://example.org/new-paper")
    assert authorship("third_party", "https://example.org/new-paper", strict=False) == "unlabelled"


def test_dropped_rows_are_logged_and_counted(tmp_path: Path) -> None:
    """Duplicates dropped by clean are logged and reach app_meta and the report."""
    raw = pd.read_csv(FIXTURE_PATH)
    dup = raw.iloc[[0]].copy()
    dup["run_id"] = "fixture:dup_of_1"
    _out, stats = clean(pd.concat([raw, dup], ignore_index=True), flag_suspect=False)
    assert stats["dropped_rows"] == [{
        "run_id": "fixture:dup_of_1", "kept_run_id": "fixture:run_1",
        "source_id": "fixture_source", "reason": stats["dropped_rows"][0]["reason"],
    }]
    log = tmp_path / "dropped_rows.csv"
    pd.DataFrame(stats["dropped_rows"]).to_csv(log, index=False)
    dropped = load_dropped_rows(log)
    df = fixture_synthetic_runs()
    dropped = [{**dropped[0], "kept_run_id": df["run_id"].iloc[0]}]
    meta = _meta(df, dropped)
    assert meta["rows_ingested"] == len(df) + 1
    assert meta["rows_dropped"] == 1
    assert sum(s["n_dropped_duplicates"] for s in meta["sources"]) == 1
    assert any("fixture:dup_of_1" in line for line in provenance_section(meta))


def test_stale_drop_log_is_refused() -> None:
    """A drop log naming a kept row that is not in the data is an error."""
    bad = [{"run_id": "x", "kept_run_id": "not-in-data", "source_id": "s", "reason": "r"}]
    with pytest.raises(ValueError, match="stale"):
        _meta(fixture_synthetic_runs(), bad)


def test_model_use_buckets_are_exclusive() -> None:
    """A run used by both models is counted once in 'both', not again in *_only."""
    df = pd.DataFrame({"run_id": ["a", "b", "c", "d"]})

    class T:  # minimal TaskData stand-in
        def __init__(self, ids: list[str]) -> None:
            self.rows = pd.DataFrame({"run_id": ids})

    mu = model_use_counts(df, {"sustain": T(["a", "b"]), "spread": T(["b", "c"])})
    assert mu == {"sustain": 2, "spread": 2, "sustain_only": 1, "spread_only": 1,
                  "both": 1, "neither": 1}


def test_moon_base_outside_when_gravity_untested() -> None:
    """Lunar gravity outside the sustain rows' gravity range puts every material outside."""
    df = fixture_synthetic_runs()  # gravity is 1e-6 or 1.0, O2 0.15-0.40
    home = _meta(df)["home"]
    assert home["moonBase"]["missionId"] == "fixture_moon"
    if home["materialsOutsideMoonBase"]:
        assert home["moonBase"]["outsideInputs"]
    tasks = {t: prepare_task(df, t) for t in TASKS}
    micro = df[df["gravity_g"] < 0.01].reset_index(drop=True)
    tasks_micro = {t: prepare_task(micro, t) for t in TASKS}
    home_micro = build_app_meta(micro, build_runs_json(micro), tasks_micro, None, MOON,
                                strict_authorship=False)["home"]
    assert "gravity_g" in home_micro["moonBase"]["outsideInputs"]
    assert home_micro["materialsOutsideMoonBase"] == home_micro["materialsTotal"]
    assert tasks  # full set built without error


def test_gaps_carry_ids_and_numbers_not_copy() -> None:
    """Gaps are ids + computed params; no English copy is baked into the JSON."""
    gaps = _meta(fixture_synthetic_runs())["home"]["topGaps"]
    assert {g["id"] for g in gaps} == {"high_o2_solids", "partial_gravity", "earth_baseline"}
    assert [g["rank"] for g in gaps] == [1, 2, 3]
    assert all("title" not in g and "sentence" not in g for g in gaps)
    assert all(0.0 <= g["score"] <= 1.0 for g in gaps)


def test_report_key_facts_read_counts_from_meta() -> None:
    """Report facts use app_meta counts and call fuel names 'materials'."""
    df = fixture_synthetic_runs()
    meta = _meta(df)
    facts = key_facts(df, meta)
    assert facts[0].startswith(f"{meta['n_runs']} runs (")
    assert f"across {meta['n_fuels']} materials" in facts[0]
    assert f"{meta['gravity_class']['microgravity']} runs in microgravity" in facts[1]
