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
from flamesense.lessons import build_lessons, build_usability
from flamesense.missions import export_missions
from flamesense.schema import CANONICAL_COLUMNS
from flamesense.support import build_support_index
from flamesense.train import TASKS, TaskData, coerce_types, model_names, prepare_task

TREE_FORMAT = "flamesense-trees-v1"
DERIVED_COLUMNS = ["log10_gravity", "o2_partial_kpa", "log10_flow", "areal_density_kg_m2"]
SOURCE_TYPES = ["nasa_psi", "nasa_report", "partner_agency", "third_party"]
GRAVITY_CLASSES = ["microgravity", "partial", "earth"]
SOLID_FUEL_CLASSES = {"thin_solid", "thick_solid"}
# Moon-base atmosphere comes from this mission in data/manual/missions.json (cited there).
MOON_BASE_MISSION_ID = "artemis_lunar"
# Solid-model valid range (PLAN.md §1.0): per input, where NASA saw both outcomes.
VALID_RANGE_COLUMNS = {"o2": "o2_mole_fraction", "pressure_kpa": "pressure_kpa",
                       "flow_mm_s": "flow_velocity_mm_s", "gravity_g": "gravity_g"}
VALID_RANGE_RULE = "both_outcomes"
# NASA's microgravity solid data stops at ~23% O2 at ~1 atm (PLAN.md §1.0).
HIGH_O2_LIMIT = 0.23
# Editorial mission-relevance weights for the "Biggest gaps" ranking (DESIGN.md §11.1b).
GAP_RELEVANCE = {"high_o2_solids": 1.0, "partial_gravity": 0.9, "earth_baseline": 0.7}
# Authorship per source (PLAN.md §1.0 "Third-party"); third-party keyed by DOI.
AUTHORSHIP_BY_TYPE = {"nasa_psi": "nasa", "nasa_report": "nasa", "partner_agency": "partner"}
THIRD_PARTY_AUTHORSHIP = {
    "https://doi.org/10.1007/s12217-024-10106-y": "nasa_coauthored",  # Sharma 2024
    "https://doi.org/10.1016/j.proci.2026.106097": "independent",  # Takahashi 2026
}
K_MAP_COLS = 64
K_MAP_ROWS = 48
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


def solid_valid_range(td: TaskData | None) -> dict | None:
    """Range where NASA saw flames both keep burning and go out (PLAN.md §1.0).

    Per input, the overlap of the burned rows' and the went-out rows' min..max in
    the sustain training data. None (no prediction anywhere) when either outcome is
    missing or the overlap is empty: a classifier can't place a limit it never saw.
    """
    if td is None or not td.available or len(td.rows) == 0:
        return None
    y = np.asarray(td.y).astype(int)
    burned, went_out = td.rows[y == 1], td.rows[y == 0]
    out: dict = {"rule": VALID_RANGE_RULE}
    for key, col in VALID_RANGE_COLUMNS.items():
        b = pd.to_numeric(burned[col], errors="coerce").dropna()
        o = pd.to_numeric(went_out[col], errors="coerce").dropna()
        if len(b) == 0 or len(o) == 0:
            return None
        lo, hi = max(float(b.min()), float(o.min())), min(float(b.max()), float(o.max()))
        if lo > hi:
            return None
        out[key] = [round_sig(lo), round_sig(hi)]
    return out


def _inside(value: float, lo: float, hi: float) -> bool:
    """lo <= value <= hi with a 1e-6 relative tolerance (mirrors ValidRange in Dart)."""
    return lo * (1 - 1e-6) <= value <= hi * (1 + 1e-6)


def in_valid_range(rng: dict | None, o2: float, pressure_kpa: float, flow_mm_s: float,
                   gravity_g: float) -> bool:
    """True when the point is inside the solid model's valid range (mirrors predictor.dart)."""
    if rng is None:
        return False
    values = {"o2": o2, "pressure_kpa": pressure_kpa, "flow_mm_s": flow_mm_s,
              "gravity_g": gravity_g}
    return all(_inside(v, *rng[k]) for k, v in values.items())


def build_feature_spec(df: pd.DataFrame, tasks: dict[str, TaskData], summaries: dict) -> dict:
    """Full feature_spec.json: user inputs, the solid valid range, per-task model features."""
    usable = df[df["quality_flag"].astype(str) != "suspect"]
    return {
        "inputs": {name: input_spec(usable, name) for name in INPUTS},
        "valid_range": solid_valid_range(tasks.get("sustain")),
        "tasks": {t: task_spec(tasks[t], summaries[t].get("monotone", [])) for t in TASKS},
    }


