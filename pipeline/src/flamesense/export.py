"""Export models and data to the app's JSON assets (PLAN.md §3.2–§3.5, Phase 5)."""

from __future__ import annotations

import hashlib
import json
import math
import subprocess
from datetime import UTC, datetime
from pathlib import Path

import lightgbm as lgb
import numpy as np
import pandas as pd

from flamesense import config
from flamesense.schema import CANONICAL_COLUMNS
from flamesense.support import build_support_index
from flamesense.train import TASKS, TaskData, coerce_types, model_names, prepare_task

TREE_FORMAT = "flamesense-trees-v1"
DERIVED_COLUMNS = ["log10_gravity", "o2_partial_kpa", "log10_flow", "areal_density_kg_m2"]
FORMULAS = {
    "log10_gravity": "log10(max(gravity_g, 1e-7))",
    "o2_partial_kpa": "o2_mole_fraction * pressure_kpa",
    "log10_flow": "log10(flow_velocity_mm_s + 1)",
    "areal_density_kg_m2": "fuel_thickness_mm / 1000 * fuel_density_kg_m3",
}
GROUP_LABELS = {"fuel_class": "featFuelClass", "flow_direction": "featFlowDir", "diluent": "featDiluent"}

# User inputs (PLAN.md §3.3). Physical limits are from PLAN.md Phase 5 step 3;
# thickness/density limits and no-data defaults are UI choices (TODO(Q-3)).
INPUTS: dict[str, dict] = {
    "o2_mole_fraction": {"label_key": "featO2", "display_scale": 100, "display_unit": "%",
                         "limits": (0.10, 0.50), "step": 0.005, "log": False, "fallback": 0.21},
    "pressure_kpa": {"label_key": "featPressure", "display_scale": 1, "display_unit": "kPa",
                     "limits": (10.0, 200.0), "step": 0.1, "log": False, "fallback": 101.3},
    "flow_velocity_mm_s": {"label_key": "featFlow", "display_scale": 1, "display_unit": "mm/s",
                           "limits": (0.0, 1000.0), "step": 1.0, "log": True, "fallback": 100.0},
    "gravity_g": {"label_key": "featGravity", "display_scale": 1, "display_unit": "g",
                  "limits": (1e-6, 1.0), "step": None, "log": True, "fallback": 1e-6,
                  "full_range": True},
    "fuel_thickness_mm": {"label_key": "featThickness", "display_scale": 1, "display_unit": "mm",
                          "limits": (0.01, 50.0), "step": 0.01, "log": True, "fallback": 0.1},
    "fuel_density_kg_m3": {"label_key": "featDensity", "display_scale": 1,
                           "display_unit": "kg/m³", "limits": (1.0, 3000.0), "step": 1.0,
                           "log": False, "fallback": 500.0},
}


def round_sig(value: float, digits: int = 6) -> float:
    """Round a float to ``digits`` significant digits."""
    if value == 0 or not math.isfinite(value):
        return value
    return round(value, digits - 1 - math.floor(math.log10(abs(value))))


def json_value(value: object) -> object:
    """Convert a cell to a JSON-safe value (NaN → null, floats → 6 significant digits)."""
    if value is None:
        return None
    if isinstance(value, (bool, np.bool_)):
        return bool(value)
    if isinstance(value, (int, np.integer)):
        return int(value)
    if isinstance(value, (float, np.floating)):
        return None if math.isnan(value) else round_sig(float(value))
    if isinstance(value, str) and value in {"", "nan", "None", "<NA>"}:
        return None
    if pd.isna(value):
        return None
    return value


# ---------------------------------------------------------------- tree models


