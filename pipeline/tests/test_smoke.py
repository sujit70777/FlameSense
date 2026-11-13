"""Smoke test to verify test harness and package import."""

import flamesense


def test_import() -> None:
    """Verify flamesense package can be imported."""
    assert flamesense is not None
