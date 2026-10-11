"""Data inspection utility for raw and manual datasets."""

from pathlib import Path
import json
from typing import Any
import pandas as pd

from flamesense.config import DATA_RAW, DATA_MANUAL, DOCS


def inspect_file(path: Path) -> str:
    """Inspect a single file and return a markdown-formatted summary."""
    lines: list[str] = [f"### `{path.relative_to(path.parents[2])}`", ""]
    stat = path.stat()
    size_kb = stat.st_size / 1024.0
    lines.append(f"- **Size:** {size_kb:.2f} KB ({stat.st_size} bytes)")
    
    suffix = path.suffix.lower()
    
    if suffix in [".csv", ".tsv"]:
        sep = "\t" if suffix == ".tsv" else ","
        try:
            df = pd.read_csv(path, sep=sep, nrows=5)
            lines.append(f"- **Format:** Delimited text ({suffix})")
            lines.append(f"- **Columns ({len(df.columns)}):** `{', '.join(df.columns.astype(str))}`")
            lines.append("\n**First 5 rows:**\n")
            lines.append(df.to_markdown(index=False) or str(df))
        except Exception as e:
            lines.append(f"- **Error reading delimited file:** {e}")

    elif suffix in [".xlsx", ".xls"]:
        lines.append(f"- **Format:** Excel spreadsheet ({suffix})")
        try:
            excel_file = pd.ExcelFile(path)
            lines.append(f"- **Sheets ({len(excel_file.sheet_names)}):** `{', '.join(excel_file.sheet_names)}`")
            for sheet in excel_file.sheet_names[:3]:
                df = pd.read_excel(path, sheet_name=sheet, nrows=5)
                lines.append(f"\n**Sheet `{sheet}` first 5 rows:**\n")
                lines.append(df.to_markdown(index=False) or str(df))
        except Exception as e:
            lines.append(f"- **Error reading Excel file:** {e}")

    elif suffix == ".json":
        lines.append("- **Format:** JSON")
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            if isinstance(data, list):
                lines.append(f"- **JSON Array:** {len(data)} items")
                sample = data[:5]
                lines.append(f"```json\n{json.dumps(sample, indent=2)[:1000]}\n```")
            elif isinstance(data, dict):
                lines.append(f"- **JSON Object Keys ({len(data)}):** `{', '.join(list(data.keys())[:20])}`")
                lines.append(f"```json\n{json.dumps({k: data[k] for k in list(data.keys())[:5]}, indent=2)[:1000]}\n```")
        except Exception as e:
            lines.append(f"- **Error reading JSON file:** {e}")

    elif suffix in [".txt", ".md", ".log"]:
        lines.append(f"- **Format:** Plain text ({suffix})")
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                head = [f.readline() for _ in range(10)]
            lines.append("```text\n" + "".join(head)[:1000] + "\n```")
        except Exception as e:
            lines.append(f"- **Error reading text file:** {e}")

    elif suffix == ".pdf":
        lines.append("- **Format:** PDF document")
        try:
            from pypdf import PdfReader
            reader = PdfReader(str(path))
            lines.append(f"- **Pages:** {len(reader.pages)}")
            if len(reader.pages) > 0:
                first_page_text = reader.pages[0].extract_text() or ""
                lines.append("**First page extract (up to 500 chars):**")
                lines.append(f"> {first_page_text[:500].strip()}")
        except Exception as e:
            lines.append(f"- **Error reading PDF:** {e}")

    elif suffix in [".mp4", ".avi", ".mov", ".mkv", ".png", ".jpg", ".jpeg"]:
        lines.append(f"- **Format:** Media ({suffix})")
        try:
            import cv2
            if suffix in [".png", ".jpg", ".jpeg"]:
                img = cv2.imread(str(path))
                if img is not None:
                    h, w, c = img.shape
                    lines.append(f"- **Resolution:** {w}x{h} ({c} channels)")
            else:
                cap = cv2.VideoCapture(str(path))
                if cap.isOpened():
                    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
                    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
                    fps = cap.get(cv2.CAP_PROP_FPS)
                    frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
                    duration_s = (frames / fps) if fps > 0 else 0.0
                    lines.append(f"- **Resolution:** {w}x{h}")
                    lines.append(f"- **FPS:** {fps:.2f}")
                    lines.append(f"- **Frames:** {frames}")
                    lines.append(f"- **Duration:** {duration_s:.2f} s")
                cap.release()
        except ImportError:
            lines.append("- OpenCV not installed; recorded file path and size only.")
        except Exception as e:
            lines.append(f"- **Error reading media:** {e}")
    else:
        lines.append(f"- **Format:** Binary/Other ({suffix})")

    lines.append("")
    return "\n".join(lines)


def run_inspect() -> str:
    """Walk data/raw and data/manual, generate markdown inspection report, and save to docs/DATA_INSPECTION.md."""
    report_lines: list[str] = [
        "# FlameSense — Data Inspection Report",
        "",
        "Generated by `python -m flamesense.cli inspect`.",
        "",
    ]

    target_dirs = [("Raw Data (`data/raw/`)", DATA_RAW), ("Manual Data (`data/manual/`)", DATA_MANUAL)]
    total_files = 0

    for title, dir_path in target_dirs:
        report_lines.append(f"## {title}")
        report_lines.append("")
        if not dir_path.exists():
            report_lines.append(f"Directory `{dir_path}` does not exist.\n")
            continue

        files = sorted([p for p in dir_path.rglob("*") if p.is_file() and p.name != ".gitkeep"])
        if not files:
            report_lines.append(f"No data files found in `{dir_path.name}/` (only `.gitkeep`).\n")
            continue

        report_lines.append(f"Found {len(files)} file(s):\n")
        for f in files:
            total_files += 1
            report_lines.append(inspect_file(f))

    report_content = "\n".join(report_lines)
    
    DOCS.mkdir(parents=True, exist_ok=True)
    out_file = DOCS / "DATA_INSPECTION.md"
    out_file.write_text(report_content, encoding="utf-8")
    
    print(f"Inspection complete. Inspected {total_files} file(s). Written to {out_file.relative_to(DOCS.parent)}")
    return report_content