def _flatten(node: dict, nodes: list[dict]) -> int:
    """Append ``node`` (and children) to ``nodes`` in preorder; return its index."""
    index = len(nodes)
    if "leaf_value" in node:
        nodes.append({"v": float(node["leaf_value"])})
        return index
    if node.get("decision_type") != "<=":
        raise ValueError(f"Unsupported split type {node.get('decision_type')!r} (categorical?)")
    if isinstance(node["threshold"], str):
        raise TypeError("Categorical split found; all features must be numeric")
    nodes.append({"f": int(node["split_feature"]), "t": float(node["threshold"])})
    nodes[index]["l"] = _flatten(node["left_child"], nodes)
    nodes[index]["r"] = _flatten(node["right_child"], nodes)
    return index


def booster_to_json(booster: lgb.Booster, task: str, link: str, calibration: dict | None) -> dict:
    """Convert a LightGBM booster to the flamesense-trees-v1 format (PLAN.md §3.4)."""
    dump = booster.dump_model()
    trees = []
    for info in dump["tree_info"]:
        nodes: list[dict] = []
        _flatten(info["tree_structure"], nodes)
        trees.append({"nodes": nodes})
    model = {"format": TREE_FORMAT, "task": task, "available": True,
             "feature_names": list(dump["feature_names"]), "link": link, "trees": trees}
    if link == "logit":
        model["calibration"] = calibration or {"a": 1.0, "b": 0.0}
    return model


def unavailable_model(task: str, link: str) -> dict:
    """Placeholder model file for a task without enough data."""
    model = {"format": TREE_FORMAT, "task": task, "available": False,
             "feature_names": [], "link": link, "trees": []}
    if link == "logit":
        model["calibration"] = {"a": 1.0, "b": 0.0}
    return model


def apply_link(model: dict, raw: float) -> float:
    """Output transform: logit → calibrated sigmoid, identity, or expm1."""
    if model["link"] == "logit":
        cal = model.get("calibration") or {"a": 1.0, "b": 0.0}
        return 1.0 / (1.0 + math.exp(-(cal["a"] * raw + cal["b"])))
    if model["link"] == "expm1":
        return math.expm1(raw)
    return raw


def eval_tree_model(model: dict, x: list[float]) -> tuple[float, float]:
    """Pure-Python evaluator: returns (raw, out) exactly as the Dart engine does."""
    if len(x) != len(model["feature_names"]):
        raise ValueError("Feature vector length does not match the model")
    raw = 0.0
    for tree in model["trees"]:
        nodes = tree["nodes"]
        node = nodes[0]
        while "f" in node:
            node = nodes[node["l"]] if x[node["f"]] <= node["t"] else nodes[node["r"]]
        raw += node["v"]
    return raw, apply_link(model, raw)


def model_link(name: str) -> str:
    """Link function for a model name (sustain → logit, spread → expm1)."""
    return "logit" if name == "sustain" else "expm1"


# --------------------------------------------------------------- feature spec


def input_spec(df: pd.DataFrame, name: str) -> dict:
    """Slider metadata for one user input from the training range (padded 10%)."""
    meta = INPUTS[name]
    lo_lim, hi_lim = meta["limits"]
    values = pd.to_numeric(df[name], errors="coerce").dropna() if name in df else pd.Series([])
    spec = {k: meta[k] for k in ("label_key", "display_scale", "display_unit", "step", "log")}
    if values.empty:
        spec.update(min=lo_lim, max=hi_lim, default=meta["fallback"], train_min=None,
                    train_max=None)
        return spec
    t_min, t_max = float(values.min()), float(values.max())
    if meta.get("full_range"):
        lo, hi = lo_lim, hi_lim
    elif meta["log"]:
        a, b = math.log10(t_min + 1), math.log10(t_max + 1)
        pad = 0.1 * (b - a)
        lo, hi = 10 ** (a - pad) - 1, 10 ** (b + pad) - 1
    else:
        pad = 0.1 * (t_max - t_min)
        lo, hi = t_min - pad, t_max + pad
    lo, hi = max(lo, lo_lim), min(hi, hi_lim)
    if hi <= lo:
        lo, hi = lo_lim, hi_lim
    default = float(np.clip(values.median(), lo, hi))
    spec.update(min=round_sig(lo), max=round_sig(hi), default=round_sig(default),
                train_min=round_sig(t_min), train_max=round_sig(t_max))
    return spec


