# Data and execution
The included `data/off_campus_routes.csv` has WorkDate, 1A, 2B, 6A, 6B and the 24 weather fields listed in functions.R. Dates are unique. Measurements are numeric, with missing route outcomes retained as empty values. The reader also accepts the project workbook, sheet 2.

From the repository root, run `Rscript setup.R` followed by `Rscript run_all.R`. R 4.4 or later is recommended. Outputs include route/month summaries, coefficients, predictions, metrics, models and SVG figures. `outputs/source_rows` uses the 119-observation sample; `outputs/report_months` uses July/August/November. Generated outputs are ignored by Git.

`Rscript verify_results.R outputs` checks temporal partitions and recalculates metrics from predictions. Numerical model results can differ across R/package versions. The optional campus aggregation requires ten monthly route workbooks and their weather workbook, supplied separately.
