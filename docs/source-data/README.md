# Issue and PR export snapshots

These CSV files are the supplied historical metadata exports used by the
triage documents:

- [`issues.csv`](issues.csv) contains issue numbers, titles, labels, authors,
  and export timestamps.
- [`pr.csv`](pr.csv) contains pull-request numbers, titles, labels, authors,
  and export timestamps.

The `state` field is preserved as exported. It is historical input and does
not represent the local implementation status; use `known-issues.md`,
`open-work-plan.md`, and `runtime-validation-pending.md` for local status.
