"""Tests for Phase 4: physics.py reference model.

Fixture numbers below are hand-computed test values chosen for clean math —
they are NOT real physical parameters (CLAUDE.md rule: never invent data).
"""

from pathlib import Path

import numpy as np
import pytest

from flamesense.physics import (
    applicability,
    buoyant_velocity_m_s,
    effective_flow_mm_s,
    interpolate_flame_temp_k,
    load_params,
    spread_rate_mm_s,
    validate_params,
)


def fixture_params() -> dict:
    """A complete params dict with clean hand-computed fixture values."""
    return {
        "version": "1",
        "signed_off_by_sci": False,
        "gas": {
            "lambda_w_mk": 0.04,
            "alpha_m2_s": 2.2e-5,
            "t_inf_k": 300.0,
            "source": "fixture source (not real)",
        },
        "fuels": {
            "test_fuel": {
                "fuel_class": "thin_solid",
                "rho_kg_m3": 1000.0,
                "c_j_kgk": 2000.0,
                "t_v_k": 500.0,
                "half_thickness_m": 0.0005,
                "source": "fixture source (not real)",
            }
        },
        "flame_temp_vs_o2": {
            "o2": [0.21, 0.30],
            "t_f_k": [1000.0, 1500.0],
            "source": "fixture source (not real)",
        },
        "buoyant_velocity": {"enabled": True, "source": "fixture source (not real)"},
    }


def fixture_row(fuel_name: str = "test_fuel", **overrides) -> dict:
    """A single run row used for physics checks."""
    row = {
        "run_id": "fixture:physics_1",
        "fuel_name": fuel_name,
        "fuel_class": "thin_solid",
        "flow_direction": "opposed",
        "o2_mole_fraction": 0.21,
        "gravity_g": 1e-6,
        "flow_velocity_mm_s": 50.0,
    }
    row.update(overrides)
    return row


# --- Equation 1: de Ris ---------------------------------------------------


def test_de_ris_spread_rate_hand_computed() -> None:
    """V_f = (π/4)·λ_g·(T_f−T_v)/(ρ_s·c_s·τ·(T_v−T_∞)), converted to mm/s.

    With λ_g=0.04, T_f=1000 (interpolated at O₂ 0.21), T_v=500, ρ=1000,
    c=2000, τ=0.0005 m, T_∞=300:
      V_f = (π/4)·0.04·500 / (1000·2000·0.0005·200) m/s
          = 5π/200 m/s = π/40 ≈ 0.07853982 mm/s.
    """
    row = fixture_row()
    assert spread_rate_mm_s(row, fixture_params()) == pytest.approx(0.07853981633974484)


def test_de_ris_flame_temp_interpolated_in_o2() -> None:
    """T_f is linearly interpolated, so higher O₂ gives a faster spread."""
    params = fixture_params()
    low = spread_rate_mm_s(fixture_row(o2_mole_fraction=0.21), params)
    high = spread_rate_mm_s(fixture_row(o2_mole_fraction=0.30), params)
    assert high is not None and low is not None
    assert high > low


# --- Equation 2: buoyant velocity -----------------------------------------


def test_buoyant_velocity_hand_computed_microgravity() -> None:
    """U_b = (g·α_g·(T_f−T_∞)/T_∞)^(1/3), g = 1e-6 × 9.80665.

     (1e-6·9.80665·2.2e-5·700/300)^(1/3) ≈ 0.0007954997495119054 m/s.
     """
    ub = buoyant_velocity_m_s(1e-6, fixture_params(), o2_mole_fraction=0.21)
    assert ub == pytest.approx(0.0007954997495119054)


def test_buoyant_velocity_hand_computed_earth() -> None:
    """At 1 g the buoyant velocity is 1000× the microgravity value (cube root)."""
    ub = buoyant_velocity_m_s(1.0, fixture_params(), o2_mole_fraction=0.21)
    assert ub == pytest.approx(0.07954997495119052)


def test_effective_flow_combines_forced_and_buoyant() -> None:
    """U_eff = sqrt(U_forced² + U_b²). With U_forced=300 mm/s, U_b≈0.7955 mm/s."""
    u_eff = effective_flow_mm_s(300.0, 1e-6, fixture_params())
    assert u_eff == pytest.approx(np.sqrt(300.0**2 + (0.0007954997495119054 * 1000.0) ** 2))


# --- Interpolation / guards -----------------------------------------------


def test_interpolate_flame_temp_linear() -> None:
    """Linear interpolation in O₂: (0.21,1000)→(0.30,1500) at 0.25 → 1222.22…"""
    assert interpolate_flame_temp_k(fixture_params(), 0.25) == pytest.approx(1222.2222222222222)


