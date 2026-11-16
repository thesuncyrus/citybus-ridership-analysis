# Evaluation and result sources

The source documents describe a semester-long team study. The executable code
provides the four-route analysis for 1A, 2B, 6A and 6B; Route 1A is the scope of
the final presentation's Random Forest comparison.

- `results/early-regression.csv` is the verified 29-observation, in-sample Route
  1A fit: R² 0.772986, rounded to 0.773. It is not a forecasting score.
- `results/reported-metrics.csv` transcribes the final presentation's slide 14,
  including reported Random Forest test R² 0.7546. `reported_results.R` labels its
  chart as reported and does not feed any value into model training.
- `results/recomputed-metrics.csv` contains the executable disjoint evaluations.
  `report_months` has 72 training and 18 test dates; `source_rows` has 95 and 24.
  Route 1A forest test R² is 0.029205 and 0.105483, respectively. These runs do not
  verify 0.7546 as disjoint test performance.

`audit_source.R` records the original Week 15 row-index expression and the actual
dates it selects. The corrected workflow uses `nrow`-based date partitions with
no train/test overlap. Neither the date selection nor the fixed seed is tuned
against a reported or test-set score.

Every computed R² is `1 - SSE/SST`, using the partition's outcome mean.
Squared correlation is separately labelled. RMSE uses the same observed targets
for all methods in a route/partition. The linear design contains aliased weather
columns; its source-style predictions are retained and non-estimable rows counted.
Regression forest importance is decrease in residual-sum-of-squares impurity.

Only aggregate outputs are distributed. The analytical workflow supports
route-specific planning discussions; it does not estimate a causal weather effect
or a measured operational improvement.
