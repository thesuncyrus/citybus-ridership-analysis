# CityBus: weather and ridership

Purdue University, Spring 2025. Faculty mentor: Xing Wang.
Team: Kelly Igo, Anushka Sharma, Lejia Zhou, and Chau Nguyen
(credited as Cyrus Nguyen in the original materials).

My documented contribution was the off-campus analysis of routes 1A, 2B, 6A
and 6B, and the final report conclusion. The wider team study covered 19 routes.

## Contents

This package connects the original weekly scripts, the final report/presentation,
the conference poster, and an executable analysis workflow using the original workbook.
It includes descriptive analytics, EDA, visualizations, regression exploration,
selected-period model comparisons, evaluation diagnostics, and qualitative
service-planning implications.

Original scripts are preserved byte-for-byte as original-week-*.R and
original-correlation-heatmap.R. original-source-manifest.csv maps the filenames
and SHA-256 hashes. These are interactive working scripts; their comments and
indices are historical source, not guarantees of correct execution.

## Run the analysis

Install R packages:

    install.packages(c("readxl", "ggplot2", "caret", "randomForest", "rpart"))

Run from this directory, using an authorized local copy of sheet 2 of
Off Campus routes.xlsx:

    Rscript tests.R
    Rscript audit_source.R "/path/to/Off Campus routes.xlsx" outputs
    Rscript eda.R "/path/to/Off Campus routes.xlsx" outputs
    Rscript regression_exploration.R "/path/to/Off Campus routes.xlsx" outputs
    Rscript run.R "/path/to/Off Campus routes.xlsx" outputs/report_months report_months
    Rscript run.R "/path/to/Off Campus routes.xlsx" outputs/source_rows source_rows
    Rscript diagnostics.R outputs/report_months
    Rscript plot.R outputs/report_months
    Rscript reported_results.R outputs

Optional team-level campus aggregation:

    Rscript raw_aggregation.R "/path/to/Datasets/From Randy" outputs

The aggregation reads ten monthly Purdue Routes files and joins KLAF weather
by date. It sums boardings and alightings and calculates the report's
ridership measure, (Boards + Alights) / 2. This campus-source path is separate
from the supplied off-campus workbook.

The workbook and individual prediction records are not included in the package.
Local outputs include predictions.csv and models.rds; distributed results are
aggregate tables and figures.

## Analysis and evaluation

The selected Route 1A regression from Weeks 8 and 15 reproduces the poster/report
R-squared: 0.772986, rounding to 0.773. It is an in-sample fit of 29 observations.
Workbook rows 240:268 are September 1–30, 2023. Some original prose describes
a broader seasonal interval; the executable script records the actual dates.

The final presentation (slide 14) is the canonical source for reported comparisons:

| Model | Train R-squared | Test R-squared | Train RMSE | Test RMSE |
| --- | ---: | ---: | ---: | ---: |
| Linear regression | 0.2446 | 0.2084 | 164.50 | 162.34 |
| Decision tree | 0.3121 | 0.2922 | 156.98 | 153.51 |
| Random forest | 0.9554 | 0.7546 | 93.97 | 90.03 |

These values are transcribed by reported_results.R, not produced by run.R.
Week 15's comments contain slightly different values, including forest test
RMSE 90.38683 and tree training RMSE 147.94; the untouched script retains them.
The poster shows the earlier regression work, not the final forest comparison.

## Period and split audit

The final report describes July, August and November and a chronological 80/20
split. The workbook contains 90 observations in those months: 72 train, 18 test.
The test dates are November 12–30.

Week 15 instead selects rows 179:297: 119 observations in July, August,
September and November. Its test expression is 96:ncol(d4_1). With 25 columns,
that evaluates to 96:25, yielding 72 test rows, 71 of which also occur in training.
Consequently the reported 0.7546 is not independently verified as a disjoint
holdout result.

Two explicit, disjoint sample definitions are provided:
- report_months: literal July, August, November; 72/18 dates.
- source_rows: the original 119-row sample; 95/24 dates, using row count correctly.

Neither changes its selection or seed to achieve a reported score. On Route 1A,
the recorded run yields forest test R-squared 0.029205 for report_months and
0.105483 for source_rows. See results/recomputed-metrics.csv and the run metadata.
These computed results do not replace the historical values in the report.

## Modeling details

The final comparison uses multiple linear regression, an anova regression tree
(rpart defaults), and caret random forest with mtry=3 and 500 trees, without
cross-validation for the final fit. A training-mean baseline is added as a
reference. Seed 1234 is reset immediately before each stochastic fit.

All 24 original weather predictors are retained; the supplied weather values
are complete. The original code mean-imputes route outcomes across the workbook.
The analysis scores only observed outcomes; Route 1A has no missing outcomes.
Other routes' row counts are recorded separately.

For every computed partition, R-squared is 1-SSE/SST. Squared correlation is
exported separately. Week 15 used squared correlation for training and
1-SSE/SST for testing, which are not interchangeable.
The linear design has aliased columns. Source-style predictions are retained,
and non-estimable rows are explicitly counted in linear_nonestimable.

Forest feature importance is the decrease in regression node impurity
(residual sum of squares), not classification Gini. It is not a causal effect.

## Analysis and source map

- prepare.R: schema/date/measurement checks and missingness audit.
- eda.R: four-route statistics, monthly and weekday plots, weather correlations.
  Full-year summaries are descriptive; correlations use report-period training dates.
- regression_exploration.R: original selected formula and exact 29-row fit.
- run.R: selected-period models, metrics, local predictions and model objects.
- audit_source.R: actual sample months, train/test dates and overlap check.
- reported_results.R: redraw the final presentation's explicitly reported scores.
- diagnostics.R and plot.R: computed errors, residuals, importance and holdout plot.
- original-week-08.R and original-week-11.R: original variable selection,
  interactions, transformations, preprocessing and regression experiments.
- original-week-13.R through original-week-15.R: model comparison and validation.

## Decision implications

The original project recommends considering route-specific demand and weather
alongside academic timing when planning service. These are qualitative planning
recommendations. The work does not estimate a causal weather effect or solve an
allocation optimization with capacity, headway, budget and service constraints.

Retain team credit when sharing. This package asserts no data redistribution
rights or open-source license.


## Portfolio

[Project overview and visualizations](https://chau-nguyen-research.gabledmango1.chatgpt.site/citybus.html) · [Chau Nguyen on LinkedIn](https://www.linkedin.com/in/chaunguyen2811)

## Supporting materials

- [Citybus Poster](documents/citybus-poster.pdf)
- [Citybus Presentation](documents/citybus-presentation.pdf)
- [Citybus Report](documents/citybus-report.pdf)
