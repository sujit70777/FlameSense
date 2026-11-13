"""Investigations hub data (PLAN Phase 3D, F20) -> investigations.json.

Everything here is computed or copied from files: PSI metadata (verbatim objective quotes,
publications), experimental tables (conditions, varied vs constant), the verified curation file
(measurements with evidence, sample sizes). AI summaries are NOT generated here: the summary fields
stay null with reviewed=false until the offline summary step runs with an API key (TODO(Q-16)).
"""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path

import pandas as pd

from flamesense.catalog import investigation as coverage_record
from flamesense.catalog import numbers, read_table, run_rows

# Hardware families as given by the challenge statement (docs/CHALLENGE_STATEMENT.md).
HARDWARE = {"CIR-ACME": r"^ACME", "CIR-MDCA": r"^(FLEX|FLEX-2|CFI)$",
            "MSG-SPICE-duct": r"^(BASS|BASS-II|SPICE|SLICE)$"}
# Pillar defaults (PLAN Phase 3D step 1); [LEAD] reviews.
PILLARS = [
    (r"^(SAME|SAME-R)$|DAFT", "detection", "smoke/aerosol measurement for fire detection"),
    (r"^(FLEX|FLEX-2)$", "suppression", "droplet extinction with CO2/He diluents"),
    (r"^(BASS|BASS-II)$|SAFFIRE|BRE", "prevention", "material flammability"),
]
FUEL_STATE = {"droplet": "liquid_droplet", "gas_jet": "gas", "solid": "solid"}
SKIP_COLS = re.compile(r"(?i)\b(id|test ?#|test no|test number|date|time|gmt|day|year|month|"
                       r"file|video|camera|comment|notes?|sample number|session|identifier)\b")
COND = {"airflow_mm_s": (r"(?i)air flow|flow velocity|air rate|inlet velocity|opposed-flow", 10.0),
        "co2_fraction": (r"(?i)^\s*co initial|co2.*(fraction|%)", 1.0),
        "he_fraction": (r"(?i)^\s*he initial|helium", 1.0),
        "droplet_diameter_mm": (r"(?i)droplet.*diameter", 1.0)}


def hardware_family(acronym: str) -> str:
    """Statement hardware family for an acronym, else 'other'."""
    for fam, pat in HARDWARE.items():
        if re.search(pat, acronym.strip(), re.IGNORECASE):
            return fam
    return "other"


def pillars(acronym: str) -> list[dict]:
    """Rule-based pillar defaults with a one-line reason; 'fundamental' otherwise."""
    out = [{"pillar": p, "reason": why} for pat, p, why in PILLARS
           if re.search(pat, acronym.upper())]
    return out or [{"pillar": "fundamental", "reason": "combustion science without a pillar default"}]


def quotes(text: str, limit: int = 300) -> list[str]:
    """Verbatim sentences of PSI text, each at most `limit` characters."""
    sents = re.split(r"(?<=[.!?])\s+", re.sub(r"\s+", " ", text or "").strip())
    return [s for s in sents if s and len(s) <= limit][:6]


def varied_constant(df: pd.DataFrame) -> tuple[list[dict], list[dict]]:
    """Columns with >1 distinct value (levels or numeric range) vs one value."""
    varied, constant = [], []
    for c in df.columns:
        vals = [v.strip() for v in df[c] if v.strip()]
        if not vals or SKIP_COLS.search(c):
            continue
        uniq = list(dict.fromkeys(vals))
        if len(uniq) == 1:
            constant.append({"variable": c.strip(), "value": uniq[0]})
            continue
        nums = [numbers(v) for v in uniq]
        if all(len(n) == 1 for n in nums) and len(uniq) > 8:
            flat = [n[0] for n in nums]
            varied.append({"variable": c.strip(), "range": [min(flat), max(flat)],
                           "n_levels": len(uniq)})
        else:
            varied.append({"variable": c.strip(), "levels": uniq[:12], "n_levels": len(uniq)})
    return varied, constant


def conditions(dfs: list[pd.DataFrame], cov: dict) -> dict:
    """Condition ranges: O2 (%) and pressure (kPa) from the atlas, others from table columns."""
    out = {"o2_pct": cov["o2_range"], "pressure_kpa": cov["pressure_range"]}
    for key, (pat, scale) in COND.items():
        vals = []
        for df in dfs:
            for c in df.columns:
                if re.search(pat, c) and not re.search(r"(?i)extinction|mg/s|sccm", c):
                    unit = 10.0 if "cm/s" in (c + " ".join(df[c])).lower() else 1.0
                    vals += [v * (unit if key == "airflow_mm_s" else scale)
                             for cell in df[c] for v in numbers(cell)]
        out[key] = [min(vals), max(vals)] if vals else None
    return out


