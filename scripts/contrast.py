"""WCAG 2.2 contrast ratios for the token pairs FlameSense uses (AUDIT §6). Prints a table.

Run: python3 scripts/contrast.py
Tints (alpha colours) are composited over the surface they sit on.
"""

DARK = {"bg": "0A1020", "surface1": "10182B", "surface2": "17213A", "surface3": "1E2A47",
        "textPrimary": "EAF0FA", "textSecondary": "A9B6CC", "textTertiary": "7E8CA6", "microg": "6CB6FF",
        "microgStrong": "3D8BFF", "onMicrog": "06101F", "emberText": "FF8A3D", "ember": "FF8A3D",
        "success": "5BD6A0", "warn": "F5C451", "danger": "FF6B7A", "focusRing": "FFD27A", "outlineStrong": "3B4A6E",
        "partial": "C79BFF", "onDanger": "1A0006", "microgTint": ("6CB6FF", 0.16), "emberTint": ("FF8A3D", 0.14),
        "warnTint": ("F5C451", 0.14), "dangerTint": ("FF6B7A", 0.14), "successTint": ("5BD6A0", 0.14)}
LIGHT = {"bg": "F5F7FA", "surface1": "FFFFFF", "surface2": "F0F3F8", "surface3": "E6ECF5",
         "textPrimary": "0D1526", "textSecondary": "42506A", "textTertiary": "5E6C85", "microg": "1F66D6",
         "microgStrong": "1F66D6", "onMicrog": "FFFFFF", "emberText": "B4480C", "ember": "E2621B",
         "success": "1E8E5A", "warn": "9A6A00", "danger": "C8283C", "focusRing": "1F66D6", "outlineStrong": "B3BFD1",
         "partial": "7B4FD6", "onDanger": "FFFFFF", "microgTint": ("1F66D6", 0.10), "emberTint": ("E2621B", 0.10),
         "warnTint": ("9A6A00", 0.10), "dangerTint": ("C8283C", 0.10), "successTint": ("1E8E5A", 0.10)}

# (foreground, background, minimum, use)
PAIRS = [
    ("textPrimary", "bg", 4.5, "body text"), ("textPrimary", "surface1", 4.5, "panel text"),
    ("textPrimary", "surface3", 4.5, "tooltip/hover"), ("textSecondary", "surface1", 4.5, "supporting text"),
    ("textSecondary", "surface2", 4.5, "table header"), ("textTertiary", "bg", 4.5, "captions on bg"),
    ("textTertiary", "surface1", 4.5, "captions in panels"), ("textTertiary", "surface2", 4.5, "hint in inputs"),
    ("microg", "bg", 4.5, "links"), ("microg", "surface1", 4.5, "links in panels"),
    ("microg", "microgTint/surface1", 4.5, "selected chip/nav"), ("onMicrog", "microgStrong", 4.5, "primary button"),
    ("emberText", "surface1", 4.5, "ember text"), ("textPrimary", "emberTint/surface1", 4.5, "Earth column text"),
    ("textPrimary", "warnTint/surface1", 4.5, "warn notice"), ("textPrimary", "dangerTint/surface1", 4.5, "danger notice"),
    ("warn", "surface1", 4.5, "unknown count / debug notes"), ("onDanger", "danger", 4.5, "danger button"),
    ("focusRing", "bg", 3.0, "focus ring (UI)"), ("focusRing", "surface1", 3.0, "focus ring in panels"),
    ("ember", "surface1", 3.0, "ember dots/markers (UI)"), ("partial", "surface1", 3.0, "partial-g markers (UI)"),
    ("success", "surface1", 3.0, "badge border (UI)"), ("danger", "surface1", 3.0, "badge border (UI)"),
    ("outlineStrong", "surface1", 3.0, "chart axes (UI)"),
]


def rgb(h: str) -> tuple[float, float, float]:
    """Hex → 0–1 RGB."""
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def resolve(theme: dict, name: str) -> tuple[float, float, float]:
    """Token (or 'tint/surface') → opaque RGB."""
    if "/" in name:
        tint, base = name.split("/")
        (h, a), b = theme[tint], rgb(theme[base])
        return tuple(a * c + (1 - a) * d for c, d in zip(rgb(h), b))
    return rgb(theme[name])


def lum(c: tuple[float, float, float]) -> float:
    """Relative luminance."""
    f = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c]
    return 0.2126 * f[0] + 0.7152 * f[1] + 0.0722 * f[2]


def ratio(a, b) -> float:
    """WCAG contrast ratio."""
    la, lb = sorted([lum(a), lum(b)], reverse=True)
    return (la + 0.05) / (lb + 0.05)


if __name__ == "__main__":
    fails = 0
    print("| Theme | Foreground | Background | Ratio | Needs | Use | Result |\n|---|---|---|---|---|---|---|")
    for tname, t in (("dark", DARK), ("light", LIGHT)):
        for fg, bg, need, use in PAIRS:
            r = ratio(resolve(t, fg), resolve(t, bg))
            ok = r >= need
            fails += not ok
            print(f"| {tname} | {fg} | {bg} | {r:.2f} | {need} | {use} | {'pass' if ok else 'FAIL'} |")
    print(f"\n{fails} failing pair(s)")