# ------------------------------------------------------------- runs and meta


def build_runs_json(df: pd.DataFrame) -> dict:
    """Columnar-by-row runs table: every §3.1 column plus the derived columns.

    Every row carries ``source_type`` (nasa_psi / nasa_report / partner_agency /
    third_party) so the app can show provenance per run.
    """
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


def gravity_class(platform: pd.Series, gravity_g: pd.Series) -> pd.Series:
    """Classify runs into microgravity / partial / earth (DESIGN.md §10.2)."""
    g = pd.to_numeric(gravity_g, errors="coerce")
    micro = (g < 0.01) | (g.isna() & platform.isin(["iss", "free_flyer", "drop_tower", "parabolic"]))
    partial = (~micro) & g.ge(0.01) & g.lt(0.9)
    out = pd.Series("earth", index=platform.index)
    out[micro] = "microgravity"
    out[partial] = "partial"
    return out


def _counts(series: pd.Series, keys: list[str] | None) -> dict[str, int]:
    """Count values, guaranteeing every key in ``keys`` appears (zero if absent)."""
    counts = series.astype(str).str.strip().str.lower().value_counts()
    out: dict[str, int] = {}
    for key in (keys or sorted(counts.index.tolist())):
        out[key] = int(counts.get(key, 0))
    return out


def _feature_value(name: str, o2: float, pressure: float, flow: float, gravity: float,
                   thickness: float, density: float) -> float:
    """One feature value for a grid cell, mirroring domain/featureValue (predictor.dart)."""
    if name == "o2_mole_fraction":
        return o2
    if name == "pressure_kpa":
        return pressure
    if name == "o2_partial_kpa":
        return o2 * pressure
    if name == "log10_flow":
        return math.log10(flow + 1)
    if name == "log10_gravity":
        return math.log10(max(gravity, 1e-7))
    if name == "fuel_thickness_mm":
        return thickness
    if name == "areal_density_kg_m2":
        return thickness / 1000 * density
    raise ValueError(f"unsupported support feature {name!r}")


def _grid_cell_features(td: TaskData, o2: float, pressure: float, flow: float, gravity: float,
                        thickness: float, density: float) -> list[float] | None:
    """Feature vector for one map cell in sustain feature order, or None if a feature
    can't be computed (e.g. a one-hot the sustain task doesn't use)."""
    try:
        return [_feature_value(f, o2, pressure, flow, gravity, thickness, density)
                for f in td.features]
    except ValueError:
        return None


def _map_low_cells(td: TaskData) -> int:
    """Count flammability-map cells with low (little/no) NASA data.

    Mirrors the Dart map grid (64 x 48: O2 linear x airflow log) evaluated at the
    default map conditions (microgravity / ISS, median solid thickness/density).
    Cells outside the solid ``valid_range`` show no prediction, so they count as low.
    Returns the cell total when the sustain task is unavailable (no data = all low).
    """
    rng = solid_valid_range(td)
    if not td.available or len(td.rows) == 0:
        return K_MAP_COLS * K_MAP_ROWS
    index = build_support_index(td.rows, td.features, td.available)
    if not index.get("available"):
        return K_MAP_COLS * K_MAP_ROWS
    names = index["feature_names"]
    mean = index["mean"]; std = index["std"]; points = index["points"]
    k = index["k"]; p50 = index["p50"]; p95 = index["p95"]
    # Default map conditions: ISS microgravity, sea-level pressure, opposed flow,
    # median solid thickness/density (fall back to input-spec defaults).
    solids = td.rows[td.rows["fuel_class"].isin(SOLID_FUEL_CLASSES)] if "fuel_class" in td.rows else td.rows.iloc[0:0]
    thickness = float(solids["fuel_thickness_mm"].median()) if len(solids) and solids["fuel_thickness_mm"].notna().any() else 0.1
    density = float(solids["fuel_density_kg_m3"].median()) if len(solids) and solids["fuel_density_kg_m3"].notna().any() else 500.0
    gravity = 1e-6; pressure = 101.3
    flow_min, flow_max = 0.0, 1000.0
    o2_min, o2_max = 0.10, 0.50
    low = 0
    for r in range(K_MAP_ROWS):
        o2 = o2_min + (r + 0.5) / K_MAP_ROWS * (o2_max - o2_min)
        for c in range(K_MAP_COLS):
            t = (c + 0.5) / K_MAP_COLS
            flow = math.expm1(math.log1p(flow_min) + t * (math.log1p(flow_max) - math.log1p(flow_min)))
            x = [_feature_value(f, o2, pressure, flow, gravity, thickness, density) for f in names]
            if not in_valid_range(rng, o2, pressure, flow, gravity) or any(v is None for v in x):
                low += 1
                continue
            z = [(x[i] - mean[i]) / std[i] for i in range(len(x))]
            dists = sorted(
                math.sqrt(sum((p[i] - z[i]) ** 2 for i in range(len(x))))
                for p in points
            )
            mean_d = sum(dists[:k]) / k
            level = "low"
            if mean_d <= p50: level = "high"
            elif mean_d <= p95: level = "medium"
            if level == "low":
                low += 1
    return low


