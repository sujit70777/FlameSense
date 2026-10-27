# CLAUDE.md — Rules for the coding agent (read before every phase)

You are building **FlameSense**, an entry for the NASA Space Apps Challenge 2026
(challenge: "Flame in Freefall: AI-Powered Fire Safety Insights from Microgravity Combustion Data").

Your job is to write code. The thinking is already done in these files:

| File | What it is | When to read |
|---|---|---|
| `docs/PLAN.md` | Phases, steps, file paths, data contracts, acceptance criteria | Start of every phase |
| `docs/DESIGN.md` | Every color, font size, spacing value, page layout, state, and copy string | Any UI work |
| `docs/AUDIT.md` | Checklists that must pass before release | End of every phase + Phase 15 |
| `docs/PROGRESS.md` | Log you maintain | Update at end of every phase |
| `docs/QUESTIONS.md` | Questions you could not answer from the docs | Write here instead of guessing |
| `docs/PLAYBOOK_LEAD.md`, `docs/PLAYBOOK_TEAM.md` | Human plans (deadlines, handoffs, videos, submission) | Phase 17 only; never change them |

## Hard rules (never break these)

1. **Never invent data.** Every number shown as NASA data must come from a file in `data/raw/` or
   `data/manual/` with a `source_citation`. No synthetic rows in any file under `app/assets/data/`.
   Test fixtures live only in `pipeline/tests/fixtures/` and `app/test/fixtures/` and are named `fixture_*`.
2. **Never commit secrets.** `ANTHROPIC_API_KEY` lives only in Cloudflare secrets and `.dev.vars`
   (gitignored). Never put any key in Dart, JS, JSON assets, or docs.
3. **No hardcoded colors, font sizes, radii, or durations in widgets.** Use the tokens from
   `app/lib/core/theme/` (generated from DESIGN.md §3–§7). If a token is missing, add it to the theme
   files first, matching DESIGN.md, then use it.
4. **No hardcoded user-facing strings in widgets.** All copy goes through `AppLocalizations`
   (`app/lib/l10n/app_en.arb`, `app_bn.arb`). English copy is given in DESIGN.md §12–§13.
5. **Do only the current phase.** Do not start the next phase. Do not refactor finished phases unless
   the current phase's steps say so.
6. **When something is ambiguous**, write the question in `docs/QUESTIONS.md` with the phase number,
   pick the safest option that does not invent data, mark it `// TODO(Q-<n>)` in code, and continue.
7. **Steps marked `[LEAD]` or `[TEAM]` are for humans.** If your phase depends on one that is not done
   (its output file is missing), stop and report which file is missing.
8. **Scientific honesty in UI copy.** Never claim the tool is certified, validated for operational
   use, or a replacement for fire safety engineering. Use the disclaimers in DESIGN.md §12.

## Commands you will use

```bash
# Python pipeline (run from repo root)
source pipeline/.venv/bin/activate
python -m flamesense.cli <command>       # commands listed in PLAN.md §5
pytest pipeline/tests -q

# Flutter app (run from app/)
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze                 # must print "No issues found!"
flutter test                    # must pass 100%
flutter run -d chrome
flutter build web --release --no-web-resources-cdn

# API function (run from repo root)
npm --prefix functions test
npx wrangler pages dev app/build/web
```

## End-of-phase routine (do all of it, every phase)

1. Run every check listed in the phase's "Done when" section.
2. Run `flutter analyze` and `flutter test` (from Phase 6 onward) and `pytest` (from Phase 2 onward).
3. Tick the matching boxes in `docs/AUDIT.md` that this phase covers.
4. Append to `docs/PROGRESS.md`: phase number, what was built, files changed, checks run with results,
   open questions.
5. Commit: `git add -A && git commit -m "phase <N>: <short summary>"`.

## Code style

- Dart: Flutter 3.x stable, Material 3, `flutter_riverpod` (no code generation), `go_router`.
  Files `snake_case.dart`, one public widget per file, widgets under 200 lines (split if longer).
- Python: 3.11+, type hints everywhere, `ruff` clean, functions under 60 lines.
- TypeScript (functions): strict mode, no `any`.
- Every public function gets a one-line doc comment saying what it does.
