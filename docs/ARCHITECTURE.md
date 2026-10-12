# Architecture and validation boundaries

[Return to the repository overview](../README.md)

## Execution path

1. `scripts/run_pipeline.R` parses options and loads the modules.
2. `R/catalog.R` reads and checks `config/nhanes_files.csv`.
3. `R/download.R` acquires official XPT files and reads them with haven.
4. `R/validate.R` checks keys and reports output dimensions.
5. `R/pipeline.R` assembles primary CBC, repeat examinations and Demographics,
   validates their relationship, and writes datasets and manifests.

The catalog is the source of truth for supported files; Quarto lessons are
educational documentation, not a replacement for the executable modules.

## Catalog contract

Required fields are `dataset_id`, `cycle`, `cycle_start`, `cycle_end`,
`component`, `file_id`, `exam`, `analysis_role`, `record_level`,
`merge_key`, `expected_rows`, and `url`.

The current implementation supports person-level records and primary or
supplementary analysis roles. Catalog identifiers must be unique, required
character fields non-empty, cycle bounds valid, and expected counts positive.
Source URLs must use the official HTTPS `wwwn.cdc.gov` host. The supplied
catalog covers ten primary CBC files, ten Demographics files and one repeat exam.

## Acquisition and assembly

HTTP downloads have status checking, a 120-second request timeout and up to four
attempts. Files are acquired into temporary paths, checked for minimum size and
copied into the cache. Existing non-empty cache files may be reused explicitly.

Reading checks expected row counts and the declared merge-key column. The
pipeline adds cycle, exam, role and source metadata to the imported records.
Component tables are assembled separately before any merge.

Primary CBC and Demographics require unique, non-missing `SEQN + cycle` keys.
Repeat examinations use `SEQN + cycle + exam`. Every primary CBC key must exist
in Demographics. A left join retains the primary sample, and both merged-key
uniqueness and unchanged primary row count are enforced.

## What validation establishes

- The reviewed catalog meets the implemented contract.
- Imported files match their expected row counts and contain their merge key.
- Component and merged keys are complete and unique.
- Demographics cover all primary CBC keys.
- The join does not multiply or drop primary CBC rows.
- Source hashes and output dimensions are recorded.

## What validation does not establish

The software does not automatically certify clinical validity, laboratory
comparability, all expected analytic variables, pooled weight suitability,
population representativeness of the repeat exam, or statistical inference.
It does not produce a universal harmonized schema or resolve method changes
merely by stacking files. These remain explicitly reviewed scientific decisions.

The provenance timestamp describes manifest construction, including a cached
run; it is not a per-file original retrieval log. The synthetic test suite
exercises catalog and merge behavior without accessing live CDC files. The
scheduled refresh separately exercises acquisition against the upstream source.

## Extensions

Add components only after defining their record level, keys, eligibility,
weights, variable mapping and method-comparability notes. Repeated-record
components need new validation and assembly rules before joining to person-level
data. Submit corresponding tests and documentation in the same pull request.

## Data separation

The Git tree contains source, metadata and documentation. Local caches, generated
datasets and dependency libraries are ignored. Release artifacts and DOI archives
preserve stable results separately. See the [data policy](../data/README.md) and
[release guide](RELEASING.md).
