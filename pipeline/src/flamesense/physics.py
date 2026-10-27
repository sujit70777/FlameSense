"""Physics reference model (Phase 4).

Reference check for the ML predictions, never the product. All parameter
values come exclusively from ``data/manual/physics_params.json``; any value
that is null makes the corresponding prediction return ``None`` (never a
guessed number).

Equations (PLAN.md Phase 4, pending [LEAD] sign-off in docs/PHYSICS_SPEC.md):

1. de Ris (1969) thermally thin opposed-flow spread:
   V_f = (π/4) · λ_g · (T_f − T_v) / (ρ_s · c_s · τ · (T_v − T_∞))   [m/s]
2. Characteristic buoyant velocity:
   U_b = (g · α_g · (T_f − T_∞) / T_∞)^(1/3),  g = gravity_g × 9.80665
"""

import json
import math
from pathlib import Path

import numpy as np

from flamesense.config import DATA_MANUAL

DEFAULT_PARAMS_PATH = DATA_MANUAL / "physics_params.json"

# Near-extinction warning threshold (TODO(Q-1), see docs/QUESTIONS.md).
NEAR_EXTINCTION_O2 = 0.15  # below this O₂ mole fraction, spread is over-predicted
NEAR_EXTINCTION_MICROG = 0.01  # gravity_g below this counts as microgravity
NEAR_EXTINCTION_FLOW_MM_S = 5.0  # quiescent-like forced flow for the warning


def load_params(path: Path | None = None) -> dict | None:
    """Load physics_params.json; return None if the file is missing."""
    params_path = path or DEFAULT_PARAMS_PATH
    if not params_path.exists():
        return None
    with open(params_path, "r", encoding="utf-8") as f:
        return json.load(f)


def interpolate_flame_temp_k(params: dict, o2_mole_fraction: float) -> float | None:
    """Flame temperature (K) by linear interpolation in O₂; None if unknown."""
    table = params.get("flame_temp_vs_o2") or {}
    xs = table.get("o2") or []
    ys = table.get("t_f_k") or []
    if not xs or len(xs) != len(ys) or any(y is None for y in ys):
        return None
    return float(np.interp(o2_mole_fraction, xs, ys))


def buoyant_velocity_m_s(g: float, params: dict, o2_mole_fraction: float = 0.21) -> float | None:
    """Characteristic buoyant velocity (m/s) for gravity_g `g`.

    Uses the flame temperature at `o2_mole_fraction` (default: standard air,
    0.21) since the equation needs a representative T_f.
    """
    gas = params.get("gas") or {}
    alpha = gas.get("alpha_m2_s")
    t_inf = gas.get("t_inf_k")
    if alpha is None or t_inf is None:
        return None
    t_f = interpolate_flame_temp_k(params, o2_mole_fraction)
    if t_f is None or t_f <= t_inf:
        return None
    g_m_s2 = g * 9.80665
    return (g_m_s2 * alpha * (t_f - t_inf) / t_inf) ** (1.0 / 3.0)


def effective_flow_mm_s(
    flow_velocity_mm_s: float | None, gravity_g: float, params: dict
) -> float | None:
    """U_eff = sqrt(U_forced² + U_b²) in mm/s — explanation/map axis note only.

    Does not change the de Ris spread rate (PLAN.md Phase 4, eq. 2).
    """
    ub = buoyant_velocity_m_s(gravity_g, params)
    if ub is None:
        return None
    forced = flow_velocity_mm_s or 0.0
    return math.sqrt(forced**2 + (ub * 1000.0) ** 2)


def applicability(row) -> str:
    """Regime check: "ok" | "not_applicable" | "near_extinction_warning"."""
    fuel_class = row.get("fuel_class")
    flow_direction = row.get("flow_direction")
    if fuel_class != "thin_solid" or flow_direction not in ("opposed", "quiescent"):
        return "not_applicable"

    o2 = row.get("o2_mole_fraction")
    gravity = row.get("gravity_g")
    flow = row.get("flow_velocity_mm_s")
    if o2 is not None and not np.isnan(o2) and o2 < NEAR_EXTINCTION_O2:
        return "near_extinction_warning"
    microgravity = gravity is not None and not np.isnan(gravity) and gravity < NEAR_EXTINCTION_MICROG
    if microgravity and (flow is None or np.isnan(flow) or flow < NEAR_EXTINCTION_FLOW_MM_S):
        return "near_extinction_warning"
    return "ok"


