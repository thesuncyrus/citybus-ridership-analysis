# Analytical workflow and source map

| Analytical stage | Executable files | Evidence |
| --- | --- | --- |
| Data preparation | `prepare.R`, `raw_aggregation.R` | Schema/date audits; source counts; campus aggregation |
| Exploration | `eda.R` | Route distributions, monthly/weekday patterns and training-period correlations |
| Early regression | `regression_exploration.R` | 29-observation fit, coefficients and diagnostic plot |
| Model comparison | `run.R`, `functions.R` | Linear regression, decision tree, Random Forest and training-mean reference |
| Evaluation | `audit_source.R`, `verify_results.R` | Chronological separation and prediction-derived R²/RMSE/MAE |
| Presentation | `diagnostics.R`, `plot.R`, `reported_results.R` | Computed figures and separately sourced presentation table |

Professional historical sources are in src/: exploratory_weather_regression.R retains screening, transformations, interactions and variable selection; historical_model_experiments.R retains the final source experiments, including the annotated split bug. All unchanged originals and checksums remain in a private backup. The top-level run_all.R is the separately corrected diagnostic workflow.

The report credits Chau Nguyen (Cyrus Nguyen in the original report) with
off-campus analysis and the conclusion. Other team sections remain credited to
Kelly Igo, Anushka Sharma and Lejia Zhou. This repository does not attribute all
team work to one person or invent additional historical milestones.
