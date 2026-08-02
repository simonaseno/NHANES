# Roadmap

The long-term goal is a scientifically explicit acquisition and harmonization
system for public-use NHANES components—not a single table that merges every file
without regard to record structure or sampling design.

## Phase 1: dependable foundation

- [x] Manifest-driven official CDC downloads
- [x] Retry, status, row-count, key, and provenance validation
- [x] Separate primary and unweighted repeat CBC examinations
- [x] Reproducible R environment and local tests
- [x] CI, scheduled source refresh, release artifacts, and documentation deployment
- [x] Repository social-preview asset prepared under `.github/`
- [ ] First versioned GitHub/Zenodo release and DOI
- [ ] Apply repository topics, social preview, and corrected GitHub About metadata
  after GitHub authentication is restored

## Phase 2: modern release periods

- Add the official 2017–March 2020 pre-pandemic release as a separate product.
- Add August 2021–August 2023 using its updated sample design and analytic guidance.
- Prevent overlap between the standalone 2017–2018 cycle and the official
  2017–March 2020 combined files.
- Document which release products may be compared and which may be combined.

## Phase 3: component expansion

Add component families in reviewable groups:

1. examination measurements;
2. core laboratory biomarkers;
3. questionnaire components;
4. dietary totals and individual-food multiple-record files;
5. medication and other repeated-record components.

Each family requires a component schema containing record level, primary key,
eligibility, applicable weights, harmonized variables, units, and cycle-specific
method changes. Multiple-record components must expose analysis-ready long and/or
documented summarized forms rather than being blindly joined to person-level data.

## Phase 4: research interface

- Promote the R modules into a documented R package.
- Add programmatic catalog search and component selection.
- Add codebook and variable metadata ingestion.
- Add explicit harmonization crosswalks with versioned tests.
- Add survey-design helpers that require users to select an appropriate weight.
- Produce worked, reproducible research examples and validation reports.

## Release criteria

A component is considered supported only when official-source provenance,
record-level validation, harmonization notes, weight guidance, tests, and a
versioned artifact are all present.
