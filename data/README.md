# Data and execution

Use an authorized local copy of **Off Campus routes.xlsx**, sheet 2. It contains
`WorkDate`, route outcomes `1A`, `2B`, `6A`, `6B`, and the 24 weather fields listed
in `functions.R`. The original workbook has 327 dated observations. Dates must be
unique; measurements numeric; ridership nonnegative. Missing route outcomes remain
missing and are excluded from model fitting/scoring, not filled to create targets.

Run with R 4.5.3 from the repository root:

```sh
Rscript setup.R
Rscript run_all.R '/path/to/Off Campus routes.xlsx' outputs
```

The optional third argument points to `Datasets/From Randy` for the campus-route
aggregation. That directory must contain the KLAF weather workbook and the ten
monthly `Purdue Routes YYYYMM.xlsx` workbooks. This is a separate team-level
source route; it does not recreate the off-campus workbook.

Outputs include data audits, route/month summaries, coefficients, fitted models,
prediction-level files, computed metrics and SVG figures. `outputs/report_months`
uses July/August/November; `outputs/source_rows` uses the 119-row source sample.
`outputs/reported` contains an explicitly labelled transcription of slide 14.

Data, fitted models and daily predictions remain local. Aggregate results and
supporting reports are included in the repository. Preserve the original source
workbook rather than inserting calendar rows or changing its row order before a
source-row experiment. File hashes and package versions appear in run metadata.

For independent checks after an original-data run:

```sh
Rscript verify_results.R outputs
```

Verification recalculates metrics from predictions, rejects overlapping dates,
checks both fixed computed references and verifies the 29-observation regression.
It does not choose seeds, periods or models to match presentation scores.
