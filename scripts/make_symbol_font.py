"""Build app/assets/fonts/FsSymbols.ttf: a superscript minus (U+207B) missing from Archivo.

The glyph is Archivo's own hyphen, scaled to the superscript-digit size and raised to their
height, so "10⁻⁶" renders with bundled fonts only (no runtime fallback-font download).
Derived from Archivo (SIL OFL 1.1, no Reserved Font Name). Requires fontTools (dev-only).
Run: pipeline/.venv/bin/python scripts/make_symbol_font.py
"""

from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

FONTS = Path(__file__).resolve().parents[1] / "app" / "assets" / "fonts"


def main() -> None:
    """Write FsSymbols.ttf with .notdef and uni207B."""
    src = TTFont(FONTS / "Archivo-Regular.ttf")
    cmap, gs = src.getBestCmap(), src.getGlyphSet()
    hyphen, sup6 = cmap[ord("-")], cmap[0x2076]
    glyf = src["glyf"]
    h_box = glyf[hyphen]
    s_box = glyf[sup6]
    scale = 0.62
    h_mid_y = (h_box.yMin + h_box.yMax) / 2
    s_mid_y = (s_box.yMin + s_box.yMax) / 2
    width = round(src["hmtx"][hyphen][0] * scale + 20)
    dx = (width - (h_box.xMax - h_box.xMin) * scale) / 2 - h_box.xMin * scale
    dy = s_mid_y - h_mid_y * scale
    rec = DecomposingRecordingPen(gs)
    gs[hyphen].draw(rec)
    pen = TTGlyphPen(None)
    rec.replay(TransformPen(pen, (scale, 0, 0, scale, dx, dy)))
    minus = pen.glyph()
    notdef = TTGlyphPen(None).glyph()
    upm = src["head"].unitsPerEm
    fb = FontBuilder(upm, isTTF=True)
    fb.setupGlyphOrder([".notdef", "uni207B"])
    fb.setupCharacterMap({0x207B: "uni207B"})
    fb.setupGlyf({".notdef": notdef, "uni207B": minus})
    fb.setupHorizontalMetrics({".notdef": (upm // 2, 0), "uni207B": (width, 0)})
    hhea = src["hhea"]
    fb.setupHorizontalHeader(ascent=hhea.ascent, descent=hhea.descent)
    fb.setupNameTable({"familyName": "FsSymbols", "styleName": "Regular",
                       "copyright": "Glyph derived from Archivo, Copyright 2020 The Archivo Project Authors; SIL OFL 1.1"})
    fb.setupOS2(sTypoAscender=hhea.ascent, sTypoDescender=hhea.descent, usWinAscent=hhea.ascent,
                usWinDescent=abs(hhea.descent))
    fb.setupPost()
    out = FONTS / "FsSymbols.ttf"
    fb.save(str(out))
    print("wrote", out, out.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
