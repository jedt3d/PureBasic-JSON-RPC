---
name: purebasic-release-manager
description: Release preparation and verification workflow for PureBasic projects. Use when preparing alpha, beta, or production-candidate releases, validating ReadTheDocs/Sphinx output, packaging source artifacts, checking PDF docs, manifests, checksums, release notes, and final Git or GitHub release evidence.
---

# PureBasic Release Manager

## Release Contract

Treat release artifacts as invalid until they are regenerated and verified from
the current tree.

## Required Checks

Run:

```sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/build-docs.sh
./tools/check.sh
```

For alpha package verification, confirm `./tools/check.sh` runs:

```sh
./tools/package-alpha.sh
./tools/verify-release-artifacts.sh
```

## Documentation

Confirm:

- Sphinx builds with warnings as errors
- long-form PDFs are generated, not committed
- release notes include behavior, harness, docs, and packaging changes
- milestones are current
- ReadTheDocs navigation includes new major docs
- package manifest includes current API, docs, examples, tests, tools, and project files

## Final Evidence

Report:

- branch or commit
- PureBasic and PureUnit versions
- test count
- `.pbp` target count
- docs build result
- package names and checksum verification
- known limitations
