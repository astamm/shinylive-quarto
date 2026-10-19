# Palmer penguins explorer

A small, dependency-light Shiny app used throughout the workshop: `app.R` plus the bundled
`penguins.csv`. It works both as a normal Shiny app (**Run App** in RStudio or Positron) and,
after exporting, as a standalone static site that runs in the browser.

It uses only WASM-safe packages (`shiny`, `dplyr`, `ggplot2`, `readr`), so it exports cleanly
with Shinylive.

It is the "standalone app" half of the Shinylive story (deck slide 5.4, tab 1). The report half
lives in `example-report/` and is published with `quarto publish gh-pages` instead.

## Run it as a normal app

In RStudio or Positron, open `app.R` and click **Run App** (`Ctrl/Cmd+Shift+K` or the Run App
button), or:

```r
shiny::runApp(".")
```

## Export a static site with Shinylive

Export the app folder to a `site/` directory, then serve it with a plain static server. The
first export downloads the Shinylive webR assets (can take a minute):

```r
shinylive::export("apps/penguins-app", "site")
httpuv::runStaticServer("site")
```

Open the printed URL (for example http://127.0.0.1:8008). The app is fully interactive, with no
R server running it. The first load is slow (webR download); reload afterwards. Inspect the
`site/` folder: the `shinylive/` subfolder holds the JS, worker scripts, and `.wasm` binaries.

You can now drop the `site/` folder on GitHub Pages, Netlify, or any static host.

## Put it on GitHub with {usethis}

To deploy to GitHub Pages, the app needs to live in a GitHub repo. Set up your token and version
control with {usethis}.

Create and store a GitHub token (one time, from an R console):

```r
install.packages("usethis")          # once, if needed
install.packages("gitcreds")         # once, if needed
usethis::create_github_token()       # opens in your browser; copy the token
gitcreds::gitcreds_set()             # paste the token when prompted
```

On a private repo the token carries the `repo` scope; for a public repo you can grant the
narrower `public_repo` scope. Then, with the app's root folder as the working directory:

```r
usethis::use_git()      # initialises git, guides your first commit and the branch name
usethis::use_github()   # connects this folder to a repo on GitHub
```

No usethis? Do it by hand: a classic token with `repo` scope in
GitHub → Settings → Developer settings → Personal access tokens, then `git init`,
`git add -A`, `git commit -m "penguins app"`, `git remote add origin <url>`,
`git push -u origin main`.

## Automate deployment with GitHub Actions

For a durable, repeatable deployment on every push to `main`, use the reusable `deploy-app.yaml`
workflow from `posit-dev/r-shinylive`
([view the source](https://github.com/posit-dev/r-shinylive/blob/actions-v1/.github/workflows/deploy-app.yaml)).
It:

- installs R plus `renv`, `shinylive`, and `sessioninfo`;
- resolves the app's dependencies and runs `shinylive::export(".", "site")`;
- uploads `site/` as a Pages artifact and deploys it to GitHub Pages on push to `main`.

### To use it in your own repo

1. Copy `deploy-app.yaml` from the link above into your repo as `.github/workflows/deploy-app.yaml`,
   with your app (this folder) at the repo root, and commit it.
2. Push the repo to GitHub (`usethis::use_github()` from the previous section already connected
   it, so `git push` is enough).
3. In GitHub → **Settings → Pages**, set **Source** to **GitHub Actions** (the workflow needs
   `pages: write` and `id-token: write` permissions to deploy).
4. Every push to `main` rebuilds the site and publishes it.

The deploy guide (including the one-off local publish commands `quarto publish gh-pages` /
`netlify` / `quarto-pub`) is folded into `site/index.qmd`.

## Notes

- The deck's slide 5.4 tab 1 is a simplified teaching illustration of this same workflow; the
  upstream `posit-dev/r-shinylive` `deploy-app.yaml` is the real artifact to copy.
- To pin exact package versions, run `renv::snapshot()` in this folder before exporting;
  `shinylive::export()` then ships those exact WASM builds (deck slide 4.10, Lab 3 stretch).
- The uploaded file and the bundled data never leave the reader's browser, but the code is
  public to anyone with the URL. Never put API keys or passwords here.
