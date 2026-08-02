# Data directories

The pipeline creates two ignored directories here:

- `raw/`: cached CDC XPT source files, named by catalog `dataset_id`.
- `derived/`: validated RDS/optional CSV outputs plus provenance and validation
  manifests.
- `legacy/`: local-only copies of the flawed v1 artifacts retained for recovery;
  never use these for a new analysis.

Do not commit these directories. Stable outputs belong in a versioned release
artifact and, for scientific citation, a DOI-backed archive.

The original root-level v1 data files predate this structure. They include a
known modeling problem in which 557 unweighted second-exam CBC observations were
appended as participant rows. Do not use those legacy CBC or merged artifacts for
new analysis.
