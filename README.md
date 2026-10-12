# NHANES CBC and Demographics Pipeline in R

[![R pipeline checks](https://github.com/simonaseno/NHANES/actions/workflows/ci.yml/badge.svg)](https://github.com/simonaseno/NHANES/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Reproducible acquisition and preparation of public-use National Health and
Nutrition Examination Survey (NHANES) data, with source manifests, validation,
and provenance. The implemented pipeline covers **Complete Blood Count (CBC)
and Demographics for 1999–2000 through 2017–2018**.

This repository contains executable R software and a Quarto educational website.
It is a source-based project, not an installable R package or the hosted Praxis
Data Lab platform. Broader component coverage is planned in [ROADMAP.md](ROADMAP.md).

## Start here

| Your task | Reference |
| --- | --- |
| Run the pipeline and interpret its outputs | [User guide](docs/USER_GUIDE.md) |
| Understand the modules and validation boundaries | [Architecture](docs/ARCHITECTURE.md) |
| Read the lessons and scientific background | [Documentation website](https://simonaseno.github.io/NHANES/) |
| Contribute a change | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Prepare a software release and Zenodo DOI | [Release guide](docs/RELEASING.md) |
| Understand refresh schedules and inactivity notices | [Maintenance guide](docs/MAINTENANCE.md) |

## Scientific scope

- NHANES continuous cycles are **repeated cross-sectional samples**, not a
  longitudinal cohort.
- The catalog contains 21 files: ten primary CBC files, ten Demographics files,
  and one supplementary 2001–2002 second-exam CBC file.
- The second-exam file (`L25_2_B`) is an unweighted convenience sample. It is
  retained separately and never appended to the primary CBC table.
- Primary CBC and Demographics are joined on **`SEQN` and `cycle`**.
- Survey design and weight variables are retained from Demographics. Selecting
  appropriate weights, eligibility criteria, and comparable variables remains
  the analyst's responsibility.
- A passing pipeline check does not establish cross-cycle laboratory-method
  equivalence or validate a particular statistical analysis.

Consult the [CDC NHANES tutorials](https://wwwn.cdc.gov/nchs/nhanes/tutorials/)
and each component's official documentation before analysis.

## Quick start

Install Git and R. `DESCRIPTION` declares R ≥ 4.1; `renv.lock` records **R 4.5.1**
and the dependency versions used for the reproducible environment. Start with
that R version where practical. Quarto is needed only to build the website.

```bash
git clone https://github.com/simonaseno/NHANES.git
cd NHANES
Rscript -e 'renv::restore()'
Rscript tests/run_tests.R
Rscript scripts/run_pipeline.R
```

The default run downloads or refreshes the cataloged CDC files, caches them in
`data/raw/`, and writes RDS datasets and CSV manifests to `data/derived/`.
Internet access is needed for initial dependency restoration and downloads.

To reuse a populated cache and also write CSV copies:

```bash
Rscript scripts/run_pipeline.R --refresh=false --write-csv=true
```

Read the result in R:

```r
data <- readRDS("data/derived/cbc_demographics_1999_2018.rds")
validation <- read.csv("data/derived/validation.csv")
provenance <- read.csv("data/derived/provenance.csv")
```

See the [user guide](docs/USER_GUIDE.md) for all options, troubleshooting, and
the distinction between installed software outputs and lesson examples.

## Outputs

| File | Contents |
| --- | --- |
| `cbc_primary_1999_2018.rds` | Primary CBC records; unique `SEQN + cycle` |
| `cbc_second_exam_2001_2002.rds` | Supplementary repeat examinations; kept separate |
| `demographics_1999_2018.rds` | Demographics, including supplied design and weight variables |
| `cbc_demographics_1999_2018.rds` | Primary CBC left-joined to Demographics; primary row count preserved |
| `provenance.csv` | Source URLs, SHA-256 hashes, sizes, dimensions, and manifest timestamp |
| `validation.csv` | Output row/column counts and participant summaries |

`--write-csv=true` additionally writes CSV copies of the four datasets. RDS is
the preferred R format; CSV does not retain R classes and variable attributes.

## Repository organization

- `R/`: catalog validation, acquisition, record validation, and assembly.
- `scripts/run_pipeline.R`: supported command-line entry point.
- `config/nhanes_files.csv`: reviewed official source catalog.
- `tests/run_tests.R`: catalog and synthetic pipeline checks.
- `renv.lock` and `renv/`: reproducible dependency environment.
- `foundations/`, `laboratory/`, `pipelines/`, and `tutorial/`: Quarto guidance.
- `docs/`: user, architecture, release, and maintenance references.
- `data/`: policy documentation; generated data directories are ignored.

## Data and reproducibility policy

Raw CDC data, regenerated datasets, session files, and local dependency libraries
are not committed. Stable research outputs should be distributed as versioned
release artifacts, with their provenance and validation manifests.

Legacy v1 CBC and merged files included **557 second-exam records as extra rows**.
Those files remain recoverable from Git history but are not suitable for new
analyses. Use the current modules and reviewed catalog to regenerate outputs.

The source archive and a generated data archive are different research objects.
Do not assume Zenodo's GitHub integration archives every attached release asset;
verify the deposited files. See [release guidance](docs/RELEASING.md).

## Automated workflows

| Workflow | Trigger | Result |
| --- | --- | --- |
| `ci.yml` | Pull requests and pushes to `main` | Synthetic R pipeline tests |
| `data-refresh.yml` | Monthly schedule or manual run | Fresh CDC acquisition and validation; temporary artifacts |
| `pages.yml` | Relevant documentation changes or manual run | Quarto build; deployment after a main-branch build |
| `release.yml` | A pushed `v*` tag | Regenerated data archive attached to a GitHub release |

Refresh artifacts currently expire after 30 days. They are not permanent DOI
archives. The [maintenance guide](docs/MAINTENANCE.md) explains the separate
60-day scheduled-workflow inactivity rule.

## Publication history\n\nOriginally published **July 16, 2025** by **Praxis Global Institute**.\nZenodo is the archive and DOI registration service for the later v0.2.0 release.\nSee [publication history and original-date evidence](docs/PUBLICATION_HISTORY.md).\n\n## Citation and licence

Software citation metadata is in [CITATION.cff](CITATION.cff). Software version
**v0.2.0** is archived on [Zenodo](https://zenodo.org/records/23309272), with
version-specific DOI **10.5281/zenodo.23309272**. Cite this archived software
version and separately acknowledge the original CDC/NCHS data sources.

The Zenodo record preserves the source-code ZIP for release commit `e5c0a45`.
Generated data attachments on GitHub are separate from this software archive.

Project code and documentation use the [MIT License](LICENSE). CDC data and
third-party dependencies retain their respective source terms and licences.

## Maintainer and support

**Dr Simon Aseno, MPH**  
[GitHub](https://github.com/simonaseno) · [Praxis Global Institute](https://praxisglobal.ac/)

For reproducible bug reports and documentation corrections, use
[GitHub Issues](https://github.com/simonaseno/NHANES/issues). Include the software
version, R version, command, and error message.

This independent project is not affiliated with or endorsed by CDC/NCHS.
Its materials do not represent the official views of any employer or government
agency.
