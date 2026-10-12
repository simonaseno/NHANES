# Maintenance, retention and inactivity notices

[Return to the repository overview](../README.md)

## Three different retention rules

| Item | Rule | Effect |
| --- | --- | --- |
| Scheduled GitHub Actions in a public repository | May be disabled after 60 days without repository activity | The scheduled job stops; source code is not deleted. |
| An inactive GitHub Codespace | Default automatic deletion after 30 days stopped and inactive; settings can differ | The development environment and unpushed work can be lost. Pushed repository commits remain. |
| This repository's data-refresh workflow artifacts | `retention-days: 30` | Temporary downloadable build outputs expire; tracked source remains. |

A warning about **60 days** commonly concerns scheduled-workflow disablement,
not repository deletion. Check the wording of the actual notice before taking
action. Committing to a repository does not reset a Codespace's separate
inactivity countdown.

## Monthly refresh

`.github/workflows/data-refresh.yml` schedules a run at **08:17 UTC on the first
day of each month**. Scheduled jobs can be delayed by GitHub's scheduling load.
The workflow also supports manual execution through **Actions → Validate current
CDC source files → Run workflow** on the default branch.

The job acquires cataloged CDC files, validates the results and uploads a
temporary artifact. It does not commit regenerated data, change the reviewed
catalog, or create a DOI. A failed expected-row-count check needs source review;
it should not be bypassed to produce a green status.

## If the refresh schedule is disabled

1. Open **Actions → Validate current CDC source files**.
2. If GitHub shows an inactivity-disabled notice, use **Enable workflow**.
3. Run it manually and inspect the logs and validation/provenance manifests.
4. Download results you need before the artifact expires.

A source update is useful repository activity, but does not prove a disabled
workflow was re-enabled. Verify the workflow's visible state. Regularly review
the project and its workflow status; do not depend on dummy commits as a
scientific maintenance strategy.

## If a Codespace is about to be deleted

Open the Codespace to reset its retention countdown, and commit and push work
you need to preserve. Where GitHub permits it, the Codespace menu offers
**Keep codespace** to exempt an individual environment from automatic deletion.
Retained storage can still incur charges.

Check that the branch and commit exist in GitHub before assuming local edits
are safe. Repository updates cannot recover already-deleted unpushed files.

## Permanent research outputs

Treat Actions artifacts as temporary working outputs. Use reviewed GitHub
releases and a verified Zenodo archive for long-term source/data preservation.
Preserve version, provenance and validation manifests, and ensure the archive
actually contains the intended files.

## Official references

- [Scheduled workflow inactivity](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
- [Codespace automatic deletion](https://docs.github.com/en/codespaces/setting-your-user-preferences/configuring-automatic-deletion-of-your-codespaces)
- [Workflow artifact retention](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
