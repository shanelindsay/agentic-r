const fs = require('fs');
const path = require('path');
const PptxGenJS = require('pptxgenjs');
const html2pptx = require('./html2pptx');

async function buildDeck() {
  const deck = new PptxGenJS();
  deck.layout = 'LAYOUT_16x9';
  deck.author = 'Shane Lindsay';
  deck.company = 'University of Hull';
  deck.title = 'Agentic AI for Reproducible Language Science';
  deck.subject = 'Agent Talk';

  const slidesDir = path.join(__dirname, 'html');
  const slideFiles = fs
    .readdirSync(slidesDir)
    .filter((file) => file.endsWith('.html'))
    .sort();

  for (const file of slideFiles) {
    const slidePath = path.join(slidesDir, file);
    await html2pptx(slidePath, deck);
  }

  const outputPath = path.join(__dirname, 'Agentic-AI-Agent-Talk.pptx');
  await deck.writeFile({ fileName: outputPath });
  console.log(`Created ${outputPath}`);
}

buildDeck().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
