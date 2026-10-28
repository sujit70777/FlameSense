"""Write docs/AI_USAGE.md from PLAN.md §6 prompts and functions/lib/prompt.ts (Phase 17 step 3).

Run: python3 scripts/make_ai_usage.py
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATES = {"1": "2026-10-11", "2": "2026-10-11", "3": "2026-10-11", "3B": "not run (no flame video data)",
         "4": "2026-10-11", "5": "2026-10-27", "6": "2026-10-27", "7": "2026-10-27", "8": "2026-10-27",
         "9": "2026-10-27", "10": "2026-10-27", "11": "2026-10-27", "11B": "2026-10-28", "12": "2026-10-28",
         "13": "2026-10-28", "14": "2026-10-28", "15": "2026-10-28",
         "16": "2026-10-28 (configuration only; deploy is a [LEAD] step)", "17": "2026-10-28"}


def phase_prompts(plan: str) -> list[tuple[str, str]]:
    """(phase heading, prompt text) for every phase that has a Prompt block."""
    out, title, in_prompt, in_code, buf = [], None, False, False, []
    for line in plan.splitlines():
        if line.startswith("### Phase "):
            title, in_prompt = line[4:].strip(), False
        elif line.startswith("**Prompt") and title:
            in_prompt = True
        elif in_prompt and line.strip() == "```":
            if in_code:
                out.append((title, "\n".join(buf)))
                buf, in_code, in_prompt = [], False, False
            else:
                in_code = True
        elif in_code:
            buf.append(line)
    return out


def system_prompt() -> str:
    """Lines of the systemPrompt() array in prompt.ts, with the language placeholder."""
    src = (ROOT / "functions" / "lib" / "prompt.ts").read_text()
    body = src[src.index("return ["):src.index("].join")]
    lines = re.findall(r"^\s+[`'\"](.*)[`'\"],$", body, flags=re.M)
    return "\n".join(line.replace("${language}", "{English|Bangla (বাংলা)}").replace("\\'", "'") for line in lines)


def main() -> None:
    """Write the document."""
    plan = (ROOT / "docs" / "PLAN.md").read_text()
    head = (ROOT / "docs" / "AI_USAGE_HEAD.md").read_text() if (ROOT / "docs" / "AI_USAGE_HEAD.md").exists() else ""
    out = [head.rstrip(), "", "## 3. The Ask system prompt (from `functions/lib/prompt.ts`)", "", "```", system_prompt(), "```", "",
           "The user message wraps retrieved sources in `<sources>` (`[S1] (title, page) text`) and the question in "
           "`<question>`; text inside both is treated as data, not instructions.", "",
           "## 4. Every phase prompt (verbatim from PLAN.md §6) and when it ran", "",
           "Phases 1–4 were run one prompt at a time. Phases 5–17 were run in one Claude Code session after the plan "
           "was revised, with the instruction: *\"There something change on the plan and other files. So right now, "
           "finish the project based on the plan, don't miss anything. and do everything correctly\"*; the agent then "
           "followed each phase prompt below in order. Dates come from `docs/PROGRESS.md`.", ""]
    for title, body in phase_prompts(plan):
        key = title.split(" ")[1]
        out += [f"### {title}", f"Run: {DATES.get(key, '[VERIFY]')}", "", "```", body.strip(), "```", ""]
    (ROOT / "docs" / "AI_USAGE.md").write_text("\n".join(out), encoding="utf-8")
    print("wrote docs/AI_USAGE.md with", len(phase_prompts(plan)), "phase prompts")


if __name__ == "__main__":
    main()
