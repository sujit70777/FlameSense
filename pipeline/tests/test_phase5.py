"""Tests for Phase 5: train.py, export.py, evaluate.py, support.py (fixture data only)."""

from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np
import pytest

from flamesense import train
from flamesense.evaluate import evaluate_all
from flamesense.export import eval_tree_model, export_all, round_sig
from flamesense.support import build_support_index, support_level
from tests.fixtures.fixture_synthetic import fixture_synthetic_runs


@pytest.fixture(scope="module")
def exported(tmp_path_factory: pytest.TempPathFactory) -> tuple[Path, Path, dict]:
    """Train and export once on synthetic fixture rows."""
    root = tmp_path_factory.mktemp("phase5")
    df = fixture_synthetic_runs()
    summaries = train.train_all(df, root / "artifacts")
    export_all(df, root / "artifacts", root / "out")
    return root / "artifacts", root / "out", summaries


def load(out: Path, name: str) -> dict:
    """Read one exported JSON file."""
    return json.loads((out / name).read_text())


def test_both_tasks_train_on_fixture(exported) -> None:
    """Synthetic data has enough rows and classes for both tasks."""
    _, _, summaries = exported
    assert summaries["sustain"]["available"]
    assert summaries["spread"]["available"]
    assert summaries["sustain"]["cv"] == "GroupKFold(5)"


def test_parity_python_eval_matches_lightgbm(exported) -> None:
    """Pure-Python evaluator equals LightGBM predict within 1e-9 for every model."""
    _, out, _ = exported
    parity = load(out, "parity_fixtures.json")
    assert set(parity) == {"model_sustain.json", "model_spread_q10.json",
                           "model_spread_q50.json", "model_spread_q90.json"}
    for file_name, rows in parity.items():
        model = load(out, file_name)
        assert len(rows) == 60
        for row in rows:
            raw, value = eval_tree_model(model, row["x"])
            assert abs(raw - row["raw"]) < 1e-9
            assert abs(value - row["out"]) < 1e-9


def test_feature_spec_order_is_model_order(exported) -> None:
    """feature_spec features list matches each model's feature_names."""
    _, out, _ = exported
    spec = load(out, "feature_spec.json")
    for task, files in {"sustain": ["model_sustain.json"],
                        "spread": ["model_spread_q50.json"]}.items():
        names = [f["name"] for f in spec["tasks"][task]["features"]]
        for f in files:
            assert load(out, f)["feature_names"] == names
    derived = [f for f in spec["tasks"]["sustain"]["features"] if f["input"] == "derived"]
    assert {f["name"] for f in derived} >= {"log10_flow", "log10_gravity", "o2_partial_kpa"}


def test_slider_ranges_padded_and_clamped(exported) -> None:
    """O₂ slider = training range ± 10%, clamped to 0.10–0.50."""
    _, out, _ = exported
    o2 = load(out, "feature_spec.json")["inputs"]["o2_mole_fraction"]
    span = o2["train_max"] - o2["train_min"]
    assert o2["min"] == pytest.approx(max(0.10, o2["train_min"] - 0.1 * span), rel=1e-5)
    assert o2["max"] == pytest.approx(min(0.50, o2["train_max"] + 0.1 * span), rel=1e-5)
    gravity = load(out, "feature_spec.json")["inputs"]["gravity_g"]
    assert (gravity["min"], gravity["max"]) == (1e-6, 1.0)


def test_metrics_have_no_nan(exported) -> None:
    """metrics.json values are finite and within their ranges."""
    artifacts, _, _ = exported
    metrics = evaluate_all(fixture_synthetic_runs(), artifacts)
    assert 0.0 <= metrics["sustain"]["roc_auc"] <= 1.0
    assert 0.0 <= metrics["spread"]["interval_80_coverage"] <= 1.0
    assert metrics["spread"]["physics_mae_mm_s"] is None  # params not signed off
    for bin_ in metrics["sustain"]["calibration_bins"]:
        assert all(math.isfinite(v) for v in bin_)


def test_runs_json_counts_and_meta(exported) -> None:
    """runs.json rows equal app_meta n_runs; floats rounded to 6 significant digits."""
    _, out, _ = exported
    runs, meta = load(out, "runs.json"), load(out, "app_meta.json")
    assert len(runs["rows"]) == meta["n_runs"] == 160
    o2_idx = runs["columns"].index("o2_mole_fraction")
    value = runs["rows"][0][o2_idx]
    assert value == round_sig(value)
    assert meta["experiments"] == ["FIXTURE_A", "FIXTURE_B"]


def test_unavailable_below_threshold(tmp_path: Path) -> None:
    """Fewer than 40 rows → both tasks unavailable with a reason; model files are placeholders."""
    df = fixture_synthetic_runs(n=39)
    summaries = train.train_all(df, tmp_path / "a")
    export_all(df, tmp_path / "a", tmp_path / "o")
    assert not summaries["sustain"]["available"]
    assert "40" in summaries["spread"]["reason"]
    assert load(tmp_path / "o", "model_sustain.json")["trees"] == []
    assert load(tmp_path / "o", "feature_spec.json")["tasks"]["sustain"]["available"] is False


def test_few_groups_falls_back_with_warning() -> None:
    """With < 3 groups, StratifiedKFold(5) is used and the warning is recorded."""
    td = train.prepare_task(fixture_synthetic_runs(n_groups=2), "sustain")
    _, cv_name, warnings = train.make_folds(td)
    assert cv_name == "StratifiedKFold(5)"
    assert warnings == [train.FEW_GROUPS_WARNING]


def test_class_balance_threshold() -> None:
    """Sustain needs at least 8 rows of each class."""
    y = np.array([1] * 45 + [0] * 7)
    assert "Class balance" in train.availability_reason("sustain", y)
    assert train.availability_reason("spread", y) is None


def test_suspect_rows_excluded_from_training() -> None:
    """quality_flag='suspect' rows never reach a task."""
    df = fixture_synthetic_runs()
    df.loc[:9, "quality_flag"] = "suspect"
    td = train.prepare_task(df, "sustain")
    assert len(td.y) == 150


def test_monotone_zero_until_confirmed() -> None:
    """Constraint signs stay 0 until the lead confirms them (Q-2)."""
    assert train.MONOTONE_CONFIRMED_BY_LEAD is False
    assert train.monotone_vector(["o2_mole_fraction", "pressure_kpa"], "sustain") == [0, 0]


def test_support_levels() -> None:
    """A training row is high support; a far point is low."""
    td = train.prepare_task(fixture_synthetic_runs(), "sustain")
    index = build_support_index(td.rows, td.features, True)
    names = index["feature_names"]
    row = td.rows.iloc[0][names].astype(float).tolist()
    assert support_level(index, row)[0] == "high"
    far = [v + 100 * s for v, s in zip(row, index["std"])]
    assert support_level(index, far)[0] == "low"
    assert index["p50"] <= index["p95"]
