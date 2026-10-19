# Interactive report example

This is a working interactive Quarto report using the `quarto-ext/shinylive` extension:
prose and static figures computed at render time, plus live `{shinylive-r}` widgets that run
entirely in the reader's browser via webR. The rendered output is **plain static files**
(`report.html` + `report_files/` + the service worker), so it deploys on any static host.

It is the "report" half of the Shinylive story. See the standalone-app half in
`apps/penguins-app/`, which is exported with `shinylive::export()` instead.

## Render

```bash
quarto render report.qmd
```

This produces `report.html` (plus supporting files) and fetches the Shinylive webR assets you
need before publishing.

## Publish to GitHub Pages with `quarto publish gh-pages`

`quarto publish gh-pages` is the report route from the deck (slide 5.4, tab 2). It deploys the
rendered site to a `gh-pages` branch. It needs your GitHub account; run it yourself in a
terminal from this folder.

### 1. Create a GitHub token with {usethis}

From an R console, create a token with the right scopes (this opens in your browser):

```r
install.packages("usethis")          # once, if needed
usethis::create_github_token()
```

Copy the generated token (`ghp_...`), then store it so git and Quarto can reuse it:

```r
install.packages("gitcreds")         # once, if needed
gitcreds::gitcreds_set()             # paste the token when prompted
```

You only do this once per machine. On a private repo the token carries the `repo` scope; for a
public repo you can grant the narrower `public_repo` scope when creating it.

### 2. Put this folder under version control and on GitHub

In an R console, with this folder's root as the working directory:

```r
usethis::use_git()      # initialises git, guides your first commit and the branch name
usethis::use_github()   # creates the repo on GitHub, sets origin, pushes
```

`use_github()` asks what to name the repo (e.g. `report-demo`). This folder becomes the `main`
branch of a GitHub repo you own.

### 3. Publish

```bash
quarto publish gh-pages
```

It will render `report.qmd` fresh (or reuse the existing output with `--no-render`), push the
rendered site to a `gh-pages` branch, and print your live URL. The token from step 1 is reused,
so it should not prompt again.

### 4. Confirm it is live

- Open the printed `https://you.github.io/report-demo/`.
- Verify both `{shinylive-r}` widgets load and react (drag the sliders). The first load is slow
  (webR download); reload afterwards.
- Because the site is plain static files, this is exactly what the deck's report workflow
  describes.

## Serve locally, no publishing

```bash
Rscript -e 'httpuv::runStaticServer(".")'
# open http://127.0.0.1:8008
```

## No usethis?

You can do the same by hand: generate a classic token in
GitHub → Settings → Developer settings → Personal access tokens (scope `repo`), then `git init`,
`git add -A`, `git commit -m "interactive report"`, `git remote add origin <url>`,
`git push -u origin main` from this folder, and finally `quarto publish gh-pages`. The
{usethis} route above finishes all of that for you.

## Automating with GitHub Actions

For a durable, repeatable deployment on every push, add a workflow that renders the report and
uploads the output folder to Pages. The app-export route (`deploy-app.yaml`) is upstream from
`posit-dev/r-shinylive`
([view the source](https://github.com/posit-dev/r-shinylive/blob/actions-v1/.github/workflows/deploy-app.yaml));
the report route is the same pattern but with `quarto render` instead of `shinylive::export()`,
then deploy the rendered folder. The deploy guide is folded into `site/index.qmd`.

## Notes

- This README documents the `quarto publish gh-pages` flow you run by hand. The deck's slide
  5.4 tab 2 and `site/index.qmd` give the nudge toward automation.
- To revoke the token afterwards: GitHub → Settings → Developer settings → Personal access
  tokens.
