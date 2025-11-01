# Data Sources 

## 1) SCLP — Simplified Chinese Lexicon Project (2025)

What it is

- Character lexical‑decision megastudy for 8,105 simplified characters plus 4,864 pseudocharacters (trial‑level). Open‑access article (CC BY 4.0). The authors provide trial‑level data and stimuli materials. DOI: https://doi.org/10.3758/s13428-025-02701-7  
- Data and materials are hosted on OSF; analysis code and images on GitHub (links provided in the article).

- Scope: 8,105 characters + 4,864 pseudocharacters; published in Behavior Research Methods, June 2025.  
- Trial‑level file: `TrialsSCLP.csv` (approximately 376k × 7) with columns `item, subject, lexicality, level, accuracy, rt, zscore`.  
- Recommended analysis uses `zscore` for RT normalization.

Where to fetch

- OSF project (trial‑level data and materials) and linked GitHub repository (images/code), as stated in the article. Start from the article DOI above and follow the OSF/GitHub links.

Field notes for this pipeline

- Filter to real characters: `lexicality == "character"`.  
- Trim implausible RTs (e.g., 200–2000 ms) and correct trials only (`accuracy == 1`).  
- Aggregate per character: `mean(log RT)` and `accuracy`; then join predictors.  
- `level` describes pseudocharacter generation depth; for real characters it is fixed at `1`—can be ignored after filtering.

Licensing/availability

- Article is CC BY 4.0; the OSF node hosts data/materials. Follow the licence statement on the OSF node for data reuse and attribution.

---

## 2) CLD — Chinese Lexical Database (2018) / CLD 2.1

What it is

- Large‑scale lexical database for simplified Mandarin with >260 variables and 48,644 words (4,895 unique characters; 3,913 one‑character words). Introduced by Sun et al. (2018, Behavior Research Methods).  
- Downloadable “text dump” (ZIP) as CLD 2.1 from the University of Tübingen repository; an online search/download site is also available.

Talk‑safe claims 

- CLD 2.1 provides many lexical/orthographic variables (e.g., frequency measures, stroke counts, neighbourhood indices).  
- Free to download from the Tübingen repository; a short PDF and README are supplied.  
- The 2018 BRM paper introduces CLD and points to the web interface.

Field notes for this pipeline

- For the demo, keep only single‑character rows and a few predictors (e.g., `log_freq`, `strokes`).  
- Column names vary slightly across exports; the dump is plain text (tab or comma).  
- Use the Tübingen record and included docs for scope/variables and terms of use.

Licensing/availability

- The Tübingen repository record provides the downloadable dataset and documentation. Check the licence/terms indicated on that record before redistribution; cite the dataset record.

---

## How they fit the Makefile + R demo

Minimal character‑level join

1. From SCLP trials → aggregate to character‑level table with: `char, mean_log_rt, acc_rate`.  
2. From CLD → select: `char, log_freq, strokes`.  
3. Inner‑join on `char`.  
4. Fit a tiny model for illustration: `lm(mean_log_rt ~ log_freq + strokes)`, then write a diffable `results/metrics.yml`.

This is exactly what the included scripts do:

- `scripts/01_prepare.R`: trims trials (200–2000 ms, correct only), aggregates, joins predictors → `outputs/data/processed.csv`.  
- `scripts/02_model.R`: fits the model, writes `outputs/results/metrics.yml`.

---

## References

- Wang, Y., Wang, Y., Chen, Q., & Keuleers, E. (2025). Simplified Chinese lexicon project: A lexical decision database with 8,105 characters and 4,864 pseudocharacters. Behavior Research Methods, 57, 206. https://doi.org/10.3758/s13428-025-02701-7  
- Sun, C. C., Hendrix, P., Ma, J. Q., & Baayen, R. H. (2018). Chinese Lexical Database (CLD): A large‑scale lexical database for simplified Chinese. Behavior Research Methods, 50(5), 2606–2629. https://doi.org/10.3758/s13428-018-1038-3  
