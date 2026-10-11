# FlameSense 🔥

**AI-Powered Fire Safety Insights from Microgravity Combustion Data**

Entry for the NASA Space Apps Challenge 2026 — *"Flame in Freefall"*

## What it is

FlameSense shows how fire behaves where "up" doesn't exist — and turns NASA's space-station fire experiments into predictions, maps, and safety lessons for spacecraft and for buildings on Earth.

## Live demo

> [flamesense.ehsanur.com](https://flamesense.ehsanur.com)

## Screenshots

TODO: Phase 17

## How it works

- **Data pipeline** (Python): ingests NASA PSI experiment data, cleans, engineers features, trains LightGBM models
- **Prediction engine** (Dart): runs ML models in the browser with zero server dependency
- **Web app** (Flutter): interactive visualizations — gravity slider, flammability maps, fire lab, data explorer
- **Ask API** (Cloudflare Pages Function): BM25 retrieval + Anthropic LLM with cited answers from NASA documents

## NASA data used

TODO: Phase 17

## Run locally

```bash
# Python pipeline
source pipeline/.venv/bin/activate
python -m flamesense.cli all

# Flutter app
cd app
flutter pub get
flutter run -d chrome

# Full build
bash scripts/build_all.sh
```

## Team

TODO: Phase 17

## License

Apache-2.0. See [LICENSE](LICENSE).

## AI disclosure

TODO: Phase 17
