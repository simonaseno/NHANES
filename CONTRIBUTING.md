# Contributing

Contributions that expand component coverage, strengthen validation, or improve
NHANES analytic guidance are welcome.

## Branch and pull-request workflow

Start with a clean checkout and synchronize it:

```bash
scripts/sync_branch.sh
git switch -c feature/short-description
```

Make focused changes, run `Rscript tests/run_tests.R`, and commit intentionally.
Then publish the branch through:

```bash
scripts/publish_branch.sh
```

The publish script refuses to push `main`, refuses a dirty worktree, runs the
tests, pushes the current branch, and creates a draft pull request when needed.

## Adding an NHANES component

1. Add official HTTPS source rows to `config/nhanes_files.csv`.
2. Declare the true record level and merge key.
3. Add validation for repeated records, eligibility, expected dimensions, and
   required variables.
4. Add explicit harmonization instead of relying on `bind_rows()` alone.
5. Document the appropriate survey weight, sample-design considerations,
   comparability changes, and missing-data behavior.
6. Include synthetic unit tests and, when appropriate, a scheduled integration
   check against CDC.

Never merge a file at person level unless its key uniqueness has been asserted.
Do not add new generated data to Git history.

## Commit and review expectations

- Keep code, documentation, and catalog changes in the same PR when they form one
  scientific change.
- Explain upstream CDC revisions and update expected row counts deliberately.
- Include citations to official component documentation for scientific choices.
- Treat changes to sample weights, eligibility, harmonization, and merge keys as
  review-critical.
