# CityBus Ridership and Weather Analysis

Purdue University · January–April 2025. Faculty mentor: Xing Wang. Industry partner: CityBus of Greater Lafayette. Team: Kelly Igo, Anushka Sharma, Lejia Zhou and Chau Nguyen.

## Research question
How do weather and academic timing relate to daily ridership, and how do model performance and demand patterns differ across routes and periods? The team studied 22 routes. Chau Nguyen contributed to data preparation across the project, the analysis of off-campus routes 1A, 2B, 6A and 6B, the conclusion, and report formatting. Each team member determined the methodology for the routes they analyzed.

## Dataset
`data/off_campus_routes.csv` contains the supplied daily analysis table: 327 observations, four route ridership measures, 24 weather variables and WorkDate. Values, row order and missing values match sheet 2 of the project workbook. It contains aggregate route observations rather than individual passenger records.

## Methods
- Examine weather–ridership patterns by route and season, considering academic timing.
- Begin with multiple linear regression and backward variable selection, then compare decision trees and Random Forest to investigate nonlinear patterns.
- Use the 29-observation Route 1A regression as an exploratory case before extending the model comparison to a larger selected period.
- Compare models using R² and RMSE; the Route 4A analysis used a chronological 80/20 train–test split. Distinguish R² calculated as 1−SSE/SST from squared correlation.

## Results in the project report
The 29-observation Route 1A regression fit had R² = 0.773. The report's larger Route 1A comparison recorded Random Forest R² = 0.7546 (approximately 0.75) and RMSE = 90.03:

| Model | Training squared correlation | Evaluation R² | Training RMSE | Evaluation RMSE |
| --- | ---: | ---: | ---: | ---: |
| Linear regression | 0.2446 | 0.2084 | 164.5 | 162.34 |
| Decision tree | 0.3121 | 0.2922 | 156.98 | 153.51 |
| Random Forest | 0.9554 | 0.7546 | 93.97 | 90.03 |

These values are transcribed from the report in [`results/report-model-comparison.csv`](results/report-model-comparison.csv), together with the evaluation context. Training scores are squared correlations; evaluation R² is calculated as 1−SSE/SST.

Wind direction and sea-level pressure led the report's Random Forest importance ranking. Feature importance describes contributions to the fitted model, not causal effects. The findings supported discussions of route-specific scheduling using weather and academic timing; no deployed scheduling gain was measured.

![Monthly ridership across four routes](figures/citybus-monthly.svg)

## Code and optional execution
The repository contains analysis code and input data. `run_all.R` runs the chronological 80/20 workflow and writes predictions and metrics to `outputs/`. The report's recorded comparison is stored separately in `results/report-model-comparison.csv`.

```sh
Rscript setup.R
Rscript run_all.R
```

An explicit workbook/CSV and output path may be supplied: `Rscript run_all.R data/off_campus_routes.csv outputs`. Generated outputs remain in the ignored output directory. See DATA_SETUP.md for the schema and execution details. No model rerun is required to read the report results.

## Additional exploratory code
The report focuses on linear regression, decision trees and Random Forest. The repository also retains exploratory work outside that final comparison:

- `src/segment_comparison.R`: a separate-period Random Forest experiment.
- `src/model_experiments.R`: additional comparisons, including k-nearest neighbors and XGBoost.
- `src/exploratory_weather_regression.R`: predictor screening and transformations.
- `src/time_segments.R`: shared date bounds for these exploratory scripts.
- [`archive/week08_route6a_interactions.R`](archive/week08_route6a_interactions.R): original Route 6A regression trials with interaction terms, transcribed from the Week 8 analysis. Examples include `humidity * snow`, `precip * precipcover`, and `sealevelpressure * visibility`.

The archived interaction trials are supplementary exploration, not a claim that manually constructed interaction terms were used in the final Route 1A model comparison. The excerpt depends on the original session's prepared data, is not part of `run_all.R`, and supplies no new performance or significance claims.

Run the predictor-screening script from the repository root with `Rscript src/exploratory_weather_regression.R data/off_campus_routes.csv outputs/exploratory-weather`. Its diagnostics and source-row selection are written to that output directory. Synthetic execution checks run with `Rscript tests/exploratory_smoke.R`; the existing metric/date checks run with `Rscript tests.R`.

Team and CityBus attribution should accompany reuse.

[Portfolio case study](https://chau-nguyen-research.gabledmango1.chatgpt.site/citybus.html)
