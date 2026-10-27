"""Out-of-fold evaluation → metrics.json, MODEL_CARD.md and charts (PLAN.md §3.6, Phase 5)."""

from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import brier_score_loss, r2_score, roc_auc_score

from flamesense.physics import applicability, load_params, spread_rate_mm_s, validate_params
from flamesense.train import coerce_types

# DESIGN.md §10 light-theme chart colours (docs images use the light theme).
COLOR_MICROG = "#1F66D6"
COLOR_EMBER = "#D9560B"
COLOR_AXIS = "#5E6C85"


def sigmoid(z: np.ndarray) -> np.ndarray:
    """Logistic function."""
    return 1.0 / (1.0 + np.exp(-z))


def calibration_bins(p: np.ndarray, y: np.ndarray, n_bins: int = 10) -> list[list[float]]:
    """10 equal-width bins of predicted probability: [pred_mean, obs_rate, count]."""
    bins = []
    edges = np.linspace(0, 1, n_bins + 1)
    for i in range(n_bins):
        upper = p <= edges[i + 1] if i == n_bins - 1 else p < edges[i + 1]
        mask = (p >= edges[i]) & upper
        if mask.any():
            bins.append([float(p[mask].mean()), float(y[mask].mean()), int(mask.sum())])
    return bins


def fold_baseline(summary: dict, values: np.ndarray, stat: str) -> np.ndarray:
    """Per-row baseline from each training fold (class prior or median)."""
    out = np.zeros(len(values))
    for train_idx, test_idx in summary["folds"]:
        train_vals = values[train_idx]
        out[test_idx] = train_vals.mean() if stat == "mean" else np.median(train_vals)
    return out


def empty_sustain(summary: dict) -> dict:
    """Metrics block for an unavailable sustain task (nulls, never NaN)."""
    return {"available": False, "reason": summary.get("reason"), "n_rows": summary["n_rows"],
            "n_groups": summary["n_groups"], "cv": None, "roc_auc": None, "brier": None,
            "accuracy_at_0_5": None, "baseline_brier": None, "physics_baseline": None,
            "calibration_bins": [], "warnings": summary.get("warnings", [])}


def sustain_metrics(summary: dict) -> dict:
    """ROC-AUC, Brier, accuracy@0.5, prior baseline and calibration bins from OOF scores."""
    if not summary["available"]:
        return empty_sustain(summary)
    y = np.asarray(summary["y"], float)
    cal = summary["calibration"]
    p = sigmoid(cal["a"] * np.asarray(summary["oof_raw"]["sustain"]) + cal["b"])
    prior = fold_baseline(summary, y, "mean")
    return {"available": True, "reason": None, "n_rows": summary["n_rows"],
            "n_groups": summary["n_groups"], "cv": summary["cv"],
            "roc_auc": float(roc_auc_score(y, p)), "brier": float(brier_score_loss(y, p)),
            "accuracy_at_0_5": float(((p >= 0.5) == (y == 1)).mean()),
            "baseline_brier": float(np.mean((prior - y) ** 2)), "physics_baseline": None,
            "calibration_bins": calibration_bins(p, y), "warnings": summary["warnings"]}


def physics_mae(summary: dict, df: pd.DataFrame, params: dict | None) -> float | None:
    """Physics MAE on applicable spread rows; None unless params are valid and signed off."""
    if params is None or validate_params(params) or not params.get("signed_off_by_lead"):
        return None
    rows = df[df["run_id"].astype(str).isin(summary["run_ids"])]
    rows = rows[rows.apply(applicability, axis=1).isin(["ok", "near_extinction_warning"])]
    pairs = [(spread_rate_mm_s(r, params), r["flame_spread_rate_mm_s"]) for _, r in rows.iterrows()]
    errors = [abs(a - b) for a, b in pairs if a is not None and b is not None]
    return float(np.mean(errors)) if errors else None


def spread_oof(summary: dict) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """(truth mm/s, q10, q50, q90 mm/s) from OOF raw scores, quantiles sorted per row."""
    truth = np.expm1(np.asarray(summary["y"], float))
    raw = np.vstack([summary["oof_raw"][f"spread_{q}"] for q in ("q10", "q50", "q90")]).T
    q = np.expm1(np.sort(raw, axis=1))
    return truth, q[:, 0], q[:, 1], q[:, 2]


def spread_metrics(summary: dict, df: pd.DataFrame, params: dict | None) -> dict:
    """MAE, median APE, R² (log), 80% coverage, median baseline and physics MAE."""
    base = {"available": summary["available"], "reason": summary.get("reason"),
            "n_rows": summary["n_rows"], "n_groups": summary["n_groups"],
            "warnings": summary.get("warnings", [])}
    if not summary["available"]:
        return {**base, "cv": None, "mae_mm_s": None, "median_ape": None, "r2_log": None,
                "interval_80_coverage": None, "baseline_mae_mm_s": None,
                "physics_mae_mm_s": None}
    truth, q10, q50, q90 = spread_oof(summary)
    baseline = fold_baseline(summary, truth, "median")
    return {**base, "cv": summary["cv"],
            "mae_mm_s": float(np.mean(np.abs(q50 - truth))),
            "median_ape": float(np.median(np.abs(q50 - truth) / truth)),
            "r2_log": float(r2_score(np.log1p(truth), np.log1p(q50))),
            "interval_80_coverage": float(np.mean((truth >= q10) & (truth <= q90))),
            "baseline_mae_mm_s": float(np.mean(np.abs(baseline - truth))),
            "physics_mae_mm_s": physics_mae(summary, df, params)}


def assert_no_nan(obj: object, path: str = "metrics") -> None:
    """Fail loudly if any float in the metrics is NaN or infinite."""
    if isinstance(obj, float) and not math.isfinite(obj):
        raise ValueError(f"Non-finite value at {path}")
    if isinstance(obj, dict):
        for k, v in obj.items():
            assert_no_nan(v, f"{path}.{k}")
    if isinstance(obj, list):
        for i, v in enumerate(obj):
            assert_no_nan(v, f"{path}[{i}]")


def evaluate_all(df: pd.DataFrame, artifacts_dir: Path, params_path: Path | None = None) -> dict:
    """Compute metrics.json content for both tasks."""
    summaries = json.loads((artifacts_dir / "train_summary.json").read_text())
    df = coerce_types(df)
    params = load_params(params_path) if params_path else load_params()
    metrics = {"sustain": sustain_metrics(summaries["sustain"]),
               "spread": spread_metrics(summaries["spread"], df, params)}
    assert_no_nan(metrics)
    return metrics
