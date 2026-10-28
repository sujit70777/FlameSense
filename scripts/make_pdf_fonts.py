"""Instance static Archivo Regular/Bold from the bundled variable font for the PDF brief.

The `pdf` package cannot apply variable-font axes, so it needs static TTFs.
Requires fontTools (dev-only): pipeline/.venv/bin/pip install fonttools
Run: pipeline/.venv/bin/python scripts/make_pdf_fonts.py
Archivo is SIL OFL 1.1 with no Reserved Font Name, so derived instances are allowed.
"""

from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

FONTS = Path(__file__).resolve().parents[1] / "app" / "assets" / "fonts"


def main() -> None:
    """Write Archivo-Regular.ttf (wght 400) and Archivo-Bold.ttf (wght 700), wdth 100."""
    for name, wght in [("Regular", 400), ("Bold", 700)]:
        font = TTFont(FONTS / "Archivo[wdth,wght].ttf")
        static = instantiateVariableFont(font, {"wght": wght, "wdth": 100}, updateFontNames=True)
        out = FONTS / f"Archivo-{name}.ttf"
        static.save(out)
        print("wrote", out, out.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
