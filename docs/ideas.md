### A. How usage frequency shapes recognition speed

**Question.** How does how often a character is encountered relate to typical response time, allowing for visual complexity?
**Why it’s interesting.** Frequency effects are among the most robust phenomena in visual word recognition; they capture experiential tuning and help benchmark models across languages and scripts. Understanding the functional form (often non‑linear) matters for theory and for practical prediction.
**Predictions.** More frequently encountered characters should be recognised faster (shorter response times). The benefit is expected to be strongest at the low‑to‑mid range and **flatten** at very high frequency (diminishing returns), even after adjusting for complexity.
**What to produce.**

* A simple model estimating the effect of frequency on response time while adjusting for visual complexity.
* A plot of response time against frequency with a smooth trend and an uncertainty band.
* A brief interpretation noting whether gains flatten at the top end.
  **References.** Balota et al., 2007; Keuleers et al., 2012; Brysbaert, Mandera, & Keuleers, 2018; Wang et al., 2025 (SCLP).

---

### B. The visual‑complexity penalty

**Question.** How does visual complexity influence response time once frequency is accounted for, and is the penalty concentrated in a particular complexity range?
**Why it’s interesting.** Visual complexity (e.g., stroke load) affects perceptual encoding and may interact with experience. Quantifying its unique contribution clarifies early processing constraints.
**Predictions.** Greater visual complexity should slow recognition. The penalty may be strongest in a **mid‑range** of complexity, with potential plateaus at the extremes, and should remain after adjusting for frequency.
**What to produce.**

* A model isolating the unique effect of complexity on response time (controlling for frequency).
* A partial‑effect plot with uncertainty, highlighting any range where the penalty is maximal.
  **References.** Leong, Cheng, & Mulcahy, 1987; Liu, Shu, & Li, 2007; Tsang et al., 2018; Wang et al., 2025 (SCLP).

---

### C. Phonological family × pronunciation match

**Question.** Do characters from larger phonological families become easier or harder to recognise depending on whether whole‑character pronunciation matches the key phonetic component?
**Why it’s interesting.** Phonological families index sublexical regularities; consistency (match vs. mismatch) can flip the direction of family effects, revealing how phonology integrates with orthography in morphosyllabic scripts.
**Predictions.** Larger phonological families should **facilitate** recognition when pronunciations match; facilitation may weaken or invert (interference) when they mismatch. The strength of the effect likely varies with overall familiarity.
**What to produce.**

* A model testing the interaction between phonological family size and pronunciation match/mismatch on response time (optionally replicate for accuracy).
* An interaction figure (lines or contours) with a two‑sentence interpretation of the pattern.
  **References.** Li et al., 2011; Lee et al., 2015; Zhou et al., 2021; Wang et al., 2025 (SCLP).

---

### D. Subcomponents in concert with whole‑character familiarity

**Question.** How do familiarities of a character’s core parts (semantic component and the other subcomponent) combine with the overall familiarity of the whole character to influence response time?
**Why it’s interesting.** Recognition may rely on both whole‑unit experience and subcomponent familiarity; their interplay can reveal competition vs. facilitation dynamics in complex characters.
**Predictions.** For lower‑to‑moderate overall familiarity, **more familiar parts** should speed recognition; at very high overall familiarity, part effects should attenuate. Very common components may also introduce **neighbour competition**, slightly slowing decisions.
**What to produce.**

* A model with the joint influence of part familiarities and overall familiarity on response time.
* Effect plots showing how part familiarities help or hinder at low, medium, and high overall familiarity, with a concise interpretation.
  **References.** Feldman & Siok, 1999; McClelland & Rumelhart, 1981; Liu et al., 2022; Wang et al., 2025 (SCLP).

---

### E. Pseudocharacter rejection difficulty across construction depth

**Pre‑condition.** Only if pseudocharacter trials are present/retained; otherwise skip and note in the report.
**Question.** Are pseudocharacters created via deeper subpart swaps harder to reject, especially when their parts are common?
**Why it’s interesting.** Pseudocharacters probe decision mechanisms and implicit statistical learning about structure; construction depth and part familiarity should modulate “character‑likeness”.
**Predictions.** Items formed via **deeper** subpart swaps and with **more familiar parts** should be **slower to reject** (longer decision times) and potentially produce more errors.
**What to produce.**

* A model relating construction depth and part familiarity to decision speed for pseudocharacters.
* A grouped plot of decision times by construction depth (with intervals) and a one‑sentence takeaway.
  **References.** Sze, Rickard Liow, & Yap, 2014; Tsang et al., 2018; Wang et al., 2025 (SCLP).

---

### F. Speed–accuracy relationship across items

**Question.** Beyond general difficulty, is there a speed–accuracy trade‑off, or are difficult items simply slower **and** less accurate?
**Why it’s interesting.** Distinguishing global difficulty from strategic trade‑offs clarifies whether latencies merely mirror item difficulty or reflect decision strategies.
**Predictions.** Expect a **negative association** between accuracy and response time driven by general difficulty (harder items are slower and less accurate). After adjusting for frequency and complexity, any residual speed–accuracy trade‑off should be modest but detectable in extremes.
**What to produce.**

* Two complementary models: response time predicted from accuracy (controlling for key confounds), and accuracy predicted from response time.
* A scatter with a smooth trend and highlighted outliers, plus a short interpretation of the dominant pattern.
  **References.** Diependaele, Brysbaert, & Neri, 2012; Perea, Rosa, & Gómez, 2002; Keuleers & Balota, 2015.

