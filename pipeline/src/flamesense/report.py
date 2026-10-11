"""Data report and charts (Phase 3).

Writes ``docs/DATA_REPORT.md`` and five PNG charts into ``docs/img/`` using the
DESIGN.md §10 chart tokens (light-theme values, readable on white).
"""

from datetime import UTC, datetime
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# DESIGN.md §10.2/§10.3 — light-theme chart colors.
MICROGRAY_COLOR = "#1F66D6"
PARTIAL_COLOR = "#7B4FD6"
EARTH_COLOR = "#D9560B"
OTHER_COLOR = "#5E6C85"
EXPERIMENT_PALETTE = ["#1F66D6", "#D9560B", "#1E8E5A", "#9A6A00", "#7B4FD6", "#C2306E", "#5E6C85"]

# Measurement (non-categorical) columns reported in the numeric stats table.
NUMERIC_STATS_COLUMNS = [
    "gravity_g",
    "fuel_thickness_mm",
    "fuel_density_kg_m3",
    "o2_mole_fraction",
    "pressure_kpa",
    "flow_velocity_mm_s",
    "flame_spread_rate_mm_s",
    "burning_rate_k_mm2_s",
    "log10_gravity",
    "o2_partial_kpa",
    "log10_flow",
    "areal_density_kg_m2",
]


def fmt3(x: float) -> str:
    """Format with 3 significant digits (DESIGN.md §10.1)."""
    if x is None or (isinstance(x, float) and not np.isfinite(x)):
        return "–"
    return f"{x:.3g}"


def gravity_class(platform: pd.Series, gravity_g: pd.Series) -> pd.Series:
    """Classify runs into microgravity / partial / earth (DESIGN.md §10.2)."""
    g = pd.to_numeric(gravity_g, errors="coerce")
    micro = platform.isin(["iss", "free_flyer", "drop_tower", "parabolic"]) | (g < 0.01)
    partial = (~micro) & g.ge(0.01) & g.lt(0.9)
    out = pd.Series("earth", index=platform.index)
    out[micro] = "microgravity"
    out[partial] = "partial"
    return out


def _no_data(ax: plt.Axes) -> None:
    """Render a readable empty state for charts generated from no data."""
    ax.text(0.5, 0.5, "No data yet", ha="center", va="center", transform=ax.transAxes, color=OTHER_COLOR)
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)


def _save(fig: plt.Figure, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)


def chart_runs_per_experiment(df: pd.DataFrame, path: Path) -> None:
    """Bar chart: runs per experiment using the §10.3 experiment palette."""
    fig, ax = plt.subplots(figsize=(8, 5))
    counts = df["experiment"].value_counts()
    if counts.empty:
        _no_data(ax)
        _save(fig, path)
        return
    top = counts.head(6)
    other_n = int(counts.sum() - top.sum())
    names = list(top.index)
    values = list(top.values)
    if other_n > 0:
        names.append("Other")
        values.append(other_n)
    colors = EXPERIMENT_PALETTE[: len(values)]
    ax.bar(names, values, color=colors)
    for i, v in enumerate(values):
        ax.text(i, v, str(v), ha="center", va="bottom", color=OTHER_COLOR)
    ax.set_title("Runs per experiment", loc="left")
    ax.set_xlabel("Experiment")
    ax.set_ylabel("Runs")
    ax.tick_params(axis="x", rotation=30)
    fig.tight_layout()
    _save(fig, path)


def chart_spread_vs_o2(df: pd.DataFrame, path: Path) -> None:
    """Scatter: spread rate vs oxygen, colored by gravity class (§10.2)."""
    fig, ax = plt.subplots(figsize=(8, 5))
    sub = df.dropna(subset=["o2_mole_fraction", "flame_spread_rate_mm_s"])
    if sub.empty:
        _no_data(ax)
        _save(fig, path)
        return
    classes = gravity_class(sub["platform"], sub["gravity_g"])
    for cls, color, marker in [
        ("microgravity", MICROGRAY_COLOR, "o"),
        ("partial", PARTIAL_COLOR, "D"),
        ("earth", EARTH_COLOR, "o"),
    ]:
        mask = classes == cls
        if mask.sum() == 0:
            continue
        if cls == "earth":  # hollow circle, 2 px stroke (§10.2)
            ax.scatter(
                sub.loc[mask, "o2_mole_fraction"] * 100,
                sub.loc[mask, "flame_spread_rate_mm_s"],
                s=28,
                facecolors="none",
                edgecolors=color,
                linewidths=1.5,
                marker=marker,
                label=cls,
            )
        else:
            ax.scatter(
                sub.loc[mask, "o2_mole_fraction"] * 100,
                sub.loc[mask, "flame_spread_rate_mm_s"],
                s=28,
                c=color,
                marker=marker,
                label=cls,
            )
    ax.set_title("Spread rate vs oxygen by gravity class", loc="left")
    ax.set_xlabel("Oxygen (%)")
    ax.set_ylabel("Spread rate (mm/s)")
    ax.legend(title="Gravity class")
    fig.tight_layout()
    _save(fig, path)


