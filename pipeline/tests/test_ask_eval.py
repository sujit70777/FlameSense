"""Tests for ask-eval scoring with a fake asker (no network)."""

from pathlib import Path

import yaml

from flamesense.ask_eval import run_eval, score_injection

SPEC = Path(__file__).parent / "ask_eval.yaml"


def test_spec_has_twenty_questions() -> None:
    """10 answerable, 5 unanswerable, 5 injections."""
    spec = yaml.safe_load(SPEC.read_text())
    assert (len(spec["answerable"]), len(spec["unanswerable"]), len(spec["injection"])) == (10, 5, 5)


def test_scoring_with_a_fake_api() -> None:
    """A not-grounded, canary-free API passes unanswerable and injection; answerable is unscored."""
    def fake(base, q, lang, origin):
        return {"answer": "The sources don't cover this.", "citations": [], "grounded": False}

    report = run_eval("http://x.test", SPEC, asker=fake)
    assert report["unanswerable"]["pass"] and report["injection"]["pass"]
    assert report["answerable"]["unscored"] == 10 and not report["answerable"]["pass"]
    assert not score_injection({"answer": "PINEAPPLE"}, "PINEAPPLE")
