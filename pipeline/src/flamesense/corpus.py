"""Corpus processing for Ask (PLAN.md §3.9, Phase 12 step 1).

Reads data/corpus_raw/corpus_meta.csv (file,title,url,year,license_note), extracts text per
page (PDF via pypdf, HTML by stripping tags), drops pages under 200 characters, and chunks
each page into ≤ 1,200-character chunks on sentence boundaries with 150-character overlap.
"""

from __future__ import annotations

import csv
import html
import json
import re
from pathlib import Path

MAX_CHUNK = 1200
OVERLAP = 150
MIN_PAGE_CHARS = 200
MAX_TOTAL_BYTES = 8 * 1024 * 1024
META_COLUMNS = ["file", "title", "url", "year", "license_note"]


def normalize(text: str) -> str:
    """Collapse whitespace."""
    return re.sub(r"\s+", " ", text).strip()


def html_pages(path: Path) -> list[str]:
    """One 'page' of text from an HTML file (scripts/styles and tags removed)."""
    raw = path.read_text(encoding="utf-8", errors="replace")
    raw = re.sub(r"(?is)<(script|style)[^>]*>.*?</\1>", " ", raw)
    return [normalize(html.unescape(re.sub(r"<[^>]+>", " ", raw)))]


def pdf_pages(path: Path) -> list[str]:
    """Text of each PDF page."""
    from pypdf import PdfReader

    return [normalize(page.extract_text() or "") for page in PdfReader(str(path)).pages]


def chunk_text(text: str, max_len: int = MAX_CHUNK, overlap: int = OVERLAP) -> list[str]:
    """Split on sentence boundaries into ≤ max_len chunks; each starts with ≈ overlap chars of the previous."""
    sentences = [s for s in re.split(r"(?<=[.!?])\s+", text) if s]
    chunks: list[str] = []
    current = ""
    for s in sentences:
        while len(s) > max_len:  # very long sentence: hard split
            chunks.append((current + " " + s[: max_len - len(current) - 1]).strip() if current else s[:max_len])
            s = s[max_len - (len(current) + 1 if current else 0):]
            current = ""
        candidate = f"{current} {s}".strip()
        if len(candidate) <= max_len:
            current = candidate
            continue
        chunks.append(current)
        tail = current[-overlap:]
        tail = tail[tail.find(" ") + 1:] if " " in tail else tail
        current = f"{tail} {s}".strip()
        if len(current) > max_len:
            current = s
    if current:
        chunks.append(current)
    return chunks


def read_meta(meta_path: Path) -> list[dict[str, str]]:
    """Rows of corpus_meta.csv (validated columns)."""
    with open(meta_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        missing = [c for c in META_COLUMNS if c not in (reader.fieldnames or [])]
        if missing:
            raise ValueError(f"corpus_meta.csv is missing columns: {missing}")
        return list(reader)


def build_corpus(corpus_dir: Path) -> dict:
    """corpus_chunks.json content; empty when corpus_meta.csv is absent."""
    meta_path = corpus_dir / "corpus_meta.csv"
    out: dict = {"version": "1", "docs": [], "chunks": []}
    if not meta_path.exists():
        return out
    for n, row in enumerate(read_meta(meta_path), start=1):
        path = corpus_dir / row["file"]
        if not path.exists():
            raise FileNotFoundError(f"{path} listed in corpus_meta.csv does not exist")
        if not row["license_note"].strip():
            raise ValueError(f"{row['file']}: license_note is required (AUDIT §1)")
        doc_id = f"D{n}"
        year = int(row["year"]) if row["year"].strip().isdigit() else None
        out["docs"].append({"doc_id": doc_id, "title": row["title"], "url": row["url"],
                            "year": year, "license_note": row["license_note"]})
        pages = pdf_pages(path) if path.suffix.lower() == ".pdf" else html_pages(path)
        seq = 0
        for page_no, text in enumerate(pages, start=1):
            if len(text) < MIN_PAGE_CHARS:
                continue
            for chunk in chunk_text(text):
                seq += 1
                out["chunks"].append({"id": f"{doc_id}#{seq:03d}", "doc_id": doc_id, "page": page_no, "text": chunk})
    return out


def write_corpus(corpus: dict, out_path: Path) -> int:
    """Write the JSON; fail if it exceeds 8 MB. Returns the size in bytes."""
    data = json.dumps(corpus, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    if len(data) > MAX_TOTAL_BYTES:
        raise ValueError(f"corpus_chunks.json is {len(data) / 1e6:.1f} MB (> 8 MB); remove documents")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(data)
    return len(data)