def _solid_micro(df: pd.DataFrame, gc: pd.Series) -> pd.DataFrame:
    """Microgravity solid-fuel runs."""
    return df[(gc == "microgravity") & df["fuel_class"].isin(SOLID_FUEL_CLASSES)]


def _max_o2_microgravity_solids_pct(df: pd.DataFrame, gc: pd.Series) -> int:
    """Highest O2 (%) at which burning solids were tested in microgravity."""
    solids = _solid_micro(df, gc)
    burning = solids.loc[solids["sustained"].map(lambda v: v is True).fillna(False)]
    sub = burning["o2_mole_fraction"].dropna()
    if len(sub) == 0:
        sub = solids["o2_mole_fraction"].dropna()  # fall back to any tested solid
    return round(float(sub.max()) * 100) if len(sub) else 0


def moon_base_atmosphere(missions_path: Path | None = None) -> dict | None:
    """Expected Moon-base atmosphere from data/manual/missions.json (cited, lead-owned)."""
    path = missions_path or config.DATA_MANUAL / "missions.json"
    if not path.exists():
        return None
    for m in json.loads(path.read_text(encoding="utf-8")).get("missions", []):
        if m.get("id") == MOON_BASE_MISSION_ID:
            return {"missionId": m["id"], "o2_mole_fraction": m.get("o2"),
                    "pressure_kpa": m.get("pressure_kpa"), "gravity_g": m.get("gravity_g")}
    return None


def _materials_outside_moon_base(df: pd.DataFrame, td: TaskData | None,
                                 moon: dict | None) -> tuple[int, int, list[str]]:
    """(outside, total, inputs outside) for the solid model at the Moon-base atmosphere.

    Uses the same ``valid_range`` as the app (predictor.dart): O2, pressure and gravity
    are checked against it; the mission has no single airflow, so airflow is not checked.
    """
    total = int(df["fuel_name"].dropna().nunique())
    rng = solid_valid_range(td)
    if moon is None or rng is None:
        return total, total, []
    outside_inputs = []
    for key, name in (("o2", "o2_mole_fraction"), ("pressure_kpa", "pressure_kpa"),
                      ("gravity_g", "gravity_g")):
        value = moon.get(name)
        if value is None or not _inside(value, *rng[key]):
            outside_inputs.append(name)
    return (total if outside_inputs else 0), total, outside_inputs


def _gap(gap_id: str, share: float, link: str, params: dict) -> dict:
    """One gap: score = mission relevance × data scarcity (1 − share of runs that cover it)."""
    score = GAP_RELEVANCE[gap_id] * max(0.0, 1.0 - share)
    return {"id": gap_id, "score": round(score, 3), "link": link, "params": params}


