# Minimal Quarto doc example

A single, intentionally minimal Quarto document (`hello.qmd`) that shows the smallest possible
rendering pipeline: YAML front matter (a title and the `html` output format) plus one code chunk
that makes a figure.

It is the "hello world" used by the deck: the source is included verbatim on slide 2.4, and its
rendered output is embedded there as an iframe. The deck's pre-render hook renders this folder and
copies the output into `slides/examples/` so the iframe stays fresh on every `quarto render`.

## Render it

```bash
quarto render hello.qmd
```

This produces `hello.html` next to the source. Confirm it appears alongside `hello.qmd`; that is
the check the deck asks you to do (deck slide 2.4).

## Why it exists

- It demonstrates a Quarto document with **no project** (no `_quarto.yml`): a single self-contained
  file.
- It is the counterpart to the other `example-*` folders in this repo, which show the Shiny app
  (`example-app/`) and the interactive report (`example-report/`).

## Notes

- The rendered `hello.html` and `hello_files/` are gitignored build output; only `hello.qmd` is
  versioned. The deck rebuilds them via its pre-render hook.