def test_interpolate_flame_temp_clamps_outside_grid() -> None:
    """O₂ outside the table clamps to the nearest endpoint (np.interp)."""
    params = fixture_params()
    assert interpolate_flame_temp_k(params, 0.10) == pytest.approx(1000.0)
    assert interpolate_flame_temp_k(params, 0.50) == pytest.approx(1500.0)


def test_spread_rate_none_when_parameter_missing() -> None:
    """A null parameter yields None, never a guessed number."""
    params = fixture_params()
    params["gas"]["lambda_w_mk"] = None
    assert spread_rate_mm_s(fixture_row(), params) is None

    params = fixture_params()
    params["flame_temp_vs_o2"]["t_f_k"] = [1000.0, None]
    assert spread_rate_mm_s(fixture_row(), params) is None

    params = fixture_params()
    params["fuels"]["test_fuel"]["t_v_k"] = None
    assert spread_rate_mm_s(fixture_row(), params) is None


def test_spread_rate_none_for_unknown_fuel_or_invalid_domain() -> None:
    """Unknown fuel and non-physical temperature ordering both give None."""
    assert spread_rate_mm_s(fixture_row(fuel_name="not_in_params"), fixture_params()) is None

    params = fixture_params()
    params["fuels"]["test_fuel"]["t_v_k"] = 200.0  # T_v <= T_∞ → invalid domain
    assert spread_rate_mm_s(fixture_row(), params) is None

    params = fixture_params()
    params["fuels"]["test_fuel"]["t_v_k"] = 1100.0  # T_f <= T_v → invalid domain
    assert spread_rate_mm_s(fixture_row(), params) is None


# --- Applicability ---------------------------------------------------------


def test_applicability_rules() -> None:
    """Regime matrix: thin+opposed ok; quiescent ok; others not_applicable."""
    assert applicability(fixture_row()) == "ok"
    assert applicability(fixture_row(flow_direction="quiescent")) == "ok"
    assert applicability(fixture_row(fuel_class="thick_solid")) == "not_applicable"
    assert applicability(fixture_row(fuel_class="droplet")) == "not_applicable"
    assert applicability(fixture_row(flow_direction="concurrent")) == "not_applicable"


def test_applicability_near_extinction_warning() -> None:
    """Very low O₂ or quiescent microgravity triggers the warning (TODO(Q-1))."""
    assert applicability(fixture_row(o2_mole_fraction=0.12)) == "near_extinction_warning"
    assert (
        applicability(fixture_row(gravity_g=1e-6, flow_velocity_mm_s=2.0))
        == "near_extinction_warning"
    )
    # 50 mm/s forced flow in microgravity is not near-extinction.
    assert applicability(fixture_row(gravity_g=1e-6, flow_velocity_mm_s=50.0)) == "ok"


# --- Validation and loading -------------------------------------------------


def test_validate_params_fixture_is_valid() -> None:
    """The complete fixture params pass validation."""
    assert validate_params(fixture_params()) == []


def test_validate_params_reports_null_values_and_empty_sources() -> None:
    """Missing values and empty sources are each reported."""
    params = fixture_params()
    params["gas"]["lambda_w_mk"] = None
    params["gas"]["source"] = ""
    params["fuels"]["test_fuel"]["t_v_k"] = None
    params["flame_temp_vs_o2"]["t_f_k"] = [1000.0, None]
    problems = validate_params(params)
    assert any("gas.lambda_w_mk" in p for p in problems)
    assert any("gas.source is empty" in p for p in problems)
    assert any("fuels.test_fuel.t_v_k" in p for p in problems)
    assert any("flame_temp_vs_o2.t_f_k" in p for p in problems)


def test_validate_params_requires_nonempty_fuels() -> None:
    """An empty fuels map is reported."""
    params = fixture_params()
    params["fuels"] = {}
    assert any("fuels is empty" in p for p in validate_params(params))


def test_validate_params_none() -> None:
    """Missing file reports a clear problem and no other confusion."""
    assert validate_params(None) == ["physics_params.json is missing"]


def test_load_params_template_file_and_missing_path() -> None:
    """The real §3.7 template loads; a missing path returns None."""
    from flamesense.config import DATA_MANUAL

    params = load_params(DATA_MANUAL / "physics_params.json")
    assert params is not None
    assert params["version"] == "1"
    assert params["signed_off_by_sci"] is False
    # Template has no invented values yet — everything SCI must fill is null.
    assert params["gas"]["lambda_w_mk"] is None

    assert load_params(Path("/nonexistent/physics_params.json")) is None


def test_template_reports_all_missing_until_sci_fills_values() -> None:
    """physics-check on the untouched template reports missing params."""
    from flamesense.config import DATA_MANUAL

    params = load_params(DATA_MANUAL / "physics_params.json")
    problems = validate_params(params)
    assert len(problems) > 0
    assert all("null" in p or "empty" in p or "missing" in p for p in problems)