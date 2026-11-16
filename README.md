# CityBus Ridership Prediction with External Weather Data

Purdue University · January–April 2025 · Faculty mentor: Prof. Xing Wang
Industry partner: CityBus of Greater Lafayette

Team: Kelly Igo, Anushka Sharma, Lejia Zhou and Chau Nguyen (Cyrus Nguyen in the original materials).

## Project

Our team studied daily weather and ridership across 19 bus routes to inform service-planning discussions. My documented contribution was the off-campus analysis of routes 1A, 2B, 6A and 6B, and the report conclusion. The analysis connects weather preparation, route-level exploration, regression, tree models, evaluation and communication of findings.

## Run

Use R 4.5.3 and an authorized copy of **Off Campus routes.xlsx**, sheet 2.

```sh
Rscript setup.R
Rscript run_all.R '/path/to/Off Campus routes.xlsx' outputs
```

This command runs the checks, data audit, EDA, early regression, final model comparisons, plots and result verification. An optional third argument supplies the campus raw-data folder. See [data setup](DATA_SETUP.md) for the exact schema and [workflow map](docs/WORKFLOW.md) for the analysis stages.

## Methods

1. Validate dates, route outcomes and weather measurements; examine missingness and descriptive patterns.
2. Explore route-specific monthly and weekday demand and weather correlations.
3. Study regression models through variable selection, interactions and transformations in the retained weekly sources.
4. Reproduce the selected 29-observation Route 1A regression as an exploratory, in-sample fit.
5. Compare multiple linear regression, an ANOVA regression tree and Random Forest on fixed, chronological 80/20 partitions; include a training-mean reference.
6. Compute R², RMSE and MAE from the same observed outcomes, inspect errors and feature importance, and communicate route-specific planning implications.

The default final comparison uses July, August and November, as specified in the report. A second named experiment uses the source script's 119-row selection. Each has disjoint training and test dates. Missing route outcomes are not synthesized. R² is `1 − SSE/SST`; squared correlation has its own output field. Forest importance uses regression node impurity.

## Results and visual evidence

The selected early regression reproduces **R² = 0.772986**, or **0.773**, on its **29-observation in-sample fit**. The final presentation's model comparison is preserved in the supporting documents. Each reported or computed table has an explicit experiment and source in [result documentation](RESULTS_PROVENANCE.md).

![Monthly demand across four off-campus routes](figures/citybus-monthly.svg)

![Selected-period training weather correlations](figures/citybus-correlations.svg)

![The original 29-observation regression](figures/citybus-early-fit.svg)

## Repository guide

| Files | Purpose |
| --- | --- |
| `prepare.R`, `raw_aggregation.R` | Workbook validation and optional campus event aggregation |
| `eda.R`, `regression_exploration.R` | Descriptive analysis and early regression |
| `functions.R`, `run.R` | Period definitions, chronological splitting and final models |
| `diagnostics.R`, `plot.R` | Figures generated from computed predictions and metrics |
| `audit_source.R`, `verify_results.R` | Date separation, metric definitions and reproducibility checks |
| `reported_results.R` | Explicit transcription of the final presentation's table |
| `original-week-*.R`, `original-correlation-heatmap.R` | Eleven unchanged original scripts |
| `original-source-manifest.csv` | Source filenames and SHA-256 checksums |
| `results/`, `figures/`, `documents/` | Aggregate evidence, visualizations and original reports |

The original scripts retain their team/course attribution. Runnable files use explicit inputs and relative paths. Data, fitted models and individual prediction records are kept outside version control.

## Implications

The project recommends considering route-specific demand, weather and academic timing when planning service. These are qualitative recommendations; the study does not measure a deployed scheduling improvement or identify a causal weather effect.

## Supporting materials

- [Conference poster](documents/citybus-poster.pdf)
- [Final presentation](documents/citybus-presentation.pdf)
- [Final report](documents/citybus-report.pdf)
- [Executed validation](docs/VALIDATION.md)
- [Portfolio case study](https://chau-nguyen-research.gabledmango1.chatgpt.site/citybus.html)

Retain team credit when sharing. This repository does not grant redistribution rights over source data or assert an open-source license.
