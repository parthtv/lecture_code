# Lessons

- Test the rendered page, not just the chunk. Serve the built HTML over http, click the real "Run Code" button (`a.exercise-editor-btn-run-code`), and read the output. A chunk that works in a bare webR session can still fail on the page.
- quarto-live only puts local files in webR's working directory if they are listed under top-level `resources:` in the front matter. Re-check that key after any edit to the qmd, since the file may have been changed by the user in between.
- Only pipe tables (`| a | b |` with a `|---|` row) render as tables. Box-drawing text pasted from a terminal becomes a mangled paragraph. Always leave a blank line before and after tables and fenced chunks.
- In quarto-live, plots drawn inside a `for` loop ignore `#| fig-width/fig-height`. Set `options(webr.fig.width = W, webr.fig.height = H)` at the top of the cell as well. Multiple plots in one cell appear as `<canvas>` elements, not `<img>`, so count canvases when testing.
- Do not run a long headless-browser test through `| tail`; output is buffered until exit. Write to a file or print as you go.
