# Validation

Executed on 2026-11-16 with R 4.5.3 on the supplied off-campus workbook.

- The complete `run_all.R` workflow passed, including EDA, original 29-row
  regression, both period definitions, all four routes, diagnostic plots and
  prediction-derived metric checks.
- `verify_results.R` confirmed that train/test dates never overlap and that
  the computed reference aggregates match within numerical tolerance.
- The optional campus pipeline aggregated 704 route-days from ten monthly
  source workbooks. No missing month was interpreted as zero service.
- The source manifest was checked against all eleven original scripts.

The source-style linear model emits rank-deficiency warnings. The exported
metrics retain its non-estimable-row counts; this is not evidence of an identified
linear effect. Reported presentation scores are not model-reproduction tests.
