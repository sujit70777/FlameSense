"""Coverage atlas of NASA PSI combustion investigations (PLAN Phase 3C, F19).

Reads every `data/raw/psi/<PSI-id>_<ACRONYM>/` folder (metadata.json + experimental tables),
detects which canonical quantities each table can fill, and writes `coverage.json`: one record per
investigation plus a matrix of runs by gravity class x O2 band x pressure band. Only values printed
in the tables are used; a row is placed in the matrix only when its table states a single O2 value
and a single pressure for it.
"""

from __future__ import annotations

import datetime as dt
import json
import re
from pathlib import Path

import pandas as pd

O2_BANDS = [("<18", 0.0, 18.0), ("18-24", 18.0, 24.0), ("24-30", 24.0, 30.0),
            ("30-36", 30.0, 36.0), (">36", 36.0, 101.0)]
P_BANDS = [("<70", 0.0, 70.0), ("70-110", 70.0, 110.0), (">110", 110.0, 1e9)]
P_UNITS = {"mmhg": 0.133322, "atm": 101.325, "bar": 100.0, "kpa": 1.0, "psi": 6.894757}
O2_COL = re.compile(r"\bo2\b|oxygen|^\s*xo2|^\s*o initial", re.IGNORECASE)
P_COL = re.compile(r"pressure|^\s*p(init|mean)\b|approx p\b", re.IGNORECASE)
OUTCOME_COL = re.compile(r"test end|ignit|self[- ]?ext|extinct|outcome|cool flame\?", re.IGNORECASE)
NUM = re.compile(r"-?\d+(?:\.\d+)?")


def read_table(path: Path) -> pd.DataFrame:
    """Experimental table as strings (PSI files are UTF-8 or Windows-1252)."""
    for enc in ("utf-8", "cp1252"):
        try:
            return pd.read_csv(path, dtype=str, encoding=enc).fillna("")
        except UnicodeDecodeError:
            continue
    return pd.DataFrame()


def numbers(cell: str) -> list[float]:
    """All numbers printed in a cell ('21; 26.5; 40' -> [21, 26.5, 40])."""
    return [float(x) for x in NUM.findall(cell.replace(",", ""))]


def find_col(df: pd.DataFrame, pattern: re.Pattern[str], exclude: str) -> str | None:
    """First column whose header matches pattern and not the exclude regex."""
    for c in df.columns:
        if pattern.search(c) and not re.search(exclude, c, re.IGNORECASE):
            return c
    return None


def o2_percent(header: str, vals: list[float]) -> list[float]:
    """O2 values converted to percent (fractions are detected from the header or the values)."""
    if re.search(r"%|percent", header, re.IGNORECASE):
        return vals
    if re.search(r"fraction|^\s*x", header, re.IGNORECASE) or (vals and max(vals) <= 1.0):
        return [v * 100 for v in vals]
    return vals


def pressure_kpa(header: str, cell: str) -> list[float]:
    """Pressure values in kPa, using the unit in the header or the cell; [] if no unit."""
    text = f"{header} {cell}".lower()
    unit = next((u for u in P_UNITS if u in text), None)
    return [v * P_UNITS[unit] for v in numbers(cell)] if unit else []


def band(value: float, bands: list[tuple[str, float, float]]) -> str:
    """Label of the band containing value (lower bound inclusive)."""
    return next(label for label, lo, hi in bands if lo <= value < hi)


def run_rows(df: pd.DataFrame) -> pd.DataFrame:
    """Rows that describe a test: drops empty rows, 'Note ...' rows and Saffire flow-video rows."""
    if df.empty:
        return df
    filled = (df.apply(lambda c: c.str.strip()) != "").sum(axis=1)
    first = df.iloc[:, 0].str.strip()
    keep = (filled >= min(2, len(df.columns))) & ~first.str.match(r"(?i)(note\b|f\d+c\d)")
    return df[keep]


def outcome_col(df: pd.DataFrame) -> str | None:
    """A row-level outcome column: outcome-like header with text (not count) values."""
    for c in df.columns:
        if OUTCOME_COL.search(c) and not re.search(r"diameter|power|time|gmt", c, re.IGNORECASE):
            vals = [v for v in df[c] if v.strip()]
            if vals and sum(bool(re.fullmatch(r"-?\d+(\.\d+)?", v.strip())) for v in vals) < len(vals) / 2:
                return c
    return None


