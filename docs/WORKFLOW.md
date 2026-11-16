# Analytical workflow and source map

| Analytical stage | Executable files | Evidence |
| --- | --- | --- |
| Data preparation | `prepare.R`, `raw_aggregation.R` | Schema/date audits; source counts; campus aggregation |
| Exploration | `eda.R` | Route distributions, monthly/weekday patterns and training-period correlations |
| Early regression | `regression_exploration.R` | 29-observation fit, coefficients and diagnostic plot |
| Model comparison | `run.R`, `functions.R` | Linear regression, decision tree, Random Forest and training-mean reference |
| Evaluation | `audit_source.R`, `verify_results.R` | Chronological separation and prediction-derived R²/RMSE/MAE |
| Presentation | `diagnostics.R`, `plot.R`, `reported_results.R` | Computed figures and separately sourced presentation table |

The eleven original scripts are retained unchanged. Their original names and
SHA-256 hashes are in `original-source-manifest.csv`. Weeks 8 and 11 include
screening, transformations, interactions and variable-selection experiments;
Weeks 13–15 develop the final model comparison. The run commands consolidate the
analysis into relative-path scripts and make evaluation definitions explicit.

The report credits Chau Nguyen (Cyrus Nguyen in the original report) with
off-campus analysis and the conclusion. Other team sections remain credited to
Kelly Igo, Anushka Sharma and Lejia Zhou. This repository does not attribute all
team work to one person or invent additional historical milestones.
