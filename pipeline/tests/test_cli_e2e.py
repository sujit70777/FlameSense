"""End-to-end CLI run on synthetic fixture rows in a temp tree (no repo files touched)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

from flamesense import cli, config, inspect_data, physics
from flamesense.ingest import registry
from flamesense.schema import CANONICAL_COLUMNS
from tests.fixtures.fixture_synthetic import fixture_synthetic_runs
from tests.make_app_fixtures import FIXTURE_PHYSICS


@pytest.fixture()
def tree(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    """Temp repo layout with fixture rows, fixture physics params and an HTML corpus doc."""
    manual, raw = tmp_path / "data" / "manual", tmp_path / "data" / "raw"
    for d in (manual, raw, tmp_path / "pipeline", tmp_path / "docs" / "img", tmp_path / "data" / "corpus_raw"):
        d.mkdir(parents=True, exist_ok=True)
    fixture_synthetic_runs()[CANONICAL_COLUMNS].to_csv(manual / "fixture_runs.csv", index=False)
    (manual / "physics_params.json").write_text(json.dumps(FIXTURE_PHYSICS))
    (tmp_path / "pipeline" / "sources.yaml").write_text(
        f"sources:\n  - id: fixture\n    adapter: manual_csv\n    files: ['{manual}/fixture_runs.csv']\n")
    corpus = tmp_path / "data" / "corpus_raw"
    (corpus / "d.html").write_text("<p>" + "FIXTURE flames are round in microgravity. " * 20 + "</p>")
    (corpus / "corpus_meta.csv").write_text("file,title,url,year,license_note\nd.html,FIXTURE,https://example.test,2020,fixture\n")
    paths = {"ROOT": tmp_path, "DATA_RAW": raw, "DATA_MANUAL": manual, "DATA_INTERIM": tmp_path / "data" / "interim",
             "DATA_PROCESSED": tmp_path / "data" / "processed", "CORPUS_RAW": corpus,
             "PIPELINE_OUT": tmp_path / "pipeline" / "out", "APP_ASSETS_OUT": tmp_path / "pipeline" / "out" / "app_assets",
             "DOCS": tmp_path / "docs", "DOCS_IMG": tmp_path / "docs" / "img", "ARTIFACTS": tmp_path / "artifacts"}
    for k, v in paths.items():
        monkeypatch.setattr(config, k, v)
    for k in ("ROOT", "DATA_RAW", "DATA_INTERIM"):
        monkeypatch.setattr(registry, k, paths[k])
    for k in ("DATA_RAW", "DATA_MANUAL", "DOCS"):
        monkeypatch.setattr(inspect_data, k, paths[k])
    monkeypatch.setattr(physics, "DEFAULT_PARAMS_PATH", manual / "physics_params.json")
    return tmp_path


def run(monkeypatch: pytest.MonkeyPatch, *args: str) -> None:
    """Invoke the CLI main() with argv."""
    monkeypatch.setattr(sys, "argv", ["flamesense", *args])
    cli.main()


def test_full_pipeline(tree: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """inspect, all (ingest → evaluate), physics-check and corpus produce every artefact."""
    run(monkeypatch, "inspect")
    assert (tree / "docs" / "DATA_INSPECTION.md").exists()
    run(monkeypatch, "all")
    out = tree / "pipeline" / "out" / "app_assets"
    for name in ["app_meta.json", "runs.json", "feature_spec.json", "model_sustain.json", "metrics.json",
                 "support_index.json", "parity_fixtures.json", "lessons.json", "usability.json"]:
        assert (out / name).exists(), name
    meta = json.loads((out / "app_meta.json").read_text())
    assert meta["n_runs"] == 160
    assert "Sustain" in (tree / "docs" / "MODEL_CARD.md").read_text()
    assert (tree / "docs" / "img" / "calibration.png").exists()
    assert (tree / "docs" / "DATA_REPORT.md").exists()
    run(monkeypatch, "physics-check")
    run(monkeypatch, "corpus")
    chunks = json.loads((tree / "pipeline" / "out" / "corpus_chunks.json").read_text())
    assert chunks["chunks"][0]["id"] == "D1#001"


def test_commands_fail_cleanly_without_inputs(tree: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """validate/clean/train exit 1 with a hint when their inputs are missing."""
    for cmd in ("validate", "clean", "train"):
        with pytest.raises(SystemExit) as e:
            run(monkeypatch, cmd)
        assert e.value.code == 1