def fuel_classes(df: pd.DataFrame, title: str, text: str) -> list[str]:
    """Coarse fuel classes from table headers, the title and PSI's objective/approach text.

    `text` is passed only for flight investigations; smoke studies' 'droplets' are smoke.
    """
    heads = " ".join(df.columns).lower()
    smoke = re.search(r"smoke (and )?aerosol|dust", title, re.IGNORECASE)
    out = []
    if "droplet" in heads or (not smoke and re.search(r"\bdroplets?\b", text, re.IGNORECASE)):
        out.append("droplet")
    if re.search(r"fuel bottle|mfc|nozzle|xfuel|mfuel|fuel rate|\bxf\b|mhc|burner", heads):
        out.append("gas_jet")
    if smoke:
        out.append("smoke_aerosol")
    elif re.search(r"material|sample thick|samle thick", heads):
        out.append("solid")
    return out


def table_facts(df: pd.DataFrame, title: str, text: str = "") -> dict:
    """Rows, detected quantities, ranges and matrix placements for one experimental table."""
    df = run_rows(df)
    o2c = find_col(df, O2_COL, r"flow|\brate\b|mg/s|\(note")
    o2c = o2c or find_col(df, O2_COL, r"flow|\brate\b|mg/s")
    pc = find_col(df, P_COL, r"partial")
    o2s, ps, placed, bad = [], [], [], 0
    for _, row in df.iterrows():
        o2 = o2_percent(o2c, numbers(row[o2c])) if o2c else []
        p = pressure_kpa(pc, row[pc]) if pc else []
        ok_o2 = [v for v in o2 if 0 < v <= 100]  # e.g. ACME BRE '3400%' is skipped
        ok_p = [v for v in p if v > 0]  # e.g. FLEX test 114 '0 mmHg' is skipped
        bad += len(o2) - len(ok_o2) + len(p) - len(ok_p)
        o2s += ok_o2
        ps += ok_p
        if len(o2) == 1 and len(p) == 1 and ok_o2 and ok_p:
            placed.append((ok_o2[0], ok_p[0]))
    spread = any("spread" in c.lower() and ("rate" in c.lower() or df[c].str.contains("mm/s").any())
                 for c in df.columns)
    return {"n_rows": len(df), "o2": o2s, "p": ps, "placed": placed, "implausible": bad,
            "has_outcome": outcome_col(df) is not None, "has_spread_rate": spread,
            "has_burning_rate": any(re.search(r"burn(ing)? ?rate", c, re.IGNORECASE) for c in df.columns),
            "fuel_classes": fuel_classes(df, title, text), "o2_col": o2c, "p_col": pc}


def years(meta: dict) -> str:
    """'2007-2016' from PSI start/end dates (MM-DD-YYYY), or '' when absent."""
    ys = [d[-4:] for d in (meta.get("start_date", ""), meta.get("end_date", "")) if d]
    return "-".join(dict.fromkeys(ys))


def gravity_class(meta: dict) -> str:
    """'microgravity' for flight investigations, 'earth' for ground studies."""
    flight = re.search(r"space station|iss|cygnus", meta.get("platform", ""), re.IGNORECASE)
    return "microgravity" if flight or "Microgravity" in meta.get("project_type", "") else "earth"


def used_experiments(processed: Path) -> set[str]:
    """Experiment names present in the processed runs (empty if none yet)."""
    if not processed.exists():
        return set()
    runs = pd.read_parquet(processed, columns=["experiment"])
    return {str(e).upper() for e in runs["experiment"].dropna()}


def why_not(rec: dict, has_table: bool) -> str:
    """Factual reasons an investigation feeds no model (empty when it does)."""
    if rec["used_in_models"]:
        return ""
    if not has_table:
        return "PSI lists no experimental table for this investigation"
    reasons = []
    if not (rec["has_outcome"] or rec["has_spread_rate"] or rec["has_burning_rate"]):
        reasons.append("no row-level outcome or rate column")
    elif rec["fuel_classes"] and "solid" not in rec["fuel_classes"]:
        kinds = " and ".join(c.replace("_", " ") for c in rec["fuel_classes"])
        reasons.append(f"{kinds} fuel; the models cover solid materials only")
    else:
        reasons.append("not ingested yet: pipeline/sources.yaml has no adapter for this table")
    if rec["o2_range"] is None:
        reasons.append("no O2 column")
    if rec["pressure_range"] is None:
        reasons.append("no pressure column")
    return "; ".join(reasons)


