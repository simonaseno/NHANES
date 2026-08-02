# NHANES CBC and Demographics Pipeline in R

[![R pipeline checks](https://github.com/simonaseno/NHANES/actions/workflows/ci.yml/badge.svg)](https://github.com/simonaseno/NHANES/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A reproducible, manifest-driven pipeline for downloading and preparing public-use
National Health and Nutrition Examination Survey (NHANES) data. The current
validated scope is Complete Blood Count (CBC) and Demographics for the ten
continuous cycles from 1999–2000 through 2017–2018.

The project is designed to grow to additional NHANES components without mixing
data acquisition, component-specific scientific decisions, and analysis code.

## Important scientific scope

- Continuous NHANES cycles are repeated cross-sectional samples, not a
  longitudinal cohort.
- The 2001–2002 second-exam CBC file (`L25_2_B`) is an unweighted convenience
  sample. It is saved separately and is never appended to the primary analytic
  CBC table.
- The pipeline carries survey design and weight variables from DEMO, but the
  appropriate analytic weight depends on the variables and cycles used. It does
  not silently invent a universal weight.
- Researchers must verify variable and laboratory-method comparability across
  cycles before fitting trends.

See the [CDC NHANES tutorials](https://wwwn.cdc.gov/nchs/nhanes/tutorials/)
and the component documentation before analysis.

## Quick start

Requirements: R 4.1 or newer and the packages recorded in `renv.lock`.

```bash
Rscript -e 'renv::restore()'
Rscript scripts/run_pipeline.R
```

By default, raw XPT files are cached under `data/raw/` and validated RDS outputs
are written under `data/derived/`. Add `--write-csv=true` only when CSV copies
are needed.

```bash
Rscript scripts/run_pipeline.R \
  --cache-dir=data/raw \
  --output-dir=data/derived \
  --refresh=true \
  --write-csv=false
```

Run local checks with:

```bash
Rscript tests/run_tests.R
```

## Validated outputs

| Output | Unit of observation | Notes |
|---|---|---|
| `cbc_primary_1999_2018.rds` | One row per participant | Primary MEC CBC only |
| `cbc_second_exam_2001_2002.rds` | One row per repeat participant | Convenience sample; no survey weights |
| `demographics_1999_2018.rds` | One row per participant | Includes design and weight variables |
| `cbc_demographics_1999_2018.rds` | One row per primary-CBC participant | Joined on `SEQN` and cycle |
| `provenance.csv` | One row per source file | URL, size, SHA-256, retrieval time, dimensions |
| `validation.csv` | One row per output | Rows, columns, unique participants |

The former root-level `*_combined_1999_2018.*` files are legacy v1 artifacts and
are not distributed from the current source tree. They remain recoverable from
the v1 history, but should not be used for new analyses: the old CBC and merged
files include 557 second-exam records as extra rows.

## How the project scales

Source files are declared in [`config/nhanes_files.csv`](config/nhanes_files.csv).
Each row records the official cycle, component, source URL, record level, merge
key, expected row count, and analytic role. To add another NHANES component:

1. Add and review its catalog rows.
2. Define its record granularity and valid key; never assume one row per person.
3. Add component-specific validation and harmonization.
4. Add tests before permitting any cross-component merge.
5. Document the applicable survey weight and comparability limitations.

Acquisition is generic; scientific harmonization is intentionally explicit.

## Automated pull/push flow

- `ci.yml` tests every branch and pull request.
- `data-refresh.yml` periodically pulls source files from CDC, validates them,
  and uploads derived data as a workflow artifact without committing data.
- `pages.yml` builds and deploys the Quarto documentation.
- `release.yml` rebuilds validated data for version tags and publishes it as a
  release artifact.
- `scripts/sync_branch.sh` safely updates a clean local branch from `origin/main`.
- `scripts/publish_branch.sh` tests and pushes a clean feature branch, then opens
  or reports its draft pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branch workflow.
The staged expansion plan is maintained in [ROADMAP.md](ROADMAP.md).

## Data and artifact policy

Raw CDC files and regenerated datasets are intentionally ignored by Git. Stable
research outputs should be attached to a versioned GitHub release and archived
with a DOI provider such as Zenodo. The source catalog and provenance manifest
make every release auditable.

NHANES data originate from the
[CDC/NCHS public-use portal](https://wwwn.cdc.gov/nchs/nhanes/). This project is
not affiliated with or endorsed by CDC/NCHS.

## Documentation, citation, and support

- Documentation: <https://simonaseno.github.io/NHANES/>
- Citation metadata: [`CITATION.cff`](CITATION.cff)
- Bugs and component requests: [GitHub Issues](https://github.com/simonaseno/NHANES/issues)

## Usage and site analytics

Maintainers with push access can review the repository's rolling traffic under
[Insights → Traffic](https://github.com/simonaseno/NHANES/graphs/traffic). GitHub
reports repository visitors and views, clones, referring sites, and popular
content for the previous 14 days. This is useful for repository discovery, but
it is not a long-term analytics record for the GitHub Pages website.

For page-level website analytics, the recommended next step is a lightweight,
privacy-focused Plausible Analytics account for
`simonaseno.github.io/NHANES/`. Quarto supports the complete Plausible tracking
snippet through the `website: plausible-analytics` setting in `_quarto.yml`.
The site-specific snippet must come from the maintainer's Plausible dashboard;
no placeholder tracker is committed because it would not collect valid data.
Google Analytics is also supported by Quarto, but requires a measurement ID and
may require cookie-consent handling depending on the applicable privacy rules.

## License

The project code and documentation are licensed under the [MIT License](LICENSE).
CDC source data remain subject to their official public-use documentation and
data-use terms.

## Maintainer

Simon Aseno, MPH — Public Health & Data Science Consultant

[GitHub](https://github.com/simonaseno) · [Medium](https://medium.com/@sbaseno)
