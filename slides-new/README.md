# Agentic AI Talk Deck

Presentation assets for "Agentic AI for Reproducible Language Science: From Prompt to Pipeline."

## Project Structure
- `html/`: One HTML file per slide plus shared `styles.css` theme.
- `build.js`: Node build script that converts HTML to PPTX through the vendored `html2pptx` helper.
- `Agentic-AI-Agent-Talk.pptx`: Latest rendered deck.

## Regenerating the Deck

```bash
cd slides-new
npm install
npx playwright install chromium   # needed on first run or after clean container
npm run build
```

The build script reads every `html/slide-*.html` file, renders them with Playwright, and writes the PowerPoint file back to `Agentic-AI-Agent-Talk.pptx`.

## Theme and Typography

The color palette and fonts are defined with CSS custom properties in `html/styles.css`:

```css
:root {
  --bg: #fcfcfc;
  --primary: #b165fb;
  --secondary: #40695b;
  --text: #182d3c;
  --muted: #4a5a68;
}
```

- Update these five variables to remap the accent, text, and background colors for the entire deck.
- Body text uses Trebuchet MS with Arial as fallback. Adjust the `font-family` on the `body` selector if you need a different web safe font.
- Spacing, column layouts, and callouts live in the same stylesheet. Small tweaks (for example, different card radii or list spacing) can be made per selector.

### Switching to a New Palette
1. Pick new hex colors that maintain strong contrast between text and background.
2. Replace the values in `:root`. If you need a darker base slide, invert `--bg` and `--text` while keeping `--muted` as an intermediate grey.
3. Rebuild the deck with `npm run build` to regenerate the PPTX with the new theme.

## Image Guidance

We currently use text-only slides but the layout leaves room for visuals. Suggested imagery to prepare:

- **Slide 1 (Title):** Hero image showing collaborative research or agents-at-work. Use a landscape asset and insert with `<img src="assets/hero.jpg" class="hero">` near the bottom of `slide-01.html`.
- **Slide 8 (Promise vs Perils):** Consider side-by-side iconography for "promise" and "perils" columns. Each image should be square and roughly 400 px.
- **Slide 16 (Pipeline Overview):** Optional schematic of the data pipeline (Makefile -> scripts -> results). A transparent PNG works best.
- **Slide 18 (Builder Demo):** Screenshot of terminal output or PR diff that illustrates the agent builder run.
- **Slide 19 (PR Review):** Screenshot of agent-generated review comments or GitHub PR summary.

### Adding Images
1. Place assets under `slides-new/html/assets/` (create the folder if needed).
2. Reference them with `<img>` tags inside the relevant slide HTML. The html2pptx pipeline will embed them directly in the PPTX.
3. Add utility classes (for example, `.hero`, `.screenshot`) in `styles.css` to control sizing. Aim to keep images within the 16:9 canvas to avoid overflow warnings during build.
4. Rebuild the deck to capture the new visuals.

## Troubleshooting
- **Validation error (text box too close to bottom):** Reduce the text size or increase spacing in the affected HTML file, then rebuild.
- **Missing fonts in PowerPoint:** Ensure you only use web safe fonts (Arial, Helvetica, Times New Roman, Georgia, Verdana, Tahoma, Trebuchet MS, Impact, Courier New, Comic Sans MS).
- **Playwright dependency errors:** Re-run `npx playwright install-deps` in the container.