def feature_entry(td: TaskData, name: str, monotone: int) -> dict:
    """One entry of a task's ``features`` list (PLAN.md §3.3)."""
    if "__" in name:
        return {"name": name, "group": name.split("__")[0], "input": "onehot"}
    col = td.rows[name].astype(float)
    entry = {"name": name, "train_min": round_sig(float(col.min())),
             "train_max": round_sig(float(col.max())), "mean": float(col.mean()),
             "std": float(col.std(ddof=0)), "monotone": monotone}
    if name in FORMULAS:
        entry.update(input="derived", formula=FORMULAS[name])
    else:
        entry.update(input="slider", label_key=INPUTS[name]["label_key"])
    return entry


def group_spec(td: TaskData) -> dict:
    """One-hot groups with options and the most common option as default."""
    groups: dict[str, dict] = {}
    for name in td.features:
        if "__" not in name:
            continue
        group, option = name.split("__", 1)
        g = groups.setdefault(group, {"label_key": GROUP_LABELS.get(group, group), "options": []})
        g["options"].append(option)
    for group, g in groups.items():
        counts = td.rows[group].value_counts()
        g["default"] = str(counts.index[0]) if len(counts) else g["options"][0]
    return groups


def task_spec(td: TaskData, monotone: list[int]) -> dict:
    """Feature spec for one task (available or not)."""
    spec = {"available": td.available, "reason_if_unavailable": td.reason,
            "target": "sustained" if td.task == "sustain" else "flame_spread_rate_mm_s",
            "output": "probability" if td.task == "sustain" else "mm_s",
            "link": "logit" if td.task == "sustain" else "expm1",
            "n_rows": len(td.y), "features": [], "groups": {}}
    if td.available:
        spec["features"] = [feature_entry(td, f, m) for f, m in zip(td.features, monotone)]
        spec["groups"] = group_spec(td)
    return spec


def build_feature_spec(df: pd.DataFrame, tasks: dict[str, TaskData], summaries: dict) -> dict:
    """Full feature_spec.json: user inputs plus per-task model features."""
    usable = df[df["quality_flag"].astype(str) != "suspect"]
    return {
        "inputs": {name: input_spec(usable, name) for name in INPUTS},
        "tasks": {t: task_spec(tasks[t], summaries[t].get("monotone", [])) for t in TASKS},
    }


# ------------------------------------------------------------- runs and meta


def build_runs_json(df: pd.DataFrame) -> dict:
    """Columnar-by-row runs table: every §3.1 column plus the derived columns."""
    columns = CANONICAL_COLUMNS + [c for c in DERIVED_COLUMNS if c in df.columns]
    rows = [[json_value(v) for v in rec] for rec in df[columns].itertuples(index=False)]
    return {"columns": columns, "rows": rows}


def git_sha() -> str:
    """Current git commit (short), or 'unknown' outside a repository."""
    try:
        out = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=config.ROOT,
                             capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def build_app_meta(df: pd.DataFrame, runs_json: dict) -> dict:
    """app_meta.json: counts, experiments, build stamp and a data version hash."""
    digest = hashlib.sha256(json.dumps(runs_json["rows"]).encode()).hexdigest()[:12]
    experiments = sorted(df["experiment"].dropna().astype(str).unique().tolist())
    return {
        "build_time_utc": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "git_sha": git_sha(),
        "n_runs": len(df),
        "n_experiments": len(experiments),
        "n_fuels": int(df["fuel_name"].dropna().nunique()),
        "experiments": experiments,
        "data_version": digest,
    }


# ------------------------------------------------------------ parity fixtures