def spread_rate_mm_s(row, params: dict | None = None) -> float | None:
    """de Ris thin-fuel spread rate in mm/s, or None when not computable.

    Returns None when the row's fuel is unknown/not thin solid, any required
    parameter is null, the flame temperature is unavailable, or the inputs are
    outside the formula's physical domain (T_f must exceed T_v, T_v must
    exceed T_∞). Never falls back to a guessed value.
    """
    if params is None:
        params = load_params()
        if params is None:
            return None

    gas = params.get("gas") or {}
    lam_g = gas.get("lambda_w_mk")
    t_inf = gas.get("t_inf_k")
    if lam_g is None or t_inf is None:
        return None

    fuel = (params.get("fuels") or {}).get(row.get("fuel_name"))
    if not fuel:
        return None
    rho = fuel.get("rho_kg_m3")
    c_s = fuel.get("c_j_kgk")
    t_v = fuel.get("t_v_k")
    tau = fuel.get("half_thickness_m")
    if None in (rho, c_s, t_v, tau) or t_v <= t_inf:
        return None

    t_f = interpolate_flame_temp_k(params, row.get("o2_mole_fraction"))
    if t_f is None or t_f <= t_v:
        return None

    v_m_s = (math.pi / 4.0) * lam_g * (t_f - t_v) / (rho * c_s * tau * (t_v - t_inf))
    return v_m_s * 1000.0


def validate_params(params: dict | None) -> list[str]:
    """Return a list of parameter problems; empty list means valid.

    Checks that every required value is not null and every ``source`` is
    non-empty (PLAN.md Phase 4 step 1). `signed_off_by_lead` is deliberately
    not part of validity here — it is a release gate reported separately.
    """
    if params is None:
        return ["physics_params.json is missing"]

    problems: list[str] = []

    gas = params.get("gas") or {}
    for key, label in [
        ("lambda_w_mk", "gas.lambda_w_mk (W/m·K)"),
        ("alpha_m2_s", "gas.alpha_m2_s (m²/s)"),
        ("t_inf_k", "gas.t_inf_k (K)"),
    ]:
        if gas.get(key) is None:
            problems.append(f"{label} is null (required)")
    if not (gas.get("source") or "").strip():
        problems.append("gas.source is empty (required)")

    flame = params.get("flame_temp_vs_o2") or {}
    xs = flame.get("o2") or []
    ys = flame.get("t_f_k") or []
    if not xs or not ys:
        problems.append("flame_temp_vs_o2 table is empty (required)")
    elif len(xs) != len(ys):
        problems.append("flame_temp_vs_o2.o2 and t_f_k must have equal lengths")
    else:
        if any(y is None for y in ys):
            problems.append(f"flame_temp_vs_o2.t_f_k has {sum(y is None for y in ys)} null value(s)")
        if list(xs) != sorted(xs):
            problems.append("flame_temp_vs_o2.o2 must be strictly increasing")
    if not (flame.get("source") or "").strip():
        problems.append("flame_temp_vs_o2.source is empty (required)")

    fuels = params.get("fuels") or {}
    if not fuels:
        problems.append("fuels is empty — at least one fuel entry is required")
    for name, fuel in fuels.items():
        for key, label in [
            ("rho_kg_m3", f"fuels.{name}.rho_kg_m3 (kg/m³)"),
            ("c_j_kgk", f"fuels.{name}.c_j_kgk (J/kg·K)"),
            ("t_v_k", f"fuels.{name}.t_v_k (K)"),
            ("half_thickness_m", f"fuels.{name}.half_thickness_m (m)"),
        ]:
            if fuel.get(key) is None:
                problems.append(f"{label} is null (required)")
        if not (fuel.get("source") or "").strip():
            problems.append(f"fuels.{name}.source is empty (required)")

    buoyant = params.get("buoyant_velocity") or {}
    if buoyant.get("enabled") and not (buoyant.get("source") or "").strip():
        problems.append("buoyant_velocity.source is empty (required while enabled)")

    return problems