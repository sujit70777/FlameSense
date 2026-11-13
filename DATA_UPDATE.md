# Updating FlameSense data

1. **Add the source.** Download files into `data/raw/<source_id>/` without renaming them, and
   add a row to `docs/DATA_SOURCES.md` (name, URL, files, format, licence note, adapter).
2. **Map it.** Run `python -m flamesense.cli inspect`, then write
   `pipeline/src/flamesense/ingest/adapters/<source_id>.py` with an explicit `COLUMN_MAP` and
   commented unit conversions (PLAN.md §3.1). Never guess a required value: log a question in
   `docs/QUESTIONS.md` and drop those rows with a logged count. Register the source in
   `pipeline/sources.yaml`. Hand-digitized tables go in `data/manual/*.csv` in the canonical
   schema with `quality_flag=digitized`.
3. **Rebuild.** `python -m flamesense.cli all` (ingest → validate → clean → features → report →
   train → export → evaluate), then `bash scripts/sync_assets.sh`. Check `docs/DATA_REPORT.md`
   and `docs/MODEL_CARD.md`.
4. **Other inputs** (all owned by the lead, each with sources): `data/manual/physics_params.json`
   (+ sign-off in `docs/PHYSICS_SPEC.md`), `data/manual/missions.json`,
   `data/manual/lessons_draft.md`, `data/manual/usability.csv`, and the Ask corpus in
   `data/corpus_raw/` + `corpus_meta.csv` (then `python -m flamesense.cli corpus` and, with the
   API running, `python -m flamesense.cli ask-cache`).
5. **Verify and deploy.** Run all tests, `node scripts/smoke.mjs http://localhost:8788`
   against `npx wrangler pages dev app/build/web`, then deploy (PLAN.md Phase 16).
