#!/usr/bin/env bash
#
# Assemble the static site under build/. Each artifact is rendered by its own
# project (so per-project _quarto.yml / pre-render hooks behave naturally), then
# copied into build/ preserving relative paths. The website's own index.qmd is
# rendered by Quarto into _site separately; build/ is copied through next to it
# via the `resources` entry in _quarto.yml.
#
set -euo pipefail
cd "$(dirname "$0")"        # -> site
ROOT="$(cd .. && pwd)"      # -> repo root
rm -rf build
mkdir -p build

echo "[site] deck (slides, project render -> fires pre-render)"
( cd "$ROOT/slides" && quarto render )
mkdir -p build/slides
cp -R "$ROOT/slides"/slides.html "$ROOT/slides"/slides_files \
      "$ROOT/slides"/examples "$ROOT/slides"/resources build/slides/

echo "[site] labs (plain HTML docs)"
mkdir -p build/labs
for lab in "$ROOT"/labs/lab-*.qmd; do
  ( cd "$ROOT/labs" && quarto render "$(basename "$lab")" )
done
cp -R "$ROOT"/labs/lab-*.html "$ROOT"/labs/lab-*_files build/labs/

echo "[site] example report (shinylive extension, own render)"
( cd "$ROOT/example-report" && quarto render report.qmd )
mkdir -p build/example-report
cp -R "$ROOT/example-report"/report.html "$ROOT/example-report"/report_files \
      "$ROOT/example-report"/shinylive-sw.js build/example-report/

echo "[site] standalone app (shinylive::export)"
Rscript -e 'shinylive::export("'"$ROOT"'/apps/penguins-app", "build/apps/penguins-app")'

echo "[site] done -> build/"