def parity_inputs(td: TaskData, n_random: int = 50, n_edge: int = 10) -> np.ndarray:
    """50 random training rows plus 10 edge rows at and beyond the training range."""
    x = td.rows[td.features].to_numpy(float)
    rng = np.random.default_rng(42)
    picks = x[rng.choice(len(x), size=min(n_random, len(x)), replace=False)]
    lo, hi = x.min(axis=0), x.max(axis=0)
    numeric = np.array(["__" not in f for f in td.features])
    edges = []
    for i in range(n_edge):
        row = x[rng.integers(len(x))].copy()
        stretch = 0.0 if i < 4 else 0.5
        target = lo - stretch * (hi - lo) if i % 2 == 0 else hi + stretch * (hi - lo)
        row[numeric] = target[numeric]
        edges.append(row)
    return np.vstack([picks, np.array(edges)])


def parity_rows(booster: lgb.Booster, model: dict, x: np.ndarray, features: list[str]) -> list:
    """Expected raw/out per row, computed with LightGBM's own predict."""
    raw = booster.predict(pd.DataFrame(x, columns=features), raw_score=True)
    return [{"x": [float(v) for v in row], "raw": float(r), "out": apply_link(model, float(r))}
            for row, r in zip(x, raw)]


# ------------------------------------------------------------------- driver


def load_summaries(artifacts_dir: Path) -> dict:
    """Read artifacts/train_summary.json written by `train`."""
    path = artifacts_dir / "train_summary.json"
    if not path.exists():
        raise FileNotFoundError(f"{path} not found. Run 'python -m flamesense.cli train' first.")
    return json.loads(path.read_text())


def export_models(tasks: dict[str, TaskData], summaries: dict, artifacts_dir: Path) -> tuple:
    """Model JSON per model name and parity fixtures for every available model."""
    models: dict[str, dict] = {}
    parity: dict[str, list] = {}
    for task in TASKS:
        td, summary = tasks[task], summaries[task]
        for name in model_names(task):
            link = model_link(name)
            file_name = f"model_{name}.json"
            if not summary["available"]:
                models[file_name] = unavailable_model(task, link)
                continue
            booster = lgb.Booster(model_file=str(artifacts_dir / summary["models"][name]))
            model = booster_to_json(booster, task, link, summary.get("calibration"))
            models[file_name] = model
            parity[file_name] = parity_rows(booster, model, parity_inputs(td), td.features)
    return models, parity


def write_json(path: Path, payload: object, indent: int | None = None) -> None:
    """Write compact (or indented) UTF-8 JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    separators = (",", ":") if indent is None else None
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=indent,
                               separators=separators), encoding="utf-8")


def export_all(df: pd.DataFrame, artifacts_dir: Path, out_dir: Path) -> dict[str, Path]:
    """Write every app asset produced by export (PLAN.md §3.2)."""
    df = coerce_types(df)
    summaries = load_summaries(artifacts_dir)
    tasks = {t: prepare_task(df, t) for t in TASKS}
    runs_json = build_runs_json(df)
    models, parity = export_models(tasks, summaries, artifacts_dir)
    payloads: dict[str, object] = {
        "app_meta.json": build_app_meta(df, runs_json),
        "runs.json": runs_json,
        "feature_spec.json": build_feature_spec(df, tasks, summaries),
        "support_index.json": {t: build_support_index(tasks[t].rows, tasks[t].features,
                                                      tasks[t].available) for t in TASKS},
        "parity_fixtures.json": parity,
        **models,
    }
    written = {}
    for name, payload in payloads.items():
        indent = 1 if name in {"app_meta.json", "feature_spec.json"} else None
        write_json(out_dir / name, payload, indent)
        written[name] = out_dir / name
    params = config.DATA_MANUAL / "physics_params.json"
    if params.exists():
        (out_dir / "physics_params.json").write_text(params.read_text(encoding="utf-8"))
        written["physics_params.json"] = out_dir / "physics_params.json"
    return written
