"""Render the FlameSense brand mark (DESIGN.md §2.3) to favicon and app icons.

Run: pipeline/.venv/bin/python scripts/make_icons.py
Writes app/web/favicon.png (32), favicon-16.png, icons/Icon-192/512 and maskable variants.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from matplotlib.patches import Circle, FancyBboxPatch, PathPatch  # noqa: E402
from matplotlib.path import Path as MPath  # noqa: E402

WEB = Path(__file__).resolve().parents[1] / "app" / "web"
BG = "#0A1020"
STROKE = "#FF8A3D"
CIRCLE = "#6CB6FF"


def bezier(p0, p1, p2, p3, n=40):
    """Sample a cubic Bézier curve."""
    t = np.linspace(0, 1, n)[:, None]
    return (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t**2 * p2 + t**3 * p3


def drop_path() -> MPath:
    """Teardrop outline in SVG coordinates (y down, 64-unit viewBox)."""
    a = bezier(np.array([32, 5]), np.array([32, 5]), np.array([51, 25]), np.array([51, 39]))
    theta = np.linspace(0, np.pi, 60)  # bottom semicircle from (51,39) to (13,39)
    arc = np.stack([32 + 19 * np.cos(theta), 39 + 19 * np.sin(theta)], axis=1)
    b = bezier(np.array([13, 39]), np.array([13, 25]), np.array([32, 5]), np.array([32, 5]))
    pts = np.vstack([a, arc, b])
    pts[:, 1] = 64 - pts[:, 1]  # flip to y-up
    return MPath(pts, closed=True)


def render(size: int, out: Path, mark_scale: float, rounded: bool) -> None:
    """Render the mark on a #0A1020 square (rounded 22% for favicons)."""
    fig = plt.figure(figsize=(1, 1), dpi=size)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 64)
    ax.set_ylim(0, 64)
    ax.axis("off")
    if rounded:
        fig.patch.set_alpha(0)
        ax.add_patch(FancyBboxPatch((0, 0), 64, 64, boxstyle="round,pad=0,rounding_size=14.08",
                                    facecolor=BG, edgecolor="none"))
    else:
        fig.patch.set_facecolor(BG)
    offset = 32 * (1 - mark_scale)
    trans = matplotlib.transforms.Affine2D().scale(mark_scale).translate(offset, offset) + ax.transData
    lw = 4 * mark_scale * 72 / 64  # 4 viewBox units in points (1 in = 72 pt = 64 units)
    ax.add_patch(PathPatch(drop_path(), facecolor="none", edgecolor=STROKE, linewidth=lw,
                           joinstyle="round", transform=trans))
    ax.add_patch(Circle((32, 64 - 39), 9, facecolor=CIRCLE, edgecolor="none", transform=trans))
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, dpi=size, transparent=rounded)
    plt.close(fig)


def main() -> None:
    """Write every icon size."""
    render(32, WEB / "favicon.png", 0.80, True)
    render(16, WEB / "favicon-16.png", 0.80, True)
    render(192, WEB / "icons" / "Icon-192.png", 0.80, True)
    render(512, WEB / "icons" / "Icon-512.png", 0.80, True)
    render(192, WEB / "icons" / "Icon-maskable-192.png", 0.60, False)
    render(512, WEB / "icons" / "Icon-maskable-512.png", 0.60, False)
    print("icons written to", WEB)


if __name__ == "__main__":
    main()
