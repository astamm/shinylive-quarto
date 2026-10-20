#!/usr/bin/env bash
#
# Pre-render hook for the slides project (_quarto.yml). Renders the small
# example Quarto docs that the deck embeds as iframes, so slides 2.4 and 2.10
# always show freshly-built HTML as part of `quarto render` - no separate step.
#
set -euo pipefail
cd "$(dirname "$0")/.."   # -> material/slides

# Slide 2.4 embeds hello.html. The source (material/examples/hello.qmd) is a
# distributable standalone example, so it renders in its own directory (its
# natural Quarto home, no cross-project --output-dir). We then copy the HTML
# and its _files sidecar into the deck's examples/ so the slide-2.4 iframe can
# use examples/hello.html with no ../ - which would otherwise request
# /examples/hello.html (404) when the deck is served with material/ as root.
echo "[pre-render] ../examples/hello.qmd -> examples/hello.html  (slide 2.4)"
(
  cd ../examples
  quarto render hello.qmd
)
rm -rf examples/hello.html examples/hello_files
cp -R ../examples/hello.html examples/hello.html
cp -R ../examples/hello_files examples/hello_files

echo "[pre-render] examples/report.qmd    -> examples/report.html (slide 2.10)"
quarto render examples/report.qmd
