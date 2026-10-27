"""Build Dart test fixtures from synthetic fixture rows (tests only, never shipped).

Run from repo root: pipeline/.venv/bin/python -m tests.make_app_fixtures  (cwd: pipeline)
Writes app/test/fixtures/fixture_<asset>.json for every exported asset.
"""

from __future__ import annotations

import json
import shutil
import tempfile
from pathlib import Path

from flamesense.evaluate import evaluate_all
from flamesense.export import export_all, write_json
from flamesense.train import train_all
from tests.fixtures.fixture_synthetic import fixture_synthetic_runs

APP_FIXTURES = Path(__file__).resolve().parents[2] / "app" / "test" / "fixtures"

FIXTURE_PHYSICS = {
    "version": "1",
    "signed_off_by_lead": True,
    "signed_off_on": "FIXTURE",
    "gas": {"lambda_w_mk": 0.04, "alpha_m2_s": 2.2e-5, "t_inf_k": 300.0,
            "source": "FIXTURE: not real values"},
    "fuels": {"fixture-thin": {"fuel_class": "thin_solid", "rho_kg_m3": 1000.0,
                               "c_j_kgk": 2000.0, "t_v_k": 500.0, "half_thickness_m": 0.0005,
                               "source": "FIXTURE: not real values"}},
    "flame_temp_vs_o2": {"o2": [0.21, 0.30], "t_f_k": [1000.0, 1500.0],
                         "source": "FIXTURE: not real values"},
    "buoyant_velocity": {"enabled": True, "source": "FIXTURE: not real values"},
}


def main() -> None:
    """Train/export on fixture rows and copy every asset into app/test/fixtures."""
    df = fixture_synthetic_runs()
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        train_all(df, root / "artifacts")
        export_all(df, root / "artifacts", root / "out")
        metrics = evaluate_all(df, root / "artifacts")
        write_json(root / "out" / "metrics.json", metrics, indent=1)
        write_json(root / "out" / "physics_params.json", FIXTURE_PHYSICS, indent=1)
        APP_FIXTURES.mkdir(parents=True, exist_ok=True)
        for f in sorted((root / "out").glob("*.json")):
            shutil.copy(f, APP_FIXTURES / f"fixture_{f.name}")
            print("wrote", APP_FIXTURES / f"fixture_{f.name}")
    meta = json.loads((APP_FIXTURES / "fixture_app_meta.json").read_text())
    print("fixture runs:", meta["n_runs"])


if __name__ == "__main__":
    main()
