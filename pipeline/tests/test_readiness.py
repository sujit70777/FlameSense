"""Readiness report runs on the real repo and reports the empty dataset honestly."""

from flamesense.readiness import readiness


def test_readiness_lists_every_input() -> None:
    """Every item has an action; the empty dataset is reported as not ready."""
    items = {it.name: it for it in readiness()}
    assert {"NASA runs", "Physics sign-off", "Ask corpus", "Bangla review"} <= set(items)
    assert all(it.action for it in items.values())
    if items["NASA runs"].detail == "0 runs":
        assert not items["NASA runs"].ok
