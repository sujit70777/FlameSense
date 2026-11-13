"""Model training with grouped cross-validation (PLAN.md Phase 5).

Two tasks:
- ``sustain``: binary classifier, target ``ignited and sustained``.
- ``spread``: three quantile regressors (0.1 / 0.5 / 0.9) on ``log1p(rate)``.

No imputation: rows missing a selected feature are dropped for that task and
the count is logged. Tasks below the data threshold are marked unavailable
with a reason instead of training on too little data.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path

import lightgbm as lgb
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import GroupKFold, KFold, StratifiedKFold

TASKS: tuple[str, ...] = ("sustain", "spread")

# Numeric candidate features in model order; one-hots are appended after them.
NUMERIC_CANDIDATES: list[str] = [
    "o2_mole_fraction",
    "pressure_kpa",
    "o2_partial_kpa",
    "log10_flow",
    "log10_gravity",
    "fuel_thickness_mm",
    "areal_density_kg_m2",
]
ONE_HOT_PREFIXES: tuple[str, ...] = ("fuel_class__", "flow_direction__", "diluent__")
NUMERIC_INPUT_COLUMNS: list[str] = [
    "gravity_g",
    "fuel_thickness_mm",
    "fuel_density_kg_m3",
    "o2_mole_fraction",
    "pressure_kpa",
    "flow_velocity_mm_s",
    "flame_spread_rate_mm_s",
]

MIN_ROWS = 40
MIN_PER_CLASS = 8
MAX_MISSING_FRACTION = 0.40
SPREAD_FUEL_CLASSES = {"thin_solid", "thick_solid"}
FEW_GROUPS_WARNING = "Few independent test series; metrics may be optimistic."

LGB_PARAMS: dict = {
    "n_estimators": 300,
    "learning_rate": 0.03,
    "num_leaves": 15,
    "max_depth": 5,
    "min_child_samples": 5,
    "subsample": 0.9,
    "subsample_freq": 1,
    "colsample_bytree": 0.9,
    "reg_lambda": 1.0,
    "random_state": 42,
    "verbose": -1,
}

QUANTILES: dict[str, float] = {"q10": 0.1, "q50": 0.5, "q90": 0.9}

# Monotone constraint signs from PLAN.md Phase 5. They are applied only after
# the lead confirms them in docs/QUESTIONS.md (Q-2); until then every sign is 0.
MONOTONE_SIGNS: dict[str, dict[str, int]] = {
    "sustain": {"o2_mole_fraction": 1, "o2_partial_kpa": 1},
    "spread": {
        "o2_mole_fraction": 1,
        "o2_partial_kpa": 1,
        "fuel_thickness_mm": -1,
        "areal_density_kg_m2": -1,
    },
}
MONOTONE_CONFIRMED_BY_LEAD = False  # TODO(Q-2): set True once the lead confirms the signs.


@dataclass
class TaskData:
    """Rows, features and target prepared for one task."""

    task: str
    available: bool
    reason: str | None
    features: list[str]
    rows: pd.DataFrame
    y: np.ndarray
    groups: np.ndarray
    warnings: list[str] = field(default_factory=list)
    n_candidate_rows: int = 0
    n_dropped_missing: int = 0


def coerce_types(df: pd.DataFrame) -> pd.DataFrame:
    """Cast numeric and boolean columns so empty/string parquet columns behave."""
    out = df.copy()
    for col in NUMERIC_INPUT_COLUMNS + NUMERIC_CANDIDATES:
        if col in out.columns:
            out[col] = pd.to_numeric(out[col], errors="coerce").astype(float)
    for col in ("ignited", "sustained"):
        if col in out.columns:
            out[col] = out[col].map(_to_bool)
    for col in out.columns:
        if col.startswith(ONE_HOT_PREFIXES):
            out[col] = pd.to_numeric(out[col], errors="coerce").fillna(0).astype(float)
    return out


def _to_bool(value: object) -> bool | None:
    """Parse a bool-like cell; None when missing or unrecognised."""
    if value is None or (isinstance(value, float) and np.isnan(value)):
        return None
    if isinstance(value, (bool, np.bool_)):
        return bool(value)
    text = str(value).strip().lower()
    if text in {"true", "1", "yes", "y", "t"}:
        return True
    if text in {"false", "0", "no", "n", "f"}:
        return False
    return None


def task_rows(df: pd.DataFrame, task: str) -> pd.DataFrame:
    """Rows eligible for a task (PLAN.md Phase 5 task definitions)."""
    not_suspect = df["quality_flag"].astype(str) != "suspect"
    if task == "sustain":
        mask = df["ignited"].notna() & not_suspect
    else:
        rate = pd.to_numeric(df["flame_spread_rate_mm_s"], errors="coerce")
        mask = (rate > 0) & df["fuel_class"].isin(SPREAD_FUEL_CLASSES) & not_suspect
    return df[mask].copy()


def task_target(rows: pd.DataFrame, task: str) -> np.ndarray:
    """Target vector: 1/0 sustain label, or log1p(spread rate)."""
    if task == "sustain":
        ignited = rows["ignited"].astype(bool)
        sustained = rows["sustained"].map(lambda v: v is True)
        return (ignited & sustained).astype(int).to_numpy()
    return np.log1p(rows["flame_spread_rate_mm_s"].astype(float).to_numpy())


def select_features(rows: pd.DataFrame) -> tuple[list[str], list[str]]:
    """Keep features with < 40% missing in the task rows; report dropped ones."""
    features: list[str] = []
    warnings: list[str] = []
    if rows.empty:
        return features, warnings
    for col in NUMERIC_CANDIDATES:
        if col not in rows.columns:
            continue
        missing = float(rows[col].isna().mean()) if len(rows) else 1.0
        if missing < MAX_MISSING_FRACTION:
            features.append(col)
        else:
            warnings.append(f"Feature '{col}' dropped: {missing:.0%} missing in task rows.")
    one_hots = sorted(c for c in rows.columns if c.startswith(ONE_HOT_PREFIXES))
    for col in one_hots:
        if len(rows) and rows[col].sum() > 0:
            features.append(col)
    return features, warnings


def prepare_task(df: pd.DataFrame, task: str) -> TaskData:
    """Select rows and features for a task and check availability thresholds."""
    df = coerce_types(df)
    rows = task_rows(df, task)
    features, warnings = select_features(rows)
    n_candidates = len(rows)
    rows = rows.dropna(subset=features) if features else rows.iloc[0:0]
    dropped = n_candidates - len(rows)
    if dropped:
        warnings.append(f"{dropped} row(s) dropped for missing feature values (no imputation).")
    y = task_target(rows, task) if len(rows) else np.array([])
    groups = rows["group_id"].astype(str).to_numpy() if len(rows) else np.array([])
    reason = availability_reason(task, y)
    return TaskData(
        task=task,
        available=reason is None,
        reason=reason,
        features=features,
        rows=rows,
        y=y,
        groups=groups,
        warnings=warnings,
        n_candidate_rows=n_candidates,
        n_dropped_missing=dropped,
    )


def availability_reason(task: str, y: np.ndarray) -> str | None:
    """Return why a task cannot be trained, or None if it has enough data."""
    if len(y) < MIN_ROWS:
        return f"Only {len(y)} usable row(s); at least {MIN_ROWS} are required."
    if task == "sustain":
        n_pos = int(y.sum())
        n_neg = int(len(y) - n_pos)
        if min(n_pos, n_neg) < MIN_PER_CLASS:
            return (
                f"Class balance too small ({n_pos} kept burning, {n_neg} went out); "
                f"at least {MIN_PER_CLASS} of each are required."
            )
    return None


def make_folds(td: TaskData) -> tuple[list[tuple[np.ndarray, np.ndarray]], str, list[str]]:
    """Grouped CV splits; falls back to (Stratified)KFold(5) when groups < 3."""
    n_groups = len(set(td.groups.tolist()))
    x_dummy = np.zeros((len(td.y), 1))
    if n_groups >= 3:
        n_splits = min(5, n_groups)
        splitter = GroupKFold(n_splits=n_splits)
        return list(splitter.split(x_dummy, td.y, td.groups)), f"GroupKFold({n_splits})", []
    if td.task == "sustain":
        folds = StratifiedKFold(n_splits=5, shuffle=True, random_state=42).split(x_dummy, td.y)
        name = "StratifiedKFold(5)"
    else:
        folds = KFold(n_splits=5, shuffle=True, random_state=42).split(x_dummy)
        name = "KFold(5)"
    return list(folds), name, [FEW_GROUPS_WARNING]


QUANTILE_MONOTONE_WARNING = (
    "Monotone constraints are not applied to the spread models: LightGBM does not "
    "support them with the quantile objective."
)


def monotone_vector(features: list[str], task: str) -> list[int]:
    """Monotone constraint per feature (0 unless confirmed by the lead; always 0 for spread)."""
    if not MONOTONE_CONFIRMED_BY_LEAD or task == "spread":
        return [0] * len(features)
    signs = MONOTONE_SIGNS.get(task, {})
    return [signs.get(f, 0) for f in features]


def fit_model(x: np.ndarray, y: np.ndarray, task: str, features: list[str], alpha: float | None):
    """Fit one LightGBM model with the fixed PLAN.md parameters."""
    if task == "sustain":
        params = dict(LGB_PARAMS, monotone_constraints=monotone_vector(features, task))
        model = lgb.LGBMClassifier(objective="binary", **params)
    else:
        # LightGBM rejects monotone_constraints with the quantile objective (TODO(Q-4)).
        model = lgb.LGBMRegressor(objective="quantile", alpha=alpha, **LGB_PARAMS)
    model.fit(pd.DataFrame(x, columns=features), y)
    return model


def raw_predict(model, x: np.ndarray, features: list[str]) -> np.ndarray:
    """Raw score (sum of leaves) from LightGBM's own predict."""
    return np.asarray(model.predict(pd.DataFrame(x, columns=features), raw_score=True), float)


