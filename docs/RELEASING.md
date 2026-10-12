# Software releases and Zenodo DOIs

[Return to the repository overview](../README.md)

## Current preparation status

The software declares version **0.2.0** in `DESCRIPTION` and `CITATION.cff`.
The first GitHub release and Zenodo software DOI are pending. A version field in
a file is not evidence that a release has been published. Keep this status
accurate after the first archive succeeds.

The project already has an MIT licence. Preserve `LICENSE` in the source
archive. The licence covers this project's code and documentation; CDC data and
bundled third-party code retain their own terms.

## Release checklist

1. Review the source catalog, documentation and scientific limitations.
2. Restore the locked environment and run `Rscript tests/run_tests.R`.
3. Review a current live-source refresh if generated data will be distributed.
4. Confirm `DESCRIPTION`, `CITATION.cff`, the changelog and release tag describe
   the same software version. Use the actual release date for the release being
   published; do not backdate a new publication.
5. Confirm the author's name and any ORCID/affiliation in citation metadata.
   Do not invent an ORCID, DOI, endorsement or funding award.
6. Check the source archive for session files, credentials, local libraries and
   legacy data. The three retained root backup files are excluded from Git
   source archives by `.gitattributes`; they remain in the repository history.
7. Connect and enable this repository in Zenodo **before** publishing the
   release if using the automatic GitHub integration.

Do not create a tag merely to test documentation. The existing `v*` tag workflow
performs a live data build and can publish a GitHub release automatically.

## Recommended route: GitHub integration

In Zenodo, open **Profile → GitHub**, select **Sync now**, and enable
`simonaseno/NHANES`. Once the connection is confirmed, publish a reviewed
versioned release in GitHub. Zenodo ingests new releases and registers a DOI.

`CITATION.cff` provides the software title, author, version, licence and keywords.
A separate `.zenodo.json` is not necessary for the current metadata. If one is
added later, Zenodo gives it precedence over `CITATION.cff`; keep both consistent.

Wait for the Zenodo record to finish processing. Verify:

- resource type is Software and licence is MIT;
- title, creator, version and publication date are correct;
- the archived source corresponds to the intended tag/commit;
- the actual files available for download contain the source and licence;
- the DOI resolves to the correct record.

The tag workflow produces `nhanes-validated-<tag>.tar.gz` containing regenerated
data and manifests, and attaches it to a GitHub release. That attachment is
distinct from GitHub's source-code ZIP. Do not assume it was included in Zenodo's
automatic source archive; inspect the record before claiming data preservation.

## Manual source deposit

If using a manual Zenodo upload instead, upload the **source-code ZIP for a
specific release/tag**, not a changing main-branch snapshot and not a PDF alone.
Include the R modules, runner scripts, catalog, lockfile, README, guides,
`CITATION.cff`, tests, and `LICENSE`.

Select Software, MIT, and the matching version, and link the exact GitHub
release. A manually reserved DOI can be recorded before publication when the
draft is ready; it does not resolve publicly until the record is published.
Avoid creating both a manual and automatic deposit of the same release without
a deliberate reason.

For a data DOI, use a separate, clearly described deposit with the regenerated
data, provenance and validation manifests and appropriate source terms. Link
related software and data records using their actual identifiers.

## After the DOI is assigned

Record the version-specific DOI in `CITATION.cff` and add a DOI link to the
README. Record both the archived version and the DOI in the release notes.
Future substantive software revisions should receive a new version/tag and
archive. Do not overwrite historical source releases.

A concept DOI represents the version family; a version DOI identifies an exact
release. Use the exact version when reporting a reproducible analysis.

## Official references

- [Enable a repository](https://help.zenodo.org/docs/github/enable-repository/)
- [Archive a GitHub release](https://help.zenodo.org/docs/github/archive-software/github-upload/)
- [Zenodo metadata precedence](https://help.zenodo.org/docs/github/describe-software/zenodo-json/)
- [Reserve a DOI](https://help.zenodo.org/docs/deposit/describe-records/reserve-doi/)
