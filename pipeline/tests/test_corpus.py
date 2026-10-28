"""Tests for corpus.py and ask_cache question loading (fixtures only)."""

from pathlib import Path

import pytest

from flamesense.ask_cache import load_questions
from flamesense.corpus import MAX_CHUNK, build_corpus, chunk_text, write_corpus

FIX = Path(__file__).parent / "fixtures"


def test_chunks_respect_length_and_overlap() -> None:
    """Chunks are ≤ 1,200 chars, split on sentences, and overlap the previous chunk."""
    text = " ".join(f"Sentence number {i} talks about flames in orbit." for i in range(200))
    chunks = chunk_text(text)
    assert len(chunks) > 1
    assert all(len(c) <= MAX_CHUNK for c in chunks)
    assert all(c.endswith(".") for c in chunks)
    tail = chunks[0][-60:]
    assert tail.split(". ")[-1] in chunks[1]


def test_build_corpus_from_html(tmp_path: Path) -> None:
    """HTML is stripped of tags/scripts and chunked with D<n>#<seq> ids."""
    (tmp_path / "doc.html").write_text((FIX / "fixture_doc.html").read_text())
    (tmp_path / "corpus_meta.csv").write_text(
        "file,title,url,year,license_note\ndoc.html,FIXTURE doc,https://example.test,2020,fixture\n")
    corpus = build_corpus(tmp_path)
    assert corpus["docs"][0]["doc_id"] == "D1"
    assert corpus["chunks"][0]["id"] == "D1#001"
    assert "var a" not in corpus["chunks"][0]["text"]
    assert write_corpus(corpus, tmp_path / "out.json") > 0


def test_missing_meta_gives_empty_corpus_and_license_is_required(tmp_path: Path) -> None:
    """No meta → empty corpus; a row without license_note fails."""
    assert build_corpus(tmp_path)["chunks"] == []
    (tmp_path / "doc.html").write_text("<p>x</p>")
    (tmp_path / "corpus_meta.csv").write_text("file,title,url,year,license_note\ndoc.html,T,u,2020,\n")
    with pytest.raises(ValueError):
        build_corpus(tmp_path)


def test_suggested_questions_come_from_the_arb_files() -> None:
    """ask-cache uses the same six questions as the UI."""
    qs = load_questions(Path(__file__).resolve().parents[2] / "app" / "lib" / "l10n")
    assert len(qs) == 6
    assert qs["askQ1"][0] == "Why are flames round in microgravity?"