def model_names(task: str) -> dict[str, float | None]:
    """Model name → quantile alpha (None for the classifier)."""
    return {"sustain": None} if task == "sustain" else {f"spread_{k}": a for k, a in QUANTILES.items()}


def cross_validate(td: TaskData) -> dict:
    """Out-of-fold raw predictions for every model of the task."""
    folds, cv_name, warnings = make_folds(td)
    x = td.rows[td.features].to_numpy(float)
    oof = {name: np.zeros(len(td.y)) for name in model_names(td.task)}
    fold_id = np.zeros(len(td.y), dtype=int)
    for i, (tr, te) in enumerate(folds):
        fold_id[te] = i
        for name, alpha in model_names(td.task).items():
            model = fit_model(x[tr], td.y[tr], td.task, td.features, alpha)
            oof[name][te] = raw_predict(model, x[te], td.features)
    return {"cv": cv_name, "warnings": warnings, "oof_raw": oof, "fold_id": fold_id,
            "folds": [(tr.tolist(), te.tolist()) for tr, te in folds]}


def calibrate(raw: np.ndarray, y: np.ndarray) -> dict[str, float]:
    """Logistic calibration p = sigmoid(a·raw + b) fitted on OOF raw scores."""
    # Very weak L2 keeps the fit finite when OOF scores separate the classes.
    lr = LogisticRegression(C=1e6, solver="lbfgs", max_iter=1000)
    lr.fit(raw.reshape(-1, 1), y)
    return {"a": float(lr.coef_[0][0]), "b": float(lr.intercept_[0])}


