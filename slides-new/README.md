# Agentic AI Agent Talk Slides

HTML-to-PowerPoint pipeline for the "Agentic AI for Reproducible Language Science" talk.

## Rebuilding

```bash
cd slides-new
npm install
npx playwright install chromium   # first run only
npm run build
```

The build script converts the HTML slides in `html/` using the `html2pptx` pipeline and writes `Agentic-AI-Agent-Talk.pptx` in this directory.
