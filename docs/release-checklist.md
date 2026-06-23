# Release Checklist

This checklist turns an alpha or beta release into a repeatable procedure. It is
written for the repository root and assumes the PureBasic 6.40 toolchain has
already been installed on the local macOS machine.

The goal is simple: a release artifact should be rebuilt from the current source
tree, checked by the same harness as development work, and easy to audit later.

## Before Starting

- Start from a clean `main` branch.
- Confirm `git status --short` is empty.
- Confirm the release branch or release commit includes the latest API pages,
  examples, tests, milestone updates, release notes, and Sphinx navigation.
- Confirm generated folders remain untracked: `.local/`, `.build/`, and
  `.reports/`.

## Required Commands

Run the focused guards first:

```sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/build-docs.sh
```

Then run the full release check:

```sh
./tools/check.sh
```

`./tools/check.sh` must run the package step and the release artifact verifier.
The final verifier is:

```sh
./tools/verify-release-artifacts.sh
```

It checks the generated tarball, checksums, PDFs, and dist manifest after
packaging.

## What The Release Must Prove

- PureBasic `6.40` and SDK PureUnit are discovered through the harness.
- Every committed `.pbp` target is verified by `./tools/verify-projects.sh`.
- Every unit test under `tests/unit/` is executed by `./tools/test.sh`.
- Every compiled numbered scenario runs without interactive input.
- MCP example smoke probes remain buildable and protocol stdout stays clean.
- Sphinx HTML builds with warnings treated as errors.
- Exactly two long-form documentation PDFs are generated.
- The alpha package is generated from the current tree.
- The dist manifest includes current API, docs, example, test, and tool files.
- SHA-256 checksum files validate their matching release artifacts.
- Tracked files contain no workstation-specific absolute paths.

## Manifest Expectations

The package manifest must include the current hardening route documents:

- `docs/release-quality-gates.md`
- `docs/jsonrpc-compliance-matrix.md`
- `docs/security-robustness.md`
- `docs/release-checklist.md`
- `API/027-release-quality-gates.md`
- `API/028-compliance-matrix.md`
- `API/029-negative-tests.md`
- `API/030-stress-lifecycle.md`
- `API/031-security-robustness.md`
- `API/032-release-automation-polish.md`

It must also list the release artifacts:

- source tarball
- tarball checksum
- overview PDF
- overview PDF checksum
- tutorial PDF
- tutorial PDF checksum

## Path Hygiene

Repository paths in committed source, docs, project files, probes, and metadata
must stay relative to the project root. Real local paths may appear in generated
logs, reports, local toolchain homes, and terminal output, but not in tracked
files.

Run this before release:

```sh
./tools/verify-paths.sh
```

If it fails, fix the tracked file. Do not silence the scanner to pass a release.

## Documentation Freshness

Generated PDF files are release artifacts, not tracked files. The Markdown
sources are authoritative, and `./tools/build-docs.sh` must regenerate the HTML
and PDFs from the latest tree.

Before tagging or publishing a release, open the generated docs locally or
inspect the Sphinx output to confirm there were no warning suppressions.

## Final Audit Record

Record the final release evidence in the release notes or release discussion:

- branch or commit
- PureBasic version reported by the harness
- PureUnit summary and test count
- docs build result
- package artifact names
- checksum verification result
- known limitations

This checklist is intentionally small enough to follow every time. If a release
requires an exception, document the exception before publishing the artifact.