def _top_gaps(df: pd.DataFrame, gc: pd.Series) -> list[dict]:
    """Top 3 research gaps ranked by relevance × scarcity; copy lives in the app's l10n."""
    n_total = len(df)
    solids = _solid_micro(df, gc)
    hi = solids[solids["o2_mole_fraction"] >= HIGH_O2_LIMIT]
    hi_p = pd.to_numeric(hi["pressure_kpa"], errors="coerce").dropna()
    partial = df[gc == "partial"]
    n_partial_nasa = int(partial["source_type"].isin(["nasa_psi", "nasa_report"]).sum())
    n_earth = int((gc == "earth").sum())
    gaps = [
        _gap("high_o2_solids", len(hi) / max(len(solids), 1), "/map", {
            "limitPct": round(HIGH_O2_LIMIT * 100),
            "nHigh": len(hi),
            "nSolid": len(solids),
            "nHighWentOut": int(hi["sustained"].map(lambda v: v is False).sum()),
            "pressureMinKpa": round(float(hi_p.min()), 1) if len(hi_p) else None,
            "pressureMaxKpa": round(float(hi_p.max()), 1) if len(hi_p) else None,
        }),
        _gap("partial_gravity", len(partial) / max(n_total, 1), "/map", {
            "nPartial": len(partial),
            "nTotal": n_total,
            "nNasa": n_partial_nasa,
            "nThirdParty": int((partial["source_type"] == "third_party").sum()),
        }),
        _gap("earth_baseline", n_earth / max(n_total, 1), "/explore", {
            "nEarth": n_earth,
            "nTotal": n_total,
        }),
    ]
    gaps.sort(key=lambda g: g["score"], reverse=True)
    for i, g in enumerate(gaps, 1):
        g["rank"] = i
    return gaps


def build_home_key_findings(df: pd.DataFrame, tasks: dict[str, TaskData],
                            moon: dict | None = None) -> dict:
    """Key findings & gaps numbers for the Home panel (DESIGN.md §11.1b).

    All values are computed at export from the cleaned data; nothing is typed by hand.
    """
    gc = gravity_class(df["platform"], df["gravity_g"])
    td = tasks.get("sustain")
    map_low = _map_low_cells(td) if td is not None else K_MAP_COLS * K_MAP_ROWS
    outside, total, outside_inputs = _materials_outside_moon_base(df, td, moon)
    return {
        "home": {
            "maxO2MicrogravitySolidsPct": _max_o2_microgravity_solids_pct(df, gc),
            "mapLowCells": map_low,
            "mapTotalCells": K_MAP_COLS * K_MAP_ROWS,
            "materialsOutsideMoonBase": outside,
            "materialsTotal": total,
            "moonBase": {**(moon or {}), "outsideInputs": outside_inputs},
            "topGaps": _top_gaps(df, gc),
        }
    }


def authorship(source_type: str, url: str, strict: bool = True) -> str:
    """Who produced a source: nasa, partner, nasa_coauthored or independent.

    With ``strict`` (the real export) a third-party source without an explicit
    label raises, so no new paper is ever shown without one (PLAN.md §1.0
    "Third-party"); test fixtures pass ``strict=False`` and get "unlabelled".
    """
    if source_type in AUTHORSHIP_BY_TYPE:
        return AUTHORSHIP_BY_TYPE[source_type]
    if url in THIRD_PARTY_AUTHORSHIP:
        return THIRD_PARTY_AUTHORSHIP[url]
    if not strict:
        return "unlabelled"
    raise ValueError(f"third-party source {url!r} has no entry in THIRD_PARTY_AUTHORSHIP")


def build_sources(df: pd.DataFrame, dropped: list[dict], strict: bool = True) -> list[dict]:
    """Data provenance rows, one per cited source, largest first."""
    citation_of = df.set_index("run_id")["source_citation"]
    stale = [d["kept_run_id"] for d in dropped if d["kept_run_id"] not in citation_of.index]
    if stale:
        raise ValueError(f"dropped_rows.csv is stale (kept rows not in data: {stale}); rerun clean")
    dropped_by = pd.Series([citation_of.get(d["kept_run_id"]) for d in dropped],
                           dtype=object).value_counts()
    keys = ["source_type", "source_citation", "source_url"]
    out = []
    for (st, cit, url), g in df.fillna({"source_url": ""}).groupby(keys, sort=False):
        out.append({
            "source_type": st,
            "authorship": authorship(st, url, strict),
            "citation": cit,
            "url": url or None,
            "experiments": sorted(g["experiment"].astype(str).unique().tolist()),
            "n_runs": len(g),
            "n_dropped_duplicates": int(dropped_by.get(cit, 0)),
        })
    out.sort(key=lambda s: (-s["n_runs"], s["citation"]))
    return out


def model_use_counts(df: pd.DataFrame, tasks: dict[str, object]) -> dict[str, int]:
    """Runs per model, plus exclusive buckets (sustain_only + spread_only + both + neither = total)."""
    all_runs = set(df["run_id"].astype(str))
    used: dict[str, set[str]] = {}
    for task in ("sustain", "spread"):
        td = tasks.get(task)
        rows = getattr(td, "rows", None)
        used[task] = set(rows["run_id"].astype(str)) if rows is not None and len(rows) else set()
    sustain, spread = used["sustain"], used["spread"]
    return {
        "sustain": len(sustain),
        "spread": len(spread),
        "sustain_only": len(sustain - spread),
        "spread_only": len(spread - sustain),
        "both": len(sustain & spread),
        "neither": len(all_runs - sustain - spread),
    }


