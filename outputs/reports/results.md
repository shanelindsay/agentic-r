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

## Visual complexity penalty

The partial effect of strokes remains reliable after holding frequency
at its median (0.605111). The smooth term uses 2.656 effective degrees
of freedom (F = 248.842, p = 0.000000). The predicted range from the
least to most complex characters implies a 0.340 increase in log RT
(about 244.060 ms). The strongest penalty lies between 21.5 and 25
strokes (top 85% of the effect curve).

                   metric    value
    1       edf (strokes)    2.656
    2         F statistic  248.842
    3             p-value 0.000000
    4         log RT span 0.340020
    5        RT span (ms)  244.060
    6 penalty strokes min     21.5
    7 penalty strokes max       25

![](../outputs/figures/visual_complexity_penalty.png)

<!--
To add another analysis:
1) create scripts/NN_slug.R that writes outputs/results/slug.yml
2) add a Makefile rule and add it to ANALYSES
3) copy this section, rename, and read slug.yml
Keep computation out of the QMD.
-->
