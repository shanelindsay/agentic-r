# Results


    here() starts at /root/repo

## Cleaning

The pipeline kept 137133 of 235016 trials (dropped 97883). Settings:
correct-only = TRUE, RT range = 200–2000 ms.

             setting  value
    1   correct_only   TRUE
    2      rt_min_ms    200
    3      rt_max_ms   2000
    4   total_trials 235016
    5    kept_trials 137133
    6 dropped_trials  97883

![](../outputs/figures/rt_hist.png)

## Baseline model: frequency and strokes

           term  estimate
    1 intercept  6.452355
    2  log_freq -0.070823
    3   strokes  0.013355

R² 0.434; adjusted R² 0.433; residual sigma 0.099. AIC -6851.160, BIC
-6826.134.

## Subcomponents with whole-character familiarity

The joint model that adds semantic and phonetic component familiarity
explained 0.395 of the variance across 2638 characters, capturing the
predicted shift from facilitation at low familiarity to competition at
the top of the frequency range (Feldman & Siok, 1999; Liu et al., 2022;
McClelland & Rumelhart, 1981; Wang et al., 2025).

      component      overall_level rt_change_ms rt_change_pct
    1  Semantic    Low (20th pct.)        12.83          1.73
    2  Semantic Medium (50th pct.)         5.50          0.77
    3  Semantic   High (80th pct.)       -13.08         -2.04
    4  Phonetic    Low (20th pct.)        26.89          3.60
    5  Phonetic Medium (50th pct.)        13.06          1.82
    6  Phonetic   High (80th pct.)       -22.18         -3.46

Positive values indicate speed-ups when the component moves from the
20th to the 80th percentile of its familiarity distribution (holding
other predictors at their medians); negative values denote slow-downs
because highly familiar components introduce more lexical competitors
near the ceiling of overall familiarity, aligning with interactive
activation accounts of neighbor conflict (McClelland & Rumelhart, 1981).

![](../outputs/figures/component_familiarity_effects.png)

The effect curves show that when overall familiarity is low-to-moderate,
familiar phonetic parts provide up to a 26.89 ms advantage (about 3.6%),
while comparable semantic advantages taper to roughly 5.5 ms by the
median familiarity tier. At the highest familiarity tier, both
components flip sign (−22.18 to −13.08 ms), consistent with the
competition predicted by structured learning paths (Liu et al., 2022;
Wang et al., 2025).

<!--
To add another analysis:
1) create scripts/NN_slug.R that writes outputs/results/slug.yml
2) add a Makefile rule and add it to ANALYSES
3) copy this section, rename, and read slug.yml
Keep computation out of the QMD.
-->