def check_counts(meta: dict) -> None:
    """Every count breakdown must sum to n_runs, so no row is silently uncounted."""
    n = meta["n_runs"]
    mu = meta["model_use"]
    sums = {
        "source_type": sum(meta["source_type"].values()),
        "gravity_class": sum(meta["gravity_class"].values()),
        "experiment": sum(meta["experiment"].values()),
        "model_use (exclusive)": mu["sustain_only"] + mu["spread_only"] + mu["both"] + mu["neither"],
        "sources": sum(s["n_runs"] for s in meta["sources"]),
    }
    bad = {k: v for k, v in sums.items() if v != n}
    if bad:
        raise ValueError(f"app_meta counts do not sum to n_runs={n}: {bad}")
    if meta["rows_ingested"] - meta["rows_dropped"] != n:
        raise ValueError("rows_ingested - rows_dropped != n_runs")


def load_dropped_rows(path: Path | None = None) -> list[dict]:
    """Rows dropped by clean (data/processed/dropped_rows.csv), or [] if none were logged."""
    path = path or config.DATA_PROCESSED / "dropped_rows.csv"
    if not path.exists():
        return []
    return pd.read_csv(path, dtype=str).fillna("").to_dict("records")


def build_app_meta(df: pd.DataFrame, runs_json: dict, tasks: dict[str, object],
                   dropped: list[dict] | None = None, moon: dict | None = None,
                   strict_authorship: bool = True) -> dict:
    """app_meta.json: counts, sources, build stamp and a data version hash.

    Counts are the single source of truth read by every page: total runs, by
    ``source_type``, by gravity class, by experiment and by model use.
    """
    dropped = dropped or []
    digest = hashlib.sha256(json.dumps(runs_json["rows"]).encode()).hexdigest()[:12]
    experiments = sorted(df["experiment"].dropna().astype(str).unique().tolist())
    gc = gravity_class(df["platform"], df["gravity_g"])
    meta = {
        "build_time_utc": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "git_sha": git_sha(),
        "n_runs": len(df),
        "rows_ingested": len(df) + len(dropped),
        "rows_dropped": len(dropped),
        "dropped_rows": dropped,
        "n_experiments": len(experiments),
        "n_fuels": int(df["fuel_name"].dropna().nunique()),
        "experiments": experiments,
        "source_type": _counts(df["source_type"], SOURCE_TYPES),
        "gravity_class": _counts(gc, GRAVITY_CLASSES),
        "experiment": df["experiment"].astype(str).value_counts().sort_index().to_dict(),
        "model_use": model_use_counts(df, tasks),
        "sources": build_sources(df, dropped, strict_authorship),
        **build_home_key_findings(df, tasks, moon),
        "data_version": digest,
    }
    meta["experiment"] = {k: int(v) for k, v in meta["experiment"].items()}
    check_counts(meta)
    return meta



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


def export_all(df: pd.DataFrame, artifacts_dir: Path, out_dir: Path,
               dropped: list[dict] | None = None, strict_authorship: bool = True) -> dict[str, Path]:
    """Write every app asset produced by export (PLAN.md §3.2).

    ``dropped`` is the clean step's drop log (``load_dropped_rows()`` for real data).
    """
    df = coerce_types(df)
    summaries = load_summaries(artifacts_dir)
    tasks = {t: prepare_task(df, t) for t in TASKS}
    runs_json = build_runs_json(df)
    models, parity = export_models(tasks, summaries, artifacts_dir)
    payloads: dict[str, object] = {
        "app_meta.json": build_app_meta(df, runs_json, tasks, dropped,
                                        moon_base_atmosphere(), strict_authorship),
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
    for warning in export_missions(config.DATA_MANUAL / "missions.json", out_dir):
        print(f"  missions: {warning}")
    for name, payload in (("lessons.json", build_lessons(config.DATA_MANUAL)),
                          ("usability.json", build_usability(config.DATA_MANUAL))):
        write_json(out_dir / name, payload, indent=1)
        written[name] = out_dir / name
    if (out_dir / "missions.json").exists():
        written["missions.json"] = out_dir / "missions.json"
    return written
