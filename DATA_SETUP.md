# Data and execution
The included `data/off_campus_routes.csv` has WorkDate, 1A, 2B, 6A, 6B and the 24 weather fields listed in functions.R. Dates are unique. Measurements are numeric, with missing route outcomes retained as empty values. The reader also accepts the project workbook, sheet 2.

`results/report-model-comparison.csv` contains the model-comparison metrics transcribed from the project report and an `evaluation_context` field. Its training statistic is squared correlation; its evaluation R² is 1−SSE/SST.

Optional execution: from the repository root, run `Rscript setup.R` followed by `Rscript run_all.R`. R 4.4 or later is recommended. The workflow enforces disjoint chronological partitions and computes R² as 1−SSE/SST. Outputs include route/month summaries, coefficients, predictions, metrics, models and SVG figures. `outputs/source_rows` uses the 119-observation sample; `outputs/report_months` uses July/August/November. Generated model outputs remain local and are ignored by Git.

`Rscript verify_results.R outputs` checks temporal partitions and recalculates metrics from the saved predictions. Numerical model outputs can differ across R/package versions. The optional campus aggregation requires ten monthly route workbooks and their weather workbook, supplied separately.

## Date selection in the additional exploratory scripts
`src/time_segments.R` supplies inclusive date bounds for the additional scripts. On the included table, these select the same observations as the corresponding original row ranges:

| Segment | Dates | Observations | Original row range |
| --- | --- | ---: | --- |
| `exploratory` | September 1–30, 2023 | 29 | 240–268 |
| `comparison` | July 1–November 30, 2023 | 119 | 179–297 |
| `segment_evaluation` | July 1–August 1, 2023 | 31 | 179–209 |

The comparison period contains July, August, September and November observations; October is absent from the supplied table. `src/segment_comparison.R` trains on `exploratory` and evaluates on `segment_evaluation`. `src/model_experiments.R` uses `exploratory` and `comparison`. The predictor-screening script uses `exploratory` and records its original source-row exclusions in `row-selection.csv` alongside its diagnostic PDF.