def curation(path: Path) -> dict[str, dict]:
    """Verified curation rows (measurements with evidence, sample sizes) by PSI id."""
    if not path.exists():
        return {}
    return {r["psi_id"]: r for r in csv.DictReader(path.open()) if r.get("verified") == "yes"}


def measurements(cur: dict | None) -> list[dict]:
    """Measurement items with the exact evidence quote they came from."""
    if not cur:
        return []
    ev = [e for e in cur["evidence"].split(" || ") if not e.startswith("sample:")]
    items = [m.strip() for m in cur["measurements"].split(";") if m.strip()]
    return [{"type": m, "evidence": next((e[len(m) + 2:] for e in ev if e.startswith(m + ":")), "")}
            for m in items]


def fuels(cur: dict | None) -> list[dict]:
    """Fuels with shape and size as printed, from the curation sample notes."""
    if not cur:
        return []
    out = []
    for part in cur["sample_size_note"].split(" | "):
        m = re.match(r'"(.+?)" -> ([^;]+)(?:; (.*))?$', part.strip())
        if m:
            out.append({"name": m.group(1), "shape": m.group(2).strip("? ") or None,
                        "size_note": m.group(3) or ""})
        elif part.strip():
            out.append({"name": "", "shape": None, "size_note": part.strip()})
    return out


def record(folder: Path, cur: dict | None, used: set[str]) -> dict:
    """One investigations.json record."""
    meta = json.loads((folder / "metadata.json").read_text())
    cov, _ = coverage_record(folder, used)
    tables = sorted((folder / "files" / "Experimental table").glob("*.csv"))
    dfs = [run_rows(read_table(t)) for t in tables]
    vc = [(t.name, *varied_constant(df)) for t, df in zip(tables, dfs)]
    acr = meta.get("acronym", "")
    smoke = "smoke_aerosol" in cov["fuel_classes"]
    return {
        "psi_id": meta["psi_id"], "acronym": acr, "title": meta.get("title", ""),
        "doi": meta.get("doi", ""), "url": meta.get("url", ""), "platform": cov["platform"],
        "years": cov["years"], "project_type": cov["project_type"],
        "pi": next((c["name"] for c in meta.get("pi_and_contacts", [])
                    if "Principal Investigator" in " ".join(c.get("roles", []))), ""),
        "hardware_family": hardware_family(acr), "hardware_text": meta.get("hardware", ""),
        "fuel_state": sorted({FUEL_STATE[f] for f in cov["fuel_classes"] if f in FUEL_STATE}
                             | ({"aerosol_dust" if "dust" in meta.get("title", "").lower()
                                 else "smoke"} if smoke else set())),
        "objectives": quotes(meta.get("objective", "")),
        "summary_student_en": None, "summary_expert_en": None, "reviewed": False,
        "fuels": fuels(cur), "conditions": conditions(dfs, cov),
        "varied": [dict(v, table=n) for n, var, _ in vc for v in var],
        "constant": [dict(v, table=n) for n, _, con in vc for v in con],
        "measurements": measurements(cur), "pillars": pillars(acr),
        "data_richness": {"n_rows": cov["n_rows"], "has_outcome": cov["has_outcome"],
                          "has_rate": cov["has_spread_rate"] or cov["has_burning_rate"],
                          "n_publications": len(meta.get("publications", []))},
        "publications": [{"title": p.get("title", ""), "link": p.get("link", "")}
                         for p in meta.get("publications", [])],
    }


def write_investigations(psi_dir: Path, curation_csv: Path, out: Path) -> int:
    """Build investigations.json for every PSI folder; returns the record count."""
    cur = curation(curation_csv)
    folders = sorted((p for p in psi_dir.glob("*_*") if (p / "metadata.json").exists()),
                     key=lambda p: int(re.sub(r"\D", "", p.name.split("_")[0]) or 0))
    recs = [record(f, cur.get(f.name.split("_")[0]), set()) for f in folders]
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({"version": "1", "investigations": recs}, indent=1,
                              ensure_ascii=False))
    return len(recs)