---

### G. Behavioural calibration of familiarity

**Question.** Can behavioural data (response time and accuracy) be used to adjust corpus‑based familiarity to better reflect readers’ experience?
**Why it’s interesting.** Corpus frequency can diverge from human familiarity due to register and exposure; behavioural calibration reveals where experience differs from text statistics.
**Predictions.** Behaviour‑implied familiarity should correlate strongly with corpus‑based metrics but show systematic **deviations**: some items look “more familiar than their corpus counts” (fast, accurate) and others “less familiar” (slow, error‑prone) due to context and component cues.
**What to produce.**

* A simple behavioural calibration: derive a behaviour‑implied familiarity signal from response time and accuracy; compare it to the baseline familiarity metric.
* A calibration plot (baseline vs. behaviour‑implied) and a short ranked list of largest positive/negative deviations with one‑paragraph commentary.
  **References.** Cai & Brysbaert, 2010 (SUBTLEX‑CH); Keuleers et al., 2015 (word prevalence); Hronský & Keuleers, 2021; Wang et al., 2025 (SCLP).

---

## Results log (fill during/after the run)

| Analysis (short name)                               | Results / notes (to fill) |
| --------------------------------------------------- | ------------------------- |
| A. Frequency → speed (adjusting for complexity)     |                           |
| B. Visual‑complexity penalty (unique effect)        |                           |
| C. Phonological family × pronunciation match        |                           |
| D. Parts × whole familiarity (joint influence)      |                           |
| E. Pseudocharacter rejection vs. construction depth |                           |
| F. Speed–accuracy relationship across items         |                           |
| G. Behavioural calibration of familiarity           |                           |

---

**Full citations (APA, for the report’s references section)**

* Balota, D. A., Yap, M. J., Hutchison, K. A., Cortese, M. J., Kessler, B., Loftis, B., … Treiman, R. (2007). The English Lexicon Project. *Behavior Research Methods, 39*, 445–459.
* Brysbaert, M., Mandera, P., & Keuleers, E. (2018). The word frequency effect in word processing: An updated review. *Current Directions in Psychological Science, 27*(1), 45–50.
* Cai, Q., & Brysbaert, M. (2010). SUBTLEX‑CH: Chinese word and character frequencies based on film subtitles. *PLoS ONE, 5*(6), e10729.
* Diependaele, K., Brysbaert, M., & Neri, P. (2012). How noisy is lexical decision? *Frontiers in Psychology, 3*, 258.
* Feldman, L. B., & Siok, W. W. (1999). Semantic radicals contribute to the visual identification of Chinese characters. *Journal of Memory and Language, 40*(4), 559–576.
* Hronský, R., & Keuleers, E. (2021). Word probability re‑estimation using topic modeling and lexical decision data. *Proceedings of the Cognitive Science Society*, 188–194.
* Keuleers, E., Lacey, P., Rastle, K., & Brysbaert, M. (2012). The British Lexicon Project: Lexical decision data for 28,730 English words. *Behavior Research Methods, 44*, 287–304.
* Keuleers, E., & Balota, D. A. (2015). Megastudies, crowdsourcing, and large datasets in psycholinguistics. *Quarterly Journal of Experimental Psychology, 68*(8), 1457–1468.
* Lee, C.‑Y., Hsu, C.‑H., Chang, Y.‑N., Chen, W.‑F., & Chao, P.‑C. (2015). The feedback consistency effect in Chinese character recognition. *Language and Linguistics, 16*(4), 535–554.
* Leong, C. K., Cheng, P.‑W., & Mulcahy, R. (1987). Automatic processing of morphemic orthography by mature readers. *Language and Speech, 30*(2), 181–196.
* Li, Q.‑L., Bi, H.‑Y., Wei, T.‑Q., & Chen, B.‑G. (2011). Orthographic neighbourhood size effect in Chinese character naming. *Acta Psychologica, 136*(1), 35–41.
* Liu, Y., Shu, H., & Li, P. (2007). Word naming and psycholinguistic norms: Chinese. *Behavior Research Methods, 39*(2), 192–198.
* Liu, X., Wisniewski, D., Vermeylen, L., Palenciano, A. F., Liu, W., & Brysbaert, M. (2022). The representations of Chinese characters: Evidence from sublexical components. *Journal of Neuroscience, 42*(1), 135–144.
* McClelland, J. L., & Rumelhart, D. E. (1981). An interactive activation model of context effects in letter perception. *Psychological Review, 88*(5), 375–407.
* Perea, M., Rosa, E., & Gómez, C. (2002). Is the go/no‑go lexical decision task an alternative to yes/no? *Memory & Cognition, 30*, 34–45.
* Sze, W. P., Rickard Liow, S. J., & Yap, M. J. (2014). The Chinese Lexicon Project: Responses for 2,500 characters. *Behavior Research Methods, 46*, 263–273.
* Tsang, Y.‑K., Huang, J., Lui, M., Xue, M., Chan, Y.‑W. F., Wang, S., & Chen, H.‑C. (2018). MELD‑SCH: A megastudy of lexical decision in simplified Chinese. *Behavior Research Methods, 50*, 1763–1777.
* Wang, Y., Wang, Y., Chen, Q., & Keuleers, E. (2025). Simplified Chinese Lexicon Project: A lexical decision database with 8,105 characters and 4,864 pseudocharacters. *Behavior Research Methods, 57*, 206.