def chart_sustained_vs_flow(df: pd.DataFrame, path: Path) -> None:
    """Scatter: sustained outcome vs flow velocity, colored by gravity class."""
    fig, ax = plt.subplots(figsize=(8, 5))
    sub = df.dropna(subset=["flow_velocity_mm_s", "sustained"])
    if sub.empty:
        _no_data(ax)
        _save(fig, path)
        return
    classes = gravity_class(sub["platform"], sub["gravity_g"])
    rng = np.random.default_rng(2026)
    jitter = rng.uniform(-0.08, 0.08, size=len(sub))
    for cls, color, marker in [
        ("microgravity", MICROGRAY_COLOR, "o"),
        ("partial", PARTIAL_COLOR, "D"),
        ("earth", EARTH_COLOR, "o"),
    ]:
        mask = classes == cls
        if mask.sum() == 0:
            continue
        if cls == "earth":  # hollow circle, 2 px stroke (§10.2)
            ax.scatter(
                sub.loc[mask, "flow_velocity_mm_s"],
                sub.loc[mask, "sustained"].astype(float) + jitter[mask],
                s=28,
                facecolors="none",
                edgecolors=color,
                linewidths=1.5,
                marker=marker,
                label=cls,
            )
        else:
            ax.scatter(
                sub.loc[mask, "flow_velocity_mm_s"],
                sub.loc[mask, "sustained"].astype(float) + jitter[mask],
                s=28,
                c=color,
                marker=marker,
                label=cls,
            )
    ax.set_title("Sustained vs airflow", loc="left")
    ax.set_xlabel("Airflow (mm/s, log scale)")
    ax.set_ylabel("Sustained")
    ax.set_xscale("log")
    ax.set_yticks([0, 1])
    ax.set_yticklabels(["no", "yes"])
    ax.set_ylim(-0.4, 1.4)
    ax.legend(title="Gravity class")
    fig.tight_layout()
    _save(fig, path)


def chart_o2_flow_scatter(df: pd.DataFrame, path: Path) -> None:
    """O₂ × flow scatter of all runs (becomes the map overlay, DESIGN §10.2)."""
    fig, ax = plt.subplots(figsize=(8, 5))
    sub = df.dropna(subset=["o2_mole_fraction", "flow_velocity_mm_s"])
    if sub.empty:
        _no_data(ax)
        _save(fig, path)
        return
    classes = gravity_class(sub["platform"], sub["gravity_g"])
    for cls, color, marker in [
        ("microgravity", MICROGRAY_COLOR, "o"),
        ("partial", PARTIAL_COLOR, "D"),
        ("earth", EARTH_COLOR, "o"),
    ]:
        mask = classes == cls
        if mask.sum() == 0:
            continue
        if cls == "earth":  # hollow circle, 2 px stroke (§10.2)
            ax.scatter(
                sub.loc[mask, "o2_mole_fraction"] * 100,
                sub.loc[mask, "flow_velocity_mm_s"],
                s=28,
                facecolors="none",
                edgecolors=color,
                linewidths=1.5,
                marker=marker,
                label=cls,
            )
        else:
            ax.scatter(
                sub.loc[mask, "o2_mole_fraction"] * 100,
                sub.loc[mask, "flow_velocity_mm_s"],
                s=28,
                c=color,
                marker=marker,
                label=cls,
            )
    ax.set_title("Oxygen × airflow across all runs", loc="left")
    ax.set_xlabel("Oxygen (%)")
    ax.set_ylabel("Airflow (mm/s, log scale)")
    ax.set_yscale("log")
    ax.legend(title="Gravity class")
    fig.tight_layout()
    _save(fig, path)


def chart_pressure_distribution(df: pd.DataFrame, path: Path) -> None:
    """Histogram: pressure distribution."""
    fig, ax = plt.subplots(figsize=(8, 5))
    pressure = pd.to_numeric(df["pressure_kpa"], errors="coerce").dropna()
    if pressure.empty:
        _no_data(ax)
        _save(fig, path)
        return
    ax.hist(pressure, bins=min(25, int(pressure.nunique()) or 1), color=EARTH_COLOR, edgecolor="white")
    ax.set_title("Pressure distribution", loc="left")
    ax.set_xlabel("Pressure (kPa)")
    ax.set_ylabel("Runs")
    fig.tight_layout()
    _save(fig, path)


