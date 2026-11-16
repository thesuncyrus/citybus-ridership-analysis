# Validation

Executed 2026-11-16 with R 4.4.3 on the authorized off-campus workbook. The complete run_all.R passed: data audit, EDA, the 29-row regression, both period definitions, all four routes, SVG plots and prediction-derived metric checks. Test dates are disjoint from training dates. Cross-version differences from the earlier R 4.5.3 reference are recorded privately rather than hidden or forced to match. Route 1A source-selection test R² remains 0.105483; the early in-sample R² is 0.772986.

Original reported 0.7546 is not a valid reproduction target. The optional campus raw aggregation was not rerun in this restoration. Historical experiments are preserved but are not claimed to pass modern holdout validity. Linear models emit documented rank-deficiency warnings.

The complete historical model experiments also executed on the workbook after repairing a plotting-only caret wrapper dispatch. Its overlapping-index RF test R² is approximately 0.758; the reported 0.7546 remains historical. The early exploratory regression script is source-restored and syntax-checked; it is not a validated holdout experiment.
