# Contributing to FlameSense

Thanks for helping. FlameSense is a research and education tool; every number it shows must
trace back to a cited source.

## Ground rules
- **Never invent data.** Rows come only from `data/raw/` or `data/manual/` with a
  `source_citation`. Test fixtures live in `pipeline/tests/fixtures/` and `app/test/fixtures/`
  and are named `fixture_*`.
- **Never commit secrets.** The Anthropic key lives only in Cloudflare secrets and a local,
  gitignored `.dev.vars`. `scripts/check_secrets.sh` must pass.
- **UI follows `docs/DESIGN.md`:** colours, sizes and durations come from `app/lib/core/theme/`;
  copy comes from `app/tool/l10n_source.py` (regenerate the ARB files with
  `python3 app/tool/l10n_source.py`, then `flutter gen-l10n`).
- **Be honest in copy:** never claim certification or operational validity.

## Setup and checks
```bash
python3 -m venv pipeline/.venv && source pipeline/.venv/bin/activate
pip install -r pipeline/requirements.txt && pip install -e pipeline
pytest pipeline/tests -q && ruff check pipeline

cd app && flutter pub get && flutter gen-l10n && flutter analyze && flutter test

npm --prefix functions-dev install && npm --prefix functions test
```
CI (`.github/workflows/ci.yml`) runs all of these on every push.

## Reporting a data error
Open a **Data correction** issue with the run id, the correction and the source.
