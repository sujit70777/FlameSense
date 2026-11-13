"""Data-support index: how close a query is to real training runs (PLAN.md §3.5).

Support = mean Euclidean distance to the ``k`` nearest training rows in
standardized slider-feature space (one-hot columns excluded). Thresholds
``p50``/``p95`` come from leave-one-out kNN distances on the training rows.
"""

from __future__ import annotations

import numpy as np
import pandas as pd

K_NEIGHBOURS = 5
ONE_HOT_MARK = "__"


def support_features(features: list[str]) -> list[str]:
    """Numeric (non one-hot) model features used for the support distance."""
    return [f for f in features if ONE_HOT_MARK not in f]


def standardize(x: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Return (z, mean, std); a zero std becomes 1 so constant columns add no distance."""
    mean = x.mean(axis=0)
    std = x.std(axis=0)
    std = np.where(std > 0, std, 1.0)
    return (x - mean) / std, mean, std


def knn_mean_distance(points: np.ndarray, query: np.ndarray, k: int) -> float:
    """Mean distance from ``query`` to its ``k`` nearest ``points``."""
    d = np.sqrt(((points - query) ** 2).sum(axis=1))
    k = min(k, len(d))
    return float(np.sort(d)[:k].mean())


def loo_distances(z: np.ndarray, k: int) -> np.ndarray:
    """Leave-one-out kNN mean distance for every training row."""
    out = np.zeros(len(z))
    for i in range(len(z)):
        others = np.delete(z, i, axis=0)
        out[i] = knn_mean_distance(others, z[i], k)
    return out


def build_support_index(rows: pd.DataFrame, features: list[str], available: bool) -> dict:
    """Support index for one task; empty (levels unavailable) when the task is unavailable."""
    names = support_features(features)
    if not available or len(rows) < 2 or not names:
        return {"available": False, "feature_names": names, "mean": [], "std": [],
                "points": [], "k": K_NEIGHBOURS, "p50": None, "p95": None}
    x = rows[names].to_numpy(float)
    z, mean, std = standardize(x)
    k = min(K_NEIGHBOURS, len(z) - 1)
    loo = loo_distances(z, k)
    return {
        "available": True,
        "feature_names": names,
        "mean": [float(v) for v in mean],
        "std": [float(v) for v in std],
        "points": [[round(float(v), 6) for v in row] for row in z],
        "k": k,
        "p50": float(np.percentile(loo, 50)),
        "p95": float(np.percentile(loo, 95)),
    }


def support_level(index: dict, x: list[float]) -> tuple[str, float | None]:
    """Support level ('high'|'medium'|'low') and distance for a raw feature vector."""
    if not index.get("available"):
        return "low", None
    z = (np.asarray(x, float) - np.asarray(index["mean"])) / np.asarray(index["std"])
    d = knn_mean_distance(np.asarray(index["points"]), z, index["k"])
    if d <= index["p50"]:
        return "high", d
    if d <= index["p95"]:
        return "medium", d
    return "low", d
