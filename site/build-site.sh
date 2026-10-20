#!/usr/bin/env bash
#
# Render every artifact and stage it in a site-local folder so the website's
# `resources` globs copy it into the _site root for deployment. Each artifact
# is rendered by its own project (so per-project _quarto.yml / pre-render hooks
# behave naturally), then copied into site/<folder>/ preserving relative paths.
#
set -euo pipefail
cd "$(dirname "$0")"        # -> site
ROOT="$(cd .. && pwd)"      # -> repo root

rm -rf slides labs apps example-report build material.zip

echo "[site] deck (slides project render -> fires pre-render)"
( cd "$ROOT/slides" && quarto render )
mkdir -p slides
cp -R "$ROOT/slides"/slides.html "$ROOT/slides"/slides_files \
      "$ROOT/slides"/examples "$ROOT/slides"/resources slides/

echo "[site] labs (plain HTML docs)"
mkdir -p labs
for lab in "$ROOT"/labs/lab-*.qmd; do
  ( cd "$ROOT/labs" && quarto render "$(basename "$lab")" )
done
cp -R "$ROOT"/labs/lab-*.html "$ROOT"/labs/lab-*_files labs/

echo "[site] example report (shinylive extension, own render)"
( cd "$ROOT/example-report" && quarto render report.qmd )
mkdir -p example-report
cp -R "$ROOT/example-report"/report.html "$ROOT/example-report"/report_files \
      "$ROOT/example-report"/shinylive-sw.js example-report/

echo "[site] standalone app (shinylive::export)"
mkdir -p apps
Rscript -e 'shinylive::export("'"$ROOT"'/apps/penguins-app", "./apps/penguins-app")'

echo "[site] workshop material archive (clone-equivalent, committed tree, no site/)"
( cd "$ROOT" && git archive --prefix=shinylive-quarto/ --format=zip -o site/material.zip HEAD -- . ':(exclude)site' )

echo "[site] done -> site/{slides,labs,apps,example-report,material.zip}/"
