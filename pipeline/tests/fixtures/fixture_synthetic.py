"""Synthetic experiment runs for tests ONLY — not NASA data (CLAUDE.md rule 1).

Every row is labelled as a fixture in ``source_citation`` and ``notes`` so it
can never be mistaken for real data. Used by pipeline tests and by
``make_app_fixtures.py`` to build Dart test fixtures in ``app/test/fixtures``.
"""

from __future__ import annotations

import numpy as np
import pandas as pd

from flamesense.features import add_features
from flamesense.schema import CANONICAL_COLUMNS

FIXTURE_CITATION = "FIXTURE: synthetic test row, not NASA data"


def fixture_synthetic_runs(n: int = 160, n_groups: int = 6, seed: int = 7) -> pd.DataFrame:
    """Canonical rows with a learnable oxygen/flow signal plus derived features."""
    rng = np.random.default_rng(seed)
    o2 = rng.uniform(0.15, 0.40, n)
    pressure = rng.choice([50.0, 70.0, 101.3], n)
    flow = rng.uniform(0, 300, n)
    gravity = rng.choice([1e-6, 1.0], n)
    fuel_class = rng.choice(["thin_solid", "thick_solid"], n)
    thickness = np.where(fuel_class == "thin_solid", rng.uniform(0.05, 0.3, n),
                         rng.uniform(1, 10, n))
    score = 30 * (o2 - 0.22) + 0.004 * flow - 0.15 * thickness + rng.normal(0, 0.6, n)
    sustained = score > 0
    rate = np.exp(1 + 6 * (o2 - 0.2) - 0.1 * thickness + rng.normal(0, 0.2, n))
    df = pd.DataFrame({
        "run_id": [f"fixture:{i}" for i in range(n)],
        "group_id": [f"fixture:g{i % n_groups}" for i in range(n)],
        "experiment": rng.choice(["FIXTURE_A", "FIXTURE_B"], n),
        "platform": np.where(gravity < 0.5, "iss", "ground"),
        "gravity_g": gravity,
        "fuel_name": np.where(fuel_class == "thin_solid", "fixture-thin", "fixture-thick"),
        "fuel_class": fuel_class,
        "fuel_thickness_mm": thickness,
        "fuel_density_kg_m3": rng.uniform(300, 1200, n),
        "o2_mole_fraction": o2,
        "pressure_kpa": pressure,
        "diluent": "n2",
        "flow_velocity_mm_s": flow,
        "flow_direction": rng.choice(["opposed", "concurrent"], n),
        "ignited": True,
        "sustained": sustained,
        "flame_spread_rate_mm_s": rate,
        "burning_rate_k_mm2_s": np.nan,
        "extinction_reason": None,
        "source_id": "fixture",
        "source_file": "pipeline/tests/fixtures/fixture_synthetic.py",
        "source_citation": FIXTURE_CITATION,
        "source_url": None,
        "quality_flag": "ok",
        "notes": "fixture",
    })
    return add_features(df[CANONICAL_COLUMNS])