def rng(values: list[float]) -> list[float] | None:
    """[min, max] rounded for display, or None when the table states no value."""
    return [round(min(values), 2), round(max(values), 2)] if values else None


def investigation(folder: Path, used: set[str]) -> tuple[dict, list[tuple[float, float]]]:
    """Coverage record for one PSI folder, plus its matrix placements (O2 %, kPa)."""
    meta = json.loads((folder / "metadata.json").read_text())
    tables = sorted((folder / "files" / "Experimental table").glob("*.csv"))
    text = (" ".join(meta.get(k, "") for k in ("objective", "approach"))
            if gravity_class(meta) == "microgravity" else "")
    facts = [table_facts(read_table(t), meta.get("title", ""), text) for t in tables]
    acr = meta.get("acronym", "")
    names = {a.strip().upper() for a in re.split(r"/", acr) if a.strip()}
    rec = {
        "psi_id": meta["psi_id"], "acronym": acr, "title": meta.get("title", ""),
        "doi": meta.get("doi", ""), "url": meta.get("url", ""),
        "platform": meta.get("platform", ""), "project_type": meta.get("project_type", ""),
        "years": years(meta), "tables": [t.name for t in tables],
        "n_rows": sum(f["n_rows"] for f in facts),
        "fuel_classes": sorted({c for f in facts for c in f["fuel_classes"]}),
        "o2_range": rng([v for f in facts for v in f["o2"]]),
        "pressure_range": rng([v for f in facts for v in f["p"]]),
        "gravity_class": gravity_class(meta),
        "has_outcome": any(f["has_outcome"] for f in facts),
        "has_spread_rate": any(f["has_spread_rate"] for f in facts),
        "has_burning_rate": any(f["has_burning_rate"] for f in facts),
        "rows_in_matrix": sum(len(f["placed"]) for f in facts),
        "implausible_values_skipped": sum(f["implausible"] for f in facts),
        "used_in_models": bool(names & used),
    }
    rec["why_not_used"] = why_not(rec, bool(tables))
    return rec, [p for f in facts for p in f["placed"]]


def build_catalog(psi_dir: Path, processed: Path) -> dict:
    """Coverage atlas for every investigation folder under psi_dir."""
    used = used_experiments(processed)
    folders = sorted((p for p in psi_dir.glob("*_*") if (p / "metadata.json").exists()),
                     key=lambda p: int(re.sub(r"\D", "", p.name.split("_")[0]) or 0))
    counts: dict[tuple[str, str, str], list[str]] = {}
    records = []
    for folder in folders:
        rec, placed = investigation(folder, used)
        records.append(rec)
        for o2, p in placed:
            key = (rec["gravity_class"], band(o2, O2_BANDS), band(p, P_BANDS))
            counts.setdefault(key, []).append(rec["psi_id"])
    cells = [{"gravity_class": g, "o2_band": o, "pressure_band": pb,
              "n_runs": len(counts.get((g, o, pb), [])),
              "investigations": sorted(set(counts.get((g, o, pb), [])))}
             for g in ("microgravity", "moon_mars", "earth")
             for pb, _, _ in P_BANDS for o, _, _ in O2_BANDS]
    return {
        "version": "1", "generated": dt.date.today().isoformat(), "source": "data/raw/psi",
        "o2_bands_pct": [b[0] for b in O2_BANDS], "pressure_bands_kpa": [b[0] for b in P_BANDS],
        "totals": {"investigations": len(records), "rows": sum(r["n_rows"] for r in records),
                   "rows_in_matrix": sum(r["rows_in_matrix"] for r in records)},
        "investigations": records, "matrix": cells,
    }


def write_coverage(psi_dir: Path, processed: Path, out: Path) -> dict:
    """Build the atlas and write coverage.json."""
    cat = build_catalog(psi_dir, processed)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(cat, indent=1, ensure_ascii=False))
    return cat
