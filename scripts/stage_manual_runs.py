"""Maps verified prep CSVs in data/manual/prep/ into canonical run CSVs in data/manual/.

Only source-stated values are used. Mappings (TODO(Q-17), lead to review):
- BASS-II Table 7.1 (SIBAL): pressure 101.325 kPa from "Ambient pressure was 1 atm" (p.102).
- BASS-II Table 5.1 (PMMA): pressure not printed with the table; 101.325 kPa from the report's
  MSG working-volume value "pressure P = 1 atm" (p.19), so quality_flag=estimated.
- Takahashi 2026 Table 1 (parabolic test conditions) and Sharma 2024 (ISS) are third-party,
  labelled in experiment and notes. Takahashi T2/T3 rows (derived values, model predictions)
  are never staged.
- fuel_class: thick_solid at >= 1 mm thickness, else thin_solid (TODO(Q-17)).
- Takahashi rows with changing gravity ("1/6 -> 0") are dropped (no single gravity_g).
- Saffire I-III orbit runs: 100 kPa from ICES-2021-266 Table 2 (NTRS 20210011521, p.8) for
  I-1, II-5, II-6, III-1; other samples on the same flights are flagged estimated. Saffire 1-g
  ground rows (no O2 printed) and the LUCI holdout are not staged. Outcomes stated in other
  NASA papers are applied via SAFFIRE_OUTCOMES (quote kept in notes).
- Saffire IV-VI (prep/saffire_iv_vi.csv): ICES-2021-266 and ICES-2024-365 Table 1 conditions.
"""

from pathlib import Path

import pandas as pd

PREP = Path("data/manual/prep")
OUT = Path("data/manual")
ONE_ATM_KPA = 101.325


def thin(df: pd.DataFrame) -> pd.DataFrame:
    """Sets blank fuel_class: thick_solid at >= 1 mm thickness, else thin_solid."""
    thick = pd.to_numeric(df["fuel_thickness_mm"], errors="coerce") >= 1.0
    df["fuel_class"] = df["fuel_class"].fillna(thick.map({True: "thick_solid", False: "thin_solid"}))
    return df


def bassii_t71() -> pd.DataFrame:
    """SIBAL burn/no-burn runs; pressure stated on p.102."""
    df = thin(pd.read_csv(PREP / "bassii_t71.csv"))
    df["pressure_kpa"] = ONE_ATM_KPA
    df["notes"] = df["notes"].fillna("") + " | pressure: 'Ambient pressure was 1 atm' (p.102)."
    return df


def bassii_t51() -> pd.DataFrame:
    """PMMA spread-rate runs; pressure from the MSG value on p.19 (estimated)."""
    df = thin(pd.read_csv(PREP / "bassii_t51.csv"))
    df["pressure_kpa"] = ONE_ATM_KPA
    df["quality_flag"] = "estimated"
    df["notes"] = df["notes"].fillna("") + (
        " | pressure not printed with Table 5.1; 101.325 kPa from the report's MSG working-volume"
        " value 'pressure P = 1 atm' (p.19)."
    )
    return df


SAFFIRE_PRESSURE_STATED = {"I-1", "II-5", "II-6", "III-1"}


def saffire() -> pd.DataFrame:
    """Saffire I-III orbit runs; 100 kPa from ICES-2021-266 Table 2 (NTRS 20210011521, p.8)."""
    df = pd.read_csv(PREP / "saffire_t1.csv")
    df = thin(df[df["platform"].eq("free_flyer")].copy())
    df["pressure_kpa"] = 100.0
    # A sustained flame implies ignition; otherwise ignition stays unknown.
    df["ignited"] = df["ignited"].astype(object)
    df["sustained"] = df["sustained"].astype(object)
    df.loc[df["sustained"].astype(str).eq("True") & df["ignited"].isna(), "ignited"] = True
    for sample, (ignited, sustained, evidence) in SAFFIRE_OUTCOMES.items():
        hit = df["sample"].eq(sample)
        df.loc[hit, "ignited"] = ignited
        df.loc[hit, "sustained"] = sustained
        df.loc[hit, "notes"] = df.loc[hit, "notes"].fillna("") + f" | outcome: {evidence}"
    df["sustained"] = df["sustained"].astype(object)
    stated = df["sample"].isin(SAFFIRE_PRESSURE_STATED)
    df.loc[~stated, "quality_flag"] = "estimated"
    df["notes"] = df["notes"].fillna("") + stated.map(
        {
            True: " | pressure 100 kPa: ICES-2021-266 Table 2 (NTRS 20210011521, p.8).",
            False: " | pressure 100 kPa estimated: same flight; Table 2 of ICES-2021-266"
            " (NTRS 20210011521, p.8) states 100 kPa for samples I-1, II-5, II-6, III-1.",
        }
    )
    return df


# Outcomes stated outside saffire_t1's source (sample -> (ignited, sustained, evidence)).
SAFFIRE_OUTCOMES = {
    **{
        f"II-{i}": (
            True,
            False,
            (
                "NTRS 20170008805 p.12: 'none of the silicone samples burned. When the igniter"
                " was powered off, a tiny gas phase flame remained but did not spread and"
                " quickly extinguished.'"
            ),
        )
        for i in (1, 2, 3, 4)
    },
    **{
        s: (
            True,
            True,
            (
                "ICES-2021-266 p.8: Saffire II two-sided PMMA samples 'grew to flame lengths of"
                " 8.0 cm for the grooved sample and 9.5 for the flat sample'"
            ),
        )
        for s in ("II-8", "II-9")
    },
    **{
        s: (True, True, "ICES-2021-266 Table 2 (p.8): steady state flame size reported")
        for s in ("I-1", "III-1")
    },
}


def saffire_later() -> pd.DataFrame:
    """Saffire IV-VI orbit runs (ICES-2021-266 and ICES-2024-365), all ignited and sustained."""
    return pd.read_csv(PREP / "saffire_iv_vi.csv")


def third_party() -> pd.DataFrame:
    """Sharma 2024 ISS runs and Takahashi 2026 Table 1 parabolic test conditions."""
    df = pd.read_csv(PREP / "third_party.csv")
    keep = df["source_id"].eq("third_party_sharma2024") | df["run_id"].str.contains(
        r"^third_party_takahashi2026:T1:", regex=True
    )
    # Rows whose gravity changed during the test ("1/6 -> 0") have no single gravity_g.
    df = thin(df[keep & df["gravity_g"].notna()].copy())
    # PLAN.md §1.0 "Third-party": Sharma 2024 is labelled "NASA co-authored" (NASA authors,
    # NASA BASS hardware); Takahashi 2026 has no NASA authors.
    sharma = df["source_id"].eq("third_party_sharma2024")
    label = sharma.map({True: "third-party, NASA co-authored",
                        False: "third-party, independent of NASA"})
    df["experiment"] = df["experiment"].astype(str) + " (" + label + ")"
    df["notes"] = "THIRD-PARTY (" + label + "). " + df["notes"].fillna("")
    return df


def main() -> None:
    """Writes the staged run CSVs."""
    for name, df in {
        "bassii_t71": bassii_t71(),
        "bassii_t51": bassii_t51(),
        "saffire_orbit": saffire(),
        "saffire_iv_vi": saffire_later(),
        "third_party_runs": third_party(),
    }.items():
        df.to_csv(OUT / f"{name}.csv", index=False)
        print(f"{name}: {len(df)} rows")


if __name__ == "__main__":
    main()
