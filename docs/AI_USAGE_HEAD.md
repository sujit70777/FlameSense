# FlameSense — Use of AI

Every AI tool used to build FlameSense, what it did, why, and what data it worked on
(NASA Space Apps 2026 rules; PLAYBOOK_TEAM §9.2). Items marked [VERIFY] are for the team to confirm.
Regenerate with `python3 scripts/make_ai_usage.py` (this header lives in `docs/AI_USAGE_HEAD.md`).

## 1. Tools

| Tool | What it did | Why | Data it worked on |
|---|---|---|---|
| **Claude Code** (Anthropic coding agent; Claude Opus 5.5 for phases 5–17) | Wrote the code, tests, configuration and draft documents phase by phase from `docs/PLAN.md`, `docs/DESIGN.md` and `docs/AUDIT.md`, under Ehsanur's review | A small team building a data pipeline, web app and API in a hackathon window | The project's own files, and NASA data files once added. It never invents data: test fixtures are synthetic, live only in `*/tests/fixtures/` and are named `fixture_*` |
| **Claude API** (model from `ASK_MODEL`, default `claude-sonnet-5-5`) | Writes the answers on the Ask page | Plain-language answers with citations | Only the NASA document chunks that BM25 retrieves for each question (system prompt in §3). Questions are not logged |
| **LightGBM** (gradient-boosted trees; not generative AI) | Predicts the chance a flame keeps burning and its spread rate | Small models that run in the browser and are checked exactly against Python (1e-9 parity) | Real NASA test runs only, validated with grouped cross-validation |
| Claude (chat) [VERIFY] | Helped draft planning documents, edited by the team | Speed | Public challenge text and NASA sources |

No images, voices or music in the app are AI-generated: the flames, icons and Open Graph image are
drawn by code (`FlamePainter`, `scripts/make_icons.py`). [VERIFY for the videos and slides.]

## 2. What humans did

- **Ehsanur (lead):** wrote the plan, design and audit documents; ran every phase; reviewed the code;
  owns the data, physics parameters and their sign-off, mission presets, lessons, deployment and
  submission.
- **Team members:** registrations, videos, slides, NASA page text, usability tests, Bangla copy review,
  device testing. [VERIFY names per the under-18 rule.]
- Every science sentence and every number shown as NASA data is checked by the lead (AUDIT §3).
