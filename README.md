# Serverless Interactive Reporting with Quarto + Shinylive

A 2-hour, hands-on workshop on **Quarto** and **Shinylive** for serverless interactive
reporting. This is the source material for the workshop.

Everything runs on your own machine: static figures and interactive widgets computed locally,
exported to run entirely in the browser with no R server.

## The one-line mental model

**Quarto is R Markdown that grew up.** **Shinylive** output is static: the host serves files and
the reader's browser runs the R via webR/WebAssembly. No server, no data transit, no hosting
cost.

## Folder layout

| Path | What it is |
|---|---|
| `slides/` | The RevealJS slide deck (the "lecture") built from `slides/slides.qmd` |
| `labs/lab-01-quarto.qmd` | Lab 1 · Quarto from R Markdown |
| `labs/lab-02-shiny.qmd` | Lab 2 · Build a Shiny app from scratch |
| `labs/lab-03-shinylive.qmd` | Lab 3 · Export a Shiny app to Shinylive |
| `labs/lab-04-shinylive-quarto.qmd` | Lab 4 · An interactive report, hosted statically |
| `examples/` | Standalone example docs used by the deck's embedded iframes |
| `apps/penguins-app/` | The reference Shiny app (`app.R` + `penguins.csv`) |
| `example-report/` | A working interactive Quarto report (prose + live widgets) |

## Prerequisites

- **R** (4.x) and **Quarto CLI** (v1.10+).
- An IDE: **RStudio** or **Positron**.
- Install the R packages once:

```r
install.packages(c("shiny", "dplyr", "ggplot2", "readr", "shinylive", "httpuv", "gt"))
```

`palmerpenguins` is used only in the example report's live widget; install it too if you plan to
render that.

## How to run each lab

Open the archive as a project (**RStudio**: File → New Project → Existing Directory → select the
extracted `shinylive-quarto` folder. **Positron**: File → Open Folder → select the extracted
folder). Work through the labs in order.

### Lab 1 — Quarto from R Markdown

Open `labs/lab-01-quarto.qmd` and render it:

- **RStudio:** click **Render** (`Ctrl/Cmd+Shift+K`).
- **Positron:** render from the Quarto preview in the editor toolbar.

A styled HTML document opens in the Viewer. The rest of the lab asks you to experiment with
chunk options (`echo`, `eval`, `fig-cap`, ...) and cross-references.

### Lab 2 — Shiny fundamentals

Create a folder `myapp/` with an `app.R` that you build up step by step, then run it with the
**Run App** button, or:

```r
shiny::runApp("myapp")
```

Copy `apps/penguins-app/penguins.csv` beside your `app.R` when you reach the file-input step, so
the app can read it with `readr::read_csv("penguins.csv")`.

### Lab 3 — From a Shiny app to Shinylive

Export your app (or the ready-made `apps/penguins-app/`) to a static site and serve it. Run R
from the workshop root:

```r
shinylive::export("apps/penguins-app", "site")
httpuv::runStaticServer("site")
```

Open the printed URL (for example http://127.0.0.1:8008). The first load is slow (webR download);
reload afterwards. The `site/` folder now runs the app in the browser with no R process.

### Lab 4 — An interactive report, hosted statically

Install the Quarto extension in the lab-4 working folder:

```bash
quarto add quarto-ext/shinylive
```

Then create `report.qmd` with the `shinylive` filter as described in the lab and render it to
see your prose, static figures, and live widgets. Publish the output folder to any static host
(GitHub Pages or Netlify). See `example-report/README.md` for the full `quarto publish gh-pages`
walk-through with a working example.

## Build the deck (optional)

The deck pulls in small example docs as iframes; rendering it invokes a pre-render hook that
builds them:

```bash
cd slides && quarto render
```

## Notes

- The app and report code is **public** once published (code + data live in the browser). Never
  put API keys or passwords in this material.
- WASM-safe R packages (`shiny`, `dplyr`, `ggplot2`, `readr`) run in the reader's browser; the
  others (`gt`, `shinylive`, `httpuv`) are used on the host or at build time only.
