# Changelog

## Unreleased

- Reorganized the repository overview and added user, architecture, release and maintenance guides.
- Documented validation boundaries, cached-run provenance timing, CLI defaults and teaching-versus-production outputs.
- Clarified MIT licensing, DOI preparation, and the separate workflow, Codespace and artifact retention rules.
- Added descriptive citation metadata and source-archive exclusions for retained backup files.
- Included nested Quarto pages in documentation workflow change detection.

## 0.2.0 - 2026-08-02

- Replaced the monolithic executable Quarto document with reusable R modules and
  a command-line entry point.
- Added a manifest-driven source catalog and provenance hashes.
- Separated the unweighted 2001–2002 second-exam CBC convenience sample from the
  primary CBC dataset.
- Added person/cycle key validation and protected CBC-demographic merging.
- Added local tests, reproducible dependency metadata, CI, data-refresh, release,
  and Pages workflows.
- Added citation, contribution, data-policy, and scientific-scope documentation.
- Removed generated v1 data and rendered HTML from the current source tree;
  versioned workflows now build validated artifacts and documentation.

## 0.1.0 - 2025-07-17

- Initial CBC and demographic download and merge workflow.