def train_task(td: TaskData, artifacts_dir: Path) -> dict:
    """Cross-validate, fit final models on all rows, save boosters; return a summary."""
    summary = {"task": td.task, "available": td.available, "reason": td.reason,
               "features": td.features, "n_rows": len(td.y),
               "n_groups": len(set(td.groups.tolist())),
               "n_candidate_rows": td.n_candidate_rows,
               "n_dropped_missing": td.n_dropped_missing, "warnings": list(td.warnings),
               "monotone": monotone_vector(td.features, td.task), "models": {}}
    if not td.available:
        return summary
    cv = cross_validate(td)
    summary.update(cv=cv["cv"], fold_id=cv["fold_id"].tolist(), folds=cv["folds"],
                   oof_raw={k: v.tolist() for k, v in cv["oof_raw"].items()},
                   y=td.y.tolist(), run_ids=td.rows["run_id"].astype(str).tolist())
    summary["warnings"] += cv["warnings"]
    if td.task == "spread" and MONOTONE_CONFIRMED_BY_LEAD:
        summary["warnings"].append(QUANTILE_MONOTONE_WARNING)
    x = td.rows[td.features].to_numpy(float)
    for name, alpha in model_names(td.task).items():
        model = fit_model(x, td.y, td.task, td.features, alpha)
        path = artifacts_dir / f"model_{name}.txt"
        model.booster_.save_model(str(path))
        summary["models"][name] = path.name
    if td.task == "sustain":
        summary["calibration"] = calibrate(np.asarray(summary["oof_raw"]["sustain"]), td.y)
    return summary


def train_all(df: pd.DataFrame, artifacts_dir: Path) -> dict[str, dict]:
    """Train every task and write artifacts/train_summary.json."""
    artifacts_dir.mkdir(parents=True, exist_ok=True)
    for stale in artifacts_dir.glob("model_*.txt"):
        stale.unlink()
    summaries = {task: train_task(prepare_task(df, task), artifacts_dir) for task in TASKS}
    (artifacts_dir / "train_summary.json").write_text(json.dumps(summaries, indent=1))
    return summaries
