"""Solid-model valid range (PLAN.md §1.0 "Solid flammability", AUDIT §15e)."""

import numpy as np
import pandas as pd

from flamesense.export import (
    _materials_outside_moon_base,
    in_valid_range,
    solid_valid_range,
)
from flamesense.train import TaskData


def _task(rows: list[tuple[float, float, float, int]]) -> TaskData:
    """Sustain TaskData (all microgravity) from (o2, pressure_kpa, flow_mm_s, burned)."""
    df = pd.DataFrame(rows, columns=["o2_mole_fraction", "pressure_kpa",
                                     "flow_velocity_mm_s", "sustained"])
    df["gravity_g"] = 1e-6
    df["fuel_name"] = "fixture_fabric"
    return TaskData(task="sustain", available=True, reason=None,
                    features=["o2_mole_fraction"], rows=df,
                    y=df["sustained"].to_numpy(), groups=np.arange(len(df)))


# Shaped like the real data: went-out runs only near 1 atm and <= 22%; burned runs
# also at 25-31% O2 and 54-73 kPa (Saffire V/VI), all at one airflow.
FIXTURE = [
    (0.164, 101.3, 100.0, 0), (0.172, 101.3, 470.0, 0), (0.221, 100.0, 200.0, 0),
    (0.169, 101.3, 530.0, 1), (0.207, 101.3, 20.0, 1), (0.220, 100.0, 200.0, 1),
    (0.262, 70.7, 200.0, 1), (0.303, 54.6, 200.0, 1), (0.310, 54.1, 200.0, 1),
]


def test_valid_range_is_where_both_outcomes_were_seen() -> None:
    rng = solid_valid_range(_task(FIXTURE))
    assert rng == {"rule": "both_outcomes", "o2": [0.169, 0.221],
                   "pressure_kpa": [100.0, 101.3], "flow_mm_s": [100.0, 470.0],
                   "gravity_g": [1e-6, 1e-6]}


def test_moon_base_conditions_are_outside() -> None:
    """O2 0.30 and 0.34 at 56.5-70.3 kPa (8.2-10.2 psi): never inside."""
    rng = solid_valid_range(_task(FIXTURE))
    for o2 in (0.30, 0.34):
        for p in np.linspace(56.5, 70.3, 7):
            for flow in (100.0, 200.0, 400.0):
                assert not in_valid_range(rng, o2, float(p), flow, 1e-6)
    assert in_valid_range(rng, 0.21, 101.3, 200.0, 1e-6)


def test_untested_gravity_is_outside() -> None:
    """Microgravity-only data: 1 g and Moon gravity get no number (never the orbit value)."""
    rng = solid_valid_range(_task(FIXTURE))
    for g in (1.0, 0.1654, 0.3794):
        assert not in_valid_range(rng, 0.21, 101.3, 200.0, g)


def test_one_outcome_only_means_no_range() -> None:
    burned_only = [r for r in FIXTURE if r[3] == 1]
    assert solid_valid_range(_task(burned_only)) is None
    assert not in_valid_range(None, 0.21, 101.3, 200.0, 1e-6)


def test_moon_base_finding_uses_valid_range() -> None:
    td = _task(FIXTURE)
    moon = {"o2_mole_fraction": 0.30, "pressure_kpa": 56.5, "gravity_g": 0.1654}
    outside, total, inputs = _materials_outside_moon_base(td.rows, td, moon)
    assert (outside, total) == (1, 1)
    assert inputs == ["o2_mole_fraction", "pressure_kpa", "gravity_g"]
    iss = {"o2_mole_fraction": 0.21, "pressure_kpa": 101.0, "gravity_g": 1e-6}
    assert _materials_outside_moon_base(td.rows, td, iss)[0] == 0