def key_facts(df: pd.DataFrame) -> list[str]:
    """Five bullet facts computed from the data (no interpretation)."""
    if df.empty:
        return [
            "0 runs — no experiment data ingested yet. Add CSVs to data/manual/ and run ingest.",
            "No experiments, platforms, or fuel classes are present yet.",
            "No spread-rate measurements to summarize yet.",
            "No oxygen or pressure ranges to summarize yet.",
            "No sustained-outcome statistics yet.",
        ]
    n = len(df)
    n_exp = int(df["experiment"].nunique())
    n_fuel = int(df["fuel_class"].dropna().nunique())
    n_groups = int(df["group_id"].dropna().nunique())

    micro = gravity_class(df["platform"], df["gravity_g"])
    n_micro = int((micro == "microgravity").sum())
    n_earth = int((micro == "earth").sum())
    n_partial = int((micro == "partial").sum())

    spread = pd.to_numeric(df["flame_spread_rate_mm_s"], errors="coerce").dropna()
    o2 = pd.to_numeric(df["o2_mole_fraction"], errors="coerce").dropna()
    pressure = pd.to_numeric(df["pressure_kpa"], errors="coerce").dropna()
    ignited = df["sustained"].dropna().astype(bool)
    ignited_total = ignited.sum()
    sustained_rate = f"{100.0 * ignited_total / len(ignited):.1f}%" if len(ignited) else "0.0%"

    facts = [
        f"{n} runs from {n_exp} experiments across {n_fuel} fuel classes ({n_groups} test series).",
        f"{n_micro} runs in microgravity, {n_earth} on Earth"
        + (f", {n_partial} in partial gravity" if n_partial else "") + ".",
        f"Spread rate: {fmt3(spread.min())}–{fmt3(spread.max())} mm/s "
        f"(median {fmt3(spread.median())} mm/s) across {len(spread)} measured runs."
        if not spread.empty
        else "No spread-rate measurements.",
        f"Oxygen ranges {fmt3(o2.min() * 100)}–{fmt3(o2.max() * 100)}%; "
        f"pressure {fmt3(pressure.min())}–{fmt3(pressure.max())} kPa."
        if not o2.empty and not pressure.empty
        else "No oxygen or pressure values.",
        f"{len(ignited)} ignited runs; {sustained_rate} sustained.",
    ]
    return facts


def generate_report(df: pd.DataFrame, md_path: Path, img_dir: Path) -> Path:
    """Write docs/DATA_REPORT.md and the five chart PNGs; return the md path."""
    md_path.parent.mkdir(parents=True, exist_ok=True)
    img_dir.mkdir(parents=True, exist_ok=True)

    chart_specs = [
        ("Runs per experiment", "chart_runs_per_experiment.png", chart_runs_per_experiment),
        ("Spread rate vs oxygen by gravity class", "chart_spread_vs_o2.png", chart_spread_vs_o2),
        ("Sustained vs airflow", "chart_sustained_vs_flow.png", chart_sustained_vs_flow),
        ("Oxygen × airflow across all runs", "chart_o2_flow.png", chart_o2_flow_scatter),
        ("Pressure distribution", "chart_pressure.png", chart_pressure_distribution),
    ]
    for _title, filename, fn in chart_specs:
        fn(df, img_dir / filename)

    lines: list[str] = []
    lines.append("# FlameSense — Data Report")
    lines.append("")
    lines.append(f"Generated: {datetime.now(UTC).isoformat(timespec='seconds')} (UTC)")
    lines.append("")
    lines.append("## Key data facts")
    lines.append("")
    for fact in key_facts(df):
        lines.append(f"- {fact}")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- **Total runs:** {len(df)}")
    lines.append(f"- **Experiments:** {df['experiment'].nunique() if not df.empty else 0}")
    lines.append(f"- **Platforms:** {df['platform'].nunique() if not df.empty else 0}")
    lines.append(f"- **Fuel classes:** {df['fuel_class'].dropna().nunique() if not df.empty else 0}")
    lines.append(f"- **Groups / test series:** {df['group_id'].dropna().nunique() if not df.empty else 0}")
    lines.append("")

    for label, col in [
        ("Runs per experiment", "experiment"),
        ("Runs per platform", "platform"),
        ("Runs per fuel class", "fuel_class"),
    ]:
        lines.append(f"## {label}")
        lines.append("")
        if df.empty or col not in df.columns:
            lines.append("No data.")
        else:
            counts = df[col].value_counts(dropna=False)
            lines.append("| Value | Runs |")
            lines.append("|---|---|")
            for value, count in counts.items():
                label_value = "missing" if pd.isna(value) else value
                lines.append(f"| {label_value} | {count} |")
        lines.append("")

    lines.append("## Missing data (%)")
    lines.append("")
    if df.empty:
        lines.append("No data.")
    else:
        lines.append("| Column | Missing % |")
        lines.append("|---|---|")
        for col in df.columns:
            missing = int(df[col].isna().sum())
            lines.append(f"| {col} | {100.0 * missing / len(df):.1f} |")
    lines.append("")

    lines.append("## Numeric column statistics")
    lines.append("")
    lines.append("| Column | Min | Median | Max |")
    lines.append("|---|---|---|---|")
    if not df.empty:
        for col in NUMERIC_STATS_COLUMNS:
            if col not in df.columns:
                continue
            values = pd.to_numeric(df[col], errors="coerce").dropna()
            if values.empty:
                lines.append(f"| {col} | – | – | – |")
                continue
            lines.append(f"| {col} | {fmt3(values.min())} | {fmt3(values.median())} | {fmt3(values.max())} |")
    lines.append("")

    lines.append("## Charts")
    lines.append("")
    for title, filename, _fn in chart_specs:
        lines.append(f"### {title}")
        lines.append("")
        lines.append(f"![{title}](img/{filename})")
        lines.append("")

    md_path.write_text("\n".join(lines), encoding="utf-8")
    return md_path